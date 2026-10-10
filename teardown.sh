#!/usr/bin/env bash
# Empty the bucket (all versions), destroy everything, then prove nothing is left.
set -u
cd "$(dirname "$0")" || exit 1
export PATH="$HOME/.local/bin:$PATH"
export AWS_REGION="${AWS_REGION:-us-east-2}"
export AWS_DEFAULT_REGION="$AWS_REGION"
. lib/s3.sh
rc=0

BUCKET=$(tofu output -raw bucket_name 2>/dev/null)
DIST_ID=$(tofu output -raw distribution_id 2>/dev/null)
if [ -n "$BUCKET" ]; then
  echo "== empty bucket first"
  empty_bucket "$BUCKET" || rc=1
else
  echo "no bucket in state (nothing deployed, or already destroyed)"
fi

echo "== tofu destroy (CloudFront must disable before delete; this takes several minutes)"
tofu destroy -input=false -auto-approve -var "region=$AWS_REGION" || rc=1

echo "== verify nothing is left"
left=$(tofu state list 2>/dev/null | wc -l | tr -d ' ')
if [ "$left" = "0" ]; then echo "  ok: tofu state is empty"; else echo "  LEFTOVER: $left resources in state" >&2; tofu state list; rc=1; fi
if [ -n "$BUCKET" ]; then bucket_gone "$BUCKET" || rc=1; fi
if [ -n "$DIST_ID" ]; then
  if aws cloudfront get-distribution --id "$DIST_ID" >/dev/null 2>&1; then
    echo "  LEFTOVER: distribution $DIST_ID" >&2; rc=1
  else
    echo "  ok: distribution $DIST_ID is gone"
  fi
fi
oac=$(aws cloudfront list-origin-access-controls \
  --query "OriginAccessControlList.Items[?Name=='static-site-demo-oac'].Id" --output text)
if [ -z "$oac" ] || [ "$oac" = "None" ]; then echo "  ok: no static-site-demo-oac"; else echo "  LEFTOVER: OAC $oac" >&2; rc=1; fi
if [ "$rc" -eq 0 ]; then echo "TEARDOWN OK"; else echo "TEARDOWN INCOMPLETE (see LEFTOVER lines)"; fi
exit "$rc"
