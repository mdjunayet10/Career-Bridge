# reports

Document ID for new user submissions: `{reporterUid}_{targetType}_{targetId}`. An active user can create one report per target. Only Admins can update or delete reports; reporters can read their own records. Existing reports remain readable and manageable.

| Field | Value |
| --- | --- |
| reporterUid | Signed-in Firebase UID |
| reporterName | Name from protected users/{uid} profile |
| targetType | job or company |
| targetId | Existing public job or approved active company ID |
| targetLabel | Matching job title or company name |
| reason | Fake Job, Scam/Fraud, Misleading Information, Inappropriate Content, Other |
| details | Optional description, empty string allowed, max 2000 characters |
| status | open initially; Admin may use inReview, resolved, dismissed |
| createdAt | Server timestamp |
| resolutionNote | Admin decision note |
| reviewedBy | Admin UID |
| updatedAt | Admin update server timestamp |
| resolvedAt | Resolution server timestamp or null |

Demo Preview reports live in the in-memory demo repository and are never inserted into this collection. New live reports are streamed to the Admin workspace ordered by createdAt, newest first (latest 300).
