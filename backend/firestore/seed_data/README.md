# Platform seed data

These files mirror the Admin demo workspace and contain only platform-owned content:

- `categories.json`
- `salary_insights.json`
- `platform_settings.json`

They intentionally do not create users, companies, jobs, applications, or private verification records. Those documents must be created through the authenticated role workflows so ownership and Security Rules remain valid.

For a university demo, the safest setup is:

1. Create the first Admin account.
2. Sign in at `/admin/login`.
3. Add or edit categories, salary insights, and platform settings from the Admin Panel.

The JSON files are a canonical reference for the values used in demo mode.
