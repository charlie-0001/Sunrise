-- load services
local UserInputService = game:GetService("UserInputService")


-- load modules
local InputModule = require(script:WaitForChild("InputModule"))


local Camera: Camera = workspace.CurrentCamera
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false) -- disable emote wheel bc useless


local function OnInputBegan(Input, GameProcessed)
    local InputType = Input.UserInputType

    if InputType == Enum.UserInputType.Keyboard then
        InputModule.AddInput(Input.KeyCode)

        -- alignment keys
        if GameProcessed then return end
        if Input.KeyCode == Enum.KeyCode.Comma then
            Camera.CFrame = CFrame.Angles(0, math.rad(45), 0) * Camera.CFrame
        elseif Input.KeyCode == Enum.KeyCode.Period then
            Camera.CFrame =  CFrame.Angles(0, math.rad(-45), 0) * Camera.CFrame
        end

    elseif InputType == Enum.UserInputType.MouseButton1 then
        InputModule.AddInput(InputType)
    elseif InputType == Enum.UserInputType.Touch then
        InputModule.AddInput(InputType)
    end
end

local function OnInputEnded(Input, GameProcessed)
    local InputType = Input.UserInputType

    if InputType == Enum.UserInputType.Keyboard then
        InputModule.RemoveInput(Input.KeyCode)
    elseif InputType == Enum.UserInputType.MouseButton1 then
        InputModule.RemoveInput(InputType)
    elseif InputType == Enum.UserInputType.Touch then
        InputModule.RemoveInput(InputType)
    end
end

UserInputService.InputBegan:Connect(OnInputBegan)
UserInputService.InputEnded:Connect(OnInputEnded)