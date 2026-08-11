# `fileObjects/{fileId}`

Firestore-backed file storage for the university-project constraint that Firebase Storage and billing-dependent services cannot be used. Every source or generated file must be **2 MB or smaller**.

```json
{
  "ownerUid": "Firebase Auth UID",
  "applicationId": "optional application ID",
  "fileName": "Junayet_Rahman_CV.pdf",
  "mimeType": "application/pdf",
  "sizeBytes": 1830000,
  "chunkCount": 4,
  "sha256": "64-character SHA-256 digest",
  "purpose": "profileImage | companyLogo | applicationCv | uploadedCv | other",
  "state": "uploading | ready",
  "createdAt": "server timestamp",
  "updatedAt": "server timestamp"
}
```

Chunks are stored under:

```text
fileObjects/{fileId}/chunks/{zeroPaddedIndex}
```

```json
{
  "index": 0,
  "data": "base64 encoded chunk"
}
```

Implementation rules:

- Raw chunks are approximately 480 KB; Base64 expands each chunk to roughly 640 KB.
- Each encoded chunk must stay below 700,000 characters and the file may use at most 8 chunks.
- Metadata is created first with `state: uploading`, then chunks are written, then metadata moves to `state: ready`.
- Reconstruction orders chunks by `index`, decodes Base64, verifies `sizeBytes`, then verifies SHA-256.
- Employers can read only a ready PDF whose `applicationId` points to an application for a job they own.
- Owners and Admins may delete a file and all child chunks.
