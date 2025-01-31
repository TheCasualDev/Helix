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

-- Main Function

function Shared.Start(container: Instance)
	if IsClient and SETTINGS.WAIT_FOR_SERVER and not workspace:GetAttribute("ServerLoaded") then
		workspace:GetAttributeChangedSignal("ServerLoaded"):Wait()
	end

	if not RunService:IsStudio() and SETTINGS.VERBOSE_LOADING then
		warn("!!WARNING!! -- VERBOSE LOADING STILL ENABLED -- !!WARNING!!")
	end

	if SETTINGS.VERBOSE_LOADING then
		Local.warn("=== LOADING MODULES ===")
		Local.RecursiveSearch(container, 0, SETTINGS.FOLDER_SEARCH_DEPTH, Local.LoadModule)
	else
		Local.RecursiveSearch(container, 0, SETTINGS.FOLDER_SEARCH_DEPTH, Local.LoadModule)
	end

	workspace:SetAttribute(`{LOADED_IDENTIFIER}Loaded`, true)
end

-- Private Functions

function Local.LoadModule(module: ModuleScript)
	local start_time = tick()

	if module:GetAttribute("Parallel") then
		-- TODO: Setup parallel loading (and make it work this time)
		Local.Warn("Parallel is not setup yet.")
	end

	if SETTINGS.VERBOSE_LOADING then
		Local.Print(("Loading module %q"):format(module.Name))
	end

	local success, response = pcall(function()
		local LoadedModule = require(module)

		Shared.Tracker.LOAD[module] = LoadedModule

		if LoadedModule.Init then
			Shared.Tracker.INIT[module] = false
		end
		if LoadedModule.Start then
			Shared.Tracker.STRT[module] = false
		end
	end)

	local end_time = tick()

	if not SETTINGS.VERBOSE_LOADING then
		return
	end

	if success then
		Local.Print(`>> Loaded module {module.Name}`, Local.Time(start_time, end_time))
	else
		Local.Warn(`>> Failed to load module {module.Name} got response: {response}`, Local.Time(start_time, end_time))
	end
end

-- RecursiveSearch is exactly what it says on the box.
-- A simple loop checks what type of instance it is, and the current search depth.
-- If it is a File, it checks the current depth and will determine
-- If it is a ModuleScript, it runs the function defined by callback (LoadModule function)
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

function Local.Time(start_time: number, end_time: number)
	("took %.3f"):format(end_time - start_time)
end

return Shared
