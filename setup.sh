#!/bin/bash

set -euo pipefail

echo pulling and building containers
docker pull envoyproxy/envoy
docker pull byrnedo/alpine-curl
docker pull python:2
docker build -t netstat - < netstat.Dockerfile


echo cleaning up from last run
docker rm -f app sidecar || true

echo "launching envoy proxy"
docker run -d --rm -it --name sidecar \
  -it -v $PWD/envoy_config:/etc/cf-assets/envoy_config \
  -p 61001:61001 \
  envoyproxy/envoy \
    envoy -c /etc/cf-assets/envoy_config/envoy.yaml \
     --service-cluster proxy-cluster --service-node "foo" \
     --drain-time-s 10 --log-level info

echo "launching app, listening on port 8080 in same netns"
docker run -d --rm -it --name app \
  --network=container:sidecar \
  -v $PWD:/src \
  python:2 \
  python /src/server.py 8080

echo waiting for proxy and app to boot
sleep 5

echo client does an https request via the proxy
curl -ksv https://127.0.0.1:61001 > /dev/null

read -p "Running.  Press enter to stop"

docker rm -f sidecar
docker rm -f app
