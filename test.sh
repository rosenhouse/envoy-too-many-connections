#!/bin/bash

set -euo pipefail

# docker pull envoyproxy/envoy
# docker pull citizenstig/httpbin
# docker pull byrnedo/alpine-curl
# docker build -t netstat - < netstat.Dockerfile

echo "launching envoy proxy"
docker run -d --rm -it --name sidecar_proxy \
  -it -v $PWD/envoy_config:/etc/cf-assets/envoy_config \
  -p 61001:61001 \
  envoyproxy/envoy \
    envoy -c /etc/cf-assets/envoy_config/envoy.yaml \
     --service-cluster proxy-cluster --service-node "foo" \
     --drain-time-s 10 --log-level info

echo "launching app, listening on port 8080 in same netns"
docker run -d --rm -it --name app_container \
  --network=container:sidecar_proxy \
  citizenstig/httpbin \
  gunicorn --bind=127.0.0.1:8080 httpbin:app

echo waiting for proxy and app to boot
sleep 5

echo client does an HTTPS request via the proxy
curl -sv 127.0.0.1:61001 > /dev/null

echo "quick open/close of TCP port"
nc -vz 127.0.0.1 61001
nc -vz 127.0.0.1 61001
nc -vz 127.0.0.1 61001

docker run --rm --network=container:sidecar_proxy \
  netstat /bin/bash -c "netstat -anp | grep 8080"

echo client does an HTTPS request via the proxy
curl -sv 127.0.0.1:61001 > /dev/null

echo success

docker logs sidecar_proxy
read -p "Press enter to continue"

docker rm -f sidecar_proxy
docker rm -f app_container
