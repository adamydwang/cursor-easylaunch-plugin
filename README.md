# EasyLaunch (Cursor plugin)

Agent skills for deploying frontends and backends on [EasyLaunch](https://easylaunch.online). The plugin **does not** bundle OS-specific CLI binaries; run `scripts/ensure-easylaunch-cli.mjs` (Node 18+) or follow the **`easylaunch-cli`** skill to download the correct build from:

`https://little-two-packages.oss-cn-hongkong.aliyuncs.com/cli/<platform>/easylaunch-cli`

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
