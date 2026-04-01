# Phase Alpha: Development Infrastructure Setup

> **Goal:** Set up git, fix the dev environment, get mod-grizbop-core to compile with a Hello World, create the first DB table, and build a minimal GM command. Establish the workflows for all future development.

**Role Split:** AI agent is the architect (plans + code snippets). You implement on Ladybug.

## Workstream Order

| # | Workstream | Why This Order |
|---|---|---|
| WS0 | Git Fork Setup | Everything else builds on a clean git history |
| WS1 | Dev Environment Cleanup | Fix launch.json env before compile/test cycles |
| WS2 | Module Skeleton Hello World | First successful compile — proves toolchain works |
| WS3 | Archetypes DB Table | First real data — proves DB pipeline works |
| WS4 | Minimal GM Commands | First in-game output — proves DB→C++→chat pipeline |
| WS5 | Workflow Documentation | Document what you learned for future reference |

---

## WS0: Git Fork Setup

### The Problem

You're working directly on a clone of `azerothcore/azerothcore-wotlk`. You need to push custom changes without polluting upstream and pull upstream updates easily.

### Step 1: Fork on GitHub

Go to `github.com/azerothcore/azerothcore-wotlk` → Fork → create `your-username/azerothcore-wotlk` (or `grizbop-core`).

### Step 2: Reconfigure Remotes on Ladybug

```bash
cd ~/azerothcore
git remote -v
git remote rename origin upstream
git remote add origin git@github.com:YOUR_USERNAME/azerothcore-wotlk.git
git remote -v
# Should show:
#   origin    git@github.com:YOUR_USERNAME/azerothcore-wotlk.git
#   upstream  https://github.com/azerothcore/azerothcore-wotlk.git
git push -u origin master
```

### Step 3: Future Upstream Sync

```bash
git fetch upstream
git merge upstream/master
git push origin master
```

### Step 4: mod-grizbop-core Git Strategy

Keep it inline (not a submodule). Check if modules are gitignored:

```bash
cat ~/azerothcore/.gitignore | grep -i module
```

If `modules/mod-grizbop-core` is gitignored, add a negation rule:

```gitignore
!modules/mod-grizbop-core/
```

---

## WS1: Dev Environment Cleanup

For the full topology, see [ENVIRONMENT.md](../ENVIRONMENT.md).

Everything runs inside a **VSCode dev-container** (`ac-dev-server`). The workspace is mounted at `/azerothcore` inside the container. The DB is reachable at `ac-database:3306` via Docker networking.

### Current `launch.json`

This is the working debug configuration. The worldserver binary path and DB hostnames use container-internal paths since VSCode runs inside the dev-container:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Launch Worldserver (Debug)",
            "type": "cppdbg",
            "request": "launch",
            "program": "/azerothcore/env/dist/bin/worldserver",
            "cwd": "${workspaceFolder}/env/dist/bin",
            "args": [],
            "environment": [
                { "name": "AC_DATA_DIR", "value": "/azerothcore/env/dist/data" },
                { "name": "AC_LOGS_DIR", "value": "/azerothcore/env/dist/logs" },
                { "name": "AC_LOGIN_DATABASE_INFO", "value": "ac-database;3306;root;password;acore_auth" },
                { "name": "AC_WORLD_DATABASE_INFO", "value": "ac-database;3306;root;password;acore_world" },
                { "name": "AC_CHARACTER_DATABASE_INFO", "value": "ac-database;3306;root;password;acore_characters" }
            ],
            "externalConsole": false,
            "sourceFileMap": {
                "/azerothcore": "${workspaceFolder}"
            },
            "linux": {
                "MIMode": "gdb",
                "miDebuggerPath": "/usr/bin/gdb",
                "setupCommands": [
                    {
                        "description": "Enable pretty-printing for gdb",
                        "text": "-enable-pretty-printing",
                        "ignoreFailures": false
                    }
                ]
            }
        }
    ]
}
```

> **Note:** `program` uses the absolute container path `/azerothcore/...` and DB connections use `ac-database` (Docker hostname). This is correct because VSCode is running inside the dev-container.

---

## WS2: Module Skeleton — Hello World

> **Goal:** Compile `mod-grizbop-core` and see `[Grizbop] mod-grizbop-core loaded.` in the worldserver log.

### Step 1: Delete old skeleton files

```bash
rm modules/mod-grizbop-core/src/MP_loader.cpp
rm modules/mod-grizbop-core/src/MyPlayer.cpp
rm modules/mod-grizbop-core/conf/my_custom.conf.dist
rm modules/mod-grizbop-core/data/sql/db-world/skeleton_module_acore_string.sql
```

### Step 2: Create `src/grizbop_loader.cpp`

```cpp
void AddSC_grizbop_worldscript();
// MUST be named Add${MODULE_DIR}Scripts() with hyphens → underscores
void Addmod_grizbop_coreScripts()
{
    AddSC_grizbop_worldscript();
}
```

### Step 3: Create `src/grizbop_worldscript.cpp`

```cpp
#include "ScriptMgr.h"
#include "Log.h"
#include "Config.h"

