# AzerothCore Build Flow Cheat Sheet

## Core Terms
- Build tree: where CMake generates build files and compiles outputs.
	Think: "workshop" with intermediate and final build products.
- Artifacts: outputs of compilation (for example: `.o`, `.a`, executables).
	Think: the things the compiler/linker actually produce.
- Install: copy step that places selected artifacts/files into runtime layout.
	Think: "package and place" outputs where the server expects them.
- Runnable tree: installed layout you actually run/debug.
	Think: "launch-ready" folder with binaries, libs, and configs in expected locations.

## Paths In This Repo
- Build tree: `var/build/obj`
	Examples:
	- `var/build/obj/CMakeCache.txt`
	- `var/build/obj/modules/CMakeFiles/modules.dir/mod-grizbop-core/src/grizbop_commandscript.cpp.o`
	- `var/build/obj/src/server/apps/worldserver`
- Runnable tree: `env/dist`
	Examples:
	- `env/dist/bin/worldserver`
	- `env/dist/lib/liblua52.a`
	- `env/dist/etc/worldserver.conf.dist`
- Built worldserver: `var/build/obj/src/server/apps/worldserver`
	Example detail: this is the linker output produced by `cmake --build`.
- Runnable worldserver: `env/dist/bin/worldserver`
	Example detail: this is what tasks/debug launch configs should execute.
- Runtime configs: `env/dist/etc`
	Examples:
	- `env/dist/etc/worldserver.conf.dist`
	- `env/dist/etc/authserver.conf.dist`
	- `env/dist/etc/modules/mod-grizbop-core.conf.dist`

## What `acore.sh` Does
1. Configure CMake (if needed).
2. Build targets into the build tree.
3. Install artifacts into the runnable tree.

Typical outcome:
- Step 1 creates/updates build metadata (like `CMakeCache.txt`).
- Step 2 compiles and links binaries/libraries in `var/build/obj`.
- Step 3 copies runtime outputs/config templates into `env/dist`.

## Mental Model
- `cmake --build` updates files in `var/build/obj`.
- `cmake --install` copies runtime outputs to `env/dist`.
- Run/debug from `env/dist/bin`, not from `var/build/obj`.

Quick check after install:
- Build output and installed binary should usually match size/build-id.
- If `env/dist/bin/worldserver` seems stale, run install again.

## Manual Commands (Equivalent Flow)
```bash
# From repo root:
cmake -S . -B var/build/obj
cmake --build var/build/obj --config Debug -j 4 --target worldserver
cmake --install var/build/obj --config Debug
```

What each command gives you:
- First command prepares the build system.
- Second command compiles/links artifacts.
- Third command publishes runnable outputs to `env/dist`.

## Tooling Guidance
- Daily iteration: use VS Code tasks or `acore.sh`.
- CMake Tools: use for visibility into configure/build/install/targets.
- Makefile Tools: optional in this repo; not the primary workflow.

Practical workflow:
- For fast module iteration: run your `[Build] Compile Core (Debug)` task.
- For understanding internals: run configure/build/install manually once.

## CMakeLists: Getting Started
- `CMakeLists.txt` files are build recipe files; CMake starts at repo root, then follows `add_subdirectory(...)` into child folders.
- There are many by design: each folder owns its own build logic (core, deps, apps, modules), which keeps changes local and easier to maintain.

Where to edit:
- Root `CMakeLists.txt`: global policies/options and high-level orchestration only.
- `deps/CMakeLists.txt`: third-party libraries and dependency toggles.
- `src/server/apps/.../CMakeLists.txt`: executables and app-level linkage.
- `modules/<your-module>/CMakeLists.txt`: your module source files, include paths, module-specific options.

Rule of thumb:
- If you add/rename a file in `mod-grizbop-core`, update that module's `CMakeLists.txt`, not the root one.
- Only touch root CMake when changing project-wide behavior.

Minimal learning loop:
1. Add a source file to your module.
2. Register it in `modules/mod-grizbop-core/CMakeLists.txt`.
3. Build + install.
4. Verify the symbol/file appears in debugger backtraces.

## Debugger: What It Connects To
- VS Code `cppdbg` launches GDB (`miDebuggerPath`) and starts the executable set in `program`.
- In this repo, `program` points to `/azerothcore/env/dist/bin/worldserver`, so GDB attaches to the installed (runnable) binary, not the one in `var/build/obj`.
- Because the binary was built in Debug mode (with debug info), GDB can resolve function names, line numbers, locals, and stack traces.

From current launch config:
- `program`: `/azerothcore/env/dist/bin/worldserver`
- `cwd`: `${workspaceFolder}/env/dist/bin` (working directory for relative paths)
- `MIMode`: `gdb` (debug engine on Linux)
- `sourceFileMap`: maps `/azerothcore` to `${workspaceFolder}`

## Source Mapping (How Files Open Correctly)
- Debug symbols in the binary store source paths from compile time (for example `/azerothcore/src/...`).
- If VS Code workspace path differs, `sourceFileMap` remaps symbol paths to local files.
- Your mapping `/azerothcore -> ${workspaceFolder}` means breakpoints and step-into open the correct local source file even when path roots differ.

Typical breakpoint flow:
1. You set a breakpoint in a local file.
2. GDB hits an address in `worldserver`.
3. Debug info maps address -> compiled source path.
4. `sourceFileMap` remaps path -> workspace file.
5. VS Code opens the local file at the right line.

## Common Debug Gotcha
- If breakpoints turn gray or never bind, the installed binary may be stale.
- Fix: rebuild and reinstall (`cmake --build ...` then `cmake --install ...`, or run your acore build task that does both).
