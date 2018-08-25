DO_NOTHING = 1
HIDE_DEFAULT_CHAT = 2
COMMAND_EXECUTED = 3
OVERWRITE_DEFAULT_BEHAVIOR = 4

local registered = {}
local keys = {}
local info = {}

USES_MESSAGE = 1
USES_COMMAND = 2
USES_INIT = 3
USES_PLAYER_CONNECT = 4
USES_PLAYER_DISCONNECT = 5
USES_PLAYER_DEATH = 6
USES_PLAYER_DEATH_TIMER_EXPIRED = 7
USES_PLAYER_RESURRECT = 8
USES_PLAYER_SKILL_CHANGE = 9
USES_PLAYER_ATTRIBUTE_CHANGE = 10
USES_PLAYER_LEVEL_CHANGE = 11
USES_PLAYER_BOUNTY_CHANGE = 12
USES_PLAYER_SHAPESHIFT = 13
USES_PLAYER_EQUIPMENT_CHANGE = 14
USES_PLAYER_INVENTORY_CHANGE = 15
USES_PLAYER_SPELLBOOK_CHANGE = 16
USES_PLAYER_QUICK_KEYS_CHANGE = 17
USES_PLAYER_JOURNAL_UPDATE = 18
USES_PLAYER_FACTION_CHANGE = 19
USES_PLAYER_TOPIC_CHANGE = 20
USES_PLAYER_KILL_COUNT_CHANGE = 21
USES_PLAYER_ADD_BOOK = 22
USES_PLAYER_END_CHARACTER_GENERATION = 23
USES_CELL_LOAD = 24
USES_CELL_UNLOAD = 25
USES_CELL_DELETE = 26
USES_ACTOR_CELL_CHANGE = 27
USES_ACTOR_LIST = 28
USES_ACTOR_EQUIPMENT_CHANGE = 29
USES_OBJECT_PLACED = 30
USES_OBJECT_SPAWN = 31
USES_OBJECT_DELETE = 32
USES_OBJECT_LOCK = 33
USES_OBJECT_TRAP = 34
USES_OBJECT_SCALE = 35
USES_OBJECT_STATE = 36
USES_CONTAINER = 37
USES_GUI_ACTION = 38
USES_MPNUM_INCREMENT = 39
USES_OBJECT_LOOP_TIME_EXPIRED = 40
USES_PLAYER_CELL_CHANGE = 41
USES_DOOR_STATE = 42
USES_POST_INIT = 43

local Methods = {}

function loadScript(pid, key, index)
	local b,err = pcall(Methods.RegisterScript, key, index)
	
	if b then
		keys[key] = index
		
		if pid then
			tes3mp.SendMessage(pid, "Loaded script \""..key.."\".\n", false)
		end
		
		print("Loaded script \""..key.."\".")
		return true
	else
		if pid then
			tes3mp.SendMessage(pid, "Could not load script with the name of \""..key.."\".\n", false)
		end
		print("Could not load script with the name of \""..key.."\".")
		print(err)
		return false
	end
	
end

Methods.Init = function()
	info = jsonInterface.load("scripts.json")
	
	if info == nil then
		info = {}
	end
	
	for index,key in pairs(info) do
		loadScript(nil, key, index)
	end
	
	for index = 1, #registered do
		if registered[index][USES_POST_INIT][1] then
			registered[index][USES_POST_INIT].Func()
		end
	end
end

Methods.RegisterScript = function(tag, index)
	local s = require (tag)
	registered[tonumber(index)] = s
end

Methods.OnPlayerSendCommand = function(pid, cmd, message)
	local admin = false
    local moderator = false
    if Players[pid]:IsAdmin() then
        admin = true
        moderator = true
    elseif Players[pid]:IsModerator() then
        moderator = true
    end
	
	if admin and cmd[1] == "loadscript" then
		if cmd[2] then
			if loadScript(cmd[2]) then
				info[#info+1] = cmd[2]
				saveScriptFile()
			end
		else
			tes3mp.SendMessage(pid, "Expected script name in argument #1.\n",false)
		end
		return true
	else
		for index = 1, #registered do
			if registered[index][USES_COMMAND][1] then
				local result = registered[index][USES_COMMAND].Func(pid, admin, moderator, cmd, message)
				if result ~= DO_NOTHING then
					if result == COMMAND_EXECUTED then
						return true
					end
				end
			end
		end
		return false
	end
end

Methods.OnPlayerSendMessage = function(pid, message)
	for index = 1, #registered do
		if registered[index][USES_MESSAGE][1] then
			local result = registered[index][USES_MESSAGE].Func(pid, message)
			if result ~= DO_NOTHING then
				if result == HIDE_DEFAULT_CHAT then
					return false
				else
					return true
				end
			end
		end
	end
end

Methods.OnPlayerConnect = function(pid)
	for index = 1, #registered do
		if registered[index][USES_PLAYER_CONNECT][1] then
			registered[index][USES_PLAYER_CONNECT].Func(pid)
		end
	end
end

Methods.OnPlayerDisconnect = function(pid)
	for index = 1, #registered do
		if registered[index][USES_PLAYER_DISCONNECT][1] then
			registered[index][USES_PLAYER_DISCONNECT].Func(pid)
		end
	end
end

Methods.OnDeathTimerExpiration = function(pid)
	for index = 1, #registered do
		if registered[index][USES_PLAYER_DEATH_TIMER_EXPIRED][1] then
			registered[index][USES_PLAYER_DEATH_TIMER_EXPIRED].Func(pid)
		end
	end
end

Methods.OnPlayerDeath = function(pid)
	for index = 1, #registered do
		if registered[index][USES_PLAYER_DEATH][1] then
			registered[index][USES_PLAYER_DEATH].Func(pid)
		end
	end
end

Methods.OnPlayerResurrect = function(pid)
	for index = 1, #registered do
		if registered[index][USES_PLAYER_RESURRECT][1] then
			registered[index][USES_PLAYER_RESURRECT].Func(pid)
		end
	end
end

Methods.OnPlayerCellChange = function(pid)
	for index = 1, #registered do
		if registered[index][USES_PLAYER_CELL_CHANGE][1] then
			registered[index][USES_PLAYER_CELL_CHANGE].Func(pid)
		end
	end
end

Methods.OnPlayerSkill = function(pid)
	for index = 1, #registered do
		if registered[index][USES_PLAYER_SKILL_CHANGE][1] then
			registered[index][USES_PLAYER_SKILL_CHANGE].Func(pid)
		end
	end
end

Methods.OnPlayerAttribute = function(pid)
	for index = 1, #registered do
		if registered[index][USES_PLAYER_ATTRIBUTE_CHANGE][1] then
			registered[index][USES_PLAYER_ATTRIBUTE_CHANGE].Func(pid)
		end
	end
end

Methods.OnPlayerLevel = function(pid)
	for index = 1, #registered do
		if registered[index][USES_PLAYER_LEVEL_CHANGE][1] then
			registered[index][USES_PLAYER_LEVEL_CHANGE].Func(pid)
		end
	end
end

Methods.OnPlayerBounty = function(pid)
	for index = 1, #registered do
		if registered[index][USES_PLAYER_BOUNTY_CHANGE][1] then
			registered[index][USES_PLAYER_BOUNTY_CHANGE].Func(pid)
		end
	end
end

Methods.OnPlayerShapeshift = function(pid)
	for index = 1, #registered do
		if registered[index][USES_PLAYER_SHAPESHIFT][1] then
			registered[index][USES_PLAYER_SHAPESHIFT].Func(pid)
		end
	end
end

Methods.OnPlayerEquipment = function(pid)
	for index = 1, #registered do
		if registered[index][USES_PLAYER_EQUIPMENT_CHANGE][1] then
			registered[index][USES_PLAYER_EQUIPMENT_CHANGE].Func(pid)
		end
	end
end

Methods.OnPlayerInventory = function(pid)
	for index = 1, #registered do
		if registered[index][USES_PLAYER_INVENTORY_CHANGE][1] then
			registered[index][USES_PLAYER_INVENTORY_CHANGE].Func(pid)
		end
	end
end

Methods.OnPlayerSpellbook = function(pid)
	for index = 1, #registered do
		if registered[index][USES_PLAYER_SPELLBOOK_CHANGE][1] then
			registered[index][USES_PLAYER_SPELLBOOK_CHANGE].Func(pid)
		end
	end
end

Methods.OnPlayerQuickKeys = function(pid)
	for index = 1, #registered do
		if registered[index][USES_PLAYER_QUICK_KEYS_CHANGE][1] then
			registered[index][USES_PLAYER_QUICK_KEYS_CHANGE].Func(pid)
		end
	end
end

Methods.OnPlayerJournal = function(pid)
	for index = 1, #registered do
		if registered[index][USES_PLAYER_JOURNAL_UPDATE][1] then
			registered[index][USES_PLAYER_JOURNAL_UPDATE].Func(pid)
		end
	end
end

Methods.OnPlayerFaction = function(pid)
	for index = 1, #registered do
		if registered[index][USES_PLAYER_FACTION_CHANGE][1] then
			registered[index][USES_PLAYER_FACTION_CHANGE].Func(pid)
		end
	end
end

Methods.OnPlayerTopic = function(pid)
	for index = 1, #registered do
		if registered[index][USES_PLAYER_TOPIC_CHANGE][1] then
			registered[index][USES_PLAYER_TOPIC_CHANGE].Func(pid)
		end
	end
end

Methods.OnPlayerKillCount = function(pid)
	for index = 1, #registered do
		if registered[index][USES_PLAYER_KILL_COUNT_CHANGE][1] then
			registered[index][USES_PLAYER_KILL_COUNT_CHANGE].Func(pid)
		end
	end
end

Methods.OnPlayerBook = function(pid)
	for index = 1, #registered do
		if registered[index][USES_PLAYER_ADD_BOOK][1] then
			registered[index][USES_PLAYER_ADD_BOOK].Func(pid)
		end
	end
end

Methods.OnPlayerEndCharGen = function(pid)
	for index = 1, #registered do
		if registered[index][USES_PLAYER_END_CHARACTER_GENERATION][1] then
			registered[index][USES_PLAYER_END_CHARACTER_GENERATION].Func(pid)
		end
	end
end

Methods.OnCellLoad = function(pid, cellDescription)
	for index = 1, #registered do
		if registered[index][USES_CELL_LOAD][1] then
			registered[index][USES_CELL_LOAD].Func(pid, cellDescription)
		end
	end
end

Methods.OnCellUnload = function(pid, cellDescription)
	for index = 1, #registered do
		if registered[index][USES_CELL_UNLOAD][1] then
			registered[index][USES_CELL_UNLOAD].Func(pid, cellDescription)
		end
	end
end

Methods.OnCellDeletion = function(pid, cellDescription)
	for index = 1, #registered do
		if registered[index][USES_CELL_DELETE][1] then
			registered[index][USES_CELL_DELETE].Func(pid, cellDescription)
		end
	end
end

Methods.OnActorList = function(pid, cellDescription)
	for index = 1, #registered do
		if registered[index][USES_ACTOR_LIST][1] then
			registered[index][USES_ACTOR_LIST].Func(pid, cellDescription)
		end
	end
end

Methods.OnActorCell = function(pid, cellDescription)
	for index = 1, #registered do
		if registered[index][USES_ACTOR_CELL_CHANGE][1] then
			registered[index][USES_ACTOR_CELL_CHANGE].Func(pid, cellDescription)
		end
	end
end

Methods.OnActorEquipment = function(pid, cellDescription)
	for index = 1, #registered do
		if registered[index][USES_ACTOR_EQUIPMENT_CHANGE][1] then
			registered[index][USES_ACTOR_EQUIPMENT_CHANGE].Func(pid, cellDescription)
		end
	end
end

Methods.OnObjectPlace = function(pid, cellDescription)
	for index = 1, #registered do
		if registered[index][USES_OBJECT_PLACED][1] then
			registered[index][USES_OBJECT_PLACED].Func(pid, cellDescription)
		end
	end
end

Methods.OnObjectSpawn = function(pid, cellDescription)
	for index = 1, #registered do
		if registered[index][USES_OBJECT_SPAWN][1] then
			registered[index][USES_OBJECT_SPAWN].Func(pid, cellDescription)
		end
	end
end

Methods.OnObjectDelete = function(pid, cellDescription)
	for index = 1, #registered do
		if registered[index][USES_OBJECT_DELETE][1] then
			registered[index][USES_OBJECT_DELETE].Func(pid, cellDescription)
		end
	end
end

Methods.OnObjectLock = function(pid, cellDescription)
	for index = 1, #registered do
		if registered[index][USES_OBJECT_LOCK][1] then
			registered[index][USES_OBJECT_LOCK].Func(pid, cellDescription)
		end
	end
end

Methods.OnObjectTrap = function(pid, cellDescription)
	for index = 1, #registered do
		if registered[index][USES_OBJECT_TRAP][1] then
			registered[index][USES_OBJECT_TRAP].Func(pid, cellDescription)
		end
	end
end

Methods.OnObjectScale = function(pid, cellDescription)
	for index = 1, #registered do
		if registered[index][USES_OBJECT_SCALE][1] then
			registered[index][USES_OBJECT_SCALE].Func(pid, cellDescription)
		end
	end
end

Methods.OnObjectState = function(pid, cellDescription)
	for index = 1, #registered do
		if registered[index][USES_OBJECT_STATE][1] then
			registered[index][USES_OBJECT_STATE].Func(pid, cellDescription)
		end
	end
end

Methods.OnDoorState = function(pid, cellDescription)
	for index = 1, #registered do
		if registered[index][USES_DOOR_STATE][1] then
			registered[index][USES_DOOR_STATE].Func(pid, cellDescription)
		end
	end
end

Methods.OnContainer = function(pid, cellDescription)
	for index = 1, #registered do
		if registered[index][USES_CONTAINER][1] then
			registered[index][USES_CONTAINER].Func(pid, cellDescription)
		end
	end
end

Methods.OnGUIAction = function(pid, idGui, data)
	for index = 1, #registered do
		if registered[index][USES_GUI_ACTION][1] then
			return registered[index][USES_GUI_ACTION].Func(pid, idGui, data)
		end
	end
end

Methods.OnMpNumIncrement = function(currentMpNum)
	for index = 1, #registered do
		if registered[index][USES_MPNUM_INCREMENT][1] then
			registered[index][USES_MPNUM_INCREMENT].Func(currentMpNum)
		end
	end
end

Methods.OnObjectLoopTimeExpiration = function(loopIndex)
	for index = 1, #registered do
		if registered[index][USES_OBJECT_LOOP_TIME_EXPIRED][1] then
			registered[index][USES_OBJECT_LOOP_TIME_EXPIRED].Func(loopIndex)
		end
	end
end

Methods.OnServerPostInit = function()
	for index = 1, #registered do
		if registered[index][USES_POST_INIT][1] then
			registered[index][USES_POST_INIT].Func()
		end
	end
end

Methods.GetScript = function(tag)
	return registered[keys[tag]]
end

return Methods
