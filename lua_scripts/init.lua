-- ==========================================
-- init.lua
-- Verify Lua engine and Wormhole binding
-- ==========================================
SendWorldMessage("|cff00ff00[ALE]|r Lua tunnel online")

-- Server Startup Verification (Console Output)
local function OnServerStartup(event)
    print("\n==================================================")
    print("[ALE] MOD_ALE LUA ENGINE INITIALIZED")
    print("[ALE] The Wormhole is active.")
    print("==================================================\n")
end

-- Custom Commands (Intercepting the C++ parser)
local function OnPlayerCommand(event, player, command)
    -- The core strips the "." prefix. 
    -- We use :match("^(%S+)") to grab just the first word, ignoring any extra arguments.
    local cmd = command:lower():match("^(%S+)")

    if cmd == "ping" then
        player:SendBroadcastMessage("pong")
        return false -- Returning false suppresses the C++ "There is no such command" error
    elseif cmd == "test" then
        player:SendBroadcastMessage("success")
        return false
    end
end

-- Register Events
RegisterServerEvent(14, OnServerStartup) -- Event 14: SERVER_EVENT_ON_STARTUP
RegisterPlayerEvent(42, OnPlayerCommand) -- Event 18: PLAYER_EVENT_ON_CHAT