#!/usr/bin/env bash
# Create the private bucket, OAC, CloudFront distribution and bucket policy.
# CloudFront takes several minutes to deploy; OpenTofu prints progress while it waits.
set -u
cd "$(dirname "$0")" || exit 1
export PATH="$HOME/.local/bin:$PATH"
export AWS_REGION="${AWS_REGION:-us-east-2}"
export AWS_DEFAULT_REGION="$AWS_REGION"
command -v tofu >/dev/null || { echo "tofu not found; run ./install-tofu.sh" >&2; exit 1; }

tofu init -input=false || exit 1
tofu apply -input=false -auto-approve -var "region=$AWS_REGION" || exit 1
tofu output
echo "Next: ./verify.sh"
