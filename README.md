# EasyLaunch (Cursor plugin)

Agent skills for deploying frontends and backends on [EasyLaunch](https://easylaunch.online). The plugin **does not** bundle OS-specific CLI binaries; use the bundled ensure scripts (recommended) or follow the **`easylaunch-cli`** skill to download the correct build from OSS:

`https://little-two-packages.oss-cn-hongkong.aliyuncs.com/cli/<platform>/easylaunch-cli`

Windows uses an `.exe` filename:

`https://little-two-packages.oss-cn-hongkong.aliyuncs.com/cli/windows-amd64/easylaunch-cli.exe`

### Install / update the CLI (recommended)

- **macOS / Linux:**

`bash scripts/ensure-easylaunch-cli.sh`

- **Windows (PowerShell):**

`powershell -ExecutionPolicy Bypass -File scripts/ensure-easylaunch-cli.ps1`

## Local test

1. Symlink or copy this folder to `~/.cursor/plugins/local/easylaunch` so it contains `.cursor-plugin/plugin.json` at the plugin root.
2. Reload Cursor; enable skills under Rules / Agent settings.

## Skills

| Skill | Purpose |
|-------|---------|
| `easylaunch-cli` | Install or update the CLI |
| `easylaunch-deploy-all` | Deploy frontend/backend/fullstack end-to-end |
| `easylaunch-build-push-image` | Cloud Docker build + push |
| `easylaunch-deploy-backend` | Deploy a container image |
| `easylaunch-deploy-frontend` | Deploy a static frontend |
| `easylaunch-create-or-get-database` | Postgres get-or-create |

## Publish

Treat this folder as the **root of the Git repository** you publish to GitHub and submit to Cursor (single-plugin layout): the repo should contain `.cursor-plugin/plugin.json`, `skills/`, `scripts/`, etc. **Do not** require a parent monorepo or a root `marketplace.json`. See [cursor/plugin-template](https://github.com/cursor/plugin-template) (“single plugin vs multi-plugin”) and [Cursor plugin docs](https://cursor.com/docs/plugins.md).
