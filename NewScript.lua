-- Template written by David-AW for ScriptLoader.lua
-- Feel free to delete any unused methods.
-- To use other loaded scripts use scriptLoader.GetScript("scriptname")

Methods = {}

for i = 1, 43 do -- do not delete/change this.
	Methods[i] = {false}
end

Methods[USES_INIT][1] = true
Methods[USES_INIT].Func = function() -- Initiate function. Use for loading JSON and other stuff.
	
end

Methods[USES_POST_INIT][1] = true
Methods[USES_POST_INIT].Func = function()

end

-- ********************
-- ::::CHAT METHODS::::
-- ********************

-- DO_NOTHING skips this script and moves to the next.
-- COMMAND_EXECUTED skips all future scripts (Because command was executed)

Methods[USES_MESSAGE][1] = true
Methods[USES_MESSAGE].Func = function(pid, message) -- On player sent message
	
	
	return DO_NOTHING
end

-- HIDE_DEFAULT_CHAT is used to stop the message from showing up in the chat box (Overwriting default chat behavior)

Methods[USES_COMMAND][1] = true
Methods[USES_COMMAND].Func = function(pid, isAdmin, isModerator, cmd, message) -- On player sent command (parameter "cmd" is a table)


	return DO_NOTHING
end

-- **********************
-- ::::PLAYER METHODS::::
-- **********************

Methods[USES_PLAYER_CONNECT][1] = true
Methods[USES_PLAYER_CONNECT].Func = function(pid) -- Called when a player joins the server


end

Methods[USES_PLAYER_DISCONNECT][1] = true
Methods[USES_PLAYER_DISCONNECT].Func = function(pid) -- Called when a player leaves the server


end

Methods[USES_PLAYER_DEATH][1] = true
Methods[USES_PLAYER_DEATH].Func = function(pid) -- Called when a player dies


end

Methods[USES_PLAYER_DEATH_TIMER_EXPIRED][1] = true
Methods[USES_PLAYER_DEATH_TIMER_EXPIRED].Func = function(pid) -- Called when the death timer ends before respawning


end

Methods[USES_PLAYER_RESURRECT][1] = true
Methods[USES_PLAYER_RESURRECT].Func = function(pid) -- Called when a player respawns


end

Methods[USES_PLAYER_SKILL_CHANGE][1] = true
Methods[USES_PLAYER_SKILL_CHANGE].Func = function(pid) -- Called when a player's skill level was changed


end

Methods[USES_PLAYER_ATTRIBUTE_CHANGE][1] = true
Methods[USES_PLAYER_ATTRIBUTE_CHANGE].Func = function(pid) -- Called when a player's attribute level was changed
	
	
end

Methods[USES_PLAYER_LEVEL_CHANGE][1] = true
Methods[USES_PLAYER_LEVEL_CHANGE].Func = function(pid) -- Called when a player's level was changed


end

Methods[USES_BOUNTY_CHANGE][1] = true
Methods[USES_BOUNTY_CHANGE].Func = function(pid) -- Called when a player's bounty was changed


end

Methods[USES_PLAYER_SHAPESHIFT][1] = true
Methods[USES_PLAYER_SHAPESHIFT].Func = function(pid) -- Called when a player shapeshifts (into werewolf im assuming)


end

Methods[USES_EQUIPMENT_CHANGE][1] = true
Methods[USES_EQUIPMENT_CHANGE].Func = function(pid) -- Called when a player equips/unequips an item


end

Methods[USES_PLAYER_INVENTORY_CHANGE][1] = true
Methods[USES_PLAYER_INVENTORY_CHANGE].Func = function(pid) -- Called when a player adds/removes item from inventory (Could mean it was equipped/unequipped)


end

Methods[USES_PLAYER_SPELLBOOK_CHANGE][1] = true
Methods[USES_PLAYER_SPELLBOOK_CHANGE].Func = function(pid) -- Called when a spell was added(/removed?) from a player's spellbook


end

Methods[USES_PLAYER_QUICK_KEYS_CHANGE][1] = true
Methods[USES_PLAYER_QUICK_KEYS_CHANGE].Func = function(pid) -- Called when a player changes their quick keys


end

Methods[USES_PLAYER_JOURNAL_UPDATE][1] = true
Methods[USES_PLAYER_JOURNAL_UPDATE].Func = function(pid) -- Called when a player gets an update to their journal


