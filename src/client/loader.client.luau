local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModuleManager = require(ReplicatedStorage.ModuleManager)

local container = script.Parent.Controllers

ModuleManager.Start(container)
