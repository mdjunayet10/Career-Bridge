# UI Polish Batch 2

Version: `1.2.0+13`

## Company presentation

- Company assets are symbol-only; no initials or company-name text are embedded in bundled logo graphics.
- Missing logos use a generic business glyph rather than a letter.
- Company listing cards now use a stronger information hierarchy and stable responsive sizing.
- Company Details uses a compact identity header and balanced About/Overview sections.

## Authentication

- The authentication shell remains scrollable at laptop heights and keeps the primary action accessible.
- The left visual panel has improved logo contrast and reduced vertical demand.
- Role selection, Job Seeker registration, and Employer registration use responsive grouped forms.
- Employer registration uses two-column field pairs when space permits and stacks cleanly on smaller screens.

## Validation

Run from the project root:

```bash
./scripts/verify_release.sh demo
./scripts/run_demo.sh
```
