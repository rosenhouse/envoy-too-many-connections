#!/bin/bash

set -euo pipefail

# docker pull envoyproxy/envoy
# docker pull citizenstig/httpbin
# docker pull byrnedo/alpine-curl
# docker pull python:2
# docker build -t netstat - < netstat.Dockerfile

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

echo client does an HTTP request via the proxy
curl -sv http://127.0.0.1:61001 > /dev/null

echo "quick open/close of TCP port"
docker run --rm --network=container:sidecar netstat /bin/bash -c "nc -vz 127.0.0.1 61001"
docker run --rm --network=container:sidecar netstat /bin/bash -c "nc -vz 127.0.0.1 61001"
docker run --rm --network=container:sidecar netstat /bin/bash -c "nc -vz 127.0.0.1 61001"
docker run --rm --network=container:sidecar netstat /bin/bash -c "nc -vz 127.0.0.1 61001"

docker run --rm --network=container:sidecar \
  netstat /bin/bash -c "netstat -anp | grep 8080"

docker run --rm --network=container:sidecar netstat /bin/bash -c "nc -vz 127.0.0.1 61001"
docker run --rm --network=container:sidecar netstat /bin/bash -c "nc -vz 127.0.0.1 61001"
docker run --rm --network=container:sidecar netstat /bin/bash -c "nc -vz 127.0.0.1 61001"
docker run --rm --network=container:sidecar netstat /bin/bash -c "nc -vz 127.0.0.1 61001"

echo client does an HTTP request via the proxy
time curl -sv http://127.0.0.1:61001 > /dev/null

echo success

docker logs sidecar
read -p "Press enter to continue"

docker rm -f sidecar
docker rm -f app