class GrizbopWorldScript : public WorldScript
{
public:
    GrizbopWorldScript() : WorldScript("GrizbopWorldScript") { }

    void OnStartup() override
    {
        if (!sConfigMgr->GetOption<bool>("Grizbop.Enable", true))
        {
            LOG_INFO("server.loading", "[Grizbop] Module is DISABLED via config.");
            return;
        }
        LOG_INFO("server.loading",
            "[Grizbop] mod-grizbop-core loaded. "
            "The factory that builds the factory is online.");
    }

    void OnShutdown() override
    {
        LOG_INFO("server.loading", "[Grizbop] mod-grizbop-core shutting down.");
    }
};

void AddSC_grizbop_worldscript()
{
    new GrizbopWorldScript();
}
```

### Step 4: Create `conf/mod-grizbop-core.conf.dist`

```ini
[worldserver]

########################################
# Grizbop Core Module
########################################

# Grizbop.Enable
#     Enable the Grizbop rogue-lite module
#     Default: 1
Grizbop.Enable = 1

# Grizbop.DebugLog
#     Enable verbose debug logging
#     Default: 0
Grizbop.DebugLog = 0
```

### Compile & Verify

```bash
CTYPE=Debug MTHREADS=4 ./acore.sh compiler build
```

Expected: No errors, CMake shows `mod-grizbop-core` in modules list. After F5 launch: `[Grizbop] mod-grizbop-core loaded.` in log.

> If linker error about `Addmod_grizbop_coreScripts`: delete `build/` and reconfigure — the generated loader caches stale function names.

---

## WS3: Archetypes DB Table

### Directory Setup

```bash
mkdir -p modules/mod-grizbop-core/data/sql/db-world/base
mkdir -p modules/mod-grizbop-core/data/sql/db-world/updates
mkdir -p modules/mod-grizbop-core/data/sql/db-characters/base
mkdir -p modules/mod-grizbop-core/data/sql/db-characters/updates
```

### Create `data/sql/db-world/base/grizbop_archetypes.sql`

```sql
DROP TABLE IF EXISTS `grizbop_archetypes`;
CREATE TABLE `grizbop_archetypes` (
    `id`             INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `class`          TINYINT UNSIGNED NOT NULL
                     COMMENT 'WoW class ID (1=War,2=Pal,3=Hunt,4=Rog,5=Pri,6=DK,7=Sha,8=Mag,9=Lock,11=Dru)',
    `name`           VARCHAR(64)  NOT NULL,
    `description`    VARCHAR(255) DEFAULT NULL,
    `display_id`     INT UNSIGNED NOT NULL DEFAULT 0
                     COMMENT 'Morph model ID (0=no morph)',
    `start_level`    TINYINT UNSIGNED NOT NULL DEFAULT 5,
    `spell_list`     TEXT DEFAULT NULL
                     COMMENT 'Comma-separated spell IDs to teach',
    `item_list`      TEXT DEFAULT NULL
                     COMMENT 'Comma-separated item entry IDs for starter gear',
    `talent_string`  TEXT DEFAULT NULL
                     COMMENT 'Serialized talent build (future)',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `grizbop_archetypes`
    (`id`, `class`, `name`, `description`, `start_level`)
VALUES
    (1, 1, 'Berserker',     'Fury warrior with massive 2H weapon',  5),
    (2, 1, 'Iron Wall',     'Shield tank with high survivability',   5),
    (3, 2, 'Crusader',      'Holy DPS paladin with heavy strikes',   5),
    (4, 5, 'Shadow Weaver', 'Shadow priest with DoT focus',          5),
    (5, 8, 'Stormcaller',   'Mage focused on lightning damage',      5),
    (6, 4, 'Phantom',       'Rogue with stealth and burst damage',   5);
```

Run in DBeaver against `acore_world`, verify with `SELECT * FROM grizbop_archetypes;`.

**SQL Migration Convention:**
- `base/` = ground truth DDL + seed data (run once)
- `updates/` = incremental scripts, timestamped (e.g., `2026_03_31_01_add_column.sql`)

---

## WS4: Minimal GM Commands

Do this after WS2 compiles and WS3 data is in the DB.

### Update `grizbop_loader.cpp`

```cpp
void AddSC_grizbop_worldscript();
void AddSC_grizbop_commandscript();

void Addmod_grizbop_coreScripts()
{
    AddSC_grizbop_worldscript();
    AddSC_grizbop_commandscript();
}
```

### Create `src/grizbop_archetype.h`

```cpp
#ifndef GRIZBOP_ARCHETYPE_H
#define GRIZBOP_ARCHETYPE_H

#include "Define.h"
#include <string>
#include <unordered_map>

struct GrizbopArchetype
{
    uint32      id          = 0;
    uint8       classId     = 0;
    std::string name;
    std::string description;
    uint32      displayId   = 0;
    uint8       startLevel  = 5;
    std::string spellList;
    std::string itemList;
    std::string talentString;
};

class GrizbopArchetypeMgr
{
public:
    static GrizbopArchetypeMgr* instance()
    {
        static GrizbopArchetypeMgr inst;
        return &inst;
    }

    void LoadFromDB();
    void Clear() { _archetypes.clear(); }

    GrizbopArchetype const* GetArchetype(uint32 id) const
    {
        auto it = _archetypes.find(id);
        return it != _archetypes.end() ? &it->second : nullptr;
    }

    std::unordered_map<uint32, GrizbopArchetype> const& GetAll() const
    { return _archetypes; }

    uint32 GetCount() const { return _archetypes.size(); }

private:
    GrizbopArchetypeMgr() = default;
    std::unordered_map<uint32, GrizbopArchetype> _archetypes;
};

#define sGrizbopArchetypeMgr GrizbopArchetypeMgr::instance()
#endif
```

### Create `src/grizbop_archetype.cpp`

```cpp
#include "grizbop_archetype.h"
#include "DatabaseEnv.h"
#include "Log.h"

void GrizbopArchetypeMgr::LoadFromDB()
{
    uint32 oldMSTime = getMSTime();
    _archetypes.clear();

    QueryResult result = WorldDatabase.Query(
        "SELECT id, class, name, description, display_id, start_level, "
        "spell_list, item_list, talent_string "
        "FROM grizbop_archetypes");

    if (!result)
    {
        LOG_WARN("server.loading",
            "[Grizbop] >> Loaded 0 archetypes. "
            "Table `grizbop_archetypes` is empty or missing!");
        return;
    }

    do
    {
        Field* fields = result->Fetch();
        GrizbopArchetype arch;
        arch.id           = fields[0].Get<uint32>();
        arch.classId      = fields[1].Get<uint8>();
        arch.name         = fields[2].Get<std::string>();
        arch.description  = fields[3].Get<std::string>();
        arch.displayId    = fields[4].Get<uint32>();
        arch.startLevel   = fields[5].Get<uint8>();
        arch.spellList    = fields[6].Get<std::string>();
        arch.itemList     = fields[7].Get<std::string>();
        arch.talentString = fields[8].Get<std::string>();
        _archetypes[arch.id] = arch;
    } while (result->NextRow());

    LOG_INFO("server.loading",
        "[Grizbop] >> Loaded {} archetypes in {} ms.",
        _archetypes.size(), GetMSTimeDiffToNow(oldMSTime));
}
```

### Update `src/grizbop_worldscript.cpp` (add DB loading)

```cpp
#include "ScriptMgr.h"
#include "Log.h"
#include "Config.h"
#include "grizbop_archetype.h"

class GrizbopWorldScript : public WorldScript
{
public:
    GrizbopWorldScript() : WorldScript("GrizbopWorldScript") { }

    void OnStartup() override
    {
        if (!sConfigMgr->GetOption<bool>("Grizbop.Enable", true))
        {
            LOG_INFO("server.loading", "[Grizbop] Module is DISABLED via config.");
            return;
        }
        LOG_INFO("server.loading",
            "[Grizbop] mod-grizbop-core loaded. "
            "The factory that builds the factory is online.");
        sGrizbopArchetypeMgr->LoadFromDB();
    }

    void OnShutdown() override
    {
        LOG_INFO("server.loading", "[Grizbop] mod-grizbop-core shutting down.");
    }
};

void AddSC_grizbop_worldscript()
{
    new GrizbopWorldScript();
}
```

### Create `src/grizbop_run_state.h`

```cpp
#ifndef GRIZBOP_RUN_STATE_H
#define GRIZBOP_RUN_STATE_H

#include "DataMap.h"

struct GrizbopRunState : public DataMap::Base
{
    uint32 archetypeId = 0;
};
#endif
```

### Create `src/grizbop_commandscript.cpp`

```cpp
#include "Chat.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "grizbop_archetype.h"
#include "grizbop_run_state.h"

using namespace Acore::ChatCommands;

class GrizbopCommandScript : public CommandScript
{
public:
    GrizbopCommandScript() : CommandScript("GrizbopCommandScript") { }

    ChatCommandTable GetCommands() const override
    {
        static ChatCommandTable grizbopArchetypeTable =
        {
            { "list",  HandleArchetypeList,  SEC_GAMEMASTER, Console::No },
            { "set",   HandleArchetypeSet,   SEC_GAMEMASTER, Console::No },
            { "clear", HandleArchetypeClear, SEC_GAMEMASTER, Console::No },
        };

        static ChatCommandTable grizbopTable =
        {
            { "archetype", grizbopArchetypeTable },
        };

        static ChatCommandTable commandTable =
        {
            { "grizbop", grizbopTable },
        };

        return commandTable;
    }

    static bool HandleArchetypeList(ChatHandler* handler,
        Optional<PlayerIdentifier> /*target*/)
    {
        auto const& archetypes = sGrizbopArchetypeMgr->GetAll();
        if (archetypes.empty())
        {
            handler->SendSysMessage("[Grizbop] No archetypes loaded.");
            return true;
        }
        handler->PSendSysMessage("[Grizbop] === Archetypes ({}) ===",
            archetypes.size());
        for (auto const& [id, arch] : archetypes)
            handler->PSendSysMessage("  [{}] {} (Class {}, Lv{}) - {}",
                id, arch.name, arch.classId, arch.startLevel, arch.description);
        return true;
    }

    static bool HandleArchetypeSet(ChatHandler* handler, uint32 archetypeId)
    {
        Player* target = handler->getSelectedPlayerOrSelf();
        if (!target)
        {
            handler->SendSysMessage("[Grizbop] No player target.");
            handler->SetSentErrorMessage(true);
            return false;
        }
        auto const* arch = sGrizbopArchetypeMgr->GetArchetype(archetypeId);
        if (!arch)
        {
            handler->PSendSysMessage("[Grizbop] Archetype ID {} not found.",
                archetypeId);
            handler->SetSentErrorMessage(true);
            return false;
        }
        auto* state = target->CustomData
            .GetDefault<GrizbopRunState>("GrizbopRunState");
        state->archetypeId = arch->id;
        target->SetLevel(arch->startLevel);
        handler->PSendSysMessage(
            "[Grizbop] Applied '{}' to {}. Level set to {}.",
            arch->name, target->GetName(), arch->startLevel);
        return true;
    }

    static bool HandleArchetypeClear(ChatHandler* handler,
        Optional<PlayerIdentifier> /*target*/)
    {
        Player* player = handler->getSelectedPlayerOrSelf();
        if (!player)
        {
            handler->SendSysMessage("[Grizbop] No player target.");
            handler->SetSentErrorMessage(true);
            return false;
        }
        auto* state = player->CustomData
            .Get<GrizbopRunState>("GrizbopRunState");
        if (!state || state->archetypeId == 0)
        {
            handler->SendSysMessage("[Grizbop] No archetype set on target.");
            return true;
        }
        state->archetypeId = 0;
        player->SetLevel(1);
        handler->PSendSysMessage(
            "[Grizbop] Archetype cleared from {}. Level reset to 1.",
            player->GetName());
        return true;
    }
};

void AddSC_grizbop_commandscript()
{
    new GrizbopCommandScript();
}
```

---

## Final File Tree

```
modules/mod-grizbop-core/
├── conf/
│   └── mod-grizbop-core.conf.dist
├── data/
│   └── sql/
│       ├── db-world/
│       │   ├── base/
│       │   │   └── grizbop_archetypes.sql
│       │   └── updates/
│       └── db-characters/
│           ├── base/
│           └── updates/
└── src/
    ├── grizbop_archetype.cpp
    ├── grizbop_archetype.h
    ├── grizbop_commandscript.cpp
    ├── grizbop_loader.cpp
    ├── grizbop_run_state.h
    └── grizbop_worldscript.cpp
```