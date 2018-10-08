notes:

- when Envoy is configured to to TLS termination, we can see occasional hangs on curl with many (NUM_CPUs?) ESTABLISHED connections to the backend
- when Envoy is configured without TLS termination, things seem fine

