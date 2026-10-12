-- load services
local ReplicatedStorage = game:GetService("ReplicatedStorage")


-- load modules
local HumanoidStateModule = require(script.Parent.Parent:WaitForChild("IntervalCheck"):WaitForChild("HumanoidStateModule"))


local GodmodeModule = {}

GodmodeModule.Invulnerable = false :: boolean

function GodmodeModule.RunEquippingLogic(Tool: Tool)
    Tool.Activated:Connect(function()
        if not GodmodeModule.Invulnerable then
            GodmodeModule.Invulnerable = true

            HumanoidStateModule.Humanoid.MaxHealth = math.huge
            HumanoidStateModule.Humanoid.Health = math.huge
            Tool.Name = "Godmode (on)"
        else
            GodmodeModule.Invulnerable = false

            HumanoidStateModule.Humanoid.MaxHealth = 100
            HumanoidStateModule.Humanoid.Health = 100
            Tool.Name = "Godmode (off)"
        end
    end)
end

function GodmodeModule.GiveTool(Player: Player, Character: Model)
    local ToolTemplate = ReplicatedStorage:WaitForChild("Gears"):WaitForChild("Godmode (off)")

     local Backpack = Player:WaitForChild("Backpack")
	if Backpack then
		local ToolClone = ToolTemplate:Clone()
		ToolClone.Parent = Backpack

        local CurrentTool = ToolClone
        GodmodeModule.RunEquippingLogic(CurrentTool)
	end
end

function GodmodeModule.Reset(Player: Player, Character: Model)
    local Backpack = Player:FindFirstChild("Backpack")
    local GodmodeTool: Tool = Backpack:FindFirstChild("Godmode (on)") or Character:FindFirstChild("Godmode (on)") or
        Backpack:FindFirstChild("Godmode (off)") or Character:FindFirstChild("Godmode (off)")
    if not GodmodeTool then return end

    HumanoidStateModule.Humanoid.MaxHealth = 100
    HumanoidStateModule.Humanoid.Health = 100

    GodmodeModule.CurrentTool = nil
    GodmodeTool:Destroy()
end

return GodmodeModule