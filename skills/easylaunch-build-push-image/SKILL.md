---
name: easylaunch-build-push-image
description: Build a Docker image on EasyLaunch (cloud pipeline) and push to Docker Hub
---

# Build / Push Image (EasyLaunch)

Package a backend (or any directory with a `Dockerfile`), upload it, and trigger a cloud build that pushes the image to Docker Hub.

## Parameter sourcing (agent)

- **`--app-id`**: User-supplied. Reuse from conversation or trustworthy project context; **do not invent**. **Ask only** if still unknown.
- **`--dir`**: Default to the user’s **project path** (the current working directory where the command is run). Only set `--dir` explicitly when the `Dockerfile` is in a subdirectory like `api/` or `backend/`.
- **`--tag`**: Default to a timestamp string in **`YYYYMMDDHHMMSS`** (local time) so the user does not need to specify a tag. Only ask for a tag when the user explicitly requests a specific one (e.g. `v1`, `prod`, `release-2026q2`).
- **Handoff to deploy**: On success the CLI prints **`Image URL: ...`**. Preserve that value **exactly** for `easylaunch-deploy-backend` (`deploy-backend --image-url`); the next skill should not guess the URL from `app-id` + tag when this output exists.

**Minimize questions:** prefer reading the repo and conversation over prompting.

## CLI name and blocking until completion

The command-line tool is **`easylaunch-cli`**. For `build-image`, **always pass `--wait`**: the process stays running and only exits after the cloud build **succeeds or fails** (non-zero on failure).

## Obtain the EasyLaunch CLI (cross-platform)

Skills **do not** ship OS-specific binaries. Before first use, run **`easylaunch-cli`** (skill) or:

**macOS / Linux:**

`bash scripts/ensure-easylaunch-cli.sh`

**Windows (PowerShell):**

`powershell -ExecutionPolicy Bypass -File scripts/ensure-easylaunch-cli.ps1`

Then invoke with **`$EASYLAUNCH_CLI`**, **`PATH`**, or `~/.easylaunch/bin/easylaunch-cli` / `%USERPROFILE%\.easylaunch\bin\easylaunch-cli.exe`. See **`easylaunch-cli`** for download URLs and manual `curl`/PowerShell examples.

## Authentication

Commands that require an account check login first. If you are not signed in, **`easylaunch-cli` interactively prompts for your username/email and password**—no extra endpoint or config step. Running `easylaunch-cli login` up front is optional.

## Linux deployment note (Dockerfile / Windows scripts)

EasyLaunch backend deployments run in a **Linux container**.

If the current project **is not a static site** and needs a server process, but:

- there is **no `Dockerfile`**, or
- the provided start script is **Windows-only** (e.g. `.ps1`, `.bat`, `powershell`, `cmd.exe`, or `set VAR=... &&`),

then you must prepare Linux-compatible artifacts before building:

- **Create a `Dockerfile`** in the backend root directory.
- **Create `scripts/start.sh`** (Linux/posix) as the equivalent startup entrypoint, and have the container use it.

### Windows-only start script indicators

- `package.json` `scripts.start` / `scripts.dev` contains: `powershell`, `cmd.exe`, `*.ps1`, `*.bat`, `set VAR=... &&`
- Repository includes only `start.ps1` / `start.bat` and no Linux alternative

### `scripts/start.sh` contract

- Must run on Linux (POSIX shell) and be executable: `chmod +x scripts/start.sh`
- Must start the server in the **foreground** (no daemonizing)
- Use POSIX env syntax (e.g. `export KEY=value`)

Minimal example (Node):

```bash
#!/usr/bin/env bash
set -euo pipefail

exec npm run start
```

In the Dockerfile, use it as the entrypoint:

```dockerfile
COPY scripts/start.sh /app/scripts/start.sh
RUN chmod +x /app/scripts/start.sh
CMD [\"bash\", \"/app/scripts/start.sh\"]
```

Run **`build-image`** from the directory that contains your `api/` (or other build context)—the CLI uploads that path.

Below, **`easylaunch-cli`** means that installed binary (same flags).

## Command: `easylaunch-cli build-image`

| Flag | Required | Description |
|------|----------|-------------|
| `--app-id` | Yes | Application ID |
| `--tag` | Yes | Image tag (recommend default: `YYYYMMDDHHMMSS`) |
| `--dir` | No | Source directory, default current directory (project root) |
| `--wait` | **Always** | Block until the build finishes (success or failure); **include in every run** |

Example (recommended defaults: current directory as build context + timestamp tag):

```bash
easylaunch-cli build-image --app-id <appId> --tag "$(date +%Y%m%d%H%M%S)" --wait
```

## Flow (high level)

1. Zip the project and upload to object storage.
2. Cloud pipeline: fetch sources, build from `Dockerfile`, push to `docker.io/aimoscloud/easylaunch-<appId>:<tag>`.

## Success output (with `--wait`)

When the build succeeds and `--wait` completes, the CLI prints:

- `Image URL: docker.io/aimoscloud/easylaunch-<appId>:<tag>`

At start it also prints `Build started (task: <uuid>)`; keep that task id for troubleshooting.

## Troubleshooting

- Poll the task: `easylaunch-cli status --task-id <task-id>` (`status` returns immediately with the current state).
- On failure, `error_message` may include a tail of pipeline logs (`log_tail`) to help debug Dockerfile or build errors.

## Next steps

Deploy the backend with the **exact** printed **`Image URL`**; see **`easylaunch-deploy-backend`**. Do not substitute a reconstructed `docker.io/...` string when you already have the CLI output line.

Recommended sequence; **both commands use `--wait`**; **infer `--port` from the Dockerfile** (or code) when running `deploy-backend`:

```bash
easylaunch-cli build-image --app-id <appId> --tag "$(date +%Y%m%d%H%M%S)" --wait
easylaunch-cli deploy-backend --app-id <appId> --image-url "<Image URL from previous command>" --port <inferred-port> --wait
```

## Related skills

- `easylaunch-cli`: install the CLI
- `easylaunch-deploy-backend`: deploy using the printed image URL
