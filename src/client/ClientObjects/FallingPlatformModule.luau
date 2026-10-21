-- load services
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local SoundService = game:GetService("SoundService")


local Sound: Sound = SoundService:FindFirstChild("FallingPlatformSound")


FallingPlatformModule = {}

function FallingPlatformModule.Fall(Part: BasePart)
    if CollectionService:HasTag(Part, "On") then return end

    local Model = Part.Parent :: Model
    if not Model then return end    

    local StartPos = Part.Position

    local End: BasePart = Model:FindFirstChild("End")
    if not End then return end

    local AlignPos: AlignPosition? = Part:FindFirstChildOfClass("AlignPosition")
    if not AlignPos then return end

    CollectionService:AddTag(Part, "On")

    -- pulse
    local Pulse = Model:GetAttribute("Pulse")
    if Pulse then
        local PulseTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        local OriginalColor = Part.Color
        local h, s, v = OriginalColor:ToHSV()
        local PulseColor = Color3.fromHSV(h, math.min(0, s - 0.1), v)

        local PulseTween = TweenService:Create(Part, PulseTweenInfo, {Color = OriginalColor})

        Part.Color = PulseColor
        PulseTween:Play()
    end

    if Sound then
        Sound:Play()
    end

    -- make part fall
    local FallTime = Model:GetAttribute("FallTime") or 1
    local FallTweenInfo = TweenInfo.new(FallTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local FallTween = TweenService:Create(AlignPos, FallTweenInfo, {Position = End.Position})
    FallTween:Play()
    FallTween.Completed:Wait()

    -- remove collision
    local RemoveCollision = Model:GetAttribute("RemoveCollision")
    if RemoveCollision then 
        Part.CanCollide = false 
        Part.Transparency = 0.75
    end

    -- stall
    local StallTime = Model:GetAttribute("Stall") or 0
    if StallTime > 0 then task.wait(StallTime) end

    -- make part return
    local ReturnTime = Model:GetAttribute("ReturnTime") or 1
    local ReturnTweenInfo = TweenInfo.new(ReturnTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

    local ReturnTween = TweenService:Create(AlignPos, ReturnTweenInfo, {Position = StartPos})
    ReturnTween:Play()
    ReturnTween.Completed:Wait()

    -- bring back collision
    if RemoveCollision then 
        Part.CanCollide = true
        Part.Transparency = 0
    end

    local Cooldown = Model:GetAttribute("Cooldown") or 0.1
    task.wait(Cooldown)

    CollectionService:RemoveTag(Part, "On")
end

function FallingPlatformModule.InitializePart(Part: BasePart)
    local Atc = Part:FindFirstChildOfClass("Attachment") :: Attachment
    if not Atc then return end

    if not Part:FindFirstChildOfClass("AlignOrientation") then
        local AlignOri: AlignOrientation = Instance.new("AlignOrientation")

        AlignOri.CFrame = Atc.WorldCFrame
        AlignOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
        AlignOri.Attachment0 = Atc
        AlignOri.MaxAngularVelocity = math.huge
        AlignOri.MaxTorque = math.huge
        AlignOri.Responsiveness = 100
        AlignOri.Parent = Part
    end

    if not Part:FindFirstChildOfClass("AlignPosition") then
        local AlignPos: AlignPosition = Instance.new("AlignPosition")

        AlignPos.Position = Atc.WorldCFrame.Position
        AlignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
        AlignPos.Attachment0 = Atc
        AlignPos.MaxForce = math.huge
        AlignPos.MaxVelocity = math.huge
        AlignPos.Responsiveness = 100
        AlignPos.Parent = Part
    end

    Part.Anchored = false
end

return FallingPlatformModule