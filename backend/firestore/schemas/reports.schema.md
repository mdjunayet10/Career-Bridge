# reports/{reportId}

User-submitted trust and safety reports.

```json
{
  "reporterUid": "uid",
  "reporterName": "Junayet Rahman",
  "targetType": "job | company | profile | content",
  "targetId": "target-document-id",
  "targetLabel": "Human-readable target",
  "reason": "Misleading information",
  "details": "Report details",
  "status": "open | inReview | resolved | dismissed",
  "resolutionNote": "Admin decision note",
  "reviewedBy": "admin-uid",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "resolvedAt": "timestamp | null"
}
```

Authenticated users may create and read their own reports. Only Admins may update or delete them.
