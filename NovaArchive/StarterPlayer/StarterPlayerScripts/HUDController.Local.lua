--[[
Path: StarterPlayer/StarterPlayerScripts/HUDController.LocalScript.lua
Purpose: Listen for server stat pushes and update HUD if present. Safe if UI not built yet.
]]

local Rep = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Net = Rep:WaitForChild("Net")
local Events = Net:WaitForChild("Events")
local StatsPush = Events:WaitForChild("StatsPush")

local state = { Health=100, MaxHealth=100, Stamina=100, XP=0, Level=1, Coins=0 }

local function applyToGui()
	-- No-op if you haven't made the ScreenGui yet. Add your Frame/TextLabels hook here later.
	-- Example (when ready):
	-- local gui = Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("HUD")
	-- if not gui then return end
	-- gui.HealthBar.Size = UDim2.new(state.Health/state.MaxHealth, 0, 1, 0)
end

StatsPush.OnClientEvent:Connect(function(payload)
	for k,v in pairs(payload or {}) do state[k] = v end
	applyToGui()
end)

-- Optional: poll local Humanoid for live health until server stats system expands
local function hookChar(char)
	local hum = char:WaitForChild("Humanoid")
	hum.HealthChanged:Connect(function(h)
		state.Health = h; state.MaxHealth = hum.MaxHealth
		applyToGui()
	end)
end

local lp = Players.LocalPlayer
if lp.Character then hookChar(lp.Character) end
lp.CharacterAdded:Connect(hookChar)
