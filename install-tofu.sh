#!/usr/bin/env bash
# CloudShell does not ship OpenTofu. Install a pinned release into ~/.local/bin
# (CloudShell keeps $HOME between sessions).
set -u
version="${TOFU_VERSION:-1.13.1}"
bin_dir="${BIN_DIR:-$HOME/.local/bin}"
case "$(uname -m)" in
  x86_64) arch=amd64 ;;
  aarch64|arm64) arch=arm64 ;;
  *) echo "unsupported arch $(uname -m)" >&2; exit 1 ;;
esac
mkdir -p "$bin_dir" || exit 1
curl -fsSL -o /tmp/tofu.zip \
  "https://github.com/opentofu/opentofu/releases/download/v${version}/tofu_${version}_linux_${arch}.zip" || exit 1
unzip -o -q /tmp/tofu.zip tofu -d "$bin_dir" || exit 1
rm -f /tmp/tofu.zip
"$bin_dir/tofu" version
case ":$PATH:" in *":$bin_dir:"*) ;; *) echo "Add to PATH: export PATH=\"$bin_dir:\$PATH\"" ;; esac
