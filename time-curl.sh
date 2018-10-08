#!/bin/bash

set -euo pipefail

while true; do
  echo starting...
  (/usr/bin/time curl -sk https://127.0.0.1:61001 2>&1 1>/dev/null) | grep real
  echo done.
  sleep 0.7
done
