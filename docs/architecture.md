# Architecture

## System shape

Two decoupled applications in one repository, communicating over HTTP/JSON.

```mermaid
flowchart TD
  subgraph Browser
    SPA["React SPA (Vite)\nTailwind · TanStack Query · Recharts\nlocalhost:5173"]
  end
  subgraph API["Rails 8 JSON API · localhost:3000"]
    C["Controllers (api/v1)\nthin, auth + params only"]
    S["Services / Query objects\nAnalytics::*, FxConverter, BandAssessment"]
    M["ActiveRecord models"]
  end
  DB[("PostgreSQL\nindexed · SQL aggregates")]

  SPA -- "fetch + Bearer token (CORS)" --> C
  C --> S --> M --> DB
  C --> M
```

Requests carry an opaque bearer token; CORS allows the SPA origin. Controllers stay
thin and delegate all compensation math to plain-Ruby service/query objects, which
push aggregation into SQL.

## Data model

```mermaid
erDiagram
  USER ||--o{ SESSION : "has many"
  EMPLOYEE ||--o{ SALARY : "has many (history)"
  EMPLOYEE }o--|| PAY_BAND : "matched by (level, country)"
  SALARY }o--|| FX_RATE : "currency → USD"

  EMPLOYEE {
    string  employee_number UK
    string  country_code
    string  department
    int     job_level
    int     gender
    int     employment_status
  }
  SALARY {
    bigint  amount_cents
    string  currency
    date    effective_date
    bool    current
  }
  PAY_BAND {
    int     job_level
    string  country_code
    bigint  min_cents
    bigint  mid_cents
    bigint  max_cents
  }
  FX_RATE {
    string  currency UK
    decimal rate_to_usd
  }
```

Key modeling choices:

- **Salary history + `current` flag.** Salaries are append-only; exactly one row per
  employee is `current`, enforced by a partial unique index
  (`UNIQUE (employee_id) WHERE current`). Aggregates filter `current = true`.
- **Money as integer minor units + ISO currency.** No floating-point drift.
- **FX normalization** to USD via `fx_rates.rate_to_usd`, joined in SQL for analytics
  and applied by `FxConverter` for single-record display.
- **Pay bands** per `(job_level, country_code)` drive compa-ratio and outlier flags.

## Analytics (computed in SQL)

All KPIs are grouped SQL aggregates over `current` salaries of active employees,
normalized to USD (`salaries.amount_cents * fx_rates.rate_to_usd`):

- **Payroll** — `COUNT`, `SUM`, `AVG`, and true median via
  `PERCENTILE_CONT(0.5) WITHIN GROUP (...)`, plus a `CASE`-bucketed distribution.
- **Breakdown** — the same aggregates grouped by country, department, or job level.
- **Equity** — average compensation grouped by gender, overall and per department,
  reported as a male-vs-female gap percentage.

No analytics path loads 10k rows into Ruby.

## Request flow (example: employee list)

1. `GET /api/v1/employees?q=&country=&page=` → `EmployeesController#index`.
2. `authenticate!` resolves the bearer token to a `Session` → `current_user`.
3. `EmployeesQuery` applies search, whitelisted filters, and a whitelisted sort.
4. `Paginatable` adds `LIMIT/OFFSET` and a count; `current_salary` is eager-loaded.
5. `EmployeeSerializer` renders rows with USD-normalized salary via `FxConverter`.

## Performance

- Indexes on `employees (country_code, department, job_level, employment_status)`
  and the partial `salaries (employee_id) WHERE current` back filters and aggregates.
- The employee list eager-loads `current_salary` (one extra query, no N+1) and is
  paginated.
- Seeding 10k employees + ~20k salary rows uses batched `insert_all` (~7s).
- Analytics are cache-ready (Solid Cache is configured) if endpoints ever need it.

## Security

- Bearer tokens stored only as SHA-256 digests; revocable; TTL-bounded.
- Login uses `authenticate_by` (constant-time) and is rate-limited.
- CORS restricted to the configured frontend origin.
- Strong parameters on all writes; Brakeman clean.

## Known trade-offs

- React Router carries two moderate advisories fixed only in a breaking v7; neither
  applies here (no SSR hydration, no links built from untrusted input), so the
  breaking upgrade is deferred.
- The SPA stores its token in `localStorage` — acceptable for a single-operator
  internal tool; a hardened deployment would prefer httpOnly cookies.
