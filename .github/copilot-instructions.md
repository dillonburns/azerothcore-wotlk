# AzerothCore — WoW: Free Grizbop

AzerothCore is a C++ WoW 3.3.5a (WotLK) server emulator powering the **Free Grizbop** custom rogue-lite server. See [GAME.md](../.docs/GAME.md) for game concept, [AGENT.md](../AGENT.md) for broader AI agent guidance.

---

## Architecture

Two server processes, three MySQL databases. See [ARCHITECTURE.md](../.docs/ARCHITECTURE.md) for internals.

| Process | Role | Port |
|---------|------|------|
| **authserver** | SRP6 auth + realm list, no game logic | 3724 |
| **worldserver** | Game engine: networking, AI, scripting, persistence | 8085 |

Databases: `acore_auth`, `acore_characters`, `acore_world`.

Custom game logic lives in `modules/mod-grizbop-core/` and `lua_scripts/`. The module system is opt-in: each module has its own `CMakeLists.txt` and is loaded via `-DMODULES=static`.

---

## Build and Test

See [BUILD.md](../.docs/BUILD.md) for the full flow. Build tree: `var/build/obj`. Runnable tree: `env/dist`.

```bash
# Preferred (VS Code task or acore.sh):
CTYPE=Debug MTHREADS=4 ./acore.sh compiler build

# Manual CMake equivalent:
cmake -S . -B var/build/obj -DCMAKE_BUILD_TYPE=Debug
cmake --build var/build/obj -j4 --target worldserver
cmake --install var/build/obj

# Unit tests:
cmake -S . -B var/build/obj -DBUILD_TESTING=ON
cmake --build var/build/obj -j4
./var/build/obj/src/test/unit_tests
```

**Always run the installed binary** (`env/dist/bin/worldserver`), not the build artifact.

Run worldserver via the **VS Code cppdbg Debugger (*F5*)** for step-through and code inspection of the worldserver process.

---

## Dev Loop

See [DEV-ENV.md](../.docs/DEV-ENV.md) for full setup details. Local config: `conf/config.sh` (gitignored copy of `conf/dist/config.sh` — never edit `dist/`).

1. Wake DB: `docker compose start ac-database`
2. Auth: `./env/dist/bin/authserver`
3. World: `./env/dist/bin/worldserver` (or **F5** to attach debugger)

Shut down in reverse order. Graceful world stop: `.server shutdown 5` in worldserver console.

---

## Code Style

Full C++ and SQL standards: [pr-reviewer.md](agents/pr-reviewer.md).

| Rule | Detail |
|------|--------|
| C++ indent | 4 spaces, no tabs |
| JSON/YAML/shell indent | 2 spaces |
| Line endings | LF, UTF-8 |
| Max line length | 80 characters |
| Braces | No braces around single-line `if`/`for` bodies |
| Log placeholders | Use `{}` — never `%u`, `%d` |
| Float literals | Always suffix: `1.5f` |
| `const` placement | After the type: `Player const* player` |
| Private members | Underscore prefix + lowerCamelCase: `_someGuid` |
| Methods | UpperCamelCase: `DoSomething(uint32 someArg)` |
| Header guards | Required in every `.h` file |

---

## SQL Updates

- New SQL goes in `data/sql/updates/pending_db_auth/`, `pending_db_characters/`, or `pending_db_world/`
- Files are assigned **random names** until their PR merges
- **Never edit** files outside `pending_*` folders (those are squashed baselines)

---

## Commit Format

```
Type(Scope/Subscope): Short description (max 50 chars)
```

Types: `feat`, `fix`, `refactor`, `style`, `docs`, `test`, `chore`  
Scopes: `Core` (C++ changes), `DB` (SQL changes)  
Examples: `fix(Core/Spells): Fix Fireball damage calc` · `fix(DB/SAI): Missing spell to Hogger`

---

## Project Docs

| Doc | Contents |
|-----|----------|
| [AGENT.md](../AGENT.md) | Full AI agent guide: scripting patterns, CMake options, PR requirements |
| [.docs/ARCHITECTURE.md](../.docs/ARCHITECTURE.md) | Engine internals, DB access patterns, world update loop |
| [.docs/BUILD.md](../.docs/BUILD.md) | Build/install flow, CMake commands, debugger attach |
| [.docs/DEV-ENV.md](../.docs/DEV-ENV.md) | Config files, Docker, RAM tuning, devcontainer tips |
| [.docs/GAME.md](../.docs/GAME.md) | Free Grizbop design: rogue-lite, archetypes, permadeath |
| [.docs/WOW-LUA-HELPERS.md](../.docs/WOW-LUA-HELPERS.md) | Eluna Lua scripting reference, ALE globals, event patterns |
| [.agent/MEMORY.md](../.agent/MEMORY.md) | Session memory index, active plans, handoff state |
| [.github/skills/dream/](skills/dream/SKILL.md) | End-of-session memory consolidation skill (`/dream`) |
