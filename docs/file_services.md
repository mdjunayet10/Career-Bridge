# File services and CV PDF workflow

Career Bridge cannot use Firebase Storage or any billing-required service. The Flutter client therefore handles small images and CV PDFs with a strict **2 MB final-file limit** and stores them in Cloud Firestore.

## Image workflow

```text
User selects JPG / PNG / WebP
        ↓
Flutter decodes and fixes orientation
        ↓
Longest side resized to at most 1600 px
        ↓
JPEG quality reduced until final file ≤ 2 MB
        ↓
SHA-256 + chunk preparation
        ↓
Firestore metadata + Base64 chunks
```

Implemented integrations:

- Job Seeker profile photo
- Employer company logo
- reusable picker, compression, validation, upload, reconstruction, cache, and display widgets

Company logos are public only after the file reaches `state: ready`. Job Seeker profile images remain private to their owner and Admin in this milestone.

## CV workflow

Structured CV data remains in `cvProfiles/{uid}`. The PDF is generated on the device with no server or Cloud Function.

```text
Structured CV
  → device-side PDF preview
  → device-side export/download
```

When a Job Seeker submits an application:

```text
Structured CV
  → device-side PDF snapshot
  → 2 MB validation
  → Firestore chunk upload with applicationId
  → application stores cvFileId
```

The Employer can reconstruct and open that immutable PDF snapshot only when the file's `applicationId` belongs to an application for a job owned by that Employer.

## Firestore chunk contract

- maximum file size: `2,097,152` bytes
- raw chunk target: `480 KB`
- encoded chunk limit: `700,000` characters
- maximum chunk count: `8`
- metadata state: `uploading → ready`
- integrity verification: expected byte count + SHA-256

Upload sequence:

1. Create `fileObjects/{fileId}` with `state: uploading`.
2. Write zero-padded chunk documents.
3. Update metadata to `state: ready`.
4. On failure, best-effort cleanup removes chunks and metadata.

Download sequence:

1. Read ready metadata.
2. Query chunks ordered by `index`.
3. Base64-decode and concatenate.
4. Verify `sizeBytes`.
5. Verify SHA-256.

## Supported MIME types

- `application/pdf`
- `image/jpeg`
- `image/png`
- `image/webp`

The image compressor currently normalizes uploaded images to JPEG before Firestore upload.
