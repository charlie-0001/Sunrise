-- load services
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")


-- load modules
local DistanceCheckModule = require(script.Parent.Parent:WaitForChild("DistanceCheckModule"))


local TurretSound: Sound = SoundService:WaitForChild("TurretFireSound")
local TurretObjects = {} :: {Turret}

local Turret = {}
Turret.__index = Turret

export type Turret = typeof(setmetatable({} :: {
    Interval: number,
    TurretPart: BasePart,
    TurretSpawner: BasePart,
    Target: BasePart,
    TravelTime: number,
    Attachment: Attachment,
    LastRun: number
}, Turret))

function Turret.new(Interval: number, TurretPart: BasePart, TurretSpawner: BasePart, Target: BasePart, TravelTime: number, Attachment: Attachment): Turret
    local self = setmetatable({} :: any, Turret)

    self.Interval = Interval
    self.TurretPart = TurretPart
    self.TurretSpawner = TurretSpawner
    self.Target = Target
    self.TravelTime = TravelTime
    self.Attachment = Attachment

    self.LastRun = 0

    return self
end


-- start module
TurretModule = {}

TurretModule.Interval = 0
TurretModule.Type = "RenderStepped"

TurretModule.InitializeTurret = function(TurretSpawner: BasePart)
    local Model = TurretSpawner:FindFirstAncestor("TurretGroup")
    local TurretPart = Model:WaitForChild("TurretPart")
    local Attachment = TurretPart:WaitForChild("Attachment")
    local Target = Model:WaitForChild("Target")

    local Interval = TurretSpawner:GetAttribute("Interval") or 1
    local TravelTime = TurretSpawner:GetAttribute("TravelTime") or 5

    local TurretObj = Turret.new(Interval, TurretPart, TurretSpawner, Target, TravelTime, Attachment)
    table.insert(TurretObjects, TurretObj)
end

TurretModule.SpawnTurret = function(TurretPart: BasePart, Target: BasePart, TravelTime: number)
    task.spawn(function() -- wrapped in a task.spawn because for some reason before it would delete clones if multiple existed
        TurretSound:Play()

        local NewTurret = TurretPart:Clone()
        NewTurret:RemoveTag("StudioOnly")
        NewTurret.CollisionGroup = "OnlyCollideWithPlayers"
        NewTurret.Transparency = 0
        NewTurret.CanCollide = true
        NewTurret.Parent = TurretPart.Parent

        local Attachment: Attachment = NewTurret:WaitForChild("Attachment")
        local AlignPosition = Attachment:WaitForChild("AlignPosition")
        AlignPosition.Position = NewTurret.Position

        local NewTweenInfo = TweenInfo.new(TravelTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local NewTween = TweenService:Create(AlignPosition, NewTweenInfo, {Position = Target.Position})
        NewTween:Play()
        NewTween.Completed:Wait()
        NewTurret:Destroy()
    end)
end

TurretModule.Run = function(DeltaTime: number)
    for _, Turret: Turret in ipairs(TurretObjects) do
        local Result = DistanceCheckModule.DistanceCheck(Turret.TurretSpawner, 100)
        if not Result then continue end

        Turret.LastRun += DeltaTime
        if Turret.LastRun >= Turret.Interval then
            TurretModule.SpawnTurret(Turret.TurretPart, Turret.Target, Turret.TravelTime, Turret.Attachment)
            Turret.LastRun = 0
        end
    end
end

return TurretModule
