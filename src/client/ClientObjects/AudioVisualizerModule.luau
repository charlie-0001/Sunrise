-- import services
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local StarterGUI = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")


-- import modules
local PulseModule = require(script.Parent:WaitForChild("PulseModule"))
local MusicZoneModule = require(script.Parent:WaitForChild("MusicZoneModule"))
local ProcessModule = require(script.Parent.Parent:WaitForChild("IntervalCheck"):WaitForChild("ProcessModule"))


local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer and LocalPlayer:WaitForChild("PlayerGui")

local rng = Random.new()
local BarSizes: { [Frame]: number } = {}
local BarSeeds: { [Frame]: { Scale: number, Phase: number, Speed: number, nextRollAt: number } } = {}

local SMOOTH_SPEED = 50 -- high = snappier
local REROLL_MIN = 2.0 -- minimum seconds between bar re-rolls
local REROLL_MAX = 4.5 -- maximum seconds between bar re-rolls
local MIN_BAR_HEIGHT = 0.35
local MAX_BAR_HEIGHT = 4
local BASE_WIDTH = 0.025

local function GetVisualizerGUI()
	local Root = PlayerGui or StarterGUI
	local Folder = Root:FindFirstChild("AudioVisualizer")
	local GUI = Folder and Folder:FindFirstChild("AudioVisualizerGUI")

	if GUI and GUI:IsA("ScreenGui") then
		return GUI
	end

	return nil
end

local function RollBarValues(Now: number)
	local minScale = rng:NextNumber(0.65, 0.85)
	local maxScale = math.max(minScale + 0.15, rng:NextNumber(1.15, 1.35))

	return {
		Scale = rng:NextNumber(minScale, maxScale),
		Phase = rng:NextNumber(0, math.pi * 2),
		Speed = rng:NextNumber(4, 9),
		nextRollAt = Now + rng:NextNumber(REROLL_MIN, REROLL_MAX),
	}
end

local function GetBarSeed(Frame: Frame, Now: number)
	local Seed = BarSeeds[Frame]
	if not Seed then
		Seed = RollBarValues(Now)
		Seed.nextRollAt = Now + rng:NextNumber(0.5, REROLL_MAX)
		BarSeeds[Frame] = Seed
	elseif Now >= Seed.nextRollAt then
		Seed = RollBarValues(Now)
		BarSeeds[Frame] = Seed
	end

	return Seed
end

local function BarActivate(Part: BasePart, Mode: boolean)
    local GUI: ScreenGui = GetVisualizerGUI()
	if not GUI then
		print("Error finding audio visualizer GUI!")
		return
	end

    local Container = GUI:FindFirstChild("Container")
    if not Container then return end

    local Info = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
    local Color = Part:GetAttribute("Color") :: Color3 or Color3.new(255, 255, 255)

    if Mode == true then
        GUI.Enabled = true
        for _, Frame: Frame in pairs(Container:GetChildren()) do
            if Frame:IsA("Frame") then
                Frame.BackgroundTransparency = 1

                Frame.BackgroundColor3 = Color
                -- TweenService:Create(Frame, Info, {BackgroundTransparency = 0.75}):Play()
            end
        end

        ProcessModule.InsertProcess(AudioVisualizerModule.AudioVisualizerProcess)

    elseif Mode == false then
        for _, Frame: Frame in pairs(Container:GetChildren()) do
            if Frame:IsA("Frame") then
                -- TweenService:Create(Frame, Info, {BackgroundTransparency = 1}):Play()
            end
        end

        ProcessModule.RemoveProcess(AudioVisualizerModule.AudioVisualizerProcess)
        GUI.Enabled = false
    else
        print("Failed to tween in/out the audiovisualizer bar GUI!")

    end
end


AudioVisualizerModule = {}

AudioVisualizerModule.Interval = 0
AudioVisualizerModule.Type = "RenderStepped"

function AudioVisualizerModule.Run(DeltaTime: number)
	local GUI: ScreenGui = GetVisualizerGUI()
	if not GUI then
		print("Error finding audio visualizer GUI!")
		return
	end

	local Container = GUI:FindFirstChild("Container")
	if not Container then return end

	local Loudness = (MusicZoneModule.CurrentSong and MusicZoneModule.CurrentSong.IsPlaying and MusicZoneModule.CurrentSong.PlaybackLoudness) or 0
	local BaseRatio = Loudness * 8 / PulseModule.MaxLoudness
	local Now = os.clock()
	local Alpha = 1 - math.exp(-SMOOTH_SPEED * DeltaTime)

	for Index, Frame: Frame in ipairs(Container:GetChildren()) do
		if Frame:IsA("Frame") then
			Frame.BackgroundTransparency = PulseModule.CurrentTransparency

			local Seed = GetBarSeed(Frame, Now)
			local ScaledBase = BaseRatio * Seed.Scale
			local WaveOffset = math.sin(Now * Seed.Speed + Index + Seed.Phase) * 0.35
			local TargetSize = math.clamp(ScaledBase + WaveOffset, MIN_BAR_HEIGHT, MAX_BAR_HEIGHT)

			local CurrentSize = BarSizes[Frame] or TargetSize
			local NextSize = CurrentSize + (TargetSize - CurrentSize) * Alpha
			BarSizes[Frame] = NextSize

			Frame.Size = UDim2.new(BASE_WIDTH, 0, NextSize, 0)
		end
	end
end

AudioVisualizerModule.AudioVisualizerProcess = ProcessModule.new(
	AudioVisualizerModule.Interval,
	AudioVisualizerModule.Run,
	AudioVisualizerModule.Type
)

function AudioVisualizerModule.Begin(Part: BasePart)
	if ProcessModule.HasProcess(AudioVisualizerModule.AudioVisualizerProcess) then return end
    BarActivate(Part, true)
end

function AudioVisualizerModule.End(Part: BasePart)
    if not ProcessModule.HasProcess(AudioVisualizerModule.AudioVisualizerProcess) then return end
	BarActivate(Part, false)
end

function AudioVisualizerModule.ChangeProperties(Part: BasePart)

end

return AudioVisualizerModule