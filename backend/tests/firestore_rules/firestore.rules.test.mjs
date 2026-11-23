import { readFile } from 'node:fs/promises';
import test, { after, before, beforeEach } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, updateDoc, serverTimestamp, deleteDoc } from 'firebase/firestore';

const projectId = 'demo-career-bridge-rules-test';
let environment;

before(async () => {
  const rules = await readFile(
    new URL('../../firebase/firestore.rules', import.meta.url),
    'utf8',
  );
  environment = await initializeTestEnvironment({
    projectId,
    firestore: { rules },
  });
});

beforeEach(async () => {
  await environment.clearFirestore();
});

after(async () => {
  await environment.cleanup();
});

async function seed(path, value) {
  await environment.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), path), value);
  });
}

test('public users can read a published active job but not a draft', async () => {
  await seed('jobs/published-job', {
    status: 'published',
    isActive: true,
    employerUid: 'employer-1',
    companyId: 'company-1',
  });
  await seed('jobs/draft-job', {
    status: 'draft',
    isActive: true,
    employerUid: 'employer-1',
    companyId: 'company-1',
  });

  const db = environment.unauthenticatedContext().firestore();
  await assertSucceeds(getDoc(doc(db, 'jobs/published-job')));
  await assertFails(getDoc(doc(db, 'jobs/draft-job')));
});

test('public registration cannot create an Admin profile', async () => {
  const db = environment
    .authenticatedContext('candidate-1', { email: 'candidate@example.com' })
    .firestore();

  await assertFails(
    setDoc(doc(db, 'users/candidate-1'), {
      name: 'Candidate',
      email: 'candidate@example.com',
      role: 'admin',
      isActive: true,
      verificationStatus: 'notRequired',
    }),
  );
});

test('a Job Seeker can read their own private profile only', async () => {
  await seed('users/seeker-1', {
    name: 'Seeker One',
    email: 'seeker@example.com',
    role: 'jobSeeker',
    isActive: true,
    verificationStatus: 'notRequired',
  });
  await seed('jobSeekerProfiles/seeker-1', {
    ownerUid: 'seeker-1',
    fullName: 'Seeker One',
  });

  const ownerDb = environment.authenticatedContext('seeker-1').firestore();
  const otherDb = environment.authenticatedContext('seeker-2').firestore();

  await assertSucceeds(getDoc(doc(ownerDb, 'jobSeekerProfiles/seeker-1')));
  await assertFails(getDoc(doc(otherDb, 'jobSeekerProfiles/seeker-1')));
});

test('an Employer cannot approve their own verification record', async () => {
  await seed('users/employer-1', {
    name: 'Employer One',
    email: 'employer@example.com',
    role: 'employer',
    isActive: true,
    verificationStatus: 'pending',
  });
  await seed('companyVerifications/employer-1', {
    companyId: 'employer-1',
    ownerUid: 'employer-1',
    tradeLicenseNumber: 'TL-123',
    status: 'pending',
  });

  const db = environment.authenticatedContext('employer-1').firestore();
  await assertFails(
    updateDoc(doc(db, 'companyVerifications/employer-1'), {
      status: 'approved',
    }),
  );
});

test('an Admin can read platform settings', async () => {
  await seed('users/admin-1', {
    name: 'Admin One',
    email: 'admin@example.com',
    role: 'admin',
    isActive: true,
    verificationStatus: 'notRequired',
  });
  await seed('platformSettings/general', {
    platformName: 'Career Bridge',
    maintenanceMode: false,
  });

  const db = environment.authenticatedContext('admin-1').firestore();
  await assertSucceeds(getDoc(doc(db, 'platformSettings/general')));
});

test('public company profiles require both approval and active status', async () => {
  await seed('companies/active-company', {
    ownerUid: 'employer-active',
    name: 'Active Company',
    verificationStatus: 'approved',
    isActive: true,
  });
  await seed('companies/suspended-company', {
    ownerUid: 'employer-suspended',
    name: 'Suspended Company',
    verificationStatus: 'approved',
    isActive: false,
  });

  const publicContext = () => environment.unauthenticatedContext().firestore();
  await assertSucceeds(getDoc(doc(publicContext(), 'companies/active-company')));
  await assertFails(getDoc(doc(publicContext(), 'companies/suspended-company')));
});

test('public users can read non-secret platform settings', async () => {
  await seed('platformSettings/general', {
    platformName: 'Career Bridge',
    supportEmail: 'support@careerbridge.edu',
    allowJobSeekerRegistration: true,
    allowEmployerRegistration: true,
    maintenanceMode: false,
  });

  const db = environment.unauthenticatedContext().firestore();
  await assertSucceeds(getDoc(doc(db, 'platformSettings/general')));
});


test('public platform-setting reads are restricted to the general document', async () => {
  await seed('platformSettings/private', {
    internalNote: 'Admin-only operational detail',
  });

  const db = environment.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(db, 'platformSettings/private')));
});

