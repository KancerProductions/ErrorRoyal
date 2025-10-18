--[[
Path: ReplicatedStorage/Modules/Movement/MovementSpec.Module.lua
Purpose: Central movement + animation tuning knobs used by PlayerController (client) and server where needed.
]]

local M = {
	-- Core speeds (studs/sec)
	Walk   = 15,
	Sprint = 30,
	Crouch = 8,

	-- Authoring speeds for footstep sync (studs/sec)
	WalkAnimBaseSpeed = 15,
	RunAnimBaseSpeed  = 30,

	-- Crouch timings & scaling (match your anim)
	CrouchTime        = 8/30,   -- 8 frames @ 30fps ≈ 0.27s
	CrouchCameraScale = 0.65,
	CrouchRigScale    = 0.86,
	CrouchHipOffset   = 0.35,

	-- Slide feel
	SlideMinSpeed   = 20,
	SlideImpulse    = 18,
	SlideDuration   = 0.65,
	SlideCooldown   = 0.60,
	SlideFriction   = 2.5,
	SlideHipExtra   = 0.25,
	SlideFOVKick    = 8.0,

	-- Stamina / Core stats (HUD-safe)
	StaminaMax          = 100,
	StaminaDrainPerSec  = 25,
	StaminaRegenPerSec  = 18,
	StaminaRegenDelay   = 0.6,

	HealthMax = 100,
	XPPerLevel = 100,

	-- Animation IDs (replace after you publish your FBX imports)
	IdleAnimId   = "rbxassetid://0",
	WalkAnimId   = "rbxassetid://0",
	RunAnimId    = "rbxassetid://0",
	CrouchAnimId = "rbxassetid://0",
	SlideAnimId  = "rbxassetid://0",
}

return M
