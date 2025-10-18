--[[
Path: ServerScriptService/Systems/PlayerService.Script.lua
Purpose: Seed player stats; push to HUD; apply health caps on spawn.
Notes: Server-only. No secrets in ReplicatedStorage.
]]

local Players = game:GetService("Players")
local Rep = game:GetService("ReplicatedStorage")

local Net = Rep:WaitForChild("Net")
local Events = Net:WaitForChild("Events")
local StatsPush = Events:WaitForChild("StatsPush")

local PlayerStats = require(Rep.Modules.Player.PlayerStats)
local store = {}

Players.PlayerAdded:Connect(function(plr)
	store[plr] = PlayerStats.default()
	StatsPush:FireClient(plr, store[plr])

	plr.CharacterAdded:Connect(function(char)
		local hum = char:WaitForChild("Humanoid")
		hum.MaxHealth = store[plr].MaxHealth
		hum.Health    = store[plr].Health
	end)
end)

Players.PlayerRemoving:Connect(function(plr)
	store[plr] = nil
end)

_G.PlayerStore = store
