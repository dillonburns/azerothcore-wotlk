-- ==============================================================================
-- ROGUE-LITE SYSTEM: The Tabula Rasa (Player Initialization & Reset)
-- ==============================================================================

-- The exact coordinates from your Caverns of Time screenshot
local HUB_MAP = 1
local HUB_X = -8503.275
local HUB_Y = -4508.954
local HUB_Z = -211.97311
local HUB_O = 1.4679132

-- The core reset function
local function PerformTabulaRasa(target)
    -- 1. Strip Default Blizzard Starting Gear & Items
    for slot = 0, 38 do
        local item = target:GetItemByPos(255, slot)
        if item then
            target:RemoveItem(item:GetEntry(), item:GetCount())
        end
    end

    -- 2. The Great Purge (Racials & Starting Class Spells)
    local SpellsToPurge = {
        -- Racials
        20599, 20598, 20864, 20597, 59752, 58985, 2481, 20596, 20595, 20594, 20589,
        20582, 20583, 20585, 58984, 21009, 20592, 20593, 20580, 20591, 28875, 6562, 
        28877, 59542, 59543, 59544, 59545, 59547, 59548, 59221, 20572, 20573, 20574, 
        21563, 7744, 20577, 20579, 20578, 20549, 20550, 20551, 20552, 20554, 20557, 
        20558, 26290, 58943, 28878, 822, 28730, 25046, 50613,
        -- Base Class Spells
        78, 2457, 100, 21084, 20271, 635, 75, 2973, 13163, 1752, 2098, 2764,
        585, 1243, 2050, 331, 403, 8071, 133, 168, 5143, 686, 688, 318, 5176, 818, 5185
    }

    for _, spellId in ipairs(SpellsToPurge) do
        if target:HasSpell(spellId) then
            target:RemoveSpell(spellId)
        end
    end

    -- 3. Grant Universal Proficiencies
    local proficiencies = {
        81, 8737, 750, 9116, -- Armor
        201, 202, 196, 197, 198, 199, 1180, 227, 200, 15590, -- Melee
        264, 5011, 266, 5009, 2567, -- Ranged
        1181, 3018 -- Mechanics
    }

    for _, spellId in ipairs(proficiencies) do
        target:LearnSpell(spellId)
    end

    -- 4. Establish Baseline Stats
    target:SetLevel(5)
    target:SetHealth(target:GetMaxHealth())
    if target:GetMaxPower(0) > 0 then
        target:SetPower(0, target:GetMaxPower(0)) -- Restore Mana
    end

    -- 5. Teleport to the Caverns of Time Hub
    target:Teleport(HUB_MAP, HUB_X, HUB_Y, HUB_Z, HUB_O)

    target:SendBroadcastMessage("|cff00ffffSystem:|r Your soul has been wiped clean. Welcome to the Astral Plane.")
end

-- ==============================================================================
-- TRIGGERS
-- ==============================================================================

-- Trigger 1: Automatic on Character Creation / First Login
local function OnFirstLogin(event, player)
    PerformTabulaRasa(player)
end

-- Trigger 2: Manual GM Command (.resetplayer)
local function OnPlayerCommand(event, player, command)
    -- Parse the command string (Event 42 ignores the '.' prefix)
    local cmd, args = command:match("^(%S+)%s*(.*)$")
    if not cmd then
        cmd = command
        args = ""
    end

    if cmd:lower() == "resetplayer" then
        -- Optional: Ensure only GMs can use this command
        if player:GetGMRank() < 3 then 
            return false 
        end
        
        local target = nil

        -- Priority 1: Check if they typed a name (e.g., .resetplayer Arthas)
        if args and args ~= "" then
            target = GetPlayerByName(args)
        -- Priority 2: Check if they have a player targeted
        else
            local selection = player:GetSelection()
            if selection and selection:GetObjectType() == "Player" then
                target = selection:ToPlayer()
            end
        end

        -- Priority 3: If no name and no target, reset themselves
        if not target then
            target = player
        end

        -- Execute the reset
        if target then
            PerformTabulaRasa(target)
            player:SendBroadcastMessage("Success: " .. target:GetName() .. " has been reset to the Astral Plane.")
        else
            player:SendBroadcastMessage("|cffff0000Error:|r Could not find that player.")
        end

        return false -- Hides the command from the chat window
    end
end

-- Register Events
RegisterPlayerEvent(30, OnFirstLogin)      -- Hook First Login
RegisterPlayerEvent(42, OnPlayerCommand)   -- Hook Chat Commands