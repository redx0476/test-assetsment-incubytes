# AI Usage

AI (Claude Code) was used intentionally to accelerate scaffolding, boilerplate, and
test generation, while all architecture, data modeling, and correctness decisions were
reviewed and owned by me.

## Standing instructions given to the AI

A senior full-stack engineering mandate was provided and kept in force for every task:

> Act as a Senior Full-Stack Developer and Software Architect. Explore and understand
> the existing codebase before changing it. Follow existing conventions, design system,
> and architecture. Reuse existing components, services, and patterns. Write clean,
> secure, scalable, production-ready code. Avoid unnecessary refactoring, duplicate
> logic, breaking changes, and regressions. Analyze impact across frontend, backend,
> database, APIs, and integrations. Test and verify thoroughly, including edge cases.
> Follow Git best practices; no AI attribution in commits.
>
> Golden Rule: understand the codebase first, follow existing conventions, make minimal
> high-quality changes, and verify everything before completion.

Additional explicit direction during the build:
- Use **RSpec** for the Ruby test suite (not the scaffold's Minitest).
- Add **dotenv-rails**; keep DB credentials in a gitignored `.env`.
- Build the frontend as a **separate React application** under `frontend/`, with the
  Rails app at the repo root as a JSON API.

## How AI was used

- **Planning**: produced a written plan and a requirements doc; clarifying questions
  resolved the architecture (decoupled React + Rails API), auth (token), analytics
  depth (FX normalization + pay bands + equity), and DB (PostgreSQL) before any code.
- **Scaffolding**: gem/package setup, migrations, controller/service skeletons, React
  app bootstrap, Docker/CI config.
- **Tests**: factory and spec generation for models, services, and request endpoints.

## Human review & correctness

- Analytics math (median via `percentile_cont`, FX normalization, compa-ratio, equity
  gap) was specified by me and pinned with tests against hand-checked fixtures.
- A real DB password that briefly landed as a committed fallback was moved into `.env`.
- Every milestone was verified (specs green, lint/security scans clean) before moving on.
