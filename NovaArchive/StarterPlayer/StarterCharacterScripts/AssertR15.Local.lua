--[[
Path: StarterPlayer/StarterCharacterScripts/AssertR15.LocalScript.lua
Purpose: Force R15 rig on spawn for consistent animation & scaling.
]]

local hum = script.Parent:WaitForChild("Humanoid")
if hum.RigType ~= Enum.HumanoidRigType.R15 then
	hum.RigType = Enum.HumanoidRigType.R15
end