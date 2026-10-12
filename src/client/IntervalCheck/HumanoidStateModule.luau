-- load services
local Player = game:GetService("Players").LocalPlayer


HumanoidState = {}

HumanoidState.Interval = 0
HumanoidState.Type = "RenderStepped"

HumanoidState.Character = nil :: Model?
HumanoidState.Humanoid = nil  :: Humanoid?
HumanoidState.HumanoidRootPart = nil :: BasePart?
HumanoidState.Inert = false :: boolean

HumanoidState.Run = function()
    local Character = Player.Character
    if not Character then return end
    HumanoidState.Character = Character

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end
    HumanoidState.Humanoid = Humanoid

    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then return end
    HumanoidState.HumanoidRootPart = HumanoidRootPart
end

return HumanoidState