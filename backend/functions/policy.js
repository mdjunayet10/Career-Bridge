'use strict';
const norm = (s) => String(s || '').trim().toLowerCase();
function eligibleJob(job, company, employer) {
  return !!(job && company && employer && job.status === 'published' && job.isActive === true
    && !job.isDemo && !job.isSample && !company.isDemo && !company.isSample
    && !/\bdemo\b|\bsample\b/i.test(job.title || '')
    && company.isActive === true && company.verificationStatus === 'approved'
    && company.ownerUid === job.employerUid
    && employer.role === 'employer' && employer.isActive === true && employer.verificationStatus === 'approved');
}
function newlyPublished(before, after) {
  return !!(after && after.status === 'published' && after.isActive === true
    && !(before && before.status === 'published' && before.isActive === true));
}
function relevantJob(job, profile) {
  const preferenceList = value => Array.isArray(value)
    ? value.filter(item => typeof item === 'string').map(norm).filter(Boolean) : [];
  const roles = preferenceList(profile?.preferredRoles);
  const locations = preferenceList(profile?.preferredLocations);
  const title = norm(job.title);
  const location = norm(job.location);
  return (!roles.length || roles.some(r => title.includes(r)))
    && (!locations.length || locations.some(l => location.includes(l) || (l === 'remote' && norm(job.workMode) === 'remote')));
}
module.exports = {eligibleJob, relevantJob, newlyPublished};
