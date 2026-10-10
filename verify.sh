#!/usr/bin/env bash
# Expect: direct bucket URL -> 403, CloudFront URL -> 200.
# Retries for up to VERIFY_MINUTES (default 20) while CloudFront finishes deploying.
set -u
cd "$(dirname "$0")" || exit 1
export PATH="$HOME/.local/bin:$PATH"

CF=$(tofu output -raw cloudfront_domain 2>/dev/null) || { echo "No outputs; run ./deploy.sh" >&2; exit 1; }
BUCKET=$(tofu output -raw bucket_regional_domain)
deadline=$(( $(date +%s) + ${VERIFY_MINUTES:-20} * 60 ))

check() {  # check URL EXPECTED_CODE
  local url="$1" want="$2" got
  while true; do
    got=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 "$url")
    if [ "$got" = "$want" ]; then
      printf 'PASS  %-3s  %s\n' "$got" "$url"
      return 0
    fi
    if [ "$(date +%s)" -ge "$deadline" ]; then
      printf 'FAIL  got %s want %s  %s\n' "$got" "$want" "$url"
      return 1
    fi
    echo "  ... $url returned $got (want $want); retrying in 30s"
    sleep 30
  done
}

rc=0
check "https://$BUCKET/index.html" 403 || rc=1
check "https://$CF/" 200 || rc=1
check "https://$CF/index.html" 200 || rc=1
if [ "$rc" -eq 0 ]; then echo "VERIFY OK: bucket is private, CloudFront serves the page"; else echo "VERIFY FAILED"; fi
exit "$rc"
