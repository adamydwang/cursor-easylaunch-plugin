---
name: easylaunch-cli
description: Install or update the EasyLaunch CLI for the current machine (downloads the correct binary from OSS; use before other easylaunch-* skills).
---

# EasyLaunch CLI (install / update)

Use this skill **before** running any **`easylaunch-*`** workflow skill when the CLI might be missing or outdated. Skills **do not** bundle OS-specific binaries; one plugin works on all supported platforms.

## Download URL (authoritative)

Base:

`https://little-two-packages.oss-cn-hongkong.aliyuncs.com/cli/{platform}/easylaunch-cli`

Replace `{platform}` with one of:

| `platform`     | Typical machine                          |
|----------------|------------------------------------------|
| `darwin-arm64` | Apple Silicon macOS                      |
| `darwin-amd64` | Intel macOS                              |
| `linux-arm64`  | Linux aarch64                            |
| `linux-amd64`  | Linux x86_64                             |
| `windows-amd64`| 64-bit Windows (x64 or arm64 host)      |

## Recommended: bundled ensure script

From the **plugin repository root** (the folder that contains the `scripts/` directory—this is what you publish to Git / install from the marketplace):

**macOS / Linux (no Node required):**

```bash
bash scripts/ensure-easylaunch-cli.sh
```

**Windows (PowerShell, no Node required):**

```bash
powershell -ExecutionPolicy Bypass -File scripts/ensure-easylaunch-cli.ps1
```

After a **Cursor plugin install**, run the same command from the plugin’s on-disk root (where `.cursor-plugin/plugin.json` lives).

The script downloads into:

- **macOS / Linux:** `~/.easylaunch/bin/easylaunch-cli`
- **Windows:** `%USERPROFILE%\.easylaunch\bin\easylaunch-cli.exe`

It prints an **`export EASYLAUNCH_CLI=...`** (Unix) or PowerShell **`$env:EASYLAUNCH_CLI = ...`** line you can reuse in the same shell session.

## Manual download (examples)

**macOS Apple Silicon:**

```bash
mkdir -p ~/.easylaunch/bin
curl -fsSL "https://little-two-packages.oss-cn-hongkong.aliyuncs.com/cli/darwin-arm64/easylaunch-cli" -o ~/.easylaunch/bin/easylaunch-cli
chmod +x ~/.easylaunch/bin/easylaunch-cli
export EASYLAUNCH_CLI="$HOME/.easylaunch/bin/easylaunch-cli"
```

**Linux x86_64:**

```bash
mkdir -p ~/.easylaunch/bin
curl -fsSL "https://little-two-packages.oss-cn-hongkong.aliyuncs.com/cli/linux-amd64/easylaunch-cli" -o ~/.easylaunch/bin/easylaunch-cli
chmod +x ~/.easylaunch/bin/easylaunch-cli
export EASYLAUNCH_CLI="$HOME/.easylaunch/bin/easylaunch-cli"
```

**Windows (PowerShell, x64):**

```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.easylaunch\bin" | Out-Null
Invoke-WebRequest "https://little-two-packages.oss-cn-hongkong.aliyuncs.com/cli/windows-amd64/easylaunch-cli" -OutFile "$env:USERPROFILE\.easylaunch\bin\easylaunch-cli.exe"
$env:EASYLAUNCH_CLI = "$env:USERPROFILE\.easylaunch\bin\easylaunch-cli.exe"
```

## How agents should invoke the CLI

Prefer, in order:

1. **`$EASYLAUNCH_CLI`** (if set) — e.g. `"$EASYLAUNCH_CLI" version`
2. **`easylaunch-cli`** on **`PATH`**
3. Explicit path: `~/.easylaunch/bin/easylaunch-cli` (Unix) or `%USERPROFILE%\.easylaunch\bin\easylaunch-cli.exe` (Windows)

In documentation below, **`easylaunch-cli`** means whichever resolved executable above.

## Authentication

After installation, run any command that needs an account (or optionally `easylaunch-cli login` first). The CLI **detects whether you are logged in**; if not, it **prompts interactively** for your username/email and password. No separate API endpoint setup is required.

## Related skills

- `easylaunch-build-push-image`, `easylaunch-deploy-backend`, `easylaunch-deploy-frontend`, `easylaunch-create-or-get-database`
