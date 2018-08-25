require("config")
class = require("classy")
tableHelper = require("tableHelper")
require("utils")
require("guiIds")
require("color")
require("time")

myMod = require("myMod")
animHelper = require("animHelper")
speechHelper = require("speechHelper")
menuHelper = require("menuHelper")
scriptLoader = require("ScriptLoader")

Database = nil
Player = nil
Cell = nil
World = nil

banList = {}
pluginList = {}
timeCounter = config.timeServerInitTime

if (config.databaseType ~= nil and config.databaseType ~= "json") and doesModuleExist("luasql." .. config.databaseType) then

    Database = require("database")
    Database:LoadDriver(config.databaseType)

    tes3mp.LogMessage(1, "Using " .. Database.driver._VERSION .. " with " .. config.databaseType .. " driver")

    Database:Connect(config.databasePath)

    -- Make sure we enable foreign keys
    Database:Execute("PRAGMA foreign_keys = ON;")

    Database:CreatePlayerTables()
    Database:CreateWorldTables()

    Player = require("player.sql")
    Cell = require("cell.sql")
    World = require("world.sql")
else
    Player = require("player.json")
    Cell = require("cell.json")
    World = require("world.json")
end



-- Handle commands that only exist based on config options


function LoadBanList()
    tes3mp.LogMessage(2, "Reading banlist.json")
    banList = jsonInterface.load("banlist.json")

    if banList.playerNames == nil then
        banList.playerNames = {}
    elseif banList.ipAddresses == nil then
        banList.ipAddresses = {}
    end

    if #banList.ipAddresses > 0 then
        local message = "- Banning manually-added IP addresses:\n"

        for index, ipAddress in pairs(banList.ipAddresses) do
            message = message .. ipAddress

            if index < #banList.ipAddresses then
                message = message .. ", "
            end

            tes3mp.BanAddress(ipAddress)
        end

        tes3mp.LogAppend(2, message)
    end

    if #banList.playerNames > 0 then
        local message = "- Banning all IP addresses stored for players:\n"

        for index, targetName in pairs(banList.playerNames) do
            message = message .. targetName

            if index < #banList.playerNames then
                message = message .. ", "
            end

            local targetPlayer = myMod.GetPlayerByName(targetName)

            if targetPlayer ~= nil then

                for index, ipAddress in pairs(targetPlayer.data.ipAddresses) do
                    tes3mp.BanAddress(ipAddress)
                end
            end
        end

        tes3mp.LogAppend(2, message)
    end
end

function SaveBanList()
    jsonInterface.save("banlist.json", banList)
end

function LoadPluginList()
    tes3mp.LogMessage(2, "Reading pluginlist.json")

    local jsonPluginList = jsonInterface.load("pluginlist.json")

    -- Fix numerical keys to print plugins in the correct order
    tableHelper.fixNumericalKeys(jsonPluginList, true)

    for listIndex, pluginEntry in ipairs(jsonPluginList) do
        for entryIndex, hashArray in pairs(pluginEntry) do
            pluginList[listIndex] = {entryIndex}
            io.write(("%d, {%s"):format(listIndex, entryIndex))
            for _, hash in ipairs(hashArray) do
                io.write((", %X"):format(tonumber(hash, 16)))
                table.insert(pluginList[listIndex], tonumber(hash, 16))
            end
            table.insert(pluginList[listIndex], "")
            io.write("}\n")
        end
    end
end

do
    local tid_ut = tes3mp.CreateTimer("UpdateTime", time.seconds(1))
    function UpdateTime()
        local hour = 0
        if config.timeSyncMode == 1 then
            timeCounter = timeCounter + (0.0083 * config.timeServerMult)
            hour = timeCounter
        elseif config.timeSyncMode == 2 then
            -- ToDo: implement like this
            -- local pid = GetFirstPlayer()
            -- hour = tes3mp.GetHours(pid)
        end
        local day = hour/24
        hour = math.fmod(hour, 24)
        for pid,_ in pairs(Players) do
            tes3mp.SetHour(pid, hour)
            tes3mp.SetDay(pid, day)
        end

        tes3mp.RestartTimer(tid_ut, time.seconds(1));
    end
    if config.timeSyncMode ~= 0 then
        tes3mp.StartTimer(tid_ut);
    end
