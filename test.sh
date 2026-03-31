#!/bin/bash

BASE_URL="http://localhost"
PATHS=("/ok" "/forbidden" "/unprocessable")

echo "=========================================="
echo " Sending requests to all scenarios"
echo "=========================================="
echo ""

for scenario in before after for-error-tracking; do
  case $scenario in
    before)             port=4001 ;;
    after)              port=4002 ;;
    for-error-tracking) port=4003 ;;
  esac
  echo "--- app-${scenario} (port ${port}) ---"

  for path in "${PATHS[@]}"; do
    http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "${BASE_URL}:${port}${path}" 2>/dev/null || echo "FAILED")
    echo "  GET ${path}  →  HTTP ${http_code}"
  done

  echo ""
done

echo "=========================================="
echo " Expected span behavior:"
echo ""
echo " before (default, no DD_TRACE_HTTP_SERVER_ERROR_STATUSES):"
echo "   /forbidden (403):     span.status=0 → APM error ❌  Error Tracking ❌"
echo "   /unprocessable (422): span.status=0 → APM error ❌  Error Tracking ❌"
echo ""
echo " after (DD_TRACE_HTTP_SERVER_ERROR_STATUSES=403,422,500-599):"
echo "   /forbidden (403):     span.status=1 → APM error ✅  Error Tracking ❌"
echo "   /unprocessable (422): span.status=1 → APM error ✅  Error Tracking ❌"
echo ""
echo " for-error-tracking (env var + error.type / error.message / error.stack):"
echo "   /forbidden (403):     span.status=1 + error tags → APM error ✅  Error Tracking ✅"
echo "   /unprocessable (422): span.status=1 + error tags → APM error ✅  Error Tracking ✅"
echo "=========================================="
