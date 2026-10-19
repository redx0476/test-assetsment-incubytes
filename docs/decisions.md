# Design Decisions & Trade-offs

## 1. PostgreSQL over SQLite
The brief suggested "like SQLite". The scaffold already ships PostgreSQL, and the core
of this product is **aggregate analytics over 10k rows** (median, group-bys, FX
normalization). Postgres gives `percentile_cont` for true median in SQL, strong
indexing, and partial indexes. Trade-off: slightly heavier local setup (handled via
`.env` + dotenv).

## 2. Decoupled React SPA + Rails JSON API (not Hotwire, not embedded)
Two applications in one repo: Rails API at root, React + Vite under `frontend/`.
- *Why not Hotwire?* The brief prescribes React/Next for the UI.
- *Why not embedded (vite_rails)?* A standalone frontend keeps a clean API contract,
  independent dev/test/build, and mirrors real production topology.
- *Trade-off:* cross-origin wiring (CORS) and token auth instead of same-origin
  cookies; a little more plumbing for a much cleaner separation.

## 3. Token-based auth (bearer) over cookie sessions
Because the SPA is cross-origin. On login Rails creates a `Session` row storing only a
**SHA-256 digest** of an opaque token; the raw token is returned once and sent as
`Authorization: Bearer`. Revocable, no cross-site cookie complexity. Trade-off: client
stores the token in `localStorage` (documented; acceptable for a single-operator
internal tool).

## 4. Money as integer minor units + ISO currency
`amount_cents` (bigint) + `currency` avoids floating-point drift. Aggregation and
display conversion happen explicitly through `FxConverter`. Trade-off: must convert at
read time for cross-currency rollups — isolated in one service and done in SQL.

## 5. Salary history with a `current` flag
Salaries are append-only history; exactly one row per employee is `current` (enforced
by a partial unique index). Aggregates filter `current = true` for fast, index-friendly
rollups instead of per-employee window queries. Trade-off: the flag must be maintained
transactionally on write (handled in the model/service).

## 6. Static seeded FX rates
Rates are reference data (`fx_rates`), not a live feed, behind `FxConverter`. A real
provider can replace the source without touching callers.

## 7. Analytics in SQL, not Ruby
All KPIs/breakdowns are computed with grouped SQL aggregates (`percentile_cont`, `avg`,
`sum`, `count`) so 10k rows never load into Ruby. Query objects under
`app/services/analytics/` keep controllers thin and the math unit-testable.

## Performance considerations
- Indexes on `employees(country_code, department, job_level, employment_status)` and
  `salaries(employee_id) WHERE current` back the list filters and aggregates.
- Seed uses batched `insert_all` to load 10k employees + history quickly.
- List endpoint is paginated (pagy); analytics endpoints are cacheable (Solid Cache
  available) if needed.