end

do
    local adminsCounter = 0
    function IncrementAdminCounter()
        adminsCounter = adminsCounter + 1
        tes3mp.SetRuleValue("adminsOnline", adminsCounter)
    end
    function DecrementAdminCounter()
        adminsCounter = adminsCounter - 1
        tes3mp.SetRuleValue("adminsOnline", adminsCounter)
    end
    function ResetAdminCounter()
        adminsCounter = 0
        tes3mp.SetRuleValue("adminsOnline", adminsCounter)
    end
end

function OnServerInit()

    local expectedVersionPrefix = "0.6.2"
    local serverVersion = tes3mp.GetServerVersion()

    if string.sub(serverVersion, 1, string.len(expectedVersionPrefix)) ~= expectedVersionPrefix then
        tes3mp.LogAppend(3, "- Version mismatch between server and Core scripts!")
        tes3mp.LogAppend(3, "- The Core scripts require a server version that starts with " .. expectedVersionPrefix)
        tes3mp.StopServer(1)
    end

    myMod.InitializeWorld()
    myMod.PushPlayerList(Players)

    LoadBanList()
    LoadPluginList()
	
	scriptLoader.Init()

    tes3mp.SetPluginEnforcementState(config.enforcePlugins)
end

function OnServerPostInit()

    local consoleRuleString = "allowed"
    if not config.allowConsole then
        consoleRuleString = "not " .. consoleRuleString
    end

    local bedRestRuleString = "allowed"
    if not config.allowBedRest then
        bedRestRuleString = "not " .. bedRestRuleString
    end

    local wildRestRuleString = "allowed"
    if not config.allowWildernessRest then
        wildRestRuleString = "not " .. wildRestRuleString
    end

    local waitRuleString = "allowed"
    if not config.allowWait then
        waitRuleString = "not " .. waitRuleString
    end

    tes3mp.SetRuleString("enforcePlugins", tostring(config.enforcePlugins))
    tes3mp.SetRuleString("difficulty", tostring(config.difficulty))
    tes3mp.SetRuleString("console", consoleRuleString)
    tes3mp.SetRuleString("bedResting", bedRestRuleString)
    tes3mp.SetRuleString("wildernessResting", wildRestRuleString)
    tes3mp.SetRuleString("waiting", waitRuleString)
    tes3mp.SetRuleString("deathPenaltyJailDays", tostring(config.deathPenaltyJailDays))
    tes3mp.SetRuleString("spawnCell", tostring(config.defaultSpawnCell))
    tes3mp.SetRuleString("shareJournal", tostring(config.shareJournal))
    tes3mp.SetRuleString("shareFactionRanks", tostring(config.shareFactionRanks))
    tes3mp.SetRuleString("shareFactionExpulsion", tostring(config.shareFactionExpulsion))
    tes3mp.SetRuleString("shareFactionReputation", tostring(config.shareFactionReputation))

    local respawnCell

    if config.respawnAtImperialShrine == true then
        respawnCell = "nearest Imperial shrine"

        if config.respawnAtTribunalTemple == true then
            respawnCell = respawnCell .. " or Tribunal temple"
        end
    elseif config.respawnAtTribunalTemple == true then
        respawnCell = "nearest Tribunal temple"
    else
        respawnCell = tostring(config.defaultRespawnCell)
    end

    tes3mp.SetRuleString("respawnCell", respawnCell)
    ResetAdminCounter()
	scriptLoader.OnServerPostInit()
end

function OnServerExit(error)
    tes3mp.LogMessage(3, tostring(error))
end

function OnRequestPluginList(id, field)
    id = id + 1
    field = field + 1
    if #pluginList < id then
        return ""
    end
    return pluginList[id][field]
end

function OnPlayerConnect(pid)
    tes3mp.SetDifficulty(pid, config.difficulty)
    tes3mp.SetConsoleAllowed(pid, config.allowConsole)
    tes3mp.SetBedRestAllowed(pid, config.allowBedRest)
    tes3mp.SetWildernessRestAllowed(pid, config.allowWildernessRest)
    tes3mp.SetWaitAllowed(pid, config.allowWait)
    tes3mp.SendSettings(pid)

    local playerName = tes3mp.GetName(pid)

    if string.len(playerName) > 35 then
        playerName = string.sub(playerName, 0, 35)
    end

    if myMod.IsPlayerNameLoggedIn(playerName) then
        myMod.OnPlayerDeny(pid, playerName)
        return false -- deny player
    else
        tes3mp.LogMessage(1, "New player with pid("..pid..") connected!")
        myMod.OnPlayerConnect(pid, playerName)
		scriptLoader.OnPlayerConnect(pid)
        return true -- accept player
    end
end

function OnLoginTimeExpiration(pid) -- timer-based event, see myMod.OnPlayerConnect
    if myMod.AuthCheck(pid) then
        if Players[pid]:IsModerator() then
            IncrementAdminCounter()
        end
    end
end

function OnPlayerDisconnect(pid)
    tes3mp.LogMessage(1, "Player with pid " .. pid .. " disconnected.")
    local message = myMod.GetChatName(pid) .. " left the server.\n"

    tes3mp.SendMessage(pid, message, true)

    -- Was this player confiscating from someone? If so, clear that
    if Players[pid] ~= nil and Players[pid].confiscationTargetName ~= nil then
        local targetName = Players[pid].confiscationTargetName
        local targetPlayer = myMod.GetPlayerByName(targetName)
        targetPlayer:SetConfiscationState(false)
    end

    -- Trigger any necessary script events useful for saving state
    myMod.OnPlayerCellChange(pid)

    myMod.OnPlayerDisconnect(pid)
    DecrementAdminCounter()
end

function OnPlayerResurrect(pid)
	scriptLoader.OnPlayerResurrect(pid)
end

function OnPlayerSendMessage(pid, message)
    local playerName = tes3mp.GetName(pid)
    tes3mp.LogMessage(1, myMod.GetChatName(pid) .. ": " .. message)

    if myMod.OnPlayerMessage(pid, message) == false then
        return false
    end

    if message:sub(1,1) == '/' then
        local cmd = (message:sub(2, #message)):split(" ")

		if not scriptLoader.OnPlayerSendCommand(pid, cmd, message) then
            local message = "Not a valid command. Type /help for more info.\n"
            tes3mp.SendMessage(pid, color.Error..message..color.Default, false)
        end

        return false -- commands should be hidden
    end

    return scriptLoader.OnPlayerSendMessage(pid, message)
end

function OnObjectLoopTimeExpiration(loopIndex)
    myMod.OnObjectLoopTimeExpiration(loopIndex)
	scriptLoader.OnObjectLoopTimeExpiration(loopIndex)
end

function OnPlayerDeath(pid)
    myMod.OnPlayerDeath(pid)
	scriptLoader.OnPlayerDeath(pid)
end

function OnDeathTimeExpiration(pid)
    myMod.OnDeathTimeExpiration(pid)
	scriptLoader.OnDeathTimerExpiration(pid)
end

function OnPlayerAttribute(pid)
    myMod.OnPlayerAttribute(pid)
	scriptLoader.OnPlayerAttribute(pid)
end

function OnPlayerSkill(pid)
    myMod.OnPlayerSkill(pid)
	scriptLoader.OnPlayerSkill(pid)
end

function OnPlayerLevel(pid)
    myMod.OnPlayerLevel(pid)
	scriptLoader.OnPlayerLevel(pid)
end

function OnPlayerBounty(pid)
    myMod.OnPlayerBounty(pid)
	scriptLoader.OnPlayerBounty(pid)
end

function OnPlayerShapeshift(pid)
    myMod.OnPlayerShapeshift(pid)
	scriptLoader.OnPlayerShapeshift(pid)
end

function OnPlayerCellChange(pid)
    myMod.OnPlayerCellChange(pid)
	scriptLoader.OnPlayerCellChange(pid)
end

function OnPlayerEquipment(pid)
    myMod.OnPlayerEquipment(pid)
	scriptLoader.OnPlayerEquipment(pid)
end

function OnPlayerInventory(pid)
    myMod.OnPlayerInventory(pid)
	scriptLoader.OnPlayerInventory(pid)
end

function OnPlayerSpellbook(pid)
    myMod.OnPlayerSpellbook(pid)
	scriptLoader.OnPlayerSpellbook(pid)
end

function OnPlayerQuickKeys(pid)
    myMod.OnPlayerQuickKeys(pid)
	scriptLoader.OnPlayerQuickKeys(pid)
end

function OnPlayerJournal(pid)
    myMod.OnPlayerJournal(pid)
	scriptLoader.OnPlayerJournal(pid)
end

function OnPlayerFaction(pid)
    myMod.OnPlayerFaction(pid)
	scriptLoader.OnPlayerFaction(pid)
end

function OnPlayerTopic(pid)
    myMod.OnPlayerTopic(pid)
	scriptLoader.OnPlayerTopic(pid)
end

function OnPlayerKillCount(pid)
    myMod.OnPlayerKillCount(pid)
	scriptLoader.OnPlayerKillCount(pid)
end

function OnPlayerBook(pid)
    myMod.OnPlayerBook(pid)
	scriptLoader.OnPlayerBook(pid)
end

function OnPlayerEndCharGen(pid)
    myMod.OnPlayerEndCharGen(pid)
	scriptLoader.OnPlayerEndCharGen(pid)
end

function OnCellLoad(pid, cellDescription)
    myMod.OnCellLoad(pid, cellDescription)
	scriptLoader.OnCellLoad(pid, cellDescription)
end

function OnCellUnload(pid, cellDescription)
    myMod.OnCellUnload(pid, cellDescription)
	scriptLoader.OnCellUnload(pid, cellDescription)
end

function OnCellDeletion(cellDescription)
    myMod.OnCellDeletion(cellDescription)
	scriptLoader.OnCellDeletion(pid, cellDescription)
end

function OnActorList(pid, cellDescription)
    myMod.OnActorList(pid, cellDescription)
	scriptLoader.OnActorList(pid, cellDescription)
end

function OnActorEquipment(pid, cellDescription)
    myMod.OnActorEquipment(pid, cellDescription)
	scriptLoader.OnActorEquipment(pid, cellDescription)
end

function OnActorCell(pid, cellDescription)
    myMod.OnActorCellChange(pid, cellDescription)
	scriptLoader.OnActorCell(pid, cellDescription)
end

function OnObjectPlace(pid, cellDescription)
    myMod.OnObjectPlace(pid, cellDescription)
	scriptLoader.OnObjectPlace(pid, cellDescription)
end

function OnObjectSpawn(pid, cellDescription)
    myMod.OnObjectSpawn(pid, cellDescription)
	scriptLoader.OnObjectSpawn(pid, cellDescription)
end

function OnObjectDelete(pid, cellDescription)
    myMod.OnObjectDelete(pid, cellDescription)
	scriptLoader.OnObjectDelete(pid, cellDescription)
end

function OnObjectLock(pid, cellDescription)
    myMod.OnObjectLock(pid, cellDescription)
	scriptLoader.OnObjectLock(pid, cellDescription)
end

function OnObjectTrap(pid, cellDescription)
    myMod.OnObjectTrap(pid, cellDescription)
	scriptLoader.OnObjectTrap(pid, cellDescription)
end

function OnObjectScale(pid, cellDescription)
    myMod.OnObjectScale(pid, cellDescription)
	scriptLoader.OnObjectScale(pid, cellDescription)
end

function OnObjectState(pid, cellDescription)
    myMod.OnObjectState(pid, cellDescription)
	scriptLoader.OnObjectState(pid, cellDescription)
end

function OnDoorState(pid, cellDescription)
    myMod.OnDoorState(pid, cellDescription)
	scriptLoader.OnDoorState(pid, cellDescription)
end

function OnContainer(pid, cellDescription)
    myMod.OnContainer(pid, cellDescription)
	scriptLoader.OnContainer(pid, cellDescription)
end

function OnGUIAction(pid, idGui, data)
    if scriptLoader.OnGUIAction(pid, idGui, data) then return end
	if myMod.OnGUIAction(pid, idGui, data) then return end
end

function OnMpNumIncrement(currentMpNum)
    myMod.OnMpNumIncrement(currentMpNum)
	scriptLoader.OnMpNumIncrement(currentMpNum)
end
