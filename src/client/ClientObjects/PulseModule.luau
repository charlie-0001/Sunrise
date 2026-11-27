-- import modules
local MusicZoneModule = require(script.Parent:WaitForChild("MusicZoneModule"))
local DistanceCheckModule = require(script.Parent.Parent:WaitForChild("DistanceCheckModule"))
local CustomBackgroundModule = require(script.Parent:WaitForChild("CustomBackgroundModule"))


local PulseObjects = {}
local CurrentTransparency = {}

local MaxTransparency = 0.85 -- resting transparency when quiet
local MinTransparency = 0.25  -- lowest transparency (strongest pulse) on loud hits

local LastSong = nil


PulseModule = {}

PulseModule.Interval = 0.05
PulseModule.Type = "RenderStepped"

PulseModule.MaxLoudness = 450
PulseModule.CurrentTransparency = 0

PulseModule.Run = function(DeltaTime: number)
    if not MusicZoneModule.CurrentSong then return end
    if not MusicZoneModule.CurrentZone then return end

    if MusicZoneModule.CurrentSong ~= LastSong then
        LastSong = MusicZoneModule.CurrentSong
    end

    local PlaybackLoudness = MusicZoneModule.CurrentSong.PlaybackLoudness
    if PlaybackLoudness <= 0 then return end

    if CustomBackgroundModule.InTween == true then return end

    for _, Instance: Instance in ipairs(PulseObjects) do
        local DistanceCheck = Instance:GetAttribute("DistanceCheck")
        if DistanceCheck == true then 
            local DistanceCheckLength = Instance:GetAttribute("DistanceCheckLength") or 150
            if not DistanceCheckModule.DistanceCheck(Instance, DistanceCheckLength) then continue end
        end
        PulseModule.Pulse(Instance, PlaybackLoudness)
    end
end

PulseModule.Pulse = function(Instance, PlaybackLoudness: number)
    local Intensity = math.clamp(PlaybackLoudness / PulseModule.MaxLoudness, 0, 1)
	local TargetTransparency = MaxTransparency - (Intensity * (MaxTransparency - MinTransparency))
	TargetTransparency = math.clamp(TargetTransparency, MinTransparency, 0.85)

	local Current = CurrentTransparency[Instance]
	if Current == nil then
		if Instance:IsA("BasePart") then
			Current = Instance.Transparency
		elseif Instance:IsA("ImageLabel") then
			Current = Instance.ImageTransparency
		else
			return
		end
	end

	local NewTransparency = Current + (TargetTransparency - Current) * 0.5
	PulseModule.CurrentTransparency = NewTransparency
	CurrentTransparency[Instance] = NewTransparency

	if Instance:IsA("BasePart") then
		Instance.Transparency = NewTransparency
	elseif Instance:IsA("ImageLabel") then
		Instance.ImageTransparency = NewTransparency
	end
end

PulseModule.Initialize = function(Instance: Instance)
    table.insert(PulseObjects, Instance)
end

return PulseModule