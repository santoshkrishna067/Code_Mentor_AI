# Code Mentor AI — Full Stack

```
backend/    Node.js + TypeScript + Express + Prisma (MongoDB Atlas)
frontend/   React + TypeScript + Vite, wired to the backend above
```

## Quick start

**1. Backend first:**
```bash
cd backend
npm install
cp .env.example .env        # fill in a real MongoDB Atlas connection string
npm run prisma:generate
npm run prisma:push         # pushes the schema to MongoDB — see backend/README.md
npm run seed:courses        # imports the 9 supplied Excel courses
npm run dev                 # http://localhost:4000
```

**2. Frontend:**
```bash
cd frontend
npm install
cp .env.example .env        # VITE_API_URL must match the backend's PORT
npm run dev                 # opens on Vite's default port, proxies to :4000
```

Create your first account via the app's Register page, then promote it to
admin directly in the database (or use `POST /api/users/admins` from an
existing admin) to access `/admin/*`.

## What to read next

- `backend/README.md` — full module-by-module status (Parts 2–5), API
  surface table, MongoDB migration notes.
- `backend/PRODUCTION_READINESS.md` — honest Part 7 findings: what was
  checked and fixed, what still needs real infrastructure to verify.
- `frontend/INTEGRATION_NOTES.md` — what was wired, real bugs found and
  fixed in the original files, and known gaps (no code-execution provider,
  no LLM provider, no password-reset-by-email, no face-detection ML).

## Honesty note on testing

Neither package's test suite has been executed in this delivery — this
build environment has no network access (`npm install` can't reach the
registry) and no live database. Everything is real, runnable code, but
`npm test` in `backend/` needs to actually be run against a real MongoDB
instance before trusting it's green. See `PRODUCTION_READINESS.md` for the
full list of what genuinely still needs live infrastructure to verify.
