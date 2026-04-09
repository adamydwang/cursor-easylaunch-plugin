#!/usr/bin/env node
/**
 * Downloads the EasyLaunch CLI for the current OS/arch into ~/.easylaunch/bin/
 * and prints the resolved executable path (and env hints).
 *
 * Base: https://little-two-packages.oss-cn-hongkong.aliyuncs.com/cli/<platform>/easylaunch-cli
 */

import { chmod, mkdir, rename, unlink } from "node:fs/promises";
import { createWriteStream } from "node:fs";
import { homedir, tmpdir } from "node:os";
import path from "node:path";
import { pipeline } from "node:stream/promises";
import { Readable } from "node:stream";

const BASE =
  "https://little-two-packages.oss-cn-hongkong.aliyuncs.com/cli";

/** @returns {string} */
function platformSlug() {
  const plat = process.platform;
  const arch = process.arch;

  if (plat === "darwin") {
    if (arch === "arm64") return "darwin-arm64";
    if (arch === "x64") return "darwin-amd64";
  }
  if (plat === "linux") {
    if (arch === "arm64") return "linux-arm64";
    if (arch === "x64") return "linux-amd64";
  }
  if (plat === "win32") {
    if (arch === "x64" || arch === "arm64") return "windows-amd64";
  }

  throw new Error(
    `Unsupported platform: ${plat}/${arch}. Supported: darwin-amd64, darwin-arm64, linux-amd64, linux-arm64, windows-amd64`,
  );
}

function cliInstallDir() {
  const home =
    process.platform === "win32" && process.env.USERPROFILE
      ? process.env.USERPROFILE
      : process.env.HOME || homedir();
  return path.join(home, ".easylaunch", "bin");
}

/** @param {string} dest */
async function downloadTo(url, dest) {
  const res = await fetch(url);
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(
      `Download failed: ${res.status} ${res.statusText} ${url}${text ? `\n${text.slice(0, 500)}` : ""}`,
    );
  }
  if (!res.body) throw new Error(`No response body for ${url}`);

  await mkdir(path.dirname(dest), { recursive: true });
  const tmp = path.join(
    tmpdir(),
    `easylaunch-cli-${Date.now()}-${Math.random().toString(36).slice(2)}.tmp`,
  );
  try {
    const out = createWriteStream(tmp, { mode: 0o600 });
    await pipeline(Readable.fromWeb(/** @type {import('stream/web').ReadableStream} */ (res.body)), out);
    await rename(tmp, dest);
  } catch (e) {
    await unlink(tmp).catch(() => {});
    throw e;
  }
}

async function main() {
  const slug = platformSlug();
  const url = `${BASE}/${slug}/easylaunch-cli`;
  const dir = cliInstallDir();
  const baseName =
    process.platform === "win32" ? "easylaunch-cli.exe" : "easylaunch-cli";
  const dest = path.join(dir, baseName);

  try {
    await downloadTo(url, dest);
  } catch (err) {
    console.error(String(err));
    process.exitCode = 1;
    return;
  }

  if (process.platform !== "win32") {
    await chmod(dest, 0o755);
  }

  process.stdout.write(`EasyLaunch CLI installed at:\n${dest}\n`);
  if (process.platform === "win32") {
    process.stdout.write(
      `\nPowerShell (current session):\n  $env:EASYLAUNCH_CLI = "${dest.replace(/\\/g, "\\\\")}"\n`,
    );
  } else {
    process.stdout.write(`\nexport EASYLAUNCH_CLI="${dest}"\n`);
  }
}

main();
