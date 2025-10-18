--[[
Path: StarterPlayer/StarterPlayerScripts/PlayerController.LocalScript.lua
Purpose: Client-side movement feel (sprint/crouch/slide), speed smoothing, and locomotion animation playback.
Notes: No damage/XP logic here. Cosmetics & input only.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Rep = game:GetService("ReplicatedStorage")

local Move = require(Rep.Modules.Movement.MovementSpec)

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

-- Animator
local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
local function loadLoop(id, prio)
	if not id or id == 0 or id == "rbxassetid://0" then return nil end
	local anim = Instance.new("Animation"); anim.AnimationId = tostring(id)
	local track = animator:LoadAnimation(anim)
	track.Looped = true
	if prio then track.Priority = prio end
	return track
end

local idleTrack = loadLoop(Move.IdleAnimId, Enum.AnimationPriority.Movement)
local walkTrack = loadLoop(Move.WalkAnimId, Enum.AnimationPriority.Movement)
local runTrack  = loadLoop(Move.RunAnimId,  Enum.AnimationPriority.Movement)
local crouchTrack = loadLoop(Move.CrouchAnimId, Enum.AnimationPriority.Movement)
local slideTrack  = loadLoop(Move.SlideAnimId,  Enum.AnimationPriority.Movement)

local function play(track)
	if not track then return end
	if not track.IsPlaying then track:Play(0.1, 1, 1) end
end
local function stop(track, fade) if track and track.IsPlaying then track:Stop(fade or 0.1) end end

-- Input state
local wantSprint = false
local wantCrouch = false
local canSlide   = true
local stamina    = Move.StaminaMax
local regenWait  = 0

-- Speed smoothing
local targetSpeed = Move.Walk
local currentSpeed = Move.Walk
local SPEED_LERP = 12

-- Crouch scaling helpers (R15)
local function setCrouch(on)
	-- Camera / rig scale (visual only)
	local scale = on and Move.CrouchRigScale or 1.0
	local bodyHeightScale = hum:FindFirstChild("BodyHeightScale") or Instance.new("NumberValue", hum)
	bodyHeightScale.Name = "BodyHeightScale"
	bodyHeightScale.Value = scale

	-- Hip height offset (feel)
	hum.HipHeight = (on and Move.CrouchHipOffset or 0)

	-- Anim
	if on then
		if crouchTrack then play(crouchTrack) end
	else
		if crouchTrack then stop(crouchTrack, 0.1) end
	end
end

-- Slide coroutine
local slideEndTime = 0
local function trySlide()
	if not canSlide then return end
	if currentSpeed < Move.SlideMinSpeed then return end
	canSlide = false
	slideEndTime = time() + Move.SlideDuration

	-- Impulse forward
	local forward = hrp.CFrame.LookVector * Move.SlideImpulse
	hrp.AssemblyLinearVelocity += Vector3.new(forward.X, 0, forward.Z)

	-- Visuals
	if slideTrack then play(slideTrack) end

	task.delay(Move.SlideDuration, function()
		if slideTrack then stop(slideTrack, 0.05) end
	end)

	task.delay(Move.SlideCooldown, function()
		canSlide = true
	end)
end

-- Input bindings
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.LeftShift then
		wantSprint = true
	elseif input.KeyCode == Enum.KeyCode.LeftControl then
		wantCrouch = true
	elseif input.KeyCode == Enum.KeyCode.C then
		trySlide()
	end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.LeftShift then
		wantSprint = false
	elseif input.KeyCode == Enum.KeyCode.LeftControl then
		wantCrouch = false
	end
end)

-- Main loop
RunService.RenderStepped:Connect(function(dt)
	-- Stamina logic (only drains while sprinting & moving)
	local moving = hum.MoveDirection.Magnitude > 0.05
	if wantSprint and moving and stamina > 0 then
		stamina = math.max(0, stamina - Move.StaminaDrainPerSec * dt)
		regenWait = Move.StaminaRegenDelay
	else
		if regenWait > 0 then regenWait -= dt end
		if regenWait <= 0 and stamina < Move.StaminaMax then
			stamina = math.min(Move.StaminaMax, stamina + Move.StaminaRegenPerSec * dt)
		end
	end
	if stamina <= 0 then wantSprint = false end

	-- Target speed
	if wantCrouch then
		targetSpeed = Move.Crouch
	else
		targetSpeed = (wantSprint and moving) and Move.Sprint or Move.Walk
	end

	-- Slide friction (simple drag)
	if time() < slideEndTime then
		targetSpeed = math.max(Move.Crouch, targetSpeed - Move.SlideFriction)
	end

	-- Smooth to target
	currentSpeed += (targetSpeed - currentSpeed) * math.min(1, dt * SPEED_LERP)
	hum.WalkSpeed = currentSpeed

	-- Apply crouch rig changes over time
	setCrouch(wantCrouch)

	-- Choose locomotion track
	if not moving then
		stop(walkTrack); stop(runTrack)
		play(idleTrack)
	else
		stop(idleTrack)
		local useRun = currentSpeed > (Move.Walk + Move.Sprint) * 0.5
		if useRun then
			stop(walkTrack); play(runTrack)
			if runTrack then runTrack:AdjustSpeed(currentSpeed / (Move.RunAnimBaseSpeed or Move.Sprint)) end
		else
			stop(runTrack); play(walkTrack)
			if walkTrack then walkTrack:AdjustSpeed(currentSpeed / (Move.WalkAnimBaseSpeed or Move.Walk)) end
		end
	end
end)
