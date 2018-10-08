## sometimes Envoy makes more connections than it should to an upstream

An attempt to reproduce [Envoy issue 4409](https://github.com/envoyproxy/envoy/issues/4409)

notes:

- when Envoy is configured to to TLS termination, we can see occasional hangs on curl with many (NUM_CPUs?) ESTABLISHED connections to the backend
- when Envoy is configured without TLS termination, things seem fine?


Open a few different terminals terminals

1. `./setup.sh` launches "app" and "sidecar" processes
2. `./watch-netstat.sh` watches for established TCP connections
3. `./time-curl.sh` measures duration of requests
4. `./ping-loop.sh` mimics a TCP healthcheck

If you start 1, 2 and 3, you'll see the curls all go pretty quick, with little variability in request duration.
You also won't see any lingering ESTABLISHED connections in netstat.

Once you start 4, then that changes.  The curls will occasionally be very slow (several seconds) and the lingering ESTABLISHED connections will start to show up.

Terminal 2
```
Every 0.5s: netstat -anp | grep 8080 | grep ESTAB              7f64a80dfec9: Mon Oct  8 01:30:52 2018

tcp        0      0 127.0.0.1:54266         127.0.0.1:8080          ESTABLISHED -
tcp        0      0 127.0.0.1:8080          127.0.0.1:54262         ESTABLISHED -
tcp        0      0 127.0.0.1:54262         127.0.0.1:8080          ESTABLISHED -
tcp        0      0 127.0.0.1:54274         127.0.0.1:8080          ESTABLISHED -
tcp        0      0 127.0.0.1:54270         127.0.0.1:8080          ESTABLISHED -
tcp       79      0 127.0.0.1:8080          127.0.0.1:54270         ESTABLISHED -
tcp        0      0 127.0.0.1:8080          127.0.0.1:54266         ESTABLISHED -
tcp        0      0 127.0.0.1:8080          127.0.0.1:54274         ESTABLISHED -
```

Terminal 3
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
