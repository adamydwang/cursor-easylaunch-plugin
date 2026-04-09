---
name: easylaunch-deploy-all
description: Deploy containerized backend (Dockerfile) or static frontend to EasyLaunch (auto-detect, optional Postgres, build image, deploy; auto-fix and retry on errors).
---

# Deploy All (EasyLaunch)

Deploy a project end-to-end on EasyLaunch with minimal user input:

- Detect project type: **containerized backend** (Dockerfile present) or **static frontend** (no Dockerfile)
- Optionally provision Postgres and wire the connection into the backend
- Build and push a backend image (write a `Dockerfile` first if missing)
- Deploy the backend service
- Retry on errors after applying targeted fixes, until success

**Important distinction:**
- If `Dockerfile` exists → **Backend service** (even if it's Next.js/NUXT with SSR, it's deployed as a single container)
- If no `Dockerfile` → **Static frontend** (use `deploy-frontend`)

## Step 1 — Get `appId`

Ask the user for **`appId`**.

If they don’t remember it, tell them to open **`easylaunch.aimos.cloud`** and copy the **App ID** from the app details page.

## Step 2 — Ensure `easylaunch-cli` exists (cross-platform)

Skills do not bundle OS-specific binaries. From the plugin repository root:

- **macOS / Linux**:

`bash scripts/ensure-easylaunch-cli.sh`

- **Windows (PowerShell)**:

`powershell -ExecutionPolicy Bypass -File scripts/ensure-easylaunch-cli.ps1`

(Node 18+ `node scripts/ensure-easylaunch-cli.mjs` is optional.)

Then invoke with **`$EASYLAUNCH_CLI`**, **`PATH`**, or `~/.easylaunch/bin/easylaunch-cli` / `%USERPROFILE%\\.easylaunch\\bin\\easylaunch-cli.exe`.

## Step 3 — Detect project type

Work from the **current project directory** and inspect the repository.

### Decision tree

1. **Does a `Dockerfile` exist** (in current dir or subdirs like `api/`, `backend/`)?
   - **YES** → **Containerized Backend** (deploy via `build-image` + `deploy-backend`)
   - **NO** → **Static Frontend** (deploy via `deploy-frontend`)

### Backend detection (Dockerfile exists)

**Backend root directory selection** (choose the first match):

1. Current directory contains `Dockerfile`
2. `api/` if it contains a `Dockerfile`
3. `backend/` if it contains a `Dockerfile`
4. Ask only if still ambiguous (rare)

**Framework detection** (for context only, deployment is still via Dockerfile):
- Go: `go.mod` exists
- Node: `package.json` exists with `express`, `fastify`, `nestjs`, `next`, `nuxt`, etc.

### Static Frontend detection (no Dockerfile)

- `package.json` exists and has `scripts.build`
- Dependencies indicate a frontend framework: `vite`, `react-scripts`, `next` (static export), `nuxt`, `sveltekit`, `astro`, `gatsby`
- Vite config exists: `vite.config.*`

**Frontend root directory selection** (choose the first match):

1. Current directory contains `package.json` + `scripts.build`
2. `web/package.json` + `scripts.build`
3. `frontend/package.json` + `scripts.build`
4. Ask only if still ambiguous (rare)

## Step 4 — Decide whether a database is needed, and provision it if so

### Detect “needs DB” (any is enough)

