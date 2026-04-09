---
name: easylaunch-create-or-get-database
description: Get or create a PostgreSQL database for an EasyLaunch app (CLI get-database)
---

# Get or Create Database (EasyLaunch)

**Get or create** a PostgreSQL database for an app and print connection details.

## Parameter sourcing (agent)

- **`--app-id`**: User-supplied. Reuse from conversation or trustworthy project context; **ask only** if still unknown.
- **`--format`**: Prefer **`env`** when the next step is **`easylaunch-deploy-backend`**, so lines map cleanly to repeated `--env KEY=VAL` without re-asking. Use `text` or `json` when the user only needs human-readable or scripted parsing.
- **`--read-only`**: Use when the user asked to **check existing DB only** (no create). Otherwise default to get-or-create **without** extra confirmation.

**Minimize questions:** infer intent from the conversation; only use `--read-only` when that matches the request.

## CLI name and blocking until completion

The command-line tool is **`easylaunch-cli`**. The `get-database` command finishes when the API responds (there is **no** `--wait` flag). When you continue to deploy, use **`deploy-backend ... --wait`** (and **`build-image ... --wait`**) so those steps block until the cloud task completes.

## Obtain the EasyLaunch CLI (cross-platform)

Skills **do not** ship OS-specific binaries. Before first use, run **`easylaunch-cli`** (skill) or:

**macOS / Linux:**

`bash scripts/ensure-easylaunch-cli.sh`

**Windows (PowerShell):**

`powershell -ExecutionPolicy Bypass -File scripts/ensure-easylaunch-cli.ps1`

**Optional (requires Node 18+):**

`node scripts/ensure-easylaunch-cli.mjs`

Then invoke with **`$EASYLAUNCH_CLI`**, **`PATH`**, or `~/.easylaunch/bin/easylaunch-cli` / `%USERPROFILE%\.easylaunch\bin\easylaunch-cli.exe`. See **`easylaunch-cli`** for download URLs and manual `curl`/PowerShell examples.

## Authentication

Commands that require an account check login first. If you are not signed in, **`easylaunch-cli` interactively prompts for your username/email and password**. Running `easylaunch-cli login` up front is optional.

## Command: `easylaunch-cli get-database`

| Flag | Required | Description |
|------|----------|-------------|
| `--app-id` | Yes | Application ID |
| `--format` | No | `text` (default) / `json` / `env` |
| `--read-only` | No | **GET** only: return existing DB info, **do not create**; returns `NOT_FOUND` if no database yet |

### Behavior

- **Default (no `--read-only`)**: POST `/api/v1/apps/:appId/database` (get-or-create). If the platform already has a DB record, returns the DSN; otherwise tries to create one (subject to plan limits such as `max_databases`); idempotent when the DB already exists.
- **`--read-only`**: GET `/database` only; does not trigger create or related plan checks for new databases.

## Examples

Print connection string (default get-or-create):

```bash
easylaunch-cli get-database --app-id <appId>
```

Emit as environment-style lines (prefer when feeding **`deploy-backend --env`**):

```bash
easylaunch-cli get-database --app-id <appId> --format env
```

Query only; never create:

```bash
easylaunch-cli get-database --app-id <appId> --read-only
```

With `--format env`, typical keys include `DATABASE_URL`, `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` (exact output is defined by the CLI).

## Next steps

- Pass `DATABASE_URL` (and related vars) into the backend container with `deploy-backend --env`; see **`easylaunch-deploy-backend`**. Use **`--wait`** on `deploy-backend` so deployment runs to completion before exit.
- Full backend path: `build-image ... --wait` (skill **`easylaunch-build-push-image`**) → `deploy-backend ... --wait` with **`Image URL`** from that build output.

## Related skills

- `easylaunch-cli`: install the CLI
- `easylaunch-deploy-backend`, `easylaunch-build-push-image`
