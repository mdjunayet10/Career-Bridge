# First Admin setup

The Admin account is not visible on the public website and cannot be created through public registration.

## Recommended Firebase Console method

### Step 1 — Create the Authentication user

Firebase Console → Authentication → Users → Add user

Use an Admin-only email address and a strong password. Copy the generated UID.

### Step 2 — Create the Firestore profile

Firebase Console → Firestore Database → `users` collection → Add document

- Document ID: the Authentication UID from Step 1
- Fields:

```json
{
  "name": "Career Bridge Admin",
  "email": "admin@example.com",
  "role": "admin",
  "isActive": true,
  "verificationStatus": "notRequired",
  "createdAt": "server timestamp",
  "updatedAt": "server timestamp"
}
```

Use Firestore Timestamp fields for `createdAt` and `updatedAt`.

### Step 3 — Sign in through the hidden route

```text
https://YOUR_HOST/admin/login
```

The route is intentionally absent from the navbar and footer.

## Security model

Admin access requires all three layers:

1. Firebase Authentication session
2. `users/{uid}.role == "admin"` and `isActive == true`
3. Firestore Security Rules

Knowing `/admin/login` is not enough to access Admin data.

## Important

Never add an Admin option to public registration. To create another Admin, repeat this controlled Firebase Console process.
