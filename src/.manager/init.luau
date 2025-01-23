--[[

    $$\      $$\                 $$\           $$\           $$\      $$\
    $$$\    $$$ |                $$ |          $$ |          $$$\    $$$ |
    $$$$\  $$$$ | $$$$$$\   $$$$$$$ |$$\   $$\ $$ | $$$$$$\  $$$$\  $$$$ | $$$$$$\  $$$$$$$\   $$$$$$\   $$$$$$\   $$$$$$\   $$$$$$\
    $$\$$\$$ $$ |$$  __$$\ $$  __$$ |$$ |  $$ |$$ |$$  __$$\ $$\$$\$$ $$ | \____$$\ $$  __$$\  \____$$\ $$  __$$\ $$  __$$\ $$  __$$\
    $$ \$$$  $$ |$$ /  $$ |$$ /  $$ |$$ |  $$ |$$ |$$$$$$$$ |$$ \$$$  $$ | $$$$$$$ |$$ |  $$ | $$$$$$$ |$$ /  $$ |$$$$$$$$ |$$ |  \__|
    $$ |\$  /$$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |$$ |$$   ____|$$ |\$  /$$ |$$  __$$ |$$ |  $$ |$$  __$$ |$$ |  $$ |$$   ____|$$ |
    $$ | \_/ $$ |\$$$$$$  |\$$$$$$$ |\$$$$$$  |$$ |\$$$$$$$\ $$ | \_/ $$ |\$$$$$$$ |$$ |  $$ |\$$$$$$$ |\$$$$$$$ |\$$$$$$$\ $$ |
    \__|     \__| \______/  \_______| \______/ \__| \_______|\__|     \__| \_______|\__|  \__| \_______| \____$$ | \_______|\__|
    By @crusherfire & modified by @thecasualdev                                                         $$\   $$ |
                                                                                                        \$$$$$$  |
                                                                                                         \______/

    ModuleManager is just a fancy name for a module loader,
    The purpose of a rewrite was so I could open it up and have a better understanding if I ever wished to expand on it.

    original: https://create.roblox.com/store/asset/17428442767

--]]

local SETTINGS = {
	FOLDER_SEARCH_DEPTH = 1,
	VERBOSE_LOADING = true,
	WAIT_FOR_SERVER = true,
}

local Local = {}
local Shared = {}

-- Fetch Service
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Variables
Shared.Tracker = {
	LOAD = {},
	INIT = {},
	STRT = {},
}

Shared.TrackerForActors = {
	LOAD = {},
	INIT = {},
	STRT = {},
}

local IsClient = RunService:IsClient()
local ActorForServer = script.ActorForServer
local ActorForClient = script.ActorForClient

local ACTOR_PARENT = if IsClient then Players.LocalPlayer.PlayerScripts else ServerScriptService

local PRINT_IDENTIFIER = if IsClient then "[C]" else "[S]"
local LOADED_IDENTIFIER = if IsClient then "Client" else "Server"

-- Private Functions

-- Recursive Search is exactly what it says on the box.
-- A simple loop checks what type of instance it is, and the current search depth.
-- If it is a File, it checks the current depth and will determine
-- If it is a ModuleScript, it runs the function defined by callback (loadModule function)
function Local.RecursiveSearch(
	container: Instance,
	current_depth: number,
	max_depth: number,
	callback: (module: ModuleScript) -> nil
)
	for _, child: Instance in container:GetChildren() do
		if child:IsA("Folder") then
			if current_depth >= max_depth then
				continue
			end
			Local.RecursiveSearch(child, current_depth + 1, max_depth, callback)
		elseif child:IsA("ModuleScript") then
			callback(child)
		end
	end
end

-- Custom print functions to make the console organised
function Local.Print(...)
	print(PRINT_IDENTIFIER, ...)
end
function Local.Warn(...)
	warn(PRINT_IDENTIFIER, ...)
end

return Shared
