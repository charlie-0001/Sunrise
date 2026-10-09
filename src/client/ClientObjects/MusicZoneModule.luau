-- load services
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")


local PlayerGUI = Players.LocalPlayer:WaitForChild("PlayerGui")
local MusicGUI = PlayerGUI:WaitForChild("MusicGUI")
local TextLabel: TextLabel = MusicGUI:WaitForChild("TextLabel")

local CurrentZone: BasePart? = nil


local MusicZoneModule = {}
MusicZoneModule.CurrentSong = nil :: Sound?

MusicZoneModule.ChangeMusic = function(Part: BasePart)
    if Part == CurrentZone then return end
    CurrentZone = Part

    local OriginalSound = Part:FindFirstChildOfClass("Sound")
    if not OriginalSound then return end

    local Sound: Sound = SoundService:FindFirstChild(OriginalSound.Name)
    if not Sound then return end

    local StringID = string.match(Sound.SoundId, "%d+")
    local AssetID = tonumber(StringID)

    local Success, MarketSound = pcall(function(...)
        return MarketplaceService:GetProductInfoAsync(AssetID)
    end)

    if Success then
        TextLabel.Text = MarketSound.Name .. " ♪"
    end 

    MusicZoneModule.CurrentSong = Sound

    if not Sound.IsPlaying then
        Sound.TimePosition = 0
        Sound.Volume = 0
        Sound:Play()
    end

    local TargetVolume = Part:GetAttribute("Volume") or OriginalSound.Volume or 1
    local NewTweenTime = Part:GetAttribute("TweenTime") or 1

    local NewTweenInfo = TweenInfo.new(NewTweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local FadeInTween = TweenService:Create(Sound, NewTweenInfo, {Volume = TargetVolume})
    
    FadeInTween:Play()
end

MusicZoneModule.ExitedZone = function(Part: BasePart)
    if CurrentZone ~= Part then return end
    CurrentZone = nil

    TextLabel.Text = "Nil ♪"

    local OriginalSound = Part:FindFirstChildOfClass("Sound")
    local Sound: Sound = SoundService:WaitForChild(OriginalSound.Name)

    local TweenTime = Part:GetAttribute("TweenTime") or 1

    local NewTweenInfo = TweenInfo.new(TweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local FadeOutTween = TweenService:Create(Sound, NewTweenInfo, {Volume = 0})
    
    FadeOutTween:Play()

    FadeOutTween.Completed:Wait()
    
    Sound:Stop()
    if MusicZoneModule.CurrentSong == Sound then
        MusicZoneModule.CurrentSong = nil
    end
end

MusicZoneModule.LoadMusic = function(Sound: Sound)
    if not SoundService:FindFirstChild(Sound.Name) then
        local Clone = Sound:Clone()
        Clone.Parent = SoundService
    end
end

return MusicZoneModule