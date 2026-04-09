---
name: easylaunch-deploy-backend
description: Deploy a backend on EasyLaunch using an existing Docker image (--image-url)
---

# Deploy Backend (EasyLaunch)

Deploy a backend from an **image that is already built** (**no source upload** for this step).

## Parameter sourcing (agent)

- **`--app-id`**: User-supplied. Reuse it if it already appears in the conversation or in trustworthy project context; **ask only** if it is still unknown after that.
- **`--image-url`**: When `build-image` completed in this session, use the **`Image URL:`** line from that output **verbatim**. Do **not** rebuild the URL from `app-id` + tag unless there is **no** build output and the user has **explicitly** confirmed which image to deploy.
- **`--port`**: Infer from the workspace (ideally the **same** source tree that was built). Order: **`Dockerfile`** (`EXPOSE`, `ENV PORT`, `ARG`), **`docker-compose.yml`** / **`compose.yaml`**, then server code (e.g. `ListenAndServe(":8080"...)`, `process.env.PORT`). Only then use stack heuristics (e.g. many Go APIs **8080**, some Node stacks **3000**). Do **not** ask the user if the port is clear from files.
- **`--env`**: From `get-database --format env` output, repo `.env` / deployment docs, or secrets the user already provided—emit repeated `--env KEY=VAL` without re-prompting when values exist.

**Minimize questions:** prefer reading the repo and prior CLI/terminal output over asking.

The CLI requires `--image-url` for this command.

## CLI name and blocking until completion

The command-line tool is **`easylaunch-cli`**. For `deploy-backend`, **always pass `--wait`**: the process stays running and only exits after the cloud deployment **succeeds or fails**.

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

## Command: `easylaunch-cli deploy-backend`

| Flag | Required | Description |
|------|----------|-------------|
| `--app-id` | Yes | Application ID |
| `--image-url` | Yes | Full image reference, e.g. `docker.io/aimoscloud/easylaunch-<appId>:<tag>` |
| `--port` | No | Port the process listens on inside the container, default `8080` (**must match the app**) |
| `--env` | No | Environment variables; repeat: `--env KEY=VAL` |
| `--wait` | **Always** | Block until deployment finishes (success or failure); **include in every run** |

**There is no `--tag` flag** for this command: put the tag inside `--image-url`.

### Ports (same as docs)

- This repository’s **`api/Dockerfile`**: commonly **8080**
- **one-api**-style images: commonly **3000**

A port mismatch vs FC custom container settings can break gateway access.

## Restrictions

- Apps with **`app_type=frontend`** cannot deploy a backend (API returns **400**).

## Recommended workflow (build + deploy)

Default path: run **`easylaunch-build-push-image`** (`build-image`) first; on success, copy the **`Image URL:`** value **exactly** into `deploy-backend --image-url`. Set **`--port` from the Dockerfile** (or fallbacks above), not from habit. **Use `--wait` on both commands** so each exits only when that step completes:

```bash
easylaunch-cli build-image --app-id <appId> --tag "$(date +%Y%m%d%H%M%S)" --wait
# On success, use the printed line verbatim, e.g. Image URL: docker.io/aimoscloud/easylaunch-<appId>:<tag>

easylaunch-cli deploy-backend \
  --app-id <appId> \
  --image-url "<paste Image URL from build output>" \
  --port <port-from-dockerfile-or-code> \
  --wait
```

With database env vars (illustrative): run `get-database --format env` first when you need DSN lines, then pass them via `--env` without re-asking:

```bash
easylaunch-cli deploy-backend \
  --app-id <appId> \
  --image-url "<from build-image output>" \
  --port <inferred-port> \
  --env DATABASE_URL=postgres://... \
  --env NODE_ENV=production \
  --wait
```

## Success output (with `--wait`)

The CLI prints:

- **`Service URL`**: backend HTTPS URL (docs show `https://...`)

Hostname rules depend on **`app_type`**:

- `app_type=fullstack`: `https://<appId>-api.<dns-domain>`
- `app_type=backend`: `https://<appId>.<dns-domain>`

## Troubleshooting

```bash
easylaunch-cli status --task-id <task-id>
```

(`status` returns immediately with the current task state.)

After deploy, confirm public marketing endpoints return JSON (not nginx `404 page not found` text), e.g. `curl -sS -i "https://<Service URL>/api/v1/public/plans"` should be **HTTP 200** and `Content-Type: application/json`. If this 404s while `/api/v1/auth/login` works, the running image is missing the route—rebuild from current `api/` and redeploy.

## Image naming (`--image-url`)

Cloud builds push to the form:

`docker.io/aimoscloud/easylaunch-<appId>:<tag>`

Agents should still prefer the **`Image URL:`** line from **`build-image`** output over reconstructing this string manually.

## Related skills

- `easylaunch-cli`: install the CLI
- `easylaunch-build-push-image`: produce the `Image URL` (use **`--wait`**)
- `easylaunch-create-or-get-database`: obtain DSN for `--env DATABASE_URL=...`
