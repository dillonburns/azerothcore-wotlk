# WoW: Free Grizbop — Game Design

**WoW: Free Grizbop** is a custom World of Warcraft (3.3.5a) rogue-lite private server. It transforms the traditional MMO engine into a highly replayable, arcade-style experience featuring permadeath, wild metaprogression, and customized class archetypes.

### Lore & Tone

The game is hosted by **Grizbop**, a goblin engineer who has recently realized he is inside a video game. To further his mysterious [TBD] goals, he is "recruiting" (read: relentlessly cloning) players and sending them into deadly dungeon runs. The tone is silly, slightly unhinged, and frequently 4th-wall breaking — "this goblin is learning devops to try to eject himself" energy.

---

## Core Gameplay Loop

- **The Run:** Every run begins with a fresh clone. Death is permanent, but metaprogression passes down certain buffs, items, or rewards to the next character.
- **Metaprogression:** TBD
- **Leveling:** Characters begin at **Level 5** and can level to **Level 60**. XP gain is accelerated but normalized through combat and dungeon progression.
- **Party Scaling:** Supports solo play and standard 5-player co-op groups.

---

## Dungeon Runs

- **Pacing:** The run is a continuous gauntlet of varying dungeons, not a single mega-dungeon.
- **Boss Defeat Rewards:** After _every_ boss, players encounter a random reward NPC (Chef offering food buffs, Enchanter offering weapon enchants, Tailor offering gear/bags).
- **Completion Rewards:** Defeating a dungeon's final boss yields major gear and the chance to absorb the boss's essence for a powerful buff.

---

## Character Creation

- **The Raw Clone:** Standard WoW character creation produces a "raw, unfinished clone." V1 supports a limited set of standard WoW classes and races.
- **Free Grizbop Specializations:** Upon entering the world, players choose a specialization — a pared-down, arcadey preset. Each class has 3 unique archetypes that don't follow standard WoW talent trees.
    - _Examples:_ Warrior → beefy shield-tank, massive 2H Whirlwind DPS, or mobile 1H sword build with low-cooldown Charge. Mage → tiny model with low gravity and lightning attacks.
- **The Preset Package:** An archetype locks in: character morph/model, pre-selected talents, preset starting abilities, and starter gear.
- **The Kickoff:** After selecting an archetype, the player gets **1 random roguelike decision** to start diverging their build.

---

## Roguelike Mechanics

**Boss Essence Capture:**
Every boss kill offers an essence capture — a stronger-than-normal buff. The _same_ essence choice is offered to the entire party for strategic synergy.

**Wild Modifiers:**
Buffs and nerfs go far beyond standard stats: becoming massive or tiny, low gravity, fire-damage farts, healing spells dealing damage instead, and more.

**Acquisition Systems:**
Food, enchants, gear stats, persistent buff auras, and more.

**Modifiable Stats & Attributes:**
Stamina, Intellect, Agility, Strength, Spirit, max resources (Energy/Mana/HP), character scale, movement speed, jump height & fall speed, attack speed/haste, procs (e.g. Chain Lightning on hit), attack/spell range, resource generation (MP5/Rage/Energy regen), stealth, temporary flight, extra lives, AoE conversion, and more.

**Dungeon Modifiers:**
All enemies become a certain type, all enemies are tiny, bigger aggro radius, two bosses, and more.

---

> For technical architecture and implementation details, see [ARCHITECTURE.md](ARCHITECTURE.md).
