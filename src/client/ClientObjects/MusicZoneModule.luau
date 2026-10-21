-- load services
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

-- load modules
local CollisionCheckModule = require(script.Parent.Parent:WaitForChild("IntervalCheck"):WaitForChild("CollisionCheckModule"))

local PlayerGUI = Players.LocalPlayer:WaitForChild("PlayerGui")
local MusicGUI = PlayerGUI:WaitForChild("MusicGUI")
local TextLabel: TextLabel = MusicGUI:WaitForChild("TextLabel")

local MusicZoneModule = {}

MusicZoneModule.CurrentSong = nil :: Sound?
MusicZoneModule.CurrentZone = nil :: BasePart?

local function GetBestZone(Excluding: BasePart?)
    local HighestPriority = -math.huge
    local BestPart = nil

    for _, ZonePart: BasePart in pairs(CollisionCheckModule.PartsInPlayer) do
        if ZonePart:HasTag("MusicZone") and ZonePart ~= Excluding then
            local Priority = ZonePart:GetAttribute("Priority") or 0
            if Priority > HighestPriority then
                BestPart, HighestPriority = ZonePart, Priority
            end
        end
    end

    return BestPart
end

local function FadeOut(Zone: BasePart)
    local Original = Zone:FindFirstChildOfClass("Sound")
    if not Original then return end
    local Sound = SoundService:FindFirstChild(Original.Name) :: Sound?
    if not Sound then return end

    local TweenTime = Zone:GetAttribute("TweenTime") or 1
    local Info = TweenInfo.new(TweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local Tween = TweenService:Create(Sound, Info, {Volume = 0})

    Tween.Completed:Once(function(state)
        -- only stop if it fully faded and nothing re-selected it
        if state == Enum.PlaybackState.Completed and MusicZoneModule.CurrentSong ~= Sound then
            Sound:Stop()
        end
    end)
    Tween:Play()
end

local function FadeIn(Zone: BasePart)
    local Original = Zone:FindFirstChildOfClass("Sound")
    if not Original then return end
    local Sound = SoundService:FindFirstChild(Original.Name) :: Sound?
    if not Sound then 
        MusicZoneModule.CurrentSong = nil
        return 
    end

    MusicZoneModule.CurrentSong = Sound

    local AssetID = tonumber(string.match(Sound.SoundId, "%d+"))
    if AssetID then
        local Success, MarketSound = pcall(function(...)
            return MarketplaceService:GetProductInfoAsync(AssetID)
        end)

        if Success and MarketSound then
            TextLabel.Text = MarketSound.Name .. " ♪"
        end 
    end

    if not Sound.IsPlaying then
        Sound.Volume = 0
        Sound:Play()
    end

    local TargetVolume = Zone:GetAttribute("Volume") or 1
    local TweenTime = Zone:GetAttribute("TweenTime") or 1
    local Info = TweenInfo.new(TweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    TweenService:Create(Sound, Info, {Volume = TargetVolume}):Play()
end

function MusicZoneModule.Refresh(Excluding: BasePart?)
    local Target = GetBestZone(Excluding)
    local Old = MusicZoneModule.CurrentZone
    if Target == Old then return end

    MusicZoneModule.CurrentZone = Target

    if Target then
        FadeIn(Target)
    else
        MusicZoneModule.CurrentSong = nil
        TextLabel.Text = "Nil ♪"
    end

    if Old then FadeOut(Old) end
end

function MusicZoneModule.ChangeMusic(Part: BasePart)
    MusicZoneModule.Refresh()
end

function MusicZoneModule.ExitedZone(Part: BasePart)
    MusicZoneModule.Refresh(Part)
end

function MusicZoneModule.LoadMusic(Sound: Sound)
    if not SoundService:FindFirstChild(Sound.Name) then
        local Clone = Sound:Clone()
        Clone.Parent = SoundService
    end
end

return MusicZoneModule