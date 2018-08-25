# tes3mp-Script-Loader
This script makes it easier to develop and install custom scripts. Just drop the custom script into **mpstuff/scripts/** and add it to **mpstuff/data/scripts.json**.

If your server is already online and you want to load up a script you just made/added; follow the steps above and then do ```/loadscript scriptname```

# Install Guide

**1.)** Take **server.lua, ScriptLoader.Lua, and DefaultCommands.lua** drop them into your **mpstuff/scripts/** folder *replacing* the old server.lua.

**2.)** Take **scripts.json** from the data folder in this github, drop it into your **mpstuff/data/** folder.


# Installing Scripts Using "ScriptLoader"

**1.)** If a script is using the script loader then go into **/mp-stuff/data/** and open **scripts.json**


**2.)** The json is set up as 
```
{
	"DefaultCommands"
}
``` 
for example multiple scripts: 
```
{
	"DefaultCommands",
  "Foo",
  "Bar"
}
```


**3.)** Drop the script into **/mp-stuff/scripts/**


**4.)** Either restart the server, or use ```/loadscript scriptname``` if you are an admin.


# Developing With "ScriptLoader"

Start with a fresh script template from this repository. Download NewScript.lua and then start developing. It has all the functions you need from server.lua there ready to use.

*If you dont need a function just delete it!!*

Chat methods return a number value back to the script loader to determine whether to break the loop to do something or not.

**Return values:**
```
DO_NOTHING = 1
HIDE_DEFAULT_CHAT = 2
COMMAND_EXECUTED = 3
```

for example in bar.lua when the command is called correctly it returns ```COMMAND_EXECUTED``` to break the command search;
When the command is not called then it returns ```DO_NOTHING``` so that the scripts that come after it get a chance to run.

```
Methods[USES_COMMAND][1] = true -- This is to tell the script loader you want to use the below function
Methods[USES_COMMAND].Func = function(pid, isAdmin, isModerator, cmd, message)

	if cmd[1] == "hello" then
		tes3mp.SendMessage(pid, "Hello World!", false)
		return COMMAND_EXECUTED
	end

	return DO_NOTHING
end
```

In **scripts.json**, the scripts at the *top* get ran last. Which is good for scripts that hide default chat and dont want to interfere with other scripts.

To use JSON in your scripts, use the Init() method to load your json tables.


