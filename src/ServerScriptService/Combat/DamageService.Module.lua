--[[
Path: ServerScriptService/Combat/DamageService.Module.lua
Purpose: Server-authoritative damage application (never trust client).
]]

local Damage = {}

function Damage.Apply(humanoid, amount, attacker, killFxKey)
	if not humanoid or not humanoid.Parent or humanoid.Health <= 0 then return end
	if attacker and attacker.UserId then
		humanoid:SetAttribute("LastHitBy", attacker.UserId)
	end
	if killFxKey then
		humanoid:SetAttribute("KillFx", killFxKey)
	end
	humanoid:TakeDamage(amount)
end

return Damage
