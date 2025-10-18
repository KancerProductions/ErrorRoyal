--[[
Path: ServerScriptService/Combat/KillService.Script.lua
Purpose: On death, notify killer client to play cosmetic kill FX. Server stays authoritative about the kill.
]]

local Players = game:GetService("Players")
local Rep = game:GetService("ReplicatedStorage")
local KillEvent = Rep:WaitForChild("Net"):WaitForChild("Events"):WaitForChild("KillEffect")

local function onCharacter(plr, char)
	local hum = char:WaitForChild("Humanoid")
	hum.Died:Connect(function()
		local killerId = hum:GetAttribute("LastHitBy")
		local fxKey    = hum:GetAttribute("KillFx") or "DEFAULT"
		local killer   = killerId and Players:GetPlayerByUserId(killerId)
		if killer then
			KillEvent:FireClient(killer, { target = char, fx = fxKey })
		end
	end)
end

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(c) onCharacter(plr, c) end)
end)
