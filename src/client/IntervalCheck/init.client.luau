-- load services
local RunService = game:GetService("RunService")


-- load modules
local TurretModule = require(script.Parent:WaitForChild("ClientObjects"):WaitForChild("TurretModule"))
local ProcessModule = require(script:WaitForChild("ProcessModule"))
local HumanoidStateModule = require(script:WaitForChild("HumanoidStateModule"))
local CollisionCheckModule = require(script:WaitForChild("CollisionCheckModule"))
local InputModule = require(script.Parent:WaitForChild("InputScript"):WaitForChild("InputModule"))
local PulsePartModule = require(script.Parent:WaitForChild("ClientObjects"):WaitForChild("PulseModule"))
local StatsModule = require(script:WaitForChild("StatsModule"))


-- load all processes and add them to a table
local HumanoidStateProcess = ProcessModule.new(
    HumanoidStateModule.Interval, 
    HumanoidStateModule.Run,
    HumanoidStateModule.Type
)
ProcessModule.InsertProcess(HumanoidStateProcess)

local CollisionCheckProcess = ProcessModule.new(
    CollisionCheckModule.Interval,
    CollisionCheckModule.Run,
    CollisionCheckModule.Type
)
ProcessModule.InsertProcess(CollisionCheckProcess)

local TurretProcess = ProcessModule.new(
    TurretModule.Interval,
    TurretModule.Run,
    TurretModule.Type
)
ProcessModule.InsertProcess(TurretProcess)

local InputProcess = ProcessModule.new(
    InputModule.Interval,
    InputModule.Run,
    InputModule.Type
)
ProcessModule.InsertProcess(InputProcess)

local PulsePartProcess = ProcessModule.new(
    PulsePartModule.Interval,
    PulsePartModule.Run,
    PulsePartModule.Type
)
ProcessModule.InsertProcess(PulsePartProcess)

--[[ local StatsModuleProcess = ProcessModule.new(
    StatsModule.Interval,
    StatsModule.Run,
    StatsModule.Type
)
ProcessModule.InsertProcess(StatsModuleProcess) ]]-- comment this out when stats are unneeded
-- end process loading here


RunService.RenderStepped:Connect(function (DeltaTime: number)
    for _, Process in ipairs(ProcessModule.RenderSteppedProcesses) do
        Process.LastRun += DeltaTime
        if Process.LastRun >= Process.Interval then
            Process.Run(DeltaTime)
            Process.LastRun = 0
        end
    end
end)

RunService.Heartbeat:Connect(function (DeltaTime: number)
    for _, Process in ipairs(ProcessModule.HeartbeatProcesses) do
        Process.LastRun += DeltaTime
        if Process.LastRun >= Process.Interval then
            Process.Run(DeltaTime)
            Process.LastRun = 0
        end
    end
end)