test('platform settings can pause Job Seeker registration', async () => {
  await seed('platformSettings/general', {
    platformName: 'Career Bridge',
    supportEmail: 'support@careerbridge.edu',
    allowJobSeekerRegistration: false,
    allowEmployerRegistration: true,
    maintenanceMode: false,
  });

  const db = environment
    .authenticatedContext('candidate-paused', { email: 'candidate@example.com' })
    .firestore();

  await assertFails(
    setDoc(doc(db, 'users/candidate-paused'), {
      name: 'Candidate',
      email: 'candidate@example.com',
      role: 'jobSeeker',
      isActive: true,
      verificationStatus: 'notRequired',
    }),
  );
});

test('a company logo becomes public only after it is attached to an approved active company', async () => {
  await seed('fileObjects/logo-1', {
    ownerUid: 'employer-logo',
    fileName: 'logo.jpg',
    mimeType: 'image/jpeg',
    purpose: 'companyLogo',
    state: 'ready',
  });

  const beforeDb = environment.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(beforeDb, 'fileObjects/logo-1')));

  await seed('companies/employer-logo', {
    ownerUid: 'employer-logo',
    name: 'Logo Company',
    verificationStatus: 'approved',
    isActive: true,
    logoFileId: 'logo-1',
  });

  const afterDb = environment.unauthenticatedContext().firestore();
  await assertSucceeds(getDoc(doc(afterDb, 'fileObjects/logo-1')));
});

test('a Job Seeker can withdraw only an active application', async () => {
  await seed('users/seeker-withdraw', {
    name: 'Seeker Withdraw',
    email: 'withdraw@example.com',
    role: 'jobSeeker',
    isActive: true,
    verificationStatus: 'notRequired',
  });
  await seed('applications/active-application', {
    applicantUid: 'seeker-withdraw',
    jobId: 'job-active',
    status: 'shortlisted',
  });
  await seed('applications/terminal-application', {
    applicantUid: 'seeker-withdraw',
    jobId: 'job-terminal',
    status: 'hired',
  });

  const db = environment.authenticatedContext('seeker-withdraw').firestore();
  await assertSucceeds(
    updateDoc(doc(db, 'applications/active-application'), {
      status: 'withdrawn',
    }),
  );
  await assertFails(
    updateDoc(doc(db, 'applications/terminal-application'), {
      status: 'withdrawn',
    }),
  );
});


test('job push preferences and device tokens belong only to an active job seeker', async () => {
  await seed('users/owner', {role:'jobSeeker', isActive:true});
  await seed('users/other', {role:'jobSeeker', isActive:true});
  await seed('users/employer', {role:'employer', isActive:true});
  const owner = environment.authenticatedContext('owner').firestore();
  const other = environment.authenticatedContext('other').firestore();
  const employer = environment.authenticatedContext('employer').firestore();
  await assertSucceeds(setDoc(doc(owner,'pushSubscriptions/owner'), {enabled:true,updatedAt:serverTimestamp()}));
  await assertFails(getDoc(doc(other,'pushSubscriptions/owner')));
  await assertFails(setDoc(doc(employer,'pushSubscriptions/employer'), {enabled:true,updatedAt:serverTimestamp()}));
  const device = {token:'sample-registration-token-1234567890',platform:'android',updatedAt:serverTimestamp()};
  await assertSucceeds(setDoc(doc(owner,'pushSubscriptions/owner/devices/test'),device));
  await assertFails(getDoc(doc(other,'pushSubscriptions/owner/devices/test')));
  await assertFails(setDoc(doc(other,'pushSubscriptions/owner/devices/hijack'),device));
  await assertFails(setDoc(doc(owner,'pushOutbox/job-id'),{jobId:'job-id'}));
  await assertSucceeds(deleteDoc(doc(owner,'pushSubscriptions/owner/devices/test')));
});

test('reports enforce target, ownership, duplicate prevention and Admin moderation', async () => {
  await seed('users/reporter', {role: 'jobSeeker', name: 'Reporter', isActive: true});
  await seed('users/admin', {role: 'admin', isActive: true});
  await seed('jobs/listing', {status: 'published', isActive: true, title: 'Test job'});
  await seed('companies/company', {verificationStatus: 'approved', isActive: true, name: 'Test company'});
  const db = environment.authenticatedContext('reporter').firestore();
  const admin = environment.authenticatedContext('admin').firestore();
  const ref = doc(db, 'reports/reporter_job_listing');
  const payload = {reporterUid: 'reporter', reporterName: 'Reporter', targetType: 'job',
    targetId: 'listing', targetLabel: 'Test job', reason: 'Fake Job', details: '', status: 'open', createdAt: serverTimestamp()};
  await assertSucceeds(getDoc(ref));
  await assertFails(setDoc(doc(db, 'reports/arbitrary'), payload));
  await assertFails(setDoc(ref, {...payload, reporterUid: 'other'}));
  await assertFails(setDoc(ref, {...payload, reason: 'invalid'}));
  await assertFails(setDoc(ref, {...payload, resolvedAt: serverTimestamp()}));
  await assertFails(setDoc(ref, {...payload, targetId: 'missing'}));
  await assertSucceeds(setDoc(ref, payload));
  await assertFails(setDoc(ref, payload));
  await assertFails(updateDoc(ref, {status: 'resolved'}));
  await assertFails(getDoc(doc(environment.unauthenticatedContext().firestore(), ref.path)));
  await assertFails(getDoc(doc(environment.authenticatedContext('other').firestore(), ref.path)));
  for (const status of ['inReview', 'resolved', 'dismissed']) {
    await assertSucceeds(updateDoc(doc(admin, ref.path), {status, resolutionNote: 'Checked'}));
    const result = await assertSucceeds(getDoc(ref));
    if (result.data().status !== status) throw Error('Status did not persist');
  }
  await assertSucceeds(setDoc(doc(db, 'reports/reporter_company_company'), {...payload,
    targetType: 'company', targetId: 'company', targetLabel: 'Test company', reason: 'Scam/Fraud'}));
});

test('two open clients receive published jobs and applicant decisions without restarting', async () => {
  const { collection, query, where, onSnapshot } = await import('firebase/firestore');
  await seed('users/live-employer', {role:'employer',isActive:true,verificationStatus:'approved',name:'Employer'});
  await seed('users/live-seeker', {role:'jobSeeker',isActive:true,name:'Seeker'});
  await seed('users/live-admin', {role:'admin',isActive:true,name:'Admin'});
  await seed('companies/live-company', {ownerUid:'live-employer',name:'Live Company',verificationStatus:'approved',isActive:true});
  await seed('jobs/live-job', {title:'Live role',companyId:'live-company',employerUid:'live-employer',status:'pending',isActive:true,location:'Dhaka',employmentType:'Full-time'});
  const employer=environment.authenticatedContext('live-employer').firestore();
  const seeker=environment.authenticatedContext('live-seeker').firestore();
  const admin=environment.authenticatedContext('live-admin').firestore();
  const first=environment.unauthenticatedContext().firestore();
  const second=environment.unauthenticatedContext().firestore();
  let a,b,received,tracked,failure;
  const subscriptions=[
    onSnapshot(query(collection(first,'jobs'),where('status','==','published'),where('isActive','==',true)),snap=>{a=snap.docs.map(d=>d.id)},err=>{failure=err}),
    onSnapshot(query(collection(second,'jobs'),where('status','==','published'),where('isActive','==',true)),snap=>{b=snap.docs.map(d=>d.id)},err=>{failure=err}),
    onSnapshot(query(collection(employer,'applications'),where('jobId','==','live-job')),snap=>{received=snap.docs.map(d=>d.data())},err=>{failure=err}),
    onSnapshot(query(collection(seeker,'applications'),where('applicantUid','==','live-seeker')),snap=>{tracked=snap.docs.map(d=>d.data())},err=>{failure=err}),
  ];
  async function until(condition) {
    const end=Date.now()+15000;
    while(!condition()) {
      if(failure) throw failure;
      if(Date.now()>end) throw Error('Live snapshot did not arrive');
      await new Promise(resolve=>setTimeout(resolve,20));
    }
  }
  try {
    await until(()=>a && b && received && tracked);
    if(a.length || b.length) throw Error('Pending job leaked to public clients');
    await assertSucceeds(updateDoc(doc(admin,'jobs/live-job'),{status:'published',publishedAt:serverTimestamp(),updatedAt:serverTimestamp()}));
    await until(()=>a.includes('live-job') && b.includes('live-job'));
    await assertSucceeds(setDoc(doc(seeker,'applications/live-application'),{
      applicantUid:'live-seeker',applicantName:'Seeker',applicantEmail:'seeker@example.invalid',applicantHeadline:'Candidate',applicantLocation:'Dhaka',applicantExperienceYears:1,applicantSkills:['Flutter'],
      jobId:'live-job',jobTitle:'Live role',companyId:'live-company',companyName:'Live Company',jobLocation:'Dhaka',jobEmploymentType:'Full-time',jobSalaryLabel:'Negotiable',status:'applied',createdAt:serverTimestamp(),updatedAt:serverTimestamp(),
    }));
    await until(()=>received.length===1 && tracked.length===1);
    for(const status of ['shortlisted','interview','hired']) {
      await assertSucceeds(updateDoc(doc(employer,'applications/live-application'),{status,updatedAt:serverTimestamp()}));
      await until(()=>tracked[0]?.status===status && received[0]?.status===status);
    }
    await assertSucceeds(updateDoc(doc(admin,'jobs/live-job'),{status:'closed',isActive:false,updatedAt:serverTimestamp()}));
    await until(()=>!a.includes('live-job') && !b.includes('live-job'));
    await seed('applications/withdrawn-live', {jobId:'live-job',applicantUid:'live-seeker',status:'withdrawn'});
    await assertFails(updateDoc(doc(employer,'applications/withdrawn-live'),{status:'hired',updatedAt:serverTimestamp()}));
  } finally { subscriptions.forEach(unsubscribe=>unsubscribe()); }
});
