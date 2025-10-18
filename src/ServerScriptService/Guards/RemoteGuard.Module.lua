--[[
Path: ServerScriptService/_Guards/RemoteGuard.Module.lua
Purpose: Simple per-player rate limiting, arg validation, and sanity checks for client→server remotes.
]]

local Players = game:GetService("Players")
local Guard = {}
local buckets = setmetatable({}, { __mode = "k" })
local function now() return os.clock() end

function Guard.RateLimit(plr, key, maxPerSecond)
	maxPerSecond = maxPerSecond or 10
	local p = buckets[plr]; if not p then p = {}; buckets[plr] = p end
	local b = p[key]; local t = now()
	if not b or (t - b.t) >= 1 then
		p[key] = { t = t, count = 1 }; return true
	else
		b.count += 1; return b.count <= maxPerSecond
	end
end

function Guard.IsPlayerAlive(plr)
	local char = plr and plr.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	return (hum and hum.Health > 0) and hum or nil
end

function Guard.SanitizeNumber(x, minV, maxV, defaultV)
	if typeof(x) ~= "number" then return defaultV end
	if minV and x < minV then return minV end
	if maxV and x > maxV then return maxV end
	return x
end

Players.PlayerRemoving:Connect(function(plr) buckets[plr] = nil end)
return Guard

