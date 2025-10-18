--[[
Path: ReplicatedStorage/Modules/Player/PlayerStats.Module.lua
Purpose: Default player stat block used on spawn and HUD seed.
]]

local Stats = {}

function Stats.default()
	return {
		Health    = 100,
		MaxHealth = 100,
		Stamina   = 100,
		XP        = 0,
		Level     = 1,
		Coins     = 0,
	}
end

return Stats