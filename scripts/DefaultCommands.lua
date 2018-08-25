-- Template written by David-AW for ScriptLoader.lua
-- Feel free to delete any unused methods.
-- To use other loaded scripts use scriptLoader.GetScript("scriptname")

require("config")

Methods = {}

local helptext = "\nCommand list:\
/message <pid> <text> - Send a private message to a player (/msg)\
/me <text> - Send a message written in the third person\
/local <text> - Send a message that only players in your area can read (/l)\
/list - List all players on the server\
/anim <animation> - Play an animation on yourself, with a list of valid inputs being provided if you use an invalid one (/a)\
/speech <type> <index> - Play a certain speech on yourself, with a list of valid inputs being provided if you use invalid ones (/s)\
/craft - Open up a small crafting menu used as a scripting example\
/help - Get the list of commands available to regular users\
/help moderator/admin - Get the list of commands available to moderators or admins, if you are one"

local modhelptext = "Moderators only:\
/kick <pid> - Kick player\
/ban ip <ip> - Ban an IP address\
/ban name <name> - Ban a player and all IP addresses stored for them\
/ban <pid> - Same as above, but using a pid as the argument\
/unban ip <ip> - Unban an IP address\
/unban name <name> - Unban a player name and all IP addresses stored for them\
/banlist ips/names - Print all banned IPs or all banned player names\
/ipaddresses <name> - Print all the IP addresses used by a player (/ips)\
/confiscate <pid> - Open up a window where you can confiscate an item from a player\
/time <value> - Set the server's time counter\
/teleport <pid>/all - Teleport another player to your position (/tp)\
/teleportto <pid> - Teleport yourself to another player (/tpto)\
/cells - List all loaded cells on the server\
/getpos <pid> - Get player position and cell\
/setattr <pid> <attribute> <value> - Set a player's attribute to a certain value\
/setskill <pid> <skill> <value> - Set a player's skill to a certain value\
/superman - Increase your acrobatics, athletics and speed\
/setauthority <pid> <cell> - Forcibly set a certain player as the authority of a cell (/setauth)"

local adminhelptext = "Admins only:\
/addmoderator <pid> - Promote player to moderator\
/removemoderator <pid> - Demote player from moderator\
/setdifficulty <pid> <value>/default - Set the difficulty for a particular player\
/setconsole <pid> on/off/default - Enable/disable in-game console for player\
/setbedrest <pid> on/off/default - Enable/disable bed resting for player\
/setwildrest <pid> on/off/default - Enable/disable wilderness resting for player\
/setwait <pid> on/off/default - Enable/disable waiting for player\
/storeconsole <pid> <command> - Store a certain console command for a player\
/runconsole <pid> (<count>) (<interval>) - Run a stored console command on a player, with optional count and interval\
/placeat <pid> <refId> (<count>) (<interval>) - Place a certain object at a player's location, with optional count and interval\
/spawnat <pid> <refId> (<count>) (<interval>) - Spawn a certain creature or NPC at a player's location, with optional count and interval\
/werewolf <pid> on/off - Set the werewolf state of a particular player"

for i = 1, 43 do -- do not delete/change this.
	Methods[i] = {false}
end

if config.allowSuicideCommand == true then
    helptext = helptext .. "\n/suicide - Commit suicide"
end

-- ********************
-- ::::CHAT METHODS::::
-- ********************

Methods[USES_COMMAND][1] = true -- Delete this and the function if not used
Methods[USES_COMMAND].Func = function(pid, isAdmin, isModerator, cmd, message) -- On player sent command (parameter "cmd" is a table)
		print(pid.." "..cmd[1].." "..message)
       if cmd[1] == "message" or cmd[1] == "msg" then
            if pid == tonumber(cmd[2]) then
                tes3mp.SendMessage(pid, "You can't message yourself.\n")
            elseif cmd[3] == nil then
                tes3mp.SendMessage(pid, "You cannot send a blank message.\n")
            elseif myMod.CheckPlayerValidity(pid, cmd[2]) then
                local targetPid = tonumber(cmd[2])
                local targetName = Players[targetPid].name
                message = myMod.GetChatName(pid) .. " to " .. myMod.GetChatName(targetPid) .. ": "
                message = message .. tableHelper.concatenateFromIndex(cmd, 3) .. "\n"
                tes3mp.SendMessage(pid, message, false)
                tes3mp.SendMessage(targetPid, message, false)
            end
			
			return COMMAND_EXECUTED

        elseif cmd[1] == "me" and cmd[2] ~= nil then
            local message = myMod.GetChatName(pid) .. " " .. tableHelper.concatenateFromIndex(cmd, 2) .. "\n"
            tes3mp.SendMessage(pid, message, true)

			return COMMAND_EXECUTED
			
        elseif (cmd[1] == "local" or cmd[1] == "l") and cmd[2] ~= nil then
            local cellDescription = Players[pid].data.location.cell

            if myMod.IsCellLoaded(cellDescription) == true then
                for index, visitorPid in pairs(LoadedCells[cellDescription].visitors) do

                    local message = myMod.GetChatName(pid) .. " to local area: "
                    message = message .. tableHelper.concatenateFromIndex(cmd, 2) .. "\n"
                    tes3mp.SendMessage(visitorPid, message, false)
                end
            end

			return COMMAND_EXECUTED
			
        elseif cmd[1] == "ban" and isModerator then

            if cmd[2] == "ip" and cmd[3] ~= nil then
                local ipAddress = cmd[3]

                if tableHelper.containsValue(banList.ipAddresses, ipAddress) == false then
                    table.insert(banList.ipAddresses, ipAddress)
                    SaveBanList()

                    tes3mp.SendMessage(pid, ipAddress .. " is now banned.\n", false)
                    tes3mp.BanAddress(ipAddress)
                else
                    tes3mp.SendMessage(pid, ipAddress .. " was already banned.\n", false)
                end
            elseif (cmd[2] == "name" or cmd[2] == "player") and cmd[3] ~= nil then
                local targetName = tableHelper.concatenateFromIndex(cmd, 3)
                myMod.BanPlayer(pid, targetName)

            elseif type(tonumber(cmd[2])) == "number" and myMod.CheckPlayerValidity(pid, cmd[2]) then
                local targetPid = tonumber(cmd[2])
                local targetName = Players[targetPid].name
                myMod.BanPlayer(pid, targetName)
            else
                tes3mp.SendMessage(pid, "Invalid input for ban.\n", false)
            end
			
			return COMMAND_EXECUTED

        elseif cmd[1] == "unban" and isModerator and cmd[3] ~= nil then

            if cmd[2] == "ip" then
                local ipAddress = cmd[3]

                if tableHelper.containsValue(banList.ipAddresses, ipAddress) == true then
                    tableHelper.removeValue(banList.ipAddresses, ipAddress)
                    SaveBanList()

                    tes3mp.SendMessage(pid, ipAddress .. " is now unbanned.\n", false)
                    tes3mp.UnbanAddress(ipAddress)
                else
                    tes3mp.SendMessage(pid, ipAddress .. " is not banned.\n", false)
                end
            elseif cmd[2] == "name" or cmd[2] == "player" then
                local targetName = tableHelper.concatenateFromIndex(cmd, 3)
                myMod.UnbanPlayer(pid, targetName)
            else
                tes3mp.SendMessage(pid, "Invalid input for unban.\n", false)
            end
			
			return COMMAND_EXECUTED

        elseif cmd[1] == "banlist" and isModerator then

            local message

            if cmd[2] == "names" or cmd[2] == "name" or cmd[2] == "players" then
                if #banList.playerNames == 0 then
                    message = "No player names have been banned.\n"
                else
                    message = "The following player names are banned:\n"

                    for index, targetName in pairs(banList.playerNames) do
                        message = message .. targetName

                        if index < #banList.playerNames then
                            message = message .. ", "
                        end
                    end

                    message = message .. "\n"
                end
            elseif cmd[2] ~= nil and (string.lower(cmd[2]) == "ips" or string.lower(cmd[2]) == "ip") then
                if #banList.ipAddresses == 0 then
                    message = "No IP addresses have been banned.\n"
                else
                    message = "The following IP addresses unattached to players are banned:\n"

                    for index, ipAddress in pairs(banList.ipAddresses) do
                        message = message .. ipAddress

                        if index < #banList.ipAddresses then
                            message = message .. ", "
                        end
                    end

                    message = message .. "\n"
                end
            end

            if message == nil then
                message = "Please specify whether you want the banlist for IPs or for names.\n"
            end

            tes3mp.SendMessage(pid, message, false)
			
			return COMMAND_EXECUTED

        elseif (cmd[1] == "ipaddresses" or cmd[1] == "ips") and isModerator and cmd[2] ~= nil then
            local targetName = tableHelper.concatenateFromIndex(cmd, 2)
            local targetPlayer = myMod.GetPlayerByName(targetName)

            if targetPlayer == nil then
                tes3mp.SendMessage(pid, "Player " .. targetName .. " does not exist.\n", false)
            elseif targetPlayer.data.ipAddresses ~= nil then
                local message = "Player " .. targetPlayer.accountName .. " has used the following IP addresses:\n"

                for index, ipAddress in pairs(targetPlayer.data.ipAddresses) do
                    message = message .. ipAddress

                    if index < #targetPlayer.data.ipAddresses then
                        message = message .. ", "
                    end
                end

                message = message .. "\n"
                tes3mp.SendMessage(pid, message, false)
            end

			return COMMAND_EXECUTED
			
        elseif cmd[1] == "players" or cmd[1] == "list" then
            GUI.ShowPlayerList(pid)

			return COMMAND_EXECUTED
			
        elseif cmd[1] == "cells" and isModerator then
            GUI.ShowCellList(pid)
			
			return COMMAND_EXECUTED

        elseif (cmd[1] == "teleport" or cmd[1] == "tp") and isModerator then
            if cmd[2] ~= "all" then
                myMod.TeleportToPlayer(pid, cmd[2], pid)
            else
                for iteratorPid, player in pairs(Players) do
                    if iteratorPid ~= pid then
                        if player:IsLoggedIn() then
                            myMod.TeleportToPlayer(pid, iteratorPid, pid)
                        end
                    end
                end
            end
			
			return COMMAND_EXECUTED

        elseif (cmd[1] == "teleportto" or cmd[1] == "tpto") and isModerator then
            myMod.TeleportToPlayer(pid, pid, cmd[2])
			
			return COMMAND_EXECUTED

        elseif (cmd[1] == "setauthority" or cmd[1] == "setauth") and isModerator and #cmd > 2 then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then
                local cellDescription = tableHelper.concatenateFromIndex(cmd, 3)

                -- Get rid of quotation marks
                cellDescription = string.gsub(cellDescription, '"', '')

                if myMod.IsCellLoaded(cellDescription) == true then
                    local targetPid = tonumber(cmd[2])
                    myMod.SetCellAuthority(targetPid, cellDescription)
                else
                    tes3mp.SendMessage(pid, "Cell \"" .. cellDescription .. "\" isn't loaded!\n", false)
                end
            end
			
			return COMMAND_EXECUTED

        elseif cmd[1] == "kick" and isModerator then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then
                local targetPid = tonumber(cmd[2])
                local targetName = Players[targetPid].name
                local message

                if Players[targetPid]:IsisAdmin() then
                    message = "You cannot kick an isAdmin from the server.\n"
                    tes3mp.SendMessage(pid, message, false)
                elseif Players[targetPid]:IsisModerator() and not isAdmin then
                    message = "You cannot kick a fellow isModerator from the server.\n"
                    tes3mp.SendMessage(pid, message, false)
                else
                    message = targetName .. " was kicked from the server by " .. playerName .. "!\n"
                    tes3mp.SendMessage(pid, message, true)
                    Players[targetPid]:Kick()
                end
            end
			
			return COMMAND_EXECUTED

        elseif cmd[1] == "addisModerator" and isAdmin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then
                local targetPid = tonumber(cmd[2])
                local targetName = Players[targetPid].name
                local message

                if Players[targetPid]:IsisAdmin() then
                    message = targetName .. " is already an isAdmin.\n"
                    tes3mp.SendMessage(pid, message, false)
                elseif Players[targetPid]:IsisModerator() then
                    message = targetName .. " is already a isModerator.\n"
                    tes3mp.SendMessage(pid, message, false)
                else
                    message = targetName .. " was promoted to isModerator!\n"
                    tes3mp.SendMessage(pid, message, true)
                    Players[targetPid].data.settings.isAdmin = 1
                    Players[targetPid]:Save()
                end
            end
			
			return COMMAND_EXECUTED

        elseif cmd[1] == "removeisModerator" and isAdmin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then
                local targetPid = tonumber(cmd[2])
                local targetName = Players[targetPid].name
                local message

                if Players[targetPid]:IsisAdmin() then
                    message = "Cannot demote " .. targetName .. " because they are an isAdmin.\n"
                    tes3mp.SendMessage(pid, message, false)
                elseif Players[targetPid]:IsisModerator() then
                    message = targetName .. " was demoted from isModerator!\n"
                    tes3mp.SendMessage(pid, message, true)
                    Players[targetPid].data.settings.isAdmin = 0
                    Players[targetPid]:Save()
                else
                    message = targetName .. " is not a isModerator.\n"
                    tes3mp.SendMessage(pid, message, false)
                end
            end
			
			return COMMAND_EXECUTED

        elseif cmd[1] == "superman" and isModerator then
            -- Set Speed to 100
            tes3mp.SetAttributeBase(pid, 4, 100)
            -- Set Athletics to 100
            tes3mp.SetSkillBase(pid, 8, 100)
            -- Set Acrobatics to 400
            tes3mp.SetSkillBase(pid, 20, 400)

            tes3mp.SendAttributes(pid)
            tes3mp.SendSkills(pid)
			
			return COMMAND_EXECUTED

        elseif cmd[1] == "setattr" and isModerator then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then
                local targetPid = tonumber(cmd[2])
                local targetName = Players[targetPid].name

                if cmd[3] ~= nil and cmd[4] ~= nil and tonumber(cmd[4]) ~= nil then
                    local attrId
                    local value = tonumber(cmd[4])

                    if tonumber(cmd[3]) ~= nil then
                        attrId = tonumber(cmd[3])
                    else
                        attrId = tes3mp.GetAttributeId(cmd[3])
                    end

                    if attrId ~= -1 and attrId < tes3mp.GetAttributeCount() then
                        tes3mp.SetAttributeBase(targetPid, attrId, value)
                        tes3mp.SendAttributes(targetPid)

                        local message = targetName.."'s "..tes3mp.GetAttributeName(attrId).." is now "..value.."\n"
                        tes3mp.SendMessage(pid, message, true)
                        Players[targetPid]:SaveAttributes()
                    end
                end
            end
			
			return COMMAND_EXECUTED

        elseif cmd[1] == "setskill" and isModerator then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then
                local targetPid = tonumber(cmd[2])
                local targetName = Players[targetPid].name

                if cmd[3] ~= nil and cmd[4] ~= nil and tonumber(cmd[4]) ~= nil then
                    local skillId
                    local value = tonumber(cmd[4])

                    if tonumber(cmd[3]) ~= nil then
                        skillId = tonumber(cmd[3])
                    else
                        skillId = tes3mp.GetSkillId(cmd[3])
                    end

                    if skillId ~= -1 and skillId < tes3mp.GetSkillCount() then
                        tes3mp.SetSkillBase(targetPid, skillId, value)
                        tes3mp.SendSkills(targetPid)

                        local message = targetName.."'s "..tes3mp.GetSkillName(skillId).." is now "..value.."\n"
                        tes3mp.SendMessage(pid, message, true)
                        Players[targetPid]:SaveSkills()
                    end
                end
            end
			
			return COMMAND_EXECUTED
			
        elseif cmd[1] == "help" then
            if (cmd[2] == "isModerator" or cmd[2] == "mod") then

                if isModerator then
                    tes3mp.CustomMessageBox(pid, -1, modhelptext .. "\n", "Ok")
                else
                    tes3mp.SendMessage(pid, "Only isModerators and higher can see those commands.", false)
                end
            elseif cmd[2] == "isAdmin" then

                if isAdmin then
                    tes3mp.CustomMessageBox(pid, -1, isAdminhelptext .. "\n", "Ok")
                else
                    tes3mp.SendMessage(pid, "Only isAdmins can see those commands.", false)
                end
            else
                tes3mp.CustomMessageBox(pid, -1, helptext .. "\n", "Ok")
            end
			
			return COMMAND_EXECUTED

        elseif cmd[1] == "setext" and isAdmin then
            tes3mp.SetExterior(pid, cmd[2], cmd[3])

			return COMMAND_EXECUTED
			
        elseif cmd[1] == "getpos" and isModerator then
            myMod.PrintPlayerPosition(pid, cmd[2])

			return COMMAND_EXECUTED
			
        elseif (cmd[1] == "setdifficulty" or cmd[1] == "setdiff") and isAdmin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then

                local targetPid = tonumber(cmd[2])
                local difficulty = cmd[3]

                if type(tonumber(difficulty)) == "number" then
                    difficulty = tonumber(difficulty)
                end

                if difficulty == "default" or type(difficulty) == "number" then
                    Players[targetPid]:SetDifficulty(difficulty)
                    Players[targetPid]:LoadSettings()
                    tes3mp.SendMessage(pid, "Difficulty for " .. Players[targetPid].name .. " is now " .. difficulty .. "\n", true)
                else
                    tes3mp.SendMessage(pid, "Not a valid argument. Use /difficulty <pid> <value>.\n", false)
                    return false
                end
            end
			
			return COMMAND_EXECUTED

        elseif cmd[1] == "setconsole" and isAdmin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then

                local targetPid = tonumber(cmd[2])
                local targetName = ""
                local state = ""

                if cmd[3] == "on" then
                    Players[targetPid]:SetConsoleAllowed(true)
                    state = " enabled.\n"
                elseif cmd[3] == "off" then
                    Players[targetPid]:SetConsoleAllowed(false)
                    state = " disabled.\n"
                elseif cmd[3] == "default" then
                    Players[targetPid]:SetConsoleAllowed("default")
                    state = " reset to default.\n"
                else
                     tes3mp.SendMessage(pid, "Not a valid argument. Use /setconsole <pid> <on/off/default>.\n", false)
                     return false
                end

                Players[targetPid]:LoadSettings()
                tes3mp.SendMessage(pid, "Console for " .. Players[targetPid].name .. state, false)
                if targetPid ~= pid then
                    tes3mp.SendMessage(targetPid, "Console" .. state, false)
                end
            end
			
			return COMMAND_EXECUTED

        elseif cmd[1] == "setbedrest" and isAdmin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then

                local targetPid = tonumber(cmd[2])
                local targetName = ""
                local state = ""

                if cmd[3] == "on" then
                    Players[targetPid]:SetBedRestAllowed(true)
                    state = " enabled.\n"
                elseif cmd[3] == "off" then
                    Players[targetPid]:SetBedRestAllowed(false)
                    state = " disabled.\n"
                elseif cmd[3] == "default" then
                    Players[targetPid]:SetBedRestAllowed("default")
                    state = " reset to default.\n"
                else
                     tes3mp.SendMessage(pid, "Not a valid argument. Use /setbedrest <pid> <on/off/default>.\n", false)
                     return false
                end

                Players[targetPid]:LoadSettings()
                tes3mp.SendMessage(pid, "Bed resting for " .. Players[targetPid].name .. state, false)
                if targetPid ~= pid then
                    tes3mp.SendMessage(targetPid, "Bed resting" .. state, false)
                end
            end

			return COMMAND_EXECUTED
			
        elseif (cmd[1] == "setwildernessrest" or cmd[1] == "setwildrest") and isAdmin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then

                local targetPid = tonumber(cmd[2])
                local targetName = ""
                local state = ""

                if cmd[3] == "on" then
                    Players[targetPid]:SetWildernessRestAllowed(true)
                    state = " enabled.\n"
                elseif cmd[3] == "off" then
                    Players[targetPid]:SetWildernessRestAllowed(false)
                    state = " disabled.\n"
                elseif cmd[3] == "default" then
                    Players[targetPid]:SetWildernessRestAllowed("default")
                    state = " reset to default.\n"
                else
                     tes3mp.SendMessage(pid, "Not a valid argument. Use /setwildrest <pid> <on/off/default>.\n", false)
                     return false
                end

                Players[targetPid]:LoadSettings()
                tes3mp.SendMessage(pid, "Wilderness resting for " .. Players[targetPid].name .. state, false)
                if targetPid ~= pid then
                    tes3mp.SendMessage(targetPid, "Wilderness resting" .. state, false)
                end
            end
			
			return COMMAND_EXECUTED

        elseif cmd[1] == "setwait" and isAdmin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then

                local targetPid = tonumber(cmd[2])
                local targetName = ""
                local state = ""

                if cmd[3] == "on" then
                    Players[targetPid]:SetWaitAllowed(true)
                    state = " enabled.\n"
                elseif cmd[3] == "off" then
                    Players[targetPid]:SetWaitAllowed(false)
                    state = " disabled.\n"
                elseif cmd[3] == "default" then
                    Players[targetPid]:SetWaitAllowed("default")
                    state = " reset to default.\n"
                else
                     tes3mp.SendMessage(pid, "Not a valid argument. Use /setwait <pid> <on/off/default>.\n", false)
                     return false
                end

                Players[targetPid]:LoadSettings()
                tes3mp.SendMessage(pid, "Waiting for " .. Players[targetPid].name .. state, false)
                if targetPid ~= pid then
                    tes3mp.SendMessage(targetPid, "Waiting" .. state, false)
                end
            end
			
			return COMMAND_EXECUTED

        elseif cmd[1] == "werewolf" and isAdmin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then

                local targetPid = tonumber(cmd[2])
                local targetName = ""
                local state = ""

                if cmd[3] == "on" then
                    Players[targetPid]:SetWerewolfState(true)
                    state = " enabled.\n"
                elseif cmd[3] == "off" then
                    Players[targetPid]:SetWerewolfState(false)
                    state = " disabled.\n"
                else
                     tes3mp.SendMessage(pid, "Not a valid argument. Use /werewolf <pid> <on/off>.\n", false)
                     return false
                end

                Players[targetPid]:LoadShapeshift()
                tes3mp.SendMessage(pid, "Werewolf state for " .. Players[targetPid].name .. state, false)
                if targetPid ~= pid then
                    tes3mp.SendMessage(targetPid, "Werewolf state" .. state, false)
                end
            end
			
			return COMMAND_EXECUTED

        elseif cmd[1] == "time" and isModerator then
            if type(tonumber(cmd[2])) == "number" then
                timeCounter = tonumber(cmd[2])
            end

        elseif cmd[1] == "suicide" then
		
            if config.allowSuicideCommand == true then
                tes3mp.SetHealthCurrent(pid, 0)
                tes3mp.SendStatsDynamic(pid)
            else
                tes3mp.SendMessage(pid, "That command is disabled on this server.\n", false)
            end
			
			return COMMAND_EXECUTED

        elseif cmd[1] == "storeconsole" and cmd[2] ~= nil and cmd[3] ~= nil and isAdmin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then

                local targetPid = tonumber(cmd[2])
                Players[targetPid].storedConsoleCommand = tableHelper.concatenateFromIndex(cmd, 3)

                tes3mp.SendMessage(pid, "That console command is now stored for player " .. targetPid, false)
            end
			
			return COMMAND_EXECUTED

        elseif cmd[1] == "runconsole" and cmd[2] ~= nil and isAdmin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then

                local targetPid = tonumber(cmd[2])

                if Players[targetPid].storedConsoleCommand == nil then
                    tes3mp.SendMessage(pid, "There is no console command stored for player " .. targetPid .. ". Please run /storeconsole on them first.\n", false)
                else
                    local consoleCommand = Players[targetPid].storedConsoleCommand
                    myMod.RunConsoleCommandOnPlayer(targetPid, consoleCommand)

                    local count = tonumber(cmd[3])

                    if count ~= nil and count > 1 then

                        count = count - 1
                        local interval = 1

                        if tonumber(cmd[4]) ~= nil and tonumber(cmd[4]) > 1 then
                            interval = tonumber(cmd[4])
                        end

                        local loopIndex = tableHelper.getUnusedNumericalIndex(ObjectLoops)
                        local timerId = tes3mp.CreateTimerEx("OnObjectLoopTimeExpiration", interval, "i", loopIndex)

                        ObjectLoops[loopIndex] = {
                            packetType = "console",
                            timerId = timerId,
                            interval = interval,
                            count = count,
                            targetPid = targetPid,
                            targetName = Players[targetPid].accountName,
                            consoleCommand = consoleCommand
                        }

                        tes3mp.StartTimer(timerId)
                    end
                end
            end
			
			return COMMAND_EXECUTED

        elseif (cmd[1] == "placeat" or cmd[1] == "spawnat") and cmd[2] ~= nil and cmd[3] ~= nil and isAdmin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then

                local targetPid = tonumber(cmd[2])
                local refId = cmd[3]
                local packetType

                if cmd[1] == "placeat" then
                    packetType = "place"
                elseif cmd[1] == "spawnat" then
                    packetType = "spawn"
                end

                myMod.CreateObjectAtPlayer(targetPid, refId, packetType)

                local count = tonumber(cmd[4])

                if count ~= nil and count > 1 then

                    -- We've already placed the first object above, so lower the count
                    -- for the object loop
                    count = count - 1
                    local interval = 1

                    if tonumber(cmd[5]) ~= nil and tonumber(cmd[5]) > 1 then
                        interval = tonumber(cmd[5])
                    end

                    local loopIndex = tableHelper.getUnusedNumericalIndex(ObjectLoops)
                    local timerId = tes3mp.CreateTimerEx("OnObjectLoopTimeExpiration", interval, "i", loopIndex)

                    ObjectLoops[loopIndex] = {
                        packetType = packetType,
                        timerId = timerId,
                        interval = interval,
                        count = count,
                        targetPid = targetPid,
                        targetName = Players[targetPid].accountName,
                        refId = refId
                    }

                    tes3mp.StartTimer(timerId)
                end
            end
			
			return COMMAND_EXECUTED

        elseif (cmd[1] == "greentext" or cmd[1] == "gt") and cmd[2] ~= nil then
            local message = myMod.GetChatName(pid) .. ": " .. color.GreenText .. ">" .. tableHelper.concatenateFromIndex(cmd, 2) .. "\n"
            tes3mp.SendMessage(pid, message, true)

			return COMMAND_EXECUTED
			
        elseif (cmd[1] == "anim" or cmd[1] == "a") and cmd[2] ~= nil then
            local isValid = animHelper.playAnimation(pid, cmd[2])
                
            if isValid == false then
                local validList = animHelper.getValidList(pid)
                tes3mp.SendMessage(pid, "That is not a valid animation. Try one of the following:\n" .. validList .. "\n", false)
            end
			
			return COMMAND_EXECUTED

        elseif (cmd[1] == "speech" or cmd[1] == "s") and cmd[2] ~= nil and cmd[3] ~= nil and type(tonumber(cmd[3])) == "number" then
            local isValid = speechHelper.playSpeech(pid, cmd[2], tonumber(cmd[3]))
                
            if isValid == false then
                local validList = speechHelper.getValidList(pid)
                tes3mp.SendMessage(pid, "That is not a valid speech. Try one of the following:\n" .. validList .. "\n", false)
            end
			
			return COMMAND_EXECUTED

        elseif cmd[1] == "confiscate" and isModerator then

            if myMod.CheckPlayerValidity(pid, cmd[2]) then

                local targetPid = tonumber(cmd[2])

                if targetPid == pid then
                    tes3mp.SendMessage(pid, "You can't confiscate from yourself!\n", false)
                elseif Players[targetPid].data.customVariables.isConfiscationTarget then
                    tes3mp.SendMessage(pid, "Someone is already confiscating from that player\n", false)
                else
                    Players[pid].confiscationTargetName = Players[targetPid].accountName

                    Players[targetPid]:SetConfiscationState(true)

                    tableHelper.cleanNils(Players[targetPid].data.inventory)
                    GUI.ShowInventoryList(config.customMenuIds.confiscate, pid, targetPid)
                end
            end
			
			return COMMAND_EXECUTED

        elseif cmd[1] == "craft" then

            Players[pid].currentCustomMenu = "default crafting origin"
            menuHelper.displayMenu(pid, Players[pid].currentCustomMenu)
			
			return COMMAND_EXECUTED
		
		end
	return DO_NOTHING
end

return Methods