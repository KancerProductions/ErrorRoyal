--[[
Path: StarterPlayer/StarterPlayerScripts/EffectsClient.LocalScript.lua
Purpose: Client-side cosmetic effects for kills and movement. Nil-safe if VFX folders aren't present yet.
]]

local Rep = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Catalog = require(Rep.Modules.EffectsCatalog)
local Net = Rep:WaitForChild("Net")
local Events = Net:WaitForChild("Events")
local KillEvent = Events:WaitForChild("KillEffect")

local function emitModel(model, parent, emitCount)
	if not model or not parent then return end
	local clone = model:Clone(); clone.Parent = parent
	for _,d in ipairs(clone:GetDescendants()) do
		if d:IsA("ParticleEmitter") then d:Emit(emitCount or d:GetAttribute("EmitCount") or 25) end
		if d:IsA("Sound") then d:Play() end
	end
	Debris:AddItem(clone, 5)
end

KillEvent.OnClientEvent:Connect(function(payload)
	local char = payload and payload.target
	if not char then return end
	local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
	local cfg = Catalog.Kill[payload.fx or "DEFAULT"] or Catalog.Kill.DEFAULT
	if torso then emitModel(cfg.particle, torso, 30) end
end)

-- Optional: light motion dust when you add VFX later
local plr = Players.LocalPlayer
local function hook(c)
	local hum = c:WaitForChild("Humanoid")
	local root = c:WaitForChild("HumanoidRootPart")
	local lastY = 0
	RunService.RenderStepped:Connect(function()
		if not root or hum.Health <= 0 then return end
		local vy = root.AssemblyLinearVelocity.Y
		if lastY < -(Catalog.Motion.Land.minVel or 25) and math.abs(vy) < 1 then
			local cfg = Catalog.Motion.Land
			if cfg and cfg.particle then emitModel(cfg.particle, root, 20) end
		end
		lastY = vy
	end)
end
if plr.Character then hook(plr.Character) end
plr.CharacterAdded:Connect(hook)
