# Career Bridge Backend

Express API backed by PostgreSQL and Prisma.

```bash
npm install
cp .env.example .env
npm run prisma:generate
npm run prisma:migrate
npm run prisma:seed
npm run dev
```

The root `docker-compose.yml` provides a local PostgreSQL service:

```bash
cd ..
docker compose up -d db
```

If login/register shows a database error, first check:

```bash
curl http://localhost:4000/api/health
```

The response should include `"database":"connected"`. If it says `"database":"unavailable"`, PostgreSQL is not running or migrations/seed data have not been applied.

If Docker is not installed, install PostgreSQL with Homebrew:

```bash
brew install postgresql@16
brew services start postgresql@16
export PATH="$(brew --prefix postgresql@16)/bin:$PATH"
createdb career_bridge
psql -d postgres -c "CREATE USER career_bridge WITH PASSWORD 'career_bridge_password';"
psql -d postgres -c "ALTER DATABASE career_bridge OWNER TO career_bridge;"
```

Then run from `backend/`:

```bash
npm run prisma:migrate
npm run prisma:seed
npm run dev
```

Main scripts:

- `npm run dev`
- `npm start`
- `npm test`
- `npm run prisma:generate`
- `npm run prisma:migrate` applies checked-in migrations
- `npm run prisma:migrate:dev` creates new migrations while changing the schema
- `npm run prisma:seed`
- `npm run db:reset`

Use `RUN_DB_TESTS=true TEST_DATABASE_URL=... npm test` for the optional Supertest database suite.

Security and production notes:

- JWT logout is client-side in this MVP: the frontend deletes the stored token. Use short token lifetimes and add token revocation/refresh tokens before high-risk production usage.
- Password reset verification codes are stored hashed. With `SMTP_HOST` configured, the backend emails a 6-digit code and never shows it in the browser. `SMTP_USER` and `SMTP_PASS` are optional for local SMTP relays. `SHOW_DEVELOPMENT_RESET_CODE=true` can be used only for non-production local demos.
- Unverified companies can save jobs as drafts, but cannot publish `OPEN` public listings until an admin verifies the company.
- CV files are stored locally under `backend/uploads/` and are never served as public static files. Move to S3, Supabase Storage, Firebase Storage, or Cloudinary before production scaling.
