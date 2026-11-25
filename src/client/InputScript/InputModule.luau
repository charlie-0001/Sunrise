local InputModule = {}

InputModule.Interval = 0
InputModule.Type = "Heartbeat"

InputModule.HeldInputs = {}
InputModule.PressedThisFrame = {}
InputModule.ReadyToClear = {}

function InputModule.IsHoldingAny(InputList: {any})
    for _, Input in ipairs(InputList) do
        if InputModule.HeldInputs[Input] then
            return true
        end
    end

    return false
end

function InputModule.Pressed(InputList: {any})
    for _, Input in ipairs(InputList) do
		if InputModule.PressedThisFrame[Input] then
			InputModule.PressedThisFrame[Input] = false
			return true
		end
	end

	return false
end 

function InputModule.AddInput(Input)
    if not InputModule.HeldInputs[Input] then
		InputModule.PressedThisFrame[Input] = true
	else 
        InputModule.PressedThisFrame[Input] = false
    end

    InputModule.HeldInputs[Input] = true
end

function InputModule.RemoveInput(Input)
    InputModule.HeldInputs[Input] = nil
end

function InputModule.Run(DeltaTime)
    for Input in pairs(InputModule.PressedThisFrame) do
		if InputModule.ReadyToClear[Input] then
			InputModule.PressedThisFrame[Input] = nil
			InputModule.ReadyToClear[Input] = nil
		else
			--[[ Your pressed input gets to survive 1 frame before triggering so unless you're running at 1 fps 
            or you're a Geomtry Dash player I don't think this will matter ]]
			InputModule.ReadyToClear[Input] = true
		end
	end
end

return InputModule