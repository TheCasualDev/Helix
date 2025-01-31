local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModuleManager = require(ReplicatedStorage.ModuleManager)

local container = script.Parent.Services

ModuleManager.Start(container)
