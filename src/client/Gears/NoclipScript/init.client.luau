-- load services
local Players = game:GetService("Players")


-- load modules
local ProcessModule = require(script.Parent.Parent:WaitForChild("IntervalCheck"):WaitForChild("ProcessModule"))
local NoclipModule = require(script:WaitForChild("NoclipModule"))
local HumanoidStateModule = require(script.Parent.Parent:WaitForChild("IntervalCheck"):WaitForChild("HumanoidStateModule"))


local Player = Players.LocalPlayer
local Backpack = Player:WaitForChild("Backpack")

local NoclipTool: Tool = Backpack:WaitForChild("Noclip", 5) or HumanoidStateModule.Character:WaitForChild("Noclip", 5)

local NoclipProcess = ProcessModule.new(
        NoclipModule.Interval, 
        NoclipModule.Run,
        NoclipModule.Type
    )

NoclipTool.Equipped:Connect(function()
    HumanoidStateModule.HumanoidRootPart.Anchored = true
    HumanoidStateModule.Inert = true
    HumanoidStateModule.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
    HumanoidStateModule.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero

    for _, BasePart: BasePart in HumanoidStateModule.Character:GetChildren() do
        if BasePart:IsA("BasePart") then
            BasePart.CollisionGroup = "CollideWithNothing"
        end
    end

    ProcessModule.InsertProcess(NoclipProcess)
    NoclipModule.BindKeys()
end)

NoclipTool.Unequipped:Connect(function()
    HumanoidStateModule.HumanoidRootPart.Anchored = false
    HumanoidStateModule.Inert = false

    for _, BasePart: BasePart in HumanoidStateModule.Character:GetChildren() do
        if BasePart:IsA("BasePart") then
            BasePart.CollisionGroup = "Players"
        end
    end

    ProcessModule.RemoveProcess(NoclipProcess)
    NoclipModule.UnbindKeys()
    HumanoidStateModule.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) -- removes possibility of ragdolling from noclip
end)
