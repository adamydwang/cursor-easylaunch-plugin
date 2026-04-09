#!/usr/bin/env bash
set -euo pipefail

BASE="https://little-two-packages.oss-cn-hongkong.aliyuncs.com/cli"

os="$(uname -s | tr '[:upper:]' '[:lower:]')"
arch="$(uname -m)"

case "$os" in
  darwin) os="darwin" ;;
  linux) os="linux" ;;
  *)
    echo "Unsupported OS: $os" >&2
    exit 1
    ;;
esac

case "$arch" in
  arm64|aarch64) arch="arm64" ;;
  x86_64|amd64) arch="amd64" ;;
  *)
    echo "Unsupported arch: $arch" >&2
    exit 1
    ;;
esac

platform="${os}-${arch}"
url="${BASE}/${platform}/easylaunch-cli"

dest_dir="${HOME}/.easylaunch/bin"
dest="${dest_dir}/easylaunch-cli"

mkdir -p "${dest_dir}"
tmp="${dest}.tmp.$$"

if command -v curl >/dev/null 2>&1; then
  curl -fsSL "${url}" -o "${tmp}"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "${tmp}" "${url}"
else
  echo "Need curl or wget to download ${url}" >&2
  exit 1
fi

chmod +x "${tmp}"
mv "${tmp}" "${dest}"

echo "EasyLaunch CLI installed at:"
echo "${dest}"
echo ""
echo "export EASYLAUNCH_CLI=\"${dest}\""
