-- Caverns of Time 

local HUB_MAP = 1
local HUB_X = -8503.275
local HUB_Y = -4508.954
local HUB_Z = -211.97311
local HUB_O = 1.4679132

-- The core reset function
local function PerformTabulaRasa(target)
    target:Teleport(HUB_MAP, HUB_X, HUB_Y, HUB_Z, HUB_O)
    target:SendBroadcastMessage("|cff00ffffSystem:|r You are birthed anew.")
end

local function OnFirstLogin(event, player)
    PerformTabulaRasa(player)
end

RegisterPlayerEvent(30, OnFirstLogin)