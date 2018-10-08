#!/bin/bash

set -euo pipefail

docker run --rm -it --network=container:sidecar \
  netstat /bin/bash -c "watch -n0.5 'nc -vz 127.0.0.1 61001'"

