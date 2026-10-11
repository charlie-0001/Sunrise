local Stats = game:GetService("Stats")


StatsModule = {}

StatsModule.Interval = 0.1
StatsModule.Type = "Heartbeat"

function StatsModule.Run(DeltaTime)
    print("Instance count is: " .. Stats.InstanceCount)
    print("Frame time is: " .. Stats.FrameTime)
    print("GPU frame time is: " .. Stats.RenderGPUFrameTime)
    print("CPU frame time is: " .. Stats.RenderCPUFrameTime)
    print("Contacts count is: " .. Stats.ContactsCount)
    print("---------------------------------------------------------------------------")
end

return StatsModule