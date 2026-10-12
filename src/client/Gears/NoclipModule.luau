-- load modules
local InputModule = require(script.Parent.Parent:WaitForChild("InputScript"):WaitForChild("InputModule"))
local HumanoidStateModule = require(script.Parent.Parent:WaitForChild("IntervalCheck"):WaitForChild("HumanoidStateModule"))
local ProcessModule = require(script.Parent.Parent:WaitForChild("IntervalCheck"):WaitForChild("ProcessModule"))


-- load services
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local Camera = game.Workspace.CurrentCamera


local NoclipModule = {}

NoclipModule.Interval = 0
NoclipModule.Type = "Heartbeat"

NoclipModule.Forward = {Enum.KeyCode.W}
NoclipModule.Backward = {Enum.KeyCode.S}
NoclipModule.Left = {Enum.KeyCode.A}
NoclipModule.Right = {Enum.KeyCode.D}
NoclipModule.Up = {Enum.KeyCode.Space}

NoclipModule.SpeedUp = {Enum.KeyCode.E}
NoclipModule.SpeedDown = {Enum.KeyCode.Q}
NoclipModule.Speed = 70

NoclipModule.CurrentTool = nil :: Tool?

function NoclipModule.Run(DeltaTime: number)
    if NoclipModule.CurrentTool == nil then return end

    local MoveVector = Vector3.zero
    local Count = 0

    if InputModule.IsHoldingAny(NoclipModule.Forward) then MoveVector += Vector3.new(0, 0, -1); Count += 1 end
    if InputModule.IsHoldingAny(NoclipModule.Backward) then MoveVector += Vector3.new(0, 0, 1); Count += 1 end
    if InputModule.IsHoldingAny(NoclipModule.Left) then MoveVector += Vector3.new(-1, 0, 0); Count += 1 end
    if InputModule.IsHoldingAny(NoclipModule.Right) then MoveVector += Vector3.new(1, 0, 0); Count += 1 end
	if InputModule.IsHoldingAny(NoclipModule.Up) then MoveVector += Vector3.new(0, 1, 0) end

    if InputModule.IsHoldingAny(NoclipModule.SpeedUp) then NoclipModule.Speed += 5 end
    if InputModule.IsHoldingAny(NoclipModule.SpeedDown) then NoclipModule.Speed -= 5 end
    if NoclipModule.Speed < 0 then NoclipModule.Speed = 5 end

    MoveVector = MoveVector * NoclipModule.Speed * DeltaTime
    if Count >= 2 then MoveVector *= (math.sqrt(2) / 2) end

    HumanoidStateModule.HumanoidRootPart.CFrame = CFrame.new(
        HumanoidStateModule.HumanoidRootPart.Position,
        HumanoidStateModule.HumanoidRootPart.Position + Camera.CFrame.LookVector)
         * CFrame.new(MoveVector)
end

local NoclipProcess = ProcessModule.new(NoclipModule.Interval, NoclipModule.Run, NoclipModule.Type)

function NoclipModule.RunEquippingLogic(Tool: Tool)
    Tool.Equipped:Connect(function() -- equipped and unequipped might cause a memory leak in the future because these are "automatically" cleaned up but that might not be the case
        HumanoidStateModule.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        HumanoidStateModule.Inert = true
        HumanoidStateModule.HumanoidRootPart.Anchored = true
        for _, Part: BasePart in HumanoidStateModule.Character:GetChildren() do
            if Part:IsA("BasePart") then
                Part.CollisionGroup = "CollideWithNothing"
            end
        end
        
        ProcessModule.InsertProcess(NoclipProcess)
    end)

    Tool.Unequipped:Connect(function()
        HumanoidStateModule.Humanoid:ChangeState("GettingUp")
        HumanoidStateModule.Inert = false
        HumanoidStateModule.HumanoidRootPart.Anchored = false 
        for _, Part: BasePart in HumanoidStateModule.Character:GetChildren() do
            if Part:IsA("BasePart") then
                Part.CollisionGroup = "Players"
            end
        end

        ProcessModule.RemoveProcess(NoclipProcess)
    end)
end

function NoclipModule.GiveTool(Player: Player, Character: Model)
    local ToolTemplate = ReplicatedStorage:WaitForChild("Gears"):WaitForChild("Noclip")

    local Backpack = Player:WaitForChild("Backpack")
	if Backpack then
		local ToolClone = ToolTemplate:Clone()
		ToolClone.Parent = Backpack

        NoclipModule.CurrentTool = ToolClone
        NoclipModule.RunEquippingLogic(NoclipModule.CurrentTool)
	end
end

function NoclipModule.Reset(Player: Player, Character: Model)
    local Backpack = Player:FindFirstChild("Backpack")
    local NoclipTool: Tool = Backpack:FindFirstChild("Noclip") or Character:FindFirstChild("Noclip")
    if not NoclipTool then return end

    NoclipModule.CurrentTool = nil
    NoclipTool:Destroy()
    ProcessModule.RemoveProcess(NoclipProcess)
end

return NoclipModule