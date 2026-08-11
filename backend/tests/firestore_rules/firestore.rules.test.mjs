import { readFile } from 'node:fs/promises';
import test, { after, before, beforeEach } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, updateDoc } from 'firebase/firestore';

const projectId = 'career-bridge-rules-test';
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
