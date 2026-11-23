# Role workflows

## Job Seeker

```text
Register → Complete profile → Search jobs → View details → Apply
→ Track progress → Interview → Hired/Rejected
```

## Employer

```text
Register → Submit company → Pending verification → Admin approval
→ Post job as pending → Admin approval → Published
→ Review applicants → Shortlist → Interview → Hire/Reject
```

## Admin

Admin is not visible on the public website.

```text
/admin/login → Firebase Authentication → role == admin
→ protected Admin Dashboard
```

The first Admin is created manually in Firebase Authentication and in `users/{uid}` with `role: "admin"`.

Admin operations:

```text
Employer submitted → Verify evidence → Approve / Reject → Notify Employer
Job submitted → Review company + content → Publish / Request changes / Suspend
Report submitted → Open → In review → Resolved / Dismissed
User or company risk → Suspend / Reactivate → Audit log
```
