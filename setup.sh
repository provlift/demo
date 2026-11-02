#!/usr/bin/env sh
# Downloads the providers and modules each root module needs, so that
# `provlift check` can see the shared module's ceiling. The lock files are
# already committed at old versions; this script does not change them.
set -eu
cd "$(dirname "$0")"

# Share provider downloads between roots; the AWS provider alone is large.
export TF_PLUGIN_CACHE_DIR="${TF_PLUGIN_CACHE_DIR:-$HOME/.terraform.d/plugin-cache}"
mkdir -p "$TF_PLUGIN_CACHE_DIR"

# envs/kubernetes is skipped on purpose so `provlift drift` reports its
# missing lock file.
for root in envs/aws-prod envs/aws-stage envs/azure envs/gcp envs/github; do
  echo "terraform init $root"
  terraform -chdir="$root" init -backend=false -input=false -no-color >/dev/null
done

if command -v tofu >/dev/null 2>&1; then
  echo "tofu init opentofu/platform"
  tofu -chdir=opentofu/platform init -backend=false -input=false -no-color >/dev/null
else
  echo "warning: tofu is not on PATH; skipping the OpenTofu stack." >&2
fi

echo "Ready. Reset between runs with: git checkout . && git clean -fd"
