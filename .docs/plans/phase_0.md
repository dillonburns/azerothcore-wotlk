# Phase 0: The Factory That Builds The Factory

> **Goal:** Build `mod-grizbop-core`, validate the build pipeline, and implement the `.grizbop` GM command suite so that every subsequent feature can be tested in under 30 seconds.

---

## What Are These 18 Commands?

The `.grizbop` command suite is a **developer control panel** — a set of GM-only chat commands that let you teleport through the rogue-lite loop, inject modifiers, trigger permadeath, and inspect run state without ever playing the game normally. Think of it as a debug console for the entire project.

They're organized into **6 subcommand groups** under the root `.grizbop` command:

```
.grizbop
├── archetype
│   ├── set <id>        — Apply an archetype preset (level, morph, spells, gear)
│   ├── clear           — Strip archetype, reset to raw clone
│   └── list            — Print all defined archetypes from DB cache
├── run
│   ├── start [floor]   — Force-start a run at floor N (default 1), teleport in
│   ├── stop            — Force-end run without permadeath, return to hub
│   ├── status          — Dump full GrizbopRunState from DataMap to chat
│   ├── next            — Force-advance to next dungeon floor (skip boss)
│   └── set <floor>     — Teleport to specific floor number
├── mod
│   ├── add <id>        — Apply a wild modifier by ID (adds the aura)
│   ├── remove <id>     — Remove a specific modifier aura
│   ├── clear           — Strip ALL Grizbop modifier auras
│   └── list            — List all active Grizbop modifiers on target
├── meta
│   ├── reset [acctId]  — Wipe metaprogression for an account
│   └── give <amount>   — Grant meta-currency to target's account
├── debug
│   ├── die             — Trigger permadeath on target (test death flow)
│   ├── revive          — Revive a perma-dead character (GM only)
│   ├── scale <value>   — Set player scale + bypass anticheat
│   └── speed <value>   — Set speed multiplier + bypass anticheat
└── reload              — Reload archetype/modifier/dungeon tables from DB
```

**Why this is Phase 0:** Every command above directly tests a subsystem that Phases 1-4 depend on. Building them first means we validate the DataMap bridge, the DB schema, the archetype application pipeline, the teleportation path, the aura system, and the permadeath flow — all before writing any actual gameplay Lua.

---

## Module Structure

```
modules/mod-grizbop-core/
├── CMakeLists.txt
├── conf/
│   └── mod-grizbop-core.conf.dist
├── sql/
│   ├── characters/
│   │   └── grizbop_character_state.sql
│   └── world/
│       └── grizbop_archetypes.sql
└── src/
    ├── grizbop_commandscript.cpp     — The .grizbop command suite
    ├── grizbop_commandscript.h       — Command handler declarations
    ├── grizbop_playerscript.cpp      — PlayerScript hooks (login, death, save)
    ├── grizbop_playerscript.h        — PlayerScript class declaration
    ├── grizbop_run_state.h           — GrizbopRunState DataMap struct
    └── grizbop_loader.cpp            — Module entry point (AddSC_ functions)
```

---

## Key Structures

### `GrizbopRunState` (DataMap Struct)

```cpp
// File: modules/mod-grizbop-core/src/grizbop_run_state.h

#include "DataMap.h"
#include <vector>
#include <string>

enum GrizbopRunPhase : uint8
{
    GRIZBOP_PHASE_IDLE              = 0,  // In hub, no active run
    GRIZBOP_PHASE_ARCHETYPE_SELECT  = 1,  // Choosing archetype
    GRIZBOP_PHASE_IN_DUNGEON        = 2,  // Inside a dungeon floor
    GRIZBOP_PHASE_BOSS_REWARD       = 3,  // Post-boss, choosing essence/reward
    GRIZBOP_PHASE_TRANSITIONING     = 4,  // Being teleported to next floor
    GRIZBOP_PHASE_DEAD              = 5,  // Permadead, awaiting cleanup
};

struct GrizbopRunState : public DataMap::Base
{
    // Identity
    uint32 archetypeId      = 0;

    // Run tracking
    bool   runActive        = false;
    GrizbopRunPhase phase   = GRIZBOP_PHASE_IDLE;
    uint32 currentFloor     = 0;
    uint32 currentMapId     = 0;
    uint32 currentInstanceId = 0;

    // Economy
    uint32 runCurrency      = 0;

    // Modifier tracking (spell IDs of active Grizbop auras)
    std::vector<uint32> activeModifiers;

    // Persistence
    bool   isAlive          = true;
    bool   isDirty          = false; // Needs DB write
    time_t runStartTime     = 0;
};
```

