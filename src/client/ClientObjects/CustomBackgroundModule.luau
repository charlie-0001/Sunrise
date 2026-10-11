-- load services
local ReplicatedStorage = game:GetService("ReplicatedStorage")


CustomBackgroundModule = {}

CustomBackgroundModule.Interval = 0
CustomBackgroundModule.Type = "RenderStepped"

function CustomBackgroundModule.Run(DeltaTime)
    local OriginalBackground = ReplicatedStorage:FindFirstChild("CustomBackground")
end

return CustomBackgroundModule