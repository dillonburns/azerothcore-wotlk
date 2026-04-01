# Development Environment

## Server Hardware: "Ladybug"

| Component | Spec |
|---|---|
| **OS** | Ubuntu Server |
| **CPU** | Intel Core i7-6700 @ 3.4 GHz (4C/8T) |
| **RAM** | 16GB Physical + 16GB Swap *(swap required to prevent OOM during C++ linking)* |
| **GPU** | GTX 1070 8GB *(unused — server is headless and CPU/RAM bound)* |

## Network (Tailscale Mesh)

The server is hosted entirely within a **Tailscale mesh network** during development — no port forwarding.

* **Broadcast IP:** `100.98.182.38` (set in `acore_auth.realmlist`)
* **Client Access:** Players must be on the project's Tailscale tailnet during development.
* **IP Override:** Enforced via `data/sql/custom/db_auth/tailscale_ip_override.sql` at Authserver boot.

## Dev-Container Topology

VSCode Remote Containers runs the dev environment inside Docker. The dev-container uses the [`docker-outside-of-docker`](https://github.com/devcontainers/features/tree/main/src/docker-outside-of-docker) feature to access the **host's Docker daemon**, so `docker compose` commands inside the dev-container control host-level containers (like `ac-database`).

```
┌─ Host Docker Daemon ──────────────────────────┐
│                                               │
│  ac-dev-server  (VSCode dev-container)        │
│    ├── authserver    (env/dist/bin/)   :3724  │
│    └── worldserver   (VSCode F5 debug) :8085  │
│                                               │
│  ac-database    (MySQL 8.4)           :3306   │
│                                               │
│  [Temporary Init Containers]                  │
│  ac-client-data-init ───┐                     │
│  ac-db-import ──────────┴ (Initializes State) │
└───────────────────────────────────────────────┘
```

| Component | Notes |
|---|---|
| `ac-dev-server` | Dev-container. Build toolchain, runs both servers. Workspace at `/azerothcore`. Can manage sibling containers via host Docker. |
| `ac-database` | Sibling container. MySQL 8.4 — `acore_auth`, `acore_characters`, `acore_world`. Reachable as `ac-database:3306`. |
| Authserver | Runs inside dev-container via VSCode task `[Run] Authserver (Native)` |
| Worldserver | Runs inside dev-container via VSCode F5 debugger |

### Stack Initialization & Service Checking

When setting up the environment, several **temporary Docker containers** from `docker-compose.yml` are used to seed the initial state:

1. **`ac-client-data-init`**: Downloads extraction data (maps, vmaps, mmaps, dbc files) into the `env/dist/data/` volume.
2. **`ac-db-import`**: Waits for `ac-database` to be healthy, then imports the base AzerothCore SQL dumps into the MySQL instance. 

The overall health of the environment is mapped directly to the `tools/check_services_status.sh` script (invoked via the VSCode task `[Status] Check All Services`). The script validates the complete stack:

- **Prerequisites**: Checks if `ac-client-data-init` ran successfully (look for `data-version`), if `ac-db-import` created the databases (queries MySQL), and if the core C++ binaries are compiled.
- **Docker Containers**: Verifies the status of the persistent sibling containers `ac-database` and `ac-dev-server`.
- **Native Processes**: Verifies `authserver` and `worldserver` are actively running inside the dev-container.

## The Wormhole (Lua Script Injection)

Live-injection pattern for Lua development using **mod-ale** (AzerothCore Lua Engine):

* `docker-compose.override.yml` maps a host directory into the Worldserver container.
* **Host Path:** `~/docker/wow/lua_scripts`
* **Config:** `ALE.AutoReload = true`, `ALE.TraceBack = false`
* Lua files on the host are instantly available to the containerized C++ runtime.