**Access pattern:**
```cpp
// Get-or-create (safe for first access)
auto* state = player->CustomData.GetDefault<GrizbopRunState>("GrizbopRunState");

// Read existing (returns nullptr if not set)
auto* state = player->CustomData.Get<GrizbopRunState>("GrizbopRunState");
```

### Command Registration Pattern

```cpp
// File: modules/mod-grizbop-core/src/grizbop_commandscript.cpp

ChatCommandTable GetCommands() const override
{
    static ChatCommandTable grizbopArchetypeTable =
    {
        { "set",   HandleArchetypeSet,   SEC_GAMEMASTER, Console::No },
        { "clear", HandleArchetypeClear, SEC_GAMEMASTER, Console::No },
        { "list",  HandleArchetypeList,  SEC_GAMEMASTER, Console::No },
    };

    static ChatCommandTable grizbopRunTable =
    {
        { "start",  HandleRunStart,  SEC_GAMEMASTER, Console::No },
        { "stop",   HandleRunStop,   SEC_GAMEMASTER, Console::No },
        { "status", HandleRunStatus, SEC_GAMEMASTER, Console::No },
        { "next",   HandleRunNext,   SEC_GAMEMASTER, Console::No },
        { "set",    HandleRunSet,    SEC_GAMEMASTER, Console::No },
    };

    static ChatCommandTable grizbopModTable =
    {
        { "add",    HandleModAdd,    SEC_GAMEMASTER, Console::No },
        { "remove", HandleModRemove, SEC_GAMEMASTER, Console::No },
        { "clear",  HandleModClear,  SEC_GAMEMASTER, Console::No },
        { "list",   HandleModList,   SEC_GAMEMASTER, Console::No },
    };

    static ChatCommandTable grizbopMetaTable =
    {
        { "reset",  HandleMetaReset, SEC_GAMEMASTER, Console::No },
        { "give",   HandleMetaGive,  SEC_GAMEMASTER, Console::No },
    };

    static ChatCommandTable grizbopDebugTable =
    {
        { "die",    HandleDebugDie,   SEC_GAMEMASTER, Console::No },
        { "revive", HandleDebugRevive,SEC_GAMEMASTER, Console::No },
        { "scale",  HandleDebugScale, SEC_GAMEMASTER, Console::No },
        { "speed",  HandleDebugSpeed, SEC_GAMEMASTER, Console::No },
    };

    static ChatCommandTable grizbopTable =
    {
        { "archetype", grizbopArchetypeTable },
        { "run",       grizbopRunTable },
        { "mod",       grizbopModTable },
        { "meta",      grizbopMetaTable },
        { "debug",     grizbopDebugTable },
        { "reload",    HandleReload, SEC_GAMEMASTER, Console::Yes },
    };

    static ChatCommandTable commandTable =
    {
        { "grizbop", grizbopTable },
    };

    return commandTable;
}
```

### PlayerScript Hooks

```cpp
// File: modules/mod-grizbop-core/src/grizbop_playerscript.cpp

class GrizbopPlayerScript : public PlayerScript
{
public:
    GrizbopPlayerScript() : PlayerScript("GrizbopPlayerScript", {
        PLAYERHOOK_ON_FIRST_LOGIN,
        PLAYERHOOK_ON_LOGIN,
        PLAYERHOOK_ON_LOGOUT,
        PLAYERHOOK_ON_PLAYER_JUST_DIED,
        PLAYERHOOK_ON_SAVE,
    }) { }

    void OnFirstLogin(Player* player) override;
    void OnLogin(Player* player) override;
    void OnLogout(Player* player) override;
    void OnPlayerJustDied(Player* player) override;
    void OnSave(Player* player) override;
};
```

