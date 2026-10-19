# ACME Salary Management

Web application for an HR Manager to manage salary data for ~10,000 employees across
multiple countries and answer questions about how the organization pays people.

Two applications in one repository:

- **Backend** — Rails 8 JSON API (PostgreSQL) at the repo root.
- **Frontend** — standalone React + Vite SPA in [`frontend/`](frontend/).

See [`docs/requirements.md`](docs/requirements.md) for scope, [`docs/architecture.md`](docs/architecture.md)
for the design, and [`docs/decisions.md`](docs/decisions.md) for trade-offs.

## Stack

| Layer     | Choice                                                                 |
|-----------|------------------------------------------------------------------------|
| Backend   | Ruby 4.0.7, Rails 8.1, PostgreSQL, token auth, RSpec                    |
| Frontend  | React 18 + TypeScript, Vite, Tailwind, TanStack Query, Recharts, Vitest |

## Prerequisites

- Ruby 4.0.7, Bundler
- Node 20+
- PostgreSQL 14+ (or run `docker compose up -d db`)

## Backend — setup & run

```bash
bundle install

cp .env.example .env            # set DB_* to match your local Postgres
bin/rails db:prepare            # create + migrate
bin/rails db:seed               # seed 10,000 employees (deterministic, ~7s)

bin/rails server                # http://localhost:3000
```

Database credentials are read from `.env` via dotenv (`DB_HOST`, `DB_PORT`,
`DB_USERNAME`, `DB_PASSWORD`). No live Postgres handy? `docker compose up -d db`
starts one matching the defaults.

## Frontend — setup & run

```bash
cd frontend
npm install
cp .env.example .env            # VITE_API_URL=http://localhost:3000
npm run dev                     # http://localhost:5173
```

## Sign in

The seed creates one HR Manager account:

- **Email:** `hr@acme.test`
- **Password:** `password123`

(In development the login form is pre-filled with these; set `SEED_HR_PASSWORD`
to override the seeded password.)

## Tests

```bash
bundle exec rspec               # backend (models, services, request specs)
bin/rubocop                     # style
bin/brakeman                    # security scan

cd frontend && npm run test     # frontend (Vitest + Testing Library)
cd frontend && npm run build    # type-check + production build
```

## Features

- **Dashboard** — headcount, total payroll, average and median compensation
  (USD-normalized), salary distribution, payroll by country, pay-equity summary.
- **Employees** — search, filter (country / department / level / status), sort,
  and paginate across 10k rows; view, create, update, deactivate.
- **Employee detail** — salary history, compa-ratio vs. pay band, outlier flag,
  and recording a new (superseding) salary.
- **Analytics** — compensation breakdowns by country / department / level and a
  gender pay-gap report overall and per department.

## API

Base URL `/api/v1`. All endpoints except login require
`Authorization: Bearer <token>`.

| Method | Path                               | Purpose                          |
|--------|------------------------------------|----------------------------------|
| POST   | `/session`                         | Log in, returns a bearer token   |
| GET    | `/session`                         | Current user                     |
| DELETE | `/session`                         | Log out (revoke token)           |
| GET    | `/employees`                       | List (search/filter/sort/page)   |
| POST   | `/employees`                       | Create                           |
| GET    | `/employees/:id`                   | Detail + history + band          |
| PATCH  | `/employees/:id`                   | Update                           |
| DELETE | `/employees/:id`                   | Deactivate (soft delete)         |
| POST   | `/employees/:id/salaries`          | Record a new current salary      |
| GET    | `/analytics/dashboard`             | Payroll KPIs                     |
| GET    | `/analytics/breakdown?dimension=`  | `country` \| `department` \| `level` |
| GET    | `/analytics/equity`                | Gender pay-gap report            |

## Deployment

Containerization is committed as deploy config:

- Backend: the production `Dockerfile` and Kamal config in `config/deploy.yml`.
- Frontend: `frontend/Dockerfile` (multi-stage build served by nginx).

The verified local flow above is the intended path for the demo.
