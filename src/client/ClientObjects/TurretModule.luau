-- load services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")


-- load modules
local DistanceCheckModule = require(script.Parent.Parent:WaitForChild("DistanceCheckModule"))


local AlignPosToClone: AlignPosition = Instance.new("AlignPosition")
AlignPosToClone.Mode = Enum.PositionAlignmentMode.OneAttachment
AlignPosToClone.MaxForce = math.huge
AlignPosToClone.MaxVelocity = math.huge
AlignPosToClone.ApplyAtCenterOfMass = true
AlignPosToClone.Responsiveness = 100

local AlignOriToClone: AlignOrientation = Instance.new("AlignOrientation")
AlignOriToClone.Mode = Enum.OrientationAlignmentMode.OneAttachment
AlignOriToClone.MaxAngularVelocity = math.huge
AlignOriToClone.MaxTorque = math.huge
AlignOriToClone.Responsiveness = 100


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
    SpawnSound: Sound,
    LastRun: number
}, Turret))

function Turret.new(Interval: number, TurretPart: BasePart, TurretSpawner: BasePart, Target: BasePart, TravelTime: number, Attachment: Attachment, SpawnSound: Sound): Turret
    local self = setmetatable({} :: any, Turret)

    self.Interval = Interval
    self.TurretPart = TurretPart
    self.TurretSpawner = TurretSpawner
    self.Target = Target
    self.TravelTime = TravelTime
    self.Attachment = Attachment
    self.SpawnSound = SpawnSound
    self.LastRun = 0

    return self
end


-- start module
TurretModule = {}

TurretModule.Interval = 0
TurretModule.Type = "RenderStepped"

TurretModule.InitializeTurret = function(TurretSpawner: BasePart)
    local SpawnSound = TurretSpawner:WaitForChild("SpawnSound")
    local Model = TurretSpawner:FindFirstAncestor("TurretGroup")
    local TurretPart = Model:WaitForChild("TurretPart")
    local Target = Model:WaitForChild("Target")
    local Attachment: Attachment = TurretPart:WaitForChild("Attachment")
    
    local Interval = Model:GetAttribute("Interval") or 1
    local TravelTime = Model:GetAttribute("TravelTime") or 5

    TurretPart.Parent = ReplicatedStorage:FindFirstChild("TurretParts")

    local AlignPos: AlignPosition = AlignPosToClone:Clone()
    AlignPos.Parent = Attachment
    AlignPos.Attachment0 = Attachment
    AlignPos.Position = Attachment.WorldPosition

    local AlignOri: AlignOrientation = AlignOriToClone:Clone()
    AlignOri.CFrame = TurretPart.CFrame
    AlignOri.Parent = Attachment
    AlignOri.Attachment0 = Attachment

    local TurretObj = Turret.new(Interval, TurretPart, TurretSpawner, Target, TravelTime, Attachment, SpawnSound)
    table.insert(TurretObjects, TurretObj)
end

TurretModule.SpawnTurret = function(Turret: Turret)
    task.spawn(function() -- wrapped in a task.spawn because for some reason before it would delete clones if multiple existed
        Turret.SpawnSound:Play()

        local Model = Turret.Target.Parent :: Model
        local NewTurret = Turret.TurretPart:Clone()
        NewTurret.Anchored = false
        NewTurret.Position = Turret.TurretSpawner.Position
        NewTurret.CollisionGroup = "OnlyCollideWithPlayers"
        NewTurret.Parent = Model

        local Attachment: Attachment = NewTurret:WaitForChild("Attachment")
        local AlignPosition = Attachment:WaitForChild("AlignPosition")
        AlignPosition.Position = NewTurret.Position

        local NewTweenInfo = TweenInfo.new(Turret.TravelTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local NewTween = TweenService:Create(AlignPosition, NewTweenInfo, {Position = Turret.Target.Position})
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
            TurretModule.SpawnTurret(Turret)
            Turret.LastRun = 0
        end
    end
end

return TurretModule