### Module Loader

```cpp
// File: modules/mod-grizbop-core/src/grizbop_loader.cpp

void AddSC_grizbop_commandscript();
void AddSC_grizbop_playerscript();

void Addmod_grizbop_coreScripts()
{
    AddSC_grizbop_commandscript();
    AddSC_grizbop_playerscript();
}
```

> [!IMPORTANT]
> The function **must** be named `Addmod_grizbop_coreScripts()` — the CMake build system auto-generates a call to `Add${MODULE_DIR_NAME}Scripts()`, where hyphens in the directory name are replaced with underscores. This is non-negotiable.

---

## Database Schema (Foundational Tables Only)

### `acore_characters.grizbop_character_state`

```sql
-- File: modules/mod-grizbop-core/sql/characters/grizbop_character_state.sql

CREATE TABLE IF NOT EXISTS `grizbop_character_state` (
    `guid`            INT UNSIGNED NOT NULL,
    `account_id`      INT UNSIGNED NOT NULL,
    `archetype_id`    INT UNSIGNED NOT NULL DEFAULT 0,
    `is_alive`        TINYINT(1)   NOT NULL DEFAULT 1,
    `run_active`      TINYINT(1)   NOT NULL DEFAULT 0,
    `run_phase`       TINYINT      NOT NULL DEFAULT 0,
    `current_floor`   INT UNSIGNED NOT NULL DEFAULT 0,
    `current_map_id`  INT UNSIGNED NOT NULL DEFAULT 0,
    `run_currency`    INT UNSIGNED NOT NULL DEFAULT 0,
    `run_start_time`  BIGINT       NOT NULL DEFAULT 0,
    `active_modifiers` TEXT         DEFAULT NULL,
    PRIMARY KEY (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### `acore_world.grizbop_archetypes`

```sql
-- File: modules/mod-grizbop-core/sql/world/grizbop_archetypes.sql

