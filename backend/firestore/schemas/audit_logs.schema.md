# auditLogs/{logId}

Append-only Admin action log.

```json
{
  "adminUid": "admin-uid",
  "action": "Employer approved",
  "subject": "NovaTech Bangladesh",
  "detail": "Company identity verified.",
  "createdAt": "timestamp"
}
```

Admin clients may read and append logs. Existing audit records cannot be edited or deleted from the client.
