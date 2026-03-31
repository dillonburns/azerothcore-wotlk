-- ==============================================================================
-- ROGUE-LITE SYSTEM: Archetype Prototype NPC
-- ==============================================================================

local NPC_ID = 8737 -- CHANGE THIS to your test NPC Entry ID

-- The Data: Our Rogue-lite starting loadouts (Level 5 Balanced)
local Archetypes = {
    [1] = {
        name = "The Shadowblade",
        morph = 21752, -- Akama
        spells = { 1752, 2098, 1784 }, -- Sinister Strike, Eviscerate, Stealth
        gear = {
            [15] = 1197,  -- Main Hand: Bronze Shortsword (White, Lvl 4)
            [16] = 2093,  -- Off Hand: Bronze Dagger (White, Lvl 5)
            [5]  = 1810,  -- Chest: Tough Leather Armor (White, Lvl 5)
            [10] = 1807,  -- Gloves: Tough Leather Gloves
            [6]  = 1803,  -- Belt: Tough Leather Belt
            [7]  = 1808,  -- Pants: Tough Leather Pants
            [8]  = 1804,  -- Shoes: Tough Leather Boots
            [11] = 11984, -- Ring: Band of Agility (+2 Agi, Green)
        }
    },
    [2] = {
        name = "The Pyromancer",
        morph = 18970, -- Medivh
        spells = { 133, 2136, 118 }, -- Fireball, Fire Blast, Polymorph
        gear = {
            [15] = 1159,  -- Main Hand: Militia Quarterstaff 
            [5]  = 56,    -- Chest: Apprentice's Robe (White, Lvl 4)
            [10] = 2465,  -- Gloves: Apprentice's Gloves
            [6]  = 2466,  -- Belt: Apprentice's Sash
            [7]  = 55,    -- Pants: Apprentice's Pants
            [8]  = 54,    -- Shoes: Apprentice's Boots
            [11] = 11986, -- Ring: Band of Intellect (+2 Int, Green)
        }
    },
    [3] = {
        name = "The Ursine Bulwark",
        morph = 2281, -- Dire Bear Form
        spells = { 6807, 779, 5229 }, -- Maul, Swipe, Enrage
        gear = {
            [15] = 2461,  -- Main Hand: Wooden Mallet (White 2H Mace, Lvl 5)
            [5]  = 1351,  -- Chest: Burnt Leather Vest (White, Lvl 7)
            [10] = 1349,  -- Gloves: Burnt Leather Gloves
            [6]  = 1347,  -- Belt: Burnt Leather Belt
            [7]  = 1352,  -- Pants: Burnt Leather Breeches
            [8]  = 1348,  -- Shoes: Burnt Leather Boots
            [11] = 11985, -- Ring: Band of Stamina (+2 Sta, Green)
        }
    },
    [4] = {
        name = "The Iron Vanguard",
        morph = 19723, -- Fel Orc Blademaster
        spells = { 100, 12294, 6343 }, -- Charge, Mortal Strike, Thunder Clap
        gear = {
            [15] = 1199,  -- Main Hand: Copper Claymore (White 2H Sword, Lvl 5)
            [5]  = 2368,  -- Chest: Banded Armor (White Mail, Lvl 5)
            [10] = 2366,  -- Gloves: Banded Gauntlets
            [6]  = 2367,  -- Belt: Banded Girdle
            [7]  = 2369,  -- Pants: Banded Leggings
            [8]  = 2365,  -- Shoes: Banded Boots
            [11] = 11987, -- Ring: Band of Strength (+2 Str, Green)
        }
    },
    [5] = {
        name = "The Divine Oracle",
        morph = 3674, -- High Inquisitor Whitemane
        spells = { 2061, 139, 585 }, -- Flash Heal, Renew, Smite
        gear = {
            [15] = 2463,  -- Main Hand: Light Mace (White 1H, Lvl 5)
            [16] = 2362,  -- Off Hand: Worn Wooden Shield (White, Lvl 5)
            [5]  = 57,    -- Chest: Acolyte's Robe (White, Lvl 5)
            [10] = 2468,  -- Gloves: Acolyte's Gloves
            [6]  = 2469,  -- Belt: Acolyte's Sash
            [7]  = 58,    -- Pants: Acolyte's Pants
            [8]  = 59,    -- Shoes: Acolyte's Shoes
            [11] = 11986, -- Ring: Band of Intellect (+2 Int, Green)
        }
    }
}

-- ==============================================================================
-- THE LOGIC
-- ==============================================================================

local function CleansePlayer(player)
    -- 1. Remove Morph
    player:DeMorph()

    -- 2. Strip Equipped Gear & Main Backpack
    -- Slots 0-18: Equipment. Slots 23-38: Main Backpack. 
    -- We loop 0 to 38 to blindly catch everything in the primary inventory.
    for slot = 0, 38 do
        local item = player:GetItemByPos(255, slot)
        if item then
            -- We get the item's Entry ID and Count to safely destroy it
            player:RemoveItem(item:GetEntry(), item:GetCount()) 
        end
    end

    -- 3. Strip ALL Prototype Spells
    -- We loop through our data table and remove any spells the archetypes offer
    for _, data in pairs(Archetypes) do
        if data.spells then
            for _, spellId in ipairs(data.spells) do
                if player:HasSpell(spellId) then
                    player:RemoveSpell(spellId)
                end
            end
        end
    end
end

local function OnGossipHello(event, player, object)
    -- Dynamically build the menu from the Archetypes table
    for id, data in pairs(Archetypes) do
        player:GossipMenuAddItem(0, "Become " .. data.name, 0, id)
    end
    player:GossipSendMenu(1, object)
end

local function OnGossipSelect(event, player, object, sender, intid, code, menu_id)
    local selection = Archetypes[intid]
    
    if selection then
        -- Wipe the slate clean (Gear, Spells, and Bags)
        CleansePlayer(player)
        
        -- Apply new life
        if selection.morph then
            player:SetDisplayId(selection.morph)
        end
        
        if selection.spells then
            for _, spellId in ipairs(selection.spells) do
                player:LearnSpell(spellId)
            end
        end
        
        if selection.gear then
            for slot, itemEntry in pairs(selection.gear) do
                player:AddItem(itemEntry, 1) -- Drops the starting gear in their freshly cleaned bag
            end
        end
        
        player:SendBroadcastMessage("|cff00ff00System:|r You have been reborn as " .. selection.name)
    end
    
    player:GossipComplete()
end

-- Hook the events
RegisterCreatureGossipEvent(NPC_ID, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_ID, 2, OnGossipSelect)