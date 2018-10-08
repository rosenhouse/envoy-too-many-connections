#!/bin/bash

set -euo pipefail

docker run --rm -it --network=container:sidecar \
  netstat /bin/bash -c "watch -n0.5 'netstat -anp | grep 8080 | grep ESTAB'"

