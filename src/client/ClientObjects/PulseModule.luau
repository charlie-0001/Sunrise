-- import modules
local MusicZoneModule = require(script.Parent:WaitForChild("MusicZoneModule"))
local DistanceCheckModule = require(script.Parent.Parent:WaitForChild("DistanceCheckModule"))
local CustomBackgroundModule = require(script.Parent:WaitForChild("CustomBackgroundModule"))


local PulseObjects = {}
local CurrentTransparency = {}

local AverageLoudness = 0
local SmoothingFactor = 0.2

local LastSong = nil


MusicPulsePart = {}

MusicPulsePart.Interval = 0.05
MusicPulsePart.Type = "RenderStepped"

MusicPulsePart.Run = function(DeltaTime: number)
    if not MusicZoneModule.CurrentSong then return end
    if not MusicZoneModule.CurrentZone then return end

    if MusicZoneModule.CurrentSong ~= LastSong then
        LastSong = MusicZoneModule.CurrentSong
        AverageLoudness = 0
    end

    local PlaybackLoudness = MusicZoneModule.CurrentSong.PlaybackLoudness
    if PlaybackLoudness <= 0 then return end

    local DropPosition = MusicZoneModule.CurrentZone:GetAttribute("DropPosition") or MusicZoneModule.CurrentSong.TimeLength
    if DropPosition == 0 then DropPosition = MusicZoneModule.CurrentSong.TimeLength end

    -- move the average loudness only at the start of the song. hopefully this makes the drop of songs more intense. 
    if MusicZoneModule.CurrentSong.TimePosition <= DropPosition and MusicZoneModule.CurrentSong.PlaybackLoudness > 0 then
        if AverageLoudness == 0 then
            AverageLoudness = PlaybackLoudness
        else
            -- exponential moving average formula
            AverageLoudness = AverageLoudness + (PlaybackLoudness - AverageLoudness) * SmoothingFactor
        end
    end

    print(CustomBackgroundModule.InTween)
    if CustomBackgroundModule.InTween == true then return end

    for _, Instance: Instance in ipairs(PulseObjects) do
        local DistanceCheck = Instance:GetAttribute("DistanceCheck")
        if DistanceCheck == true then 
            local DistanceCheckLength = Instance:GetAttribute("DistanceCheckLength") or 150
            if not DistanceCheckModule.DistanceCheck(Instance, DistanceCheckLength) then continue end
        end
        MusicPulsePart.Pulse(Instance, PlaybackLoudness)
    end
end

MusicPulsePart.Pulse = function(Instance, PlaybackLoudness: number)
    if AverageLoudness <= 0 then return end 

    local Ratio = PlaybackLoudness / AverageLoudness
    local TargetTransparency = 0.8 - ((Ratio - 1) * 0.35)
    TargetTransparency = math.clamp(TargetTransparency, 0, 0.9)

    local Current = CurrentTransparency[Instance] or Instance.Transparency or Instance.ImageTransparency
    local NewTransparency = Current + (TargetTransparency - Current) * 0.25

    if Instance:IsA("BasePart") then
        CurrentTransparency[Instance] = NewTransparency
        Instance.Transparency = NewTransparency
    elseif Instance:IsA("ImageLabel") then
        CurrentTransparency[Instance] = NewTransparency
        Instance.ImageTransparency = NewTransparency
    end
end

MusicPulsePart.Initialize = function(Instance: Instance)
    table.insert(PulseObjects, Instance)
end

return MusicPulsePart