---@meta

-- Generated from mod-ale bindings and docs.
-- Sources:
--   modules/mod-ale/src/LuaEngine/LuaFunctions.cpp
--   modules/mod-ale/src/LuaEngine/methods/GlobalMethods.h
-- Regenerate with: python3 tools/gen_mod_ale_lua_stubs.py

---@overload fun(entry: integer, event: integer, callback: function): function
---@overload fun(entry: integer, event: integer, callback: function, shots?: integer): function
---@diagnostic disable-next-line: duplicate-set-field
function RegisterPacketEvent(...) end

---@overload fun(event: integer, callback: function): function
---@overload fun(event: integer, callback: function, shots?: integer): function
---@diagnostic disable-next-line: duplicate-set-field
function RegisterServerEvent(...) end

---@overload fun(event: integer, callback: function): function
---@overload fun(event: integer, callback: function, shots?: integer): function
---@diagnostic disable-next-line: duplicate-set-field
function RegisterPlayerEvent(...) end

---@overload fun(event: integer, callback: function): function
---@overload fun(event: integer, callback: function, shots?: integer): function
---@diagnostic disable-next-line: duplicate-set-field
function RegisterGuildEvent(...) end

---@overload fun(event: integer, callback: function): function
---@overload fun(event: integer, callback: function, shots?: integer): function
---@diagnostic disable-next-line: duplicate-set-field
function RegisterGroupEvent(...) end

---@overload fun(entry: integer, event: integer, callback: function): function
---@overload fun(entry: integer, event: integer, callback: function, shots?: integer): function
---@diagnostic disable-next-line: duplicate-set-field
function RegisterCreatureEvent(...) end

---@overload fun(guid: any, instance_id: integer, event: integer, callback: function): function
---@overload fun(guid: any, instance_id: integer, event: integer, callback: function, shots?: integer): function
---@diagnostic disable-next-line: duplicate-set-field
function RegisterUniqueCreatureEvent(...) end

---@overload fun(entry: integer, event: integer, callback: function): function
---@overload fun(entry: integer, event: integer, callback: function, shots?: integer): function
---@diagnostic disable-next-line: duplicate-set-field
function RegisterCreatureGossipEvent(...) end

---@overload fun(entry: integer, event: integer, callback: function): function
---@overload fun(entry: integer, event: integer, callback: function, shots?: integer): function
---@diagnostic disable-next-line: duplicate-set-field
function RegisterGameObjectEvent(...) end

---@overload fun(entry: integer, event: integer, callback: function): function
---@overload fun(entry: integer, event: integer, callback: function, shots?: integer): function
---@diagnostic disable-next-line: duplicate-set-field
function RegisterGameObjectGossipEvent(...) end

---@overload fun(entry: integer, event: integer, callback: function): function
---@overload fun(entry: integer, event: integer, callback: function, shots?: integer): function
---@diagnostic disable-next-line: duplicate-set-field
function RegisterItemEvent(...) end

---@overload fun(entry: integer, event: integer, callback: function): function
---@overload fun(entry: integer, event: integer, callback: function, shots?: integer): function
---@diagnostic disable-next-line: duplicate-set-field
function RegisterItemGossipEvent(...) end

---@overload fun(menu_id: integer, event: integer, callback: function): function
---@overload fun(menu_id: integer, event: integer, callback: function, shots?: integer): function
---@diagnostic disable-next-line: duplicate-set-field
function RegisterPlayerGossipEvent(...) end

---@overload fun(event: integer, callback: function): function
---@overload fun(event: integer, callback: function, shots?: integer): function
---@diagnostic disable-next-line: duplicate-set-field
function RegisterBGEvent(...) end

---@overload fun(map_id: integer, event: integer, callback: function, shots?: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function RegisterMapEvent(...) end

---@overload fun(instance_id: integer, event: integer, callback: function, shots?: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function RegisterInstanceEvent(...) end

---@overload fun(event: integer, callback: function, shots?: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function RegisterTicketEvent(...) end

---@overload fun(entry: integer, event: integer, callback: function, shots?: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function RegisterSpellEvent(...) end

---@overload fun(event: integer, callback: function, shots?: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function RegisterAllCreatureEvent(...) end

---@overload fun(): any
---@overload fun(event_type: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function ClearBattleGroundEvents(...) end

---@overload fun(entry: integer): any
---@overload fun(entry: integer, event_type: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function ClearCreatureEvents(...) end

---@overload fun(entry: any): any
---@overload fun(entry: any, event_type: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function ClearUniqueCreatureEvents(...) end

---@overload fun(entry: integer): any
---@overload fun(entry: integer, event_type: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function ClearCreatureGossipEvents(...) end

---@overload fun(entry: integer): any
---@overload fun(entry: integer, event_type: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function ClearGameObjectEvents(...) end

---@overload fun(entry: integer): any
---@overload fun(entry: integer, event_type: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function ClearGameObjectGossipEvents(...) end

---@overload fun(): any
---@overload fun(event_type: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function ClearGroupEvents(...) end

---@overload fun(): any
---@overload fun(event_type: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function ClearGuildEvents(...) end

---@overload fun(entry: integer): any
---@overload fun(entry: integer, event_type: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function ClearItemEvents(...) end

---@overload fun(entry: integer): any
---@overload fun(entry: integer, event_type: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function ClearItemGossipEvents(...) end

---@overload fun(opcode: integer): any
---@overload fun(opcode: integer, event_type: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function ClearPacketEvents(...) end

---@overload fun(): any
---@overload fun(event_type: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function ClearPlayerEvents(...) end

---@overload fun(entry: integer): any
---@overload fun(entry: integer, event_type: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function ClearPlayerGossipEvents(...) end

---@overload fun(): any
---@overload fun(event_type: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function ClearServerEvents(...) end

---@overload fun(map_id: integer): any
---@overload fun(map_id: integer, event_type: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function ClearMapEvents(...) end

---@overload fun(instance_id: any): any
---@overload fun(instance_id: any, event_type: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function ClearInstanceEvents(...) end

---@overload fun(): any
---@overload fun(event_type: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function ClearTicketEvents(...) end

---@overload fun(entry: integer): any
---@overload fun(entry: integer, event_type: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function ClearSpellEvents(...) end

---@overload fun(): any
---@overload fun(event_type: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function ClearAllCreatureEvents(...) end

---@diagnostic disable-next-line: duplicate-set-field
function GetLuaEngine(...) end

---@diagnostic disable-next-line: duplicate-set-field
function GetCoreName(...) end

---@overload fun(name: string): any
---@diagnostic disable-next-line: duplicate-set-field
function GetConfigValue(...) end

---@diagnostic disable-next-line: duplicate-set-field
function GetRealmID(...) end

---@diagnostic disable-next-line: duplicate-set-field
function GetCoreVersion(...) end

---@diagnostic disable-next-line: duplicate-set-field
function GetCoreExpansion(...) end

---@diagnostic disable-next-line: duplicate-set-field
function GetStateMap(...) end

---@diagnostic disable-next-line: duplicate-set-field
function GetStateMapId(...) end

---@diagnostic disable-next-line: duplicate-set-field
function GetStateInstanceId(...) end

---@overload fun(questId: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function GetQuest(...) end

---@overload fun(guid: any): any
---@diagnostic disable-next-line: duplicate-set-field
function GetPlayerByGUID(...) end

---@overload fun(name: string): any
---@diagnostic disable-next-line: duplicate-set-field
function GetPlayerByName(...) end

---@diagnostic disable-next-line: duplicate-set-field
function GetGameTime(...) end

---@overload fun(team?: any, onlyGM?: boolean): any
---@diagnostic disable-next-line: duplicate-set-field
function GetPlayersInWorld(...) end

---@overload fun(name: string): any
---@diagnostic disable-next-line: duplicate-set-field
function GetGuildByName(...) end

---@overload fun(guid: any): any
---@diagnostic disable-next-line: duplicate-set-field
function GetGuildByLeaderGUID(...) end

---@diagnostic disable-next-line: duplicate-set-field
function GetPlayerCount(...) end

---@overload fun(lowguid: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function GetPlayerGUID(...) end

---@overload fun(lowguid: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function GetItemGUID(...) end

---@overload fun(itemID: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function GetItemTemplate(...) end

---@overload fun(lowguid: integer, entry: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function GetObjectGUID(...) end

---@overload fun(lowguid: integer, entry: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function GetUnitGUID(...) end

---@overload fun(guid: any): any
---@diagnostic disable-next-line: duplicate-set-field
function GetGUIDLow(...) end

---@overload fun(guid: any): any
---@diagnostic disable-next-line: duplicate-set-field
function GetGUIDType(...) end

---@overload fun(guid: any): any
---@diagnostic disable-next-line: duplicate-set-field
function GetGUIDEntry(...) end

---@overload fun(guid: any): any
---@diagnostic disable-next-line: duplicate-set-field
function GetPackedGUIDSize(...) end

---@overload fun(areaOrZoneId: integer, locale?: any): any
---@diagnostic disable-next-line: duplicate-set-field
function GetAreaName(...) end

---@diagnostic disable-next-line: duplicate-set-field
function GetOwnerHalaa(...) end

---@overload fun(a: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function bit_not(...) end

---@overload fun(a: integer, b: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function bit_xor(...) end

---@overload fun(a: integer, b: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function bit_rshift(...) end

---@overload fun(a: integer, b: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function bit_lshift(...) end

---@overload fun(a: integer, b: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function bit_or(...) end

---@overload fun(a: integer, b: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function bit_and(...) end

---@overload fun(entry: integer, locale?: any): any
---@diagnostic disable-next-line: duplicate-set-field
function GetItemLink(...) end

---@overload fun(mapId: integer, instanceId?: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function GetMapById(...) end

---@diagnostic disable-next-line: duplicate-set-field
function GetCurrTime(...) end

---@overload fun(oldTime: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function GetTimeDiff(...) end

---@diagnostic disable-next-line: duplicate-set-field
function PrintInfo(...) end

---@diagnostic disable-next-line: duplicate-set-field
function PrintError(...) end

---@diagnostic disable-next-line: duplicate-set-field
function PrintDebug(...) end

---@diagnostic disable-next-line: duplicate-set-field
function GetActiveGameEvents(...) end

---@overload fun(menuId: integer, optionId: integer, locale: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function GetGossipMenuOptionLocale(...) end

---@overload fun(mapId: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function GetMapEntrance(...) end

---@overload fun(spellId: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function GetSpellInfo(...) end

---@diagnostic disable-next-line: duplicate-set-field
function IsCompatibilityMode(...) end

---@overload fun(bag: integer, slot: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function IsInventoryPos(...) end

---@overload fun(bag: integer, slot: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function IsEquipmentPos(...) end

---@overload fun(bag: integer, slot: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function IsBankPos(...) end

---@overload fun(bag: integer, slot: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function IsBagPos(...) end

---@overload fun(eventId: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function IsGameEventActive(...) end

---@diagnostic disable-next-line: duplicate-set-field
function ReloadALE(...) end

---@overload fun(command: string): any
---@diagnostic disable-next-line: duplicate-set-field
function RunCommand(...) end

---@overload fun(message: string): any
---@diagnostic disable-next-line: duplicate-set-field
function SendWorldMessage(...) end

---@overload fun(sql: string): any
---@diagnostic disable-next-line: duplicate-set-field
function WorldDBQuery(...) end

---@overload fun(sql: string, callback: function): any
---@diagnostic disable-next-line: duplicate-set-field
function WorldDBQueryAsync(...) end

---@overload fun(sql: string): any
---@diagnostic disable-next-line: duplicate-set-field
function WorldDBExecute(...) end

---@overload fun(sql: string): any
---@diagnostic disable-next-line: duplicate-set-field
function CharDBQuery(...) end

---@overload fun(sql: string, callback: function): any
---@diagnostic disable-next-line: duplicate-set-field
function CharDBQueryAsync(...) end

---@overload fun(sql: string): any
---@diagnostic disable-next-line: duplicate-set-field
function CharDBExecute(...) end

---@overload fun(sql: string): any
---@diagnostic disable-next-line: duplicate-set-field
function AuthDBQuery(...) end

---@overload fun(sql: string, callback: function): any
---@diagnostic disable-next-line: duplicate-set-field
function AuthDBQueryAsync(...) end

---@overload fun(sql: string): any
---@diagnostic disable-next-line: duplicate-set-field
function AuthDBExecute(...) end

---@overload fun(callback: function, delay: integer): any
---@overload fun(callback: function, delaytable: any): any
---@overload fun(callback: function, delay: integer, repeats?: integer): any
---@overload fun(callback: function, delaytable: any, repeats?: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function CreateLuaEvent(...) end

---@overload fun(eventId: integer, all_Events?: boolean): any
---@diagnostic disable-next-line: duplicate-set-field
function RemoveEventById(...) end

---@overload fun(all_Events?: boolean): any
---@diagnostic disable-next-line: duplicate-set-field
function RemoveEvents(...) end

---@overload fun(spawnType: integer, entry: integer, mapId: integer, instanceId: integer, x: number, y: number, z: number, o: number, save?: boolean, durorresptime?: integer, phase?: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function PerformIngameSpawn(...) end

---@overload fun(opcode: any, size: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function CreatePacket(...) end

---@overload fun(entry: integer, item: integer, maxcount: integer, incrtime: integer, extendedcost: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function AddVendorItem(...) end

---@overload fun(entry: integer, item: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function VendorRemoveItem(...) end

---@overload fun(entry: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function VendorRemoveAllItems(...) end

---@overload fun(player: any): any
---@diagnostic disable-next-line: duplicate-set-field
function Kick(...) end

---@overload fun(banMode: any, nameOrIP: string, duration: integer, reason?: string, whoBanned?: string): any
---@diagnostic disable-next-line: duplicate-set-field
function Ban(...) end

---@diagnostic disable-next-line: duplicate-set-field
function SaveAllPlayers(...) end

---@overload fun(subject: string, text: string, receiverGUIDLow: integer, senderGUIDLow?: integer, stationary?: any, delay?: integer, money?: integer, cod?: integer, entry?: integer, amount?: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function SendMail(...) end

---@overload fun(waypoints: any, mountA: integer, mountH: integer, price?: integer, pathId?: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function AddTaxiPath(...) end

---@diagnostic disable-next-line: duplicate-set-field
function CreateInt64(...) end

---@diagnostic disable-next-line: duplicate-set-field
function CreateUint64(...) end

---@overload fun(eventId: integer, force?: boolean): any
---@diagnostic disable-next-line: duplicate-set-field
function StartGameEvent(...) end

---@overload fun(eventId: integer, force?: boolean): any
---@diagnostic disable-next-line: duplicate-set-field
function StopGameEvent(...) end

---@overload fun(httpMethod: string, url: string, callback: function): any
---@overload fun(httpMethod: string, url: string, headers: any, callback: function): any
---@overload fun(httpMethod: string, url: string, body: string, contentType: string, callback: function): any
---@overload fun(httpMethod: string, url: string, body: string, contentType: string, headers: any, callback: function): any
---@diagnostic disable-next-line: duplicate-set-field
function HttpRequest(...) end

---@overload fun(teamId: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function SetOwnerHalaa(...) end

---@overload fun(dbcName: string, id: integer): any
---@diagnostic disable-next-line: duplicate-set-field
function LookupEntry(...) end
