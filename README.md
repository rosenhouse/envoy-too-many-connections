## sometimes Envoy makes more connections than it should to an upstream

An attempt to reproduce [Envoy issue 4409](https://github.com/envoyproxy/envoy/issues/4409)

notes:

- when Envoy is configured to to TLS termination, we can see occasional hangs on curl with many (NUM_CPUs?) ESTABLISHED connections to the backend
- when Envoy is configured without TLS termination, things seem fine?


Open 4 terminals

1. `./setup.sh` launches "app" and "sidecar" processes
2. `./watch-netstat.sh` watches for established TCP connections
3. `./ping-loop.sh` mimics a TCP healthcheck
4. `./time-curl.sh` measures duration of requests

you'll see several (NUM_CPUS?) ESTABLISHED connections

the requests will often be fast, but occasionally more than 1 second

```
starting...
        0.05 real         0.01 user         0.00 sys
done.
starting...
        0.04 real         0.01 user         0.00 sys
done.
starting...
        4.32 real         0.01 user         0.00 sys
done.
starting...
        0.08 real         0.01 user         0.00 sys
done.
starting...
        0.04 real         0.01 user         0.00 sys
done.
```
