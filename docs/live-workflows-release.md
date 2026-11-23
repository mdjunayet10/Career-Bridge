# Career Bridge 1.7.5+33

Public jobs/companies, seeker applications/notifications, employer applicants/jobs and Admin queues now use Firestore snapshot listeners. Connected views rebuild in place without restarting the app. Listeners are replaced on account, company/job-set and Live/Demo changes; late events from the previous source are ignored. Search filters, draft fields and scroll state are preserved.

A new listing still follows the existing moderation policy: pending jobs reach the Admin queue immediately, and public users see them immediately after publication. Draft/pending/closed jobs stay out of public results.

Applicant cards and details expose Shortlist, Interview and Select actions. Interview opens a compact schedule/message dialog; final selection and rejection use a short confirmation. Changes and candidate notifications are atomic. Withdrawn applications cannot be selected by a stale employer action.

Jobs opens on All Jobs, independent of the user's CV. Recommended ordering remains available in a visible adjacent choice. The seeker dashboard also offers Browse All Jobs.

Sample job cards open normally. Guests and live users can explicitly choose Use demo & apply, entering a sample seeker session. Demo applications and employer decisions are shared locally between sample accounts; no sample record is written to production Firestore. Demo mutations remain session-local and do not synchronize between different devices.

Build/setup instructions and configuration exclusions remain documented in docs/reporting-release.md. Both Android flavors and Firebase Hosting use this release; reports and the previous Admin responsive fixes remain included.
