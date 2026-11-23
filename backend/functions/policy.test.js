const {test} = require('node:test');
const assert = require('node:assert/strict');
const {eligibleJob, relevantJob, newlyPublished} = require('./policy');
const job = {status:'published', isActive:true, title:'Flutter Developer', companyId:'c', employerUid:'u', location:'Dhaka', workMode:'Hybrid', skills:['Dart']};
const company = {ownerUid:'u', isActive:true, verificationStatus:'approved'};
const employer = {role:'employer', isActive:true, verificationStatus:'approved'};
test('only active published approved live jobs are eligible', () => {
  assert.equal(eligibleJob(job, company, employer), true);
  for (const change of [{status:'draft'},{status:'pending'},{isActive:false},{isSample:true},{isDemo:true},{title:'Engineer (demo)'}]) assert.equal(eligibleJob({...job,...change},company,employer), false);
  assert.equal(eligibleJob(job,{...company,verificationStatus:'pending'},employer),false);
  assert.equal(eligibleJob(job,company,{...employer,isActive:false}),false);
  assert.equal(eligibleJob(job,{...company,ownerUid:'other'},employer),false);
});
test('edits to already published jobs never announce as new', () => {
  assert.equal(newlyPublished(null, job),true);
  assert.equal(newlyPublished({...job,title:'Old'},job),false);
  assert.equal(newlyPublished({...job,status:'pending'},job),true);
});
test('role and location preferences exclude irrelevant jobs', () => {
  assert.equal(relevantJob(job,{}),true);
  assert.equal(relevantJob(job,{preferredRoles:['Flutter'],preferredLocations:['Dhaka']}),true);
  assert.equal(relevantJob(job,{preferredRoles:['Accountant']}),false);
  assert.equal(relevantJob(job,{preferredLocations:['Chattogram']}),false);
  assert.equal(relevantJob({...job,workMode:'Remote'},{preferredLocations:['Remote']}),true);
});
test('malformed user preferences cannot abort notification delivery', () => {
  assert.equal(relevantJob(job,{preferredRoles:'Flutter',preferredLocations:{city:'Dhaka'}}),true);
  assert.equal(relevantJob(job,{preferredRoles:[null,{},42,'Flutter'],preferredLocations:[null,'Dhaka']}),true);
});
