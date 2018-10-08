notes:

- when Envoy is configured to to TLS termination, we can see occasional hangs on curl with many (NUM_CPUs?) ESTABLISHED connections to the backend
- when Envoy is configured without TLS termination, things seem fine

```
watch -n0.5 'docker run --rm --network=container:sidecar netstat /bin/bash -c "nc -vz 127.0.0.1 61001"'
```

```
watch -n0.5 'docker run --rm --network=container:sidecar netstat /bin/bash -c "netstat -anp | grep 8080 | grep ESTAB"'
```
you'll see several (NUM_CPUS?) ESTABLISHED connections

```
time curl -k https://127.0.0.1:61001
<html><head><title>Python app.</title></head><body><p>python, world</p></body></html>
real	0m21.280s
user	0m0.019s
sys	0m0.006s
```
sometimes this is fast, sometimes slow