- The project references `DATABASE_URL`, `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `PG*`, etc. (in `.env*`, source, or configs)
- Dependencies suggest Postgres/ORM usage: `pg`, `pgx`, `lib/pq`, `gorm`, `prisma`, `sequelize`, `typeorm`, `drizzle`
- Existing `.env.example` indicates DB variables

### If DB is needed

Run:

```bash
easylaunch-cli get-database --app-id <appId> --format env
```

Parse the output into env pairs and use them as follows:

- Prefer passing env to backend deployment via repeated `--env KEY=VAL`
- Include at least `DATABASE_URL`, plus split fields if present (e.g. `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`)

Avoid writing secrets into git-tracked files by default.

## Step 5 — If project is containerized backend: ensure a `Dockerfile`, then build & push image

### If there is no `Dockerfile`

Create one in the backend root directory.

Pick the template based on detected backend type:

- **Go**: multi-stage build (`golang` builder → runtime), run the compiled binary. Prefer a small runtime image.
  - Typical shape:
    - builder: `golang:1.22` + `go mod download` + `go build -o /out/app`
    - runtime: `gcr.io/distroless/base-debian12` or `alpine:3.20`
    - `EXPOSE <port>` when known
    - `CMD [\"/app\"]`
- **Node**: `node:20-alpine`, install deps, build if needed, and run the server.
  - Prefer `npm ci` when `package-lock.json` exists
  - If there is a build step, run `npm run build` then start with `npm run start`
  - Set `NODE_ENV=production`
  - `EXPOSE <port>` when known

Also add a minimal `.dockerignore` if missing (e.g. `node_modules`, `.git`, `dist`, `build`, `.env*`).

### Common build-failure fixes (apply then retry)

- **COPY path errors**: adjust `COPY` lines to match the chosen build context directory
- **Missing lockfile / wrong install**: switch between `npm ci` and `npm install` based on presence of lockfile
- **Native deps**: prefer `alpine` + needed build tools in builder stage, or use a `debian`-based Node image if alpine musl causes issues
- **Go module download failures**: ensure `go.mod`/`go.sum` are copied before the rest to leverage caching
- **Wrong start command**: ensure the container `CMD` matches actual entrypoint (`npm run start`, `node dist/server.js`, etc.)

### Build and push (retry until success)

Use a default tag: **`YYYYMMDDHHMMSS`** (local time).

Run from the backend root directory (so `--dir` is not needed):

```bash
easylaunch-cli build-image --app-id <appId> --tag "$(date +%Y%m%d%H%M%S)" --wait
```

If you are not in the backend root directory, add `--dir <backend-root>`.

On failure:

- Read the error output (often points to missing files, wrong workdir, missing build step, or `COPY` paths)
- Apply a concrete fix (Dockerfile / .dockerignore / build context / entrypoint)
- Retry the build

Stop only once build succeeds and you have the printed line:

- `Image URL: ...`

## Step 6 — Deploy backend (retry until success)

Infer `--port` from the backend:

1. `Dockerfile` (`EXPOSE`, `ENV PORT`)
2. compose files (`docker-compose.yml` / `compose.yaml`)
3. server source code bindings

Run:

```bash
easylaunch-cli deploy-backend \
  --app-id <appId> \
  --image-url "<Image URL>" \
  --port <inferred-port> \
  --env DATABASE_URL=... \
  --env DB_HOST=... \
  --wait
```

If deployment fails:

- Fix the cause (port mismatch, missing env, app crashes on boot)
- Retry `deploy-backend` until it succeeds

Capture:

- Backend `Service URL: ...`

## Step 7 — If project is static frontend: deploy frontend (retry until success)

Only run this step if **no Dockerfile exists** (static site deployment).

Run from the frontend root directory so `--dir` is not needed:

```bash
easylaunch-cli deploy-frontend --app-id <appId> --wait
```

If running from elsewhere, add `--dir <frontend-root>`.

Auto-detect build parameters:

- `--build-cmd`: prefer `scripts.build` from `package.json`; otherwise use `npm run build`
- `--output-dir`: infer from framework config; otherwise use `dist`

On failure:

- Fix the cause (install/build command mismatch, wrong output dir, missing env at build time)
- Retry `deploy-frontend` until it succeeds

Capture:

- Frontend `Service URL: ...`

## Step 8 — Final output (always show)

At the end, present:

- **Service URL** (backend or frontend, depending on project type)
- **Image URL** (if containerized backend was built)
