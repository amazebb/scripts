#!/usr/bin/env bash
# Run every tests/test_*.sh; exit non-zero if any fail

cd "$(dirname "$0")" || exit 1
rc=0
for f in test_*.sh; do
  bash "$f" || rc=1
done
exit $rc
