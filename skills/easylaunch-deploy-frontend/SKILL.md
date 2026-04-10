---
name: easylaunch-deploy-frontend
description: Deploy a frontend static site to EasyLaunch (pack, cloud build, OSS + HTTPS)
---

# Deploy Frontend (EasyLaunch)

Package frontend source, upload it, and run a cloud build that deploys a static site.

## Parameter sourcing (agent)

- **`--app-id`**: User-supplied. Reuse from conversation or trustworthy project context; **ask only** if still unknown.
- **`--dir`**: Default to the user’s **local project path** (current working directory where the command is run). Only set `--dir` explicitly when the frontend lives in a subdirectory like `web/` or `frontend/`.
- **`--build-cmd`**: Auto-detect from the frontend `package.json` (prefer `scripts.build`). If detection is unclear, **do not ask the user**—fall back to `npm run build`.
- **`--output-dir`**: Auto-detect from the frontend project (prefer, in order): Vite `build.outDir`, CRA `build`, Next.js static export `out`, otherwise fall back to `dist`. **Do not ask the user**.

**Minimize questions:** prefer reading `package.json` and framework config over asking.

## CLI name and blocking until completion

The command-line tool is **`easylaunch-cli`**. For `deploy-frontend`, **always pass `--wait`**: the process stays running and only exits after the cloud deployment **succeeds or fails**.

## Obtain the EasyLaunch CLI (cross-platform)

Skills **do not** ship OS-specific binaries. Before first use, run **`easylaunch-cli`** (skill) or:

**macOS / Linux:**

`bash scripts/ensure-easylaunch-cli.sh`

**Windows (PowerShell):**

`powershell -ExecutionPolicy Bypass -File scripts/ensure-easylaunch-cli.ps1`

Then invoke with **`$EASYLAUNCH_CLI`**, **`PATH`**, or `~/.easylaunch/bin/easylaunch-cli` / `%USERPROFILE%\.easylaunch\bin\easylaunch-cli.exe`. See **`easylaunch-cli`** for download URLs and manual `curl`/PowerShell examples.

## Authentication

Commands that require an account check login first. If you are not signed in, **`easylaunch-cli` interactively prompts for your username/email and password**. Running `easylaunch-cli login` up front is optional.

## Command: `easylaunch-cli deploy-frontend`

| Flag | Required | Description |
|------|----------|-------------|
| `--app-id` | Yes | Application ID |
| `--dir` | No | Frontend project directory, default current directory (project root) |
| `--build-cmd` | No | Build command, default `npm run build` (recommended: auto-detect from `package.json`) |
| `--output-dir` | No | Build output directory, default `dist` (recommended: auto-detect from project config) |
| `--wait` | **Always** | Block until deployment finishes (success or failure); **include in every run** |

## Restrictions

- Apps with **`app_type=backend`** cannot deploy a frontend (API returns **400**).

## Flow (high level)

1. Package and upload source.
2. Cloud pipeline: install dependencies, run the build, publish artifacts to static hosting (OSS), wire DNS and HTTPS.

## Recommended example

Recommended: run from your frontend project directory and let the agent auto-detect `--build-cmd` and `--output-dir` from `package.json` / framework config.

```bash
easylaunch-cli deploy-frontend \
  --app-id <appId> \
  --wait
```

If you must run from a different directory, set `--dir` only:

```bash
easylaunch-cli deploy-frontend \
  --app-id <appId> \
  --dir <frontend-root> \
  --wait
```

## Success output (with `--wait`)

The CLI prints:

- `Service URL: https://<appId>.<dns-domain>`

The real hostname depends on platform DNS; `<dns-domain>` is a placeholder as in the docs.

## Troubleshooting

```bash
easylaunch-cli status --task-id <task-id>
```

(`status` returns immediately with the current task state.)

Failed responses may include a short tail of pipeline logs in the error payload.

## SPA routes and HTTP status (payments / domain review)

The Vite build copies `dist/index.html` into `dist/<slug>/index.html` for marketing paths such as `terms`, `privacy`, `pricing`, `refunds`, `download`, `docs`, and `support`, so object storage can serve `https://<host>/terms/` with **HTTP 200**.

If `https://<host>/terms` (no trailing slash) still returns **404**, configure your CDN or static hosting **rewrite/redirect** to `/terms/` or `/terms/index.html`. Payment providers and crawlers often request the bare path; a 404 status can fail review even when the HTML body looks correct.

## Related skills

- `easylaunch-cli`: install the CLI
- Backend image build and deploy: `easylaunch-build-push-image`, `easylaunch-deploy-backend`
- Full-stack: frontend URL is typically `https://<appId>.<dns-domain>`; backend URL rules depend on `app_type` (see `easylaunch-deploy-backend`)
