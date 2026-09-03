# Solution Steps

1. Update the API/worker entrypoint scripts to `exec "$@"` (no backgrounding). This makes the Go process PID 1 so Docker SIGTERM reaches it directly and shutdown drains cleanly.

2. Harden API least-privilege: remove `user: "0:0"`, `cap_add: [SYS_PTRACE]`, and `security_opt: seccomp:unconfined` from `docker-compose.yml`. Instead, set the API image to run as the non-root `app` user.

3. Make the API scratch directory writable under `read_only: true` by mounting a tmpfs at `/var/run/telemetry`. The verification expects `/var/run/telemetry` to appear in the container’s `HostConfig.Tmpfs`.

4. Install `redis-cli` into the API and worker runtime images (via `apk add --no-cache redis`) so healthchecks can measure `compacted:count` and `worker:ready` realistically.

5. Replace the simplistic healthchecks with end-to-end readiness checks in `docker-compose.yml`:
- Worker healthcheck: ensure `worker:ready == 1`, push one event into `telemetry:events`, and wait until `compacted:count` increases; then mark done in `/tmp`.
- API healthcheck: ensure `/ready` is 200, capture `compacted:count`, enqueue one event via `POST /events`, and wait until `compacted:count` increases; then mark done in `/var/run/telemetry`.
This ties “healthy” to real enqueue + compaction capability.

6. Fix orchestration so the stack reaches healthy deterministically: change `depends_on` for api/worker from `service_started` to `service_healthy` for redis, and ensure the override file no longer disables the API healthcheck.

7. Ensure restart/upgrade correctness: because the healthcheck markers are stored in writable tmpfs/tmp, they revalidate after fresh container starts (and verification cleanup removes volumes, so there’s no stale state).

8. After implementing, run `./run.sh` and then (when ready) `verify/verify_stack.sh` to confirm: (1) api/worker reach healthy only when compaction works, (2) api runs as non-root with read-only rootfs and no elevated capabilities, (3) SIGTERM triggers the Go graceful shutdown log and exit code 0, and (4) compaction output survives worker restart in `/data/compacted.log`.

