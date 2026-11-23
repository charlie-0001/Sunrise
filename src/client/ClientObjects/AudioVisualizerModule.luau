-- import services
local Players = game:GetService("Players")
local StarterGUI = game:GetService("StarterGui")


-- import modules
local PulseModule = require(script.Parent:WaitForChild("PulseModule"))
local MusicZoneModule = require(script.Parent:WaitForChild("MusicZoneModule"))
local ProcessModule = require(script.Parent.Parent:WaitForChild("IntervalCheck"):WaitForChild("ProcessModule"))


local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer and LocalPlayer:WaitForChild("PlayerGui")

local BarSizes: { [Frame]: number } = {}
local SMOOTH_SPEED = 25 -- high = snappier

local function GetVisualizerGUI()
	local Root = PlayerGui or StarterGUI
	local Folder = Root:FindFirstChild("AudioVisualizer")
	local GUI = Folder and Folder:FindFirstChild("AudioVisualizerGUI")

	if GUI and GUI:IsA("ScreenGui") then
		return GUI
	end

	return nil
end


AudioVisualizerModule = {}

AudioVisualizerModule.Interval = 0
AudioVisualizerModule.Type = "RenderStepped"

function AudioVisualizerModule.Run(DeltaTime: number)
    local GUI: ScreenGui = GetVisualizerGUI()
	if not GUI then 
		print("Error finding audio visualizer GUI!") 
		return 
	else
		local Bars = GUI:FindFirstChild("Container")
		if not Bars then return end

		local Loudness = (MusicZoneModule.CurrentSong and MusicZoneModule.CurrentSong.IsPlaying and MusicZoneModule.CurrentSong.PlaybackLoudness) or 0
		local MaxLoudness = math.max(PulseModule.MaxLoudness, 1)
		local BaseRatio = Loudness * 15 / MaxLoudness
		local Alpha = 1 - math.exp(-SMOOTH_SPEED * DeltaTime)

		for Index, Frame: Frame in ipairs(Bars:GetChildren()) do
			if Frame:IsA("Frame") then
				Frame.BackgroundTransparency = PulseModule.CurrentTransparency

				-- sin wave offet per bar
				local WaveOffset = math.sin(DeltaTime * 6 + Index * 1)
				local TargetSize = math.clamp(BaseRatio + WaveOffset, 1, 7)

				local CurrentSize = BarSizes[Frame] or TargetSize
				local NextSize = CurrentSize + (TargetSize - CurrentSize) * Alpha
				BarSizes[Frame] = NextSize

				Frame.Size = UDim2.new(0.1, 0, NextSize, 0)
			end
		end
	end
end

AudioVisualizerModule.AudioVisualizerProcess = ProcessModule.new(
    AudioVisualizerModule.Interval,
    AudioVisualizerModule.Run,
    AudioVisualizerModule.Type
)

function AudioVisualizerModule.Begin(Part: BasePart)
    local GUI: ScreenGui = GetVisualizerGUI()
    if not GUI then 
        print("Error finding audio visualizer GUI!") 
        return 
    else
        GUI.Enabled = true
    end

    local Color = Part:GetAttribute("Color") :: Color3
    if Color then 
        local Bars = GUI:FindFirstChild("Container")
        for _, Frame: Frame in ipairs(Bars:GetChildren()) do
            if Frame:IsA("Frame") then
                Frame.BackgroundColor3 = Color
            end
        end
    end

    if ProcessModule.HasProcess(AudioVisualizerModule.AudioVisualizerProcess) then return end
    ProcessModule.InsertProcess(AudioVisualizerModule.AudioVisualizerProcess)
end

function AudioVisualizerModule.End()
    local GUI: ScreenGui = GetVisualizerGUI()
    if not GUI then 
        print("Error finding audio visualizer GUI!") 
        return 
    else
        GUI.Enabled = false
    end

    ProcessModule.RemoveProcess(AudioVisualizerModule.AudioVisualizerProcess)
end

function AudioVisualizerModule.ChangeProperties(Part: BasePart)

end

return AudioVisualizerModule