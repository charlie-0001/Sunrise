-- load services
local TweenService = game:GetService("TweenService")


-- load modules
local ProcessModule = require(script.Parent.Parent:WaitForChild("IntervalCheck"):WaitForChild("ProcessModule"))


local CurrentBackgrounds = {} :: {BasePart}


CustomBackgroundModule = {}

CustomBackgroundModule.Interval = 0
CustomBackgroundModule.Type = "RenderStepped"

CustomBackgroundModule.InTween = false

function CustomBackgroundModule.Run(DeltaTime: number)
    local Camera: Camera = game.Workspace.CurrentCamera

    for _, Part: BasePart in ipairs(CurrentBackgrounds) do
        local Folder = Part.Parent :: Folder
        local Giver = Folder:FindFirstChild("CustomBackgroundGiver")

        local SpinSpeed = Giver:GetAttribute("SpinSpeed") or 0
        local SpinRadius = Giver:GetAttribute("SpinRadius") or 15 -- Default distance if not set

        local currentAngle = Part:GetAttribute("CurrentAngle") or 0
        currentAngle += SpinSpeed * DeltaTime
        Part:SetAttribute("CurrentAngle", currentAngle)

        local targetCFrame = Camera.CFrame * CFrame.Angles(0, currentAngle, 0) * CFrame.new(0, 0, -SpinRadius)

        Part.CFrame = Part.CFrame:Lerp(targetCFrame, 0.6)
    end
end

CustomBackgroundModule.BackgroundProcess = ProcessModule.new(
    CustomBackgroundModule.Interval, 
    CustomBackgroundModule.Run, 
    CustomBackgroundModule.Type
)

function CustomBackgroundModule.BackgroundGiverTouched(Part: BasePart)
    local Folder = Part.Parent :: Folder
    if not Folder then return end
    if Folder:FindFirstChild("Clone") then return end -- end if theres already a clone
    local TargetBackground: BasePart = Folder:FindFirstChild("Background")
    if not TargetBackground then return end

    local NewBackground: BasePart = TargetBackground:Clone()
    if NewBackground:FindFirstChildOfClass("BoolValue") then
        local Pulse = (NewBackground:FindFirstChildOfClass("BoolValue") :: BoolValue).Value
        if Pulse == true then NewBackground:AddTag("Pulse") end
    end
    NewBackground.Color = Part:GetAttribute("Color") :: Color3 or Color3.fromRGB(255, 255 , 255)
    NewBackground.Transparency = Part:GetAttribute("Transparency") :: number or 0
    NewBackground.Name = "Clone"
    NewBackground.Parent = Folder

    -- enable the process running if there are no current backgrounds since one is just about to get added
    if #CurrentBackgrounds == 0 then
        ProcessModule.InsertProcess(CustomBackgroundModule.BackgroundProcess)
    end

    table.insert(CurrentBackgrounds, NewBackground)
end

function CustomBackgroundModule.BackgroundRemoverTouched(Part: BasePart)
    local Folder = Part.Parent :: Folder
    local Clone = Folder:FindFirstChild("Clone")
    if not Clone then return end

    local Index = table.find(CurrentBackgrounds, Clone)
    table.remove(CurrentBackgrounds, Index)
    Clone:Destroy()

    -- disable the process running if there are no current backgrounds
    if #CurrentBackgrounds == 0 then
        ProcessModule.RemoveProcess(CustomBackgroundModule.BackgroundProcess)
    end
end

function CustomBackgroundModule.ChangeBackgroundProperties(Part: BasePart)
    if Part:HasTag("Cooldown") then return end
    Part:AddTag("Cooldown")

    local Folder = Part.Parent :: Folder
    local Clone: BasePart = Folder:FindFirstChild("Clone")
    if not Clone then return end

    local WillTween = Part:GetAttribute("Tween") or false
    local TargetTransparency = Part:GetAttribute("Transparency") or 0
    local TargetColor = Part:GetAttribute("Color") or Color3.new(255, 255, 255)

    if WillTween == true then
        CustomBackgroundModule.InTween = true
        print(CustomBackgroundModule.InTween)

        local TweenTime = Part:GetAttribute("TweenTime") or 1
        local TweenInfo = TweenInfo.new(TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        local TransparencyTween = TweenService:Create(Clone, TweenInfo, {Transparency = TargetTransparency})
        local ColorTween = TweenService:Create(Clone, TweenInfo, {Color = TargetColor})
        TransparencyTween:Play()
        ColorTween:Play()

        ColorTween.Completed:Wait()
        CustomBackgroundModule.InTween = false

        Part:RemoveTag("Cooldown")
    else
        Clone.Color = TargetColor
        Clone.Transparency = TargetTransparency
        Part:RemoveTag("Cooldown")
    end
end

return CustomBackgroundModule