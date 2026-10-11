local InputModule = {}

InputModule.Interval = 0
InputModule.Type = "Heartbeat"

InputModule.HeldInputs = {}
InputModule.PreviousHeldInputs = {}

function InputModule.IsHoldingAny(InputList: {})
    for _, Input in ipairs(InputList) do
        if InputModule.HeldInputs[Input] then
            return true
        end
    end
    return false
end

function InputModule.Pressed(InputList: {})
    for _, Input in ipairs(InputList) do
        local IsHeldNow = InputModule.HeldInputs[Input]
        local WasHeldLastFrame = InputModule.PreviousHeldInputs[Input]

        if IsHeldNow and not WasHeldLastFrame then
            return true
        end
    end
    return false
end 

function InputModule.AddInput(Input)
    InputModule.HeldInputs[Input] = true
end

function InputModule.RemoveInput(Input)
    InputModule.HeldInputs[Input] = nil
end

function InputModule.Run(DeltaTime)
    table.clear(InputModule.PreviousHeldInputs)
    for Key, Value in pairs(InputModule.HeldInputs) do
        InputModule.PreviousHeldInputs[Key] = Value
    end
end

return InputModule