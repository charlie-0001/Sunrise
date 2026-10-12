local Process = {}

-- current processes stored here
Process.RenderSteppedProcesses = {} :: {Process}
Process.HeartbeatProcesses = {} :: {Process}

-- Process object
Process.__index = Process

export type Process = typeof(setmetatable({} :: {
    Interval: number,
    Run: (DeltaTime: number?) -> (),
    Type: string,
    LastRun: number
}, Process))

function Process.new(Interval: number, Run: (DeltaTime: number?) -> (), Type: string): Process
    local self = setmetatable({} :: any, Process)

    self.Interval = Interval
    self.Run = Run
    self.Type = Type
    self.LastRun = 0

    return self
end

-- useful functions for processes
Process.InsertProcess = function(Proc: Process)
    if Proc.Type == "Heartbeat" then
        table.insert(Process.HeartbeatProcesses, Proc)
    elseif Proc.Type == "RenderStepped" then
        table.insert(Process.RenderSteppedProcesses, Proc)
    end
end

Process.RemoveProcess = function(Proc: Process)
    if Proc.Type == "Heartbeat" then
        local index = table.find(Process.HeartbeatProcesses, Proc)
        if index then
            table.remove(Process.HeartbeatProcesses, index)
        end
    elseif Proc.Type == "RenderStepped" then
        local index = table.find(Process.RenderSteppedProcesses, Proc)
        if index then
            table.remove(Process.RenderSteppedProcesses, index)
        end
    end
end

return Process