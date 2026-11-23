# UI Polish Batch 3

Version: `1.3.0+14`

## Company logo architecture

The company profile is now the only source of the company logo.

```text
Employer uploads/replaces one company logo
→ Flutter compresses and validates the image
→ Firestore stores the file in chunks
→ companies/{companyId}.logoFileId is updated
→ CompanyLogoRegistry notifies all logo widgets
→ every public, Employer, Job Seeker, and Admin view refreshes
```

Jobs no longer carry `companyLogoFileId` or company initials. Applications keep `companyId` and company-name/job snapshots, but never duplicate the logo. Demo assets remain symbol-only fallbacks when there is no uploaded file.

## Workspace polish

- responsive dashboard shell with stronger navigation and role context
- premium metric cards and balanced desktop/mobile spacing
- consistent loading and retry states across Job Seeker, Employer, and Admin workspaces
- Job Seeker recommendation cards now use real company logos
- Employer dashboard includes a company identity banner, logo, profile completion, and primary actions
- Admin dashboard includes moderation shortcuts and company logos in verification queues
- Admin company management and verification surfaces use the same company-profile logo

## Validation

Run from the project root:

```bash
./scripts/verify_release.sh demo
./scripts/run_demo.sh
```

The implementation environment validates project structure, imports, JSON/YAML, shell scripts, rules structure, and archive integrity. Flutter analysis, tests, browser review, and release build still need to run on the user's Mac.