end

Methods[USES_PLAYER_FACTION_CHANGE][1] = true
Methods[USES_PLAYER_FACTION_CHANGE].Func = function(pid) -- Called when a player's rank/expulsion status/reputation is changed


end

Methods[USES_PLAYER_TOPIC_CHANGE][1] = true
Methods[USES_PLAYER_TOPIC_CHANGE].Func = function(pid)


end

Methods[USES_PLAYER_KILL_COUNT_CHANGE][1] = true
Methods[USES_PLAYER_KILL_COUNT_CHANGE].Func = function(pid) -- Called when a player kills an NPC??


end

Methods[USES_PLAYER_ADD_BOOK][1] = true
Methods[USES_PLAYER_ADD_BOOK].Func = function(pid) -- Called when player reads a book that gives stats


end

Methods[USES_PLAYER_END_CHARACTER_GENERATION][1] = true
Methods[USES_PLAYER_END_CHARACTER_GENERATION].Func = function(pid) -- Called when a player finishes registering


end

-- ********************
-- ::::CELL METHODS::::
-- ********************

Methods[USES_CELL_LOAD][1] = true
Methods[USES_CELL_LOAD].Func = function(pid, cellDescription) -- Called when Cell is loaded by the server


end

Methods[USES_CELL_UNLOAD][1] = true
Methods[USES_CELL_UNLOAD].Func = function(pid, cellDescription) -- Called when Cell is unloaded by the server


end

Methods[USES_CELL_DELETE][1] = true
Methods[USES_CELL_DELETE].Func = function(cellDescription) -- Called when the Cell is deleted by the server


end

--- *********************
--- ::::ACTOR METHODS::::
--- *********************

Methods[USES_ACTOR_LIST][1] = true
Methods[USES_ACTOR_LIST].Func = function(pid, cellDescription) -- Called when a cell loads its actors


end

Methods[USES_ACTOR_CELL_CHANGE][1] = true
Methods[USES_ACTOR_CELL_CHANGE].Func = function(pid, cellDescription) -- Called when an actor changes cells


end

Methods[USES_ACTOR_EQUIPMENT_CHANGE][1] = true
Methods[USES_ACTOR_EQUIPMENT_CHANGE].Func = function(pid, cellDescription) -- Called when an actor changes equipment


end

--- **********************
--- ::::OBJECT METHODS::::
--- **********************

Methods[USES_OBJECT_PLACED][1] = true
Methods[USES_OBJECT_PLACED].Func = function(pid, cellDescription) -- Called when an object is placed in a cell


end

Methods[USES_OBJECT_SPAWN][1] = true
Methods[USES_OBJECT_SPAWN].Func = function(pid, cellDescription) -- Called when an object is spawned in a cell


end

Methods[USES_OBJECT_DELETE][1] = true
Methods[USES_OBJECT_DELETE].Func = function(pid, cellDescription) -- Called when an object is deleted from a cell


end

Methods[USES_OBJECT_LOCK][1] = true
Methods[USES_OBJECT_LOCK].Func = function(pid, cellDescription)


end

Methods[USES_OBJECT_TRAP][1] = true
Methods[USES_OBJECT_TRAP].Func = function(pid, cellDescription)


end

Methods[USES_OBJECT_SCALE][1] = true
Methods[USES_OBJECT_SCALE].Func = function(pid, cellDescription) -- Called when an object's scale is changed


end

Methods[USES_OBJECT_STATE][1] = true
Methods[USES_OBJECT_STATE].Func = function(pid, cellDescription)


end

Methods[USES_DOOR_STATE][1] = true
Methods[USES_DOOR_STATE].Func = function(pid, cellDescription)


end

--- ************************
--- ::::CONTAINER METHOD::::
--- ************************

Methods[USES_CONTAINER][1] = true
Methods[USES_CONTAINER].Func = function(pid, cellDescription)


end

--- ******************
--- ::::GUI METHOD::::
--- ******************

Methods[USES_GUI_ACTION][1] = true
Methods[USES_GUI_ACTION].Func = function(pid, idGui, data)


end

--- *********************
--- ::::MP NUM METHOD::::
--- *********************

Methods[USES_MPNUM_INCREMENT][1] = true
Methods[USES_MPNUM_INCREMENT].Func = function(currentMpNum)


end

return Methods