CREATE TABLE IF NOT EXISTS `grizbop_archetypes` (
    `id`             INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `class`          TINYINT UNSIGNED NOT NULL COMMENT 'WoW class ID',
    `name`           VARCHAR(64)  NOT NULL,
    `description`    VARCHAR(255) DEFAULT NULL,
    `display_id`     INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Morph model ID',
    `start_level`    TINYINT UNSIGNED NOT NULL DEFAULT 5,
    `spell_list`     TEXT         DEFAULT NULL COMMENT 'Comma-separated spell IDs to learn',
    `item_list`      TEXT         DEFAULT NULL COMMENT 'Comma-separated item entry IDs for starter gear',
    `talent_string`  TEXT         DEFAULT NULL COMMENT 'Serialized talent build',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Seed data: one test archetype per class for development
INSERT IGNORE INTO `grizbop_archetypes` (`id`, `class`, `name`, `description`, `start_level`)
VALUES
    (1, 1, 'Berserker',     'Fury warrior with massive 2H weapon', 5),
    (2, 1, 'Iron Wall',     'Shield tank with high survivability', 5),
    (3, 2, 'Crusader',      'Holy DPS paladin with heavy strikes', 5),
    (4, 5, 'Shadow Weaver', 'Shadow priest with DoT focus',        5),
    (5, 8, 'Stormcaller',   'Mage focused on lightning damage',    5),
    (6, 4, 'Phantom',       'Rogue with stealth and burst damage', 5);
```

---

## Implementation Sequence

### Step 1: Module Skeleton — "Hello, Grizbop"
- Create directory structure
- Write `CMakeLists.txt` (minimal, no Lua dependency)
- Write `grizbop_loader.cpp` with empty `AddSC_` functions
- Write a WorldScript that logs `"[Grizbop] Module loaded."` on startup
- **Verify:** Compile, deploy, check worldserver log for the message

### Step 2: DataMap Bridge — `.grizbop run status`
- Implement `GrizbopRunState` struct
- Implement `OnLogin` to create the DataMap entry
- Implement `.grizbop run status` command that dumps the struct to chat
- **Verify:** Log in, run `.grizbop run status`, see default values

### Step 3: Archetype Commands — `.grizbop archetype`
- Create SQL tables, load archetype definitions at startup into a static cache
- Implement `set`, `clear`, `list` commands
- `set` applies: level change, morph, spell learning, item equipping, DataMap update
- **Verify:** `.grizbop archetype list` shows seed data, `.grizbop archetype set 1` transforms the character

### Step 4: Run Commands — `.grizbop run`
- Implement `start`, `stop`, `next`, `set` commands
- `start` sets `runActive = true`, `phase = IN_DUNGEON`, teleports to a hardcoded dungeon
- `stop` resets state, teleports to a hardcoded hub location
- `next` increments floor, teleports to next dungeon
- **Verify:** Complete start → next → next → stop loop

### Step 5: Permadeath Commands — `.grizbop debug die/revive`
- Implement `OnPlayerJustDied` hook (if run active: set `isAlive = false`, block rez)
- Implement `die` command that programmatically triggers the death flow
- Implement `revive` that resets `isAlive` and teleports to hub
- **Verify:** `.grizbop debug die` → character can't resurrect → `.grizbop debug revive` → character restored

### Step 6: Modifier Commands — `.grizbop mod`
- Implement `add`, `remove`, `clear`, `list`
- For now, `add` just calls `Player::AddAura(spellId)` with a real spell ID (e.g., a basic stat buff)
- `list` iterates `activeModifiers` vector and prints spell names
- **Verify:** `.grizbop mod add 17` (Power Word: Shield) → visible buff → `.grizbop mod clear` → buff removed

---

## Verification Plan

### Automated
- Module compiles without warnings (`-Werror` is enforced by CI)
- Worldserver starts and logs `[Grizbop] Module loaded.`
- All 18 commands appear in `.help grizbop`

### Manual (In-Game)
1. Log in with a fresh character
2. `.grizbop run status` → see IDLE state
3. `.grizbop archetype list` → see 6 seed archetypes
4. `.grizbop archetype set 1` → character transforms, level changes
5. `.grizbop run start` → teleported to dungeon, status shows IN_DUNGEON
6. `.grizbop mod add <spellId>` → buff appears on character
7. `.grizbop debug die` → permadeath fires, can't resurrect
8. `.grizbop debug revive` → character alive, back in hub
9. `.grizbop run stop` → clean return to IDLE

---

## Confirmed: Hub Location — Caverns of Time

> [!IMPORTANT]
> **The Grizbop Hub is the Caverns of Time interior** (Map 1 / Kalimdor). This is perfect:
> - **Thematically:** "Outside of time" — exactly what a rogue-lite loop *is*.
> - **Architecturally:** It's a large, open indoor area on the main Kalimdor map (no instance needed). Multiple alcoves and corridors for shop NPCs, combat dummies, portals.
> - **Existing NPCs:** The Keepers of Time NPCs are already there. We can repurpose or despawn them.
> - **Accessibility:** Already has grid/navmesh data. Players can walk around naturally.

### Hub Coordinates

| Location | Map | X | Y | Z | O | Use |
|---|---|---|---|---|---|---|
| **Surface Entrance** | 1 | -8204.88 | -4495.25 | 9.01 | 4.73 | `.tele CavernsOfTime` (existing) |
| **Interior — Andormu (Child)** | 1 | -8371.93 | -4250.21 | -204.38 | 4.15 | Near the instance portals — good for "Begin Run" NPC |
| **Interior — Andormu (Adult)** | 1 | -8589.53 | -4194.63 | -208.67 | 3.05 | Deeper in the cavern — good for Grizbop's main throne/shop area |

**Default hub spawn point for `.grizbop run stop` and post-permadeath teleport:**
```cpp
// Caverns of Time interior — near the main chamber
constexpr uint32 GRIZBOP_HUB_MAP   = 1;       // Kalimdor
constexpr float  GRIZBOP_HUB_X     = -8371.93f;
constexpr float  GRIZBOP_HUB_Y     = -4250.21f;
constexpr float  GRIZBOP_HUB_Z     = -204.38f;
constexpr float  GRIZBOP_HUB_O     = 4.15f;
```
