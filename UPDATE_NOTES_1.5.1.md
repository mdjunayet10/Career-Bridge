# Career Bridge 1.5.1 — Data Integrity & Presentation Cleanup

This update keeps the clean Admin login flow unchanged and refines only the public/job-seeker experience requested in the latest review.

## Public landing cleanup

- Removed the fake `12 Applications / 3 Shortlisted / 1 Interview` dashboard statistics from the landing hero preview.
- Kept the three previously corrected landing sections left-aligned: Explore Career Paths, Featured Opportunities, and Trusted Employers.
- Location chips continue to wrap into multiple rows; horizontal scrolling is not used.
- Renamed the public landing section from **Recommended Opportunities** to **Featured Opportunities** so it is not confused with personalized Job Seeker recommendations.

## Sample jobs without fake live counts

- Firebase `jobs` remains the source of truth for search, recommendations, applications, and the **Live jobs** count.
- If fewer than six real jobs exist, the landing showcase fills the remaining cards with demo jobs.
- Demo cards are clearly marked **SAMPLE** and are preview-only.
- Sample cards are kept out of the real Jobs catalogue, recommendation engine, and live statistics.
- The landing page explains when sample cards are being used.

## Company / Employer cleanup

- Removed the Companies-page hero summary box (`Verified / company count / role count`).
- Removed the entire fake Employer `Recruitment overview` preview, including `8 Active jobs`, `146 Applicants`, `17 Shortlisted`, and the candidate-pipeline bars.
- The public Employer hero now stays clean and left-aligned.

## Automatic Salary Insights

- Public Salary Insights no longer reads the manually maintained Firestore `salaryInsights` collection.
- Salary Insights are calculated automatically from active, published jobs with comparable monthly salary ranges.
- The system calculates minimum, median, average, maximum, and sample size.
- Role-specific groups are preferred; category/location market groups are used as a fallback where appropriate.
- At least 3 comparable listings are required before an insight is displayed.
- When there is not enough data, the UI shows **Not enough salary data yet**.
- The Admin Salary Insights page is now read-only and explains that the figures are generated automatically. There is no Add/Edit salary-insight UI.

## Job-match notifications

- Job Seeker recommendations remain based on Profile + Auto CV data.
- Matching-job notifications are now refreshed when the Job Seeker workspace loads as well as after a profile update.
- Up to three new unseen matching jobs can create notifications in one sync, while duplicate job notifications are prevented.
- Notification text does **not** show a match percentage.
- Example: `New job match found` → `Flutter Developer at NovaTech may be a good fit for your profile.`
- Match percentages may still appear inside Recommendation cards, where they are useful for ranking/explanation.

## Preserved behavior

- Clean Admin authentication/login routing from the supplied baseline was not modified.
- Profile → Auto CV sync remains enabled.
- CV/profile-based recommendation ranking remains enabled.
- Existing application/interview notifications remain intact.
