# notifications/{notificationId}

```json
{
  "recipientUid": "Firebase Auth UID",
  "title": "Interview scheduled",
  "message": "Recipient-facing update text",
  "type": "application | interview | job | company | profile | general",
  "applicationId": "optional application document ID",
  "actionRoute": "/job-seeker/applications/applicationId",
  "isRead": false,
  "createdAt": "timestamp"
}
```

A recipient can read their own notifications and update only `isRead`. An Employer can create an application-linked notification only when the linked application belongs to a job they own. Admin retains full access.
