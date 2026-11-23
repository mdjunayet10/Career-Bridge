# Live workflows and usable demos

Implement in current local source; preserve authentication, moderation and sample/live boundaries.

1. Add tested stream combiners (latest query snapshots and cancellation-safe switching). Firebase public, seeker, employer and Admin repositories expose live snapshots using existing authorized queries. Controllers own/cancel subscriptions on session/source changes; views rebuild without clearing filters, draft input or scroll.
2. Applicant cards expose Shortlist, Interview and Select actions, with a compact interview schedule dialog and More actions. Reuse the same controls on details. Keep existing Firestore status values and candidate notifications, disable duplicate writes and withdrawn edits.
3. Enable opening sample jobs and applying from demo seeker sessions. Offer an explicit demo-session entry for guests/live users; never create sample applications in Firestore. Share demo application/status mutations locally between seeker and employer sample sessions.
4. Add prominent All Jobs / Recommended controls; All Jobs is the full published catalogue independent of CV, recommended ordering stays available. Both respond to live catalogue changes.
5. Test stream updates/cancellation, list actions, sample apply workflow, all-jobs selection, responsive widths, and two-client Firestore job/application listeners. Analyze/build before updating both APKs, web deployment and source ZIP. Keep final files local; the user cancelled external file delivery.

A posted job remains pending until the existing Admin approval requirement is met. Once published, every connected catalogue should update without restart. No sample records enter live Firestore.
