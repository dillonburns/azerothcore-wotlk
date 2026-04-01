# Dev Environment Facts

## Config Files

- `conf/config.sh` — local build config, gitignored. Copy of `conf/dist/config.sh`. This is the file to edit.
- `conf/dist/config.sh` — version-controlled template. Never edit directly.
- `.env` (repo root) — for docker-compose only. Does NOT affect the build pipeline.
- `MTHREADS` and `CTYPE` are env vars. `conf/config.sh` reads them via `${VAR:-default}` pattern.
    - Set defaults in `conf/config.sh`, override per-task in VS Code tasks or shell.

## Build Pipeline (acore.sh)

- Build system is acore.sh → apps/compiler/includes/functions.sh → cmake --build + cmake --install.
- Build tree: `var/build/obj`. Runnable tree: `env/dist`.
- `cmake --build` → artifacts in `var/build/obj`.
- `cmake --install` → copies executables/configs to `env/dist`.
- `env/dist/bin/worldserver` is what tasks and launch.json should always reference.
- See `.prompts/BUILD.md` for full cheat sheet with examples and debugger setup.

## Tooling Roles

- `ms-vscode.cpptools`: C/C++ IntelliSense + cppdbg debugger. Required.
- `ms-vscode.cmake-tools`: CMake project visibility, configure/build/install support. Good for learning.
- `ms-vscode.makefile-tools`: Not the primary workflow here (no root Makefile). Can be hidden.
- Daily dev: use VS Code tasks or `acore.sh compiler build`.
- Manual CMake: useful for understanding the pipeline; see BUILD.md.

## Debugger

- `type: cppdbg` in launch.json uses GDB via ms-vscode.cpptools.
- `program` must point to installed binary: `/azerothcore/env/dist/bin/worldserver`.
- `sourceFileMap: { "/azerothcore": "${workspaceFolder}" }` remaps compile-time paths to workspace.
- Gray/unbound breakpoints usually mean stale installed binary → rebuild + reinstall.

## Dev Container

- `shutdownAction: "stopCompose"` stops all Docker services on disconnect (slow cold restart).
- `shutdownAction: "none"` is more ergonomic for active dev (instant reconnect, DB stays up).
- `postStartCommand` re-wwakes ac-database on every reconnect regardless of shutdownAction.

## RAM / Performance

- worldserver has no explicit memory limit flags. It dynamically uses available RAM.
- Tune via: `WorldDatabase.WorkerThreads` in worldserver.conf (more threads = more RAM + concurrency).
- Biggest lever: MySQL buffer pool size in `.env` (`MYSQL_BUFFER_POOL_SIZE`).
- `DontCacheRandomMovementPaths = 1` saves RAM (disables NPC path caching).
