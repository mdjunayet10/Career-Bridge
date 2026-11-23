# Career Bridge 1.7.2 — fictional demo accounts

All 32 accounts below use **`Demo123!`**. These credentials are for local sample sessions only. They do not create, modify, or authenticate production Firebase users.

On the Job Seeker or Employer sign-in screen, open **Choose a demo account**, select an account, and press **Use**. This fills the email and password; use the normal sign-in button to continue. The picker stays compact and scrolls through its options. Sign out to return to live login.

There is **no Admin demo login**. The sample administrator directory row, if viewed through a test/sample admin workspace, is not an authentication account and has no supplied credentials.

## Job Seekers — 20

Each fictional seeker has a distinct career focus, profile, sample CV, saved jobs, applications, and notification content. Completion percentages reflect the information actually present; example links or missing photos do not receive artificial credit.

| # | Fictional name | Email | Career focus |
|---|---|---|---|
| 1 | Ayan Rahman (Demo) | `jobseeker@careerbridge.demo` | Flutter Developer |
| 2 | Mira Sen (Demo) | `designer@careerbridge.demo` | Product Designer |
| 3 | Tariq Noor (Demo) | `analyst@careerbridge.demo` | Junior Data Analyst |
| 4 | Farah Kabir (Demo) | `accountant@careerbridge.demo` | Junior Accountant |
| 5 | Nabil Karim (Demo) | `marketer@careerbridge.demo` | Digital Marketing Executive |
| 6 | Ritu Das (Demo) | `civil@careerbridge.demo` | Civil Engineering Trainee |
| 7 | Samiha Roy (Demo) | `support@careerbridge.demo` | Customer Support Specialist |
| 8 | Adnan Saha (Demo) | `hr@careerbridge.demo` | HR Coordinator |
| 9 | Lina Chowdhury (Demo) | `writer@careerbridge.demo` | Content Writer |
| 10 | Rafiq Alam (Demo) | `qa@careerbridge.demo` | Software QA Engineer |
| 11 | Nora Islam (Demo) | `operations@careerbridge.demo` | Operations Coordinator |
| 12 | Ishan Dey (Demo) | `energy@careerbridge.demo` | Energy Analyst Intern |
| 13 | Rehan Pal (Demo) | `backend@careerbridge.demo` | Backend Developer |
| 14 | Tania Dey (Demo) | `teacher@careerbridge.demo` | Teaching Assistant |
| 15 | Afsana Sen (Demo) | `nurse@careerbridge.demo` | Nursing Graduate |
| 16 | Omar Roy (Demo) | `researcher@careerbridge.demo` | Research Assistant |
| 17 | Priya Alam (Demo) | `sales@careerbridge.demo` | Sales Executive |
| 18 | Rayan Saha (Demo) | `graphic@careerbridge.demo` | Graphic Designer |
| 19 | Dina Noor (Demo) | `food@careerbridge.demo` | Food Quality Assistant |
| 20 | Kabir Das (Demo) | `electrical@careerbridge.demo` | Electrical Engineering Trainee |

## Employers — 12

Each employer owns a separate fictional company and its own workspace data. Eleven accounts are approved sample employers. Orbit Labs demonstrates the pending-verification flow; its sample jobs stay pending and it has no published catalog vacancy. “Approved” here describes sample workflow state, not real business verification.

| # | Fictional company | Contact | Email | Demo state |
|---|---|---|---|---|
| 1 | NovaTech Bangladesh (Demo) | Nusrat Hasan (Demo) | `employer@careerbridge.demo` | Approved sample |
| 2 | Orbit Labs (Demo) | Arif Sen (Demo) | `pending@careerbridge.demo` | Pending verification |
| 3 | Bengal DataWorks (Demo) | Maliha Noor (Demo) | `bengal@careerbridge.demo` | Approved sample |
| 4 | SummitLabs Digital (Demo) | Fahim Roy (Demo) | `summit@careerbridge.demo` | Approved sample |
| 5 | GreenGrid Energy (Demo) | Rina Karim (Demo) | `greengrid@careerbridge.demo` | Approved sample |
| 6 | CareNest Health (Demo) | Imran Saha (Demo) | `carenest@careerbridge.demo` | Approved sample |
| 7 | PixelHarbor Studio (Demo) | Sara Dey (Demo) | `pixel@careerbridge.demo` | Approved sample |
| 8 | LedgerLeaf Finance (Demo) | Tanvir Sen (Demo) | `ledger@careerbridge.demo` | Approved sample |
| 9 | StorySpring Media (Demo) | Amina Roy (Demo) | `story@careerbridge.demo` | Approved sample |
| 10 | PeoplePath Consulting (Demo) | Mahin Das (Demo) | `people@careerbridge.demo` | Approved sample |
| 11 | BuildBloom Engineering (Demo) | Nadia Alam (Demo) | `build@careerbridge.demo` | Approved sample |
| 12 | HarborLink Logistics (Demo) | Faisal Noor (Demo) | `harbor@careerbridge.demo` | Approved sample |

## Data boundaries

- Account, profile, job, application, and notification changes in a demo session remain in the local sample repositories. They do not write to live Firebase collections.
- Sample public jobs are marked as sample data and are not shown as verified employers. Pending-demo jobs are not published.
- Demo identities are recognized by exact catalog membership. Other email addresses continue through the configured live sign-in path.
- Demo sessions and edits are temporary. Signing out restores the live repository selection; a new app/session can reset sample content.
- The legacy `jobseeker@careerbridge.demo`, `employer@careerbridge.demo`, and `pending@careerbridge.demo` credentials remain available. The former Admin demo credentials are rejected by the demo authentication repository.

## Verification status

Catalog and picker checks have passed locally, including all 32 logins, distinct company ownership, sample public/private job mapping, new-account demo isolation, and rejection of the former Admin demo login. Final full-suite, build, and runtime results for release 1.7.2 must be recorded in `UPDATE_1.7.2.md` before delivery is reported as complete.
