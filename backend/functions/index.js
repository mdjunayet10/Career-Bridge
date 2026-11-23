'use strict';
const {onDocumentWritten, onDocumentCreated} = require('firebase-functions/v2/firestore');
const {initializeApp} = require('firebase-admin/app');
const {getFirestore, FieldValue} = require('firebase-admin/firestore');
const {getMessaging} = require('firebase-admin/messaging');
const {createHash} = require('node:crypto');
const {eligibleJob, relevantJob, newlyPublished} = require('./policy');
initializeApp();
const db = getFirestore();

// Only Admin-controlled published transitions may enqueue a real approved job.
exports.queuePublishedJob = onDocumentWritten({document:'jobs/{jobId}', retry:true}, async event => {
  const after = event.data?.after.data();
  const before = event.data?.before.data();
  if (!newlyPublished(before,after)) return;
  const [company,employer] = await Promise.all([
    db.doc(`companies/${after.companyId}`).get(), db.doc(`users/${after.employerUid}`).get()
  ]);
  if (!eligibleJob(after,company.data(),employer.data())) return;
  // One announcement per job, including republish and duplicated Firestore events.
  try {
    await db.doc(`pushOutbox/${event.params.jobId}`).create({jobId:event.params.jobId, createdAt:FieldValue.serverTimestamp()});
  } catch (error) { if (error.code !== 6) throw error; }
});

exports.deliverPublishedJob = onDocumentCreated({document:'pushOutbox/{jobId}', retry:true, timeoutSeconds:540}, async event => {
  const jobId = event.params.jobId;
  const jobDoc = await db.doc(`jobs/${jobId}`).get();
  const job = jobDoc.data();
  if (!job) return;
  const [company,employer] = await Promise.all([db.doc(`companies/${job.companyId}`).get(),db.doc(`users/${job.employerUid}`).get()]);
  if (!eligibleJob(job,company.data(),employer.data())) return;
  // Iterate subscriptions in bounded pages, respecting current account state.
  let cursor;
  let transient = false;
  do {
    let query = db.collection('pushSubscriptions').where('enabled','==',true).orderBy('__name__').limit(100);
    if (cursor) query = query.startAfter(cursor);
    const page = await query.get();
    if (page.empty) break;
    for (const subscription of page.docs) {
      const uid = subscription.id;
      const [user, profile, devices] = await Promise.all([
        db.doc(`users/${uid}`).get(), db.doc(`jobSeekerProfiles/${uid}`).get(), subscription.ref.collection('devices').get()
      ]);
      if (user.data()?.role !== 'jobSeeker' || user.data()?.isActive !== true || !relevantJob(job,profile.data() || {})) continue;
      for (const device of devices.docs) {
        const token = device.data().token;
        if (typeof token !== 'string' || !token) continue;
        const key = createHash('sha256').update(`${uid}:${token}`).digest('hex');
        const ledger = event.data.ref.collection('deliveries').doc(key);
        const claimed = await db.runTransaction(async tx => {
          const current = (await tx.get(ledger)).data();
          if (current?.status === 'sent' || current?.status === 'invalid') return false;
          if (current?.leaseUntil > Date.now()) { transient = true; return false; }
          tx.set(ledger,{status:'sending',leaseUntil:Date.now()+60000,updatedAt:FieldValue.serverTimestamp()});
          return true;
        });
        if (!claimed) continue;
        // Recheck opt-out immediately before delivery.
        if (!(await subscription.ref.get()).data()?.enabled || !(await device.ref.get()).exists) {
          await ledger.delete(); continue;
        }
        try {
          await getMessaging().send({token,
            notification:{title:`New job: ${String(job.title).slice(0,90)}`,body:`${String(company.data().name || 'Approved employer').slice(0,90)} - view details`},
            data:{route:`/jobs/${jobId}`,jobId,eventId:`job-${jobId}`},
            android:{priority:'high',collapseKey:`job-${jobId}`,notification:{channelId:'career_bridge_jobs',tag:`job-${jobId}`}}
          });
          await ledger.set({status:'sent',updatedAt:FieldValue.serverTimestamp()});
        } catch (error) {
          if (['messaging/registration-token-not-registered','messaging/invalid-registration-token'].includes(error.code)) {
            await device.ref.delete();
            await ledger.set({status:'invalid',updatedAt:FieldValue.serverTimestamp()});
          } else {
            await ledger.set({status:'retry',leaseUntil:0,updatedAt:FieldValue.serverTimestamp()}); transient = true;
          }
        }
      }
    }
    cursor = page.docs.at(-1);
    if (page.size < 100) break;
  } while (cursor);
  if (transient) throw new Error('Some job notifications need retry');
  await event.data.ref.set({completedAt:FieldValue.serverTimestamp()},{merge:true});
});
