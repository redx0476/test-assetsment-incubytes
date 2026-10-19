# Requirements — ACME Salary Management

## Goal

Give ACME's HR Manager a web application to manage salary data for ~10,000 employees
across multiple countries, replacing error-prone spreadsheets, and to **answer
questions about how the organization pays people** (totals, averages, distribution,
pay bands, and pay equity) across currencies.

## Primary user

A single HR Manager persona. Authenticated; trusted; manages all employees.

## Scope & features (in)

1. **Authentication** — email/password login for the HR Manager (token-based API auth).
2. **Employee management** — list with server-side search, filter (country, department,
   level, status), sort, and pagination over 10k rows; view, create, update, deactivate.
3. **Salary management** — each employee has a salary history (amount + currency +
   effective date); recording a new salary supersedes the prior "current" one.
4. **Multi-currency normalization** — salaries stored in local currency; aggregates
   normalized to a base currency (USD) via stored FX rates, so cross-country totals
   and comparisons are meaningful.
5. **Analytics / "how we pay"**
   - KPIs: headcount, total payroll, average & **median** compensation (USD).
   - Breakdowns by country, department, and job level (count, avg, median, total).
   - Compensation distribution chart.
   - **Pay bands & compa-ratio**: salary vs band midpoint; below-min / above-max outliers.
   - **Pay equity**: compensation gap by gender within department / level.
6. **Seed** of 10,000 employees with realistic multi-country, multi-currency data.

## Out of scope (deliberate) & reasoning

- **Multi-user roles / permissions / org hierarchy** — persona is a single HR Manager;
  RBAC adds surface without serving the core question. Modeled as a `role` enum so it
  can grow later.
- **Live FX feed** — rates are seeded static reference data. A live provider is an
  integration detail orthogonal to the product; a `FxConverter` service isolates it so
  a real feed can drop in.
- **Payroll runs, tax, benefits, payslips** — this is salary *insight & management*,
  not payroll processing; those are large separate domains.
- **Audit log, approval workflows, bulk Excel import/export** — valuable operationally
  but not needed to demonstrate the core model and analytics; noted as next steps.
- **SSO / password reset / email** — standard auth plumbing; one seeded account keeps
  the demo focused on the domain.
- **Real deployment hardening** (autoscaling, secrets manager) — local/Docker demo;
  deploy config is provided but a live hosted deploy is deferred.

## Non-goals / failure conditions

It fails if: aggregates are wrong or slow at 10k scale; multi-currency totals mix
currencies naively; the list can't be searched/paginated; or numbers can't be trusted
(no tests). Correctness and clarity beat feature count.

## Key assumptions

- Base reporting currency is **USD**.
- "Current salary" = the most recent effective salary per employee.
- Gender is captured only to enable pay-equity analysis and is optional.
