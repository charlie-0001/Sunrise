-- load services
local Debris = game:GetService("Debris")


-- load modules
local ProcessModule = require(script.Parent.Parent:WaitForChild("IntervalCheck"):WaitForChild("ProcessModule"))
local HumanoidStateModule = require(script.Parent.Parent:WaitForChild("IntervalCheck"):WaitForChild("HumanoidStateModule"))


local function FindPointOnCurve(Time, StartPoint, ControlPoint, EndPoint)
    local Position = (1 - Time) ^ 2 * StartPoint 
        + 2 * (1 - Time) * Time * ControlPoint 
        + Time ^ 2 * EndPoint

    local Rotation = 2 * (1 - Time) * (ControlPoint - StartPoint) 
        + 2 * Time * (EndPoint - ControlPoint)

    return Position, Rotation
end


CurveTeleporterModule = {}

function CurveTeleporterModule.CurveTeleport(Part: BasePart, Humanoid: Humanoid)
    local StartPoint: BasePart = Part
    local Model = Part.Parent :: Model
    if not Model then return end
    local EndPoint: BasePart = Model:FindFirstChild("End")
    if not EndPoint then return end
    local Trail = Model:FindFirstChildOfClass("Trail")

    local TeleportTime = Model:GetAttribute("TeleportTime") or 2
    local RemoveTrailSecondsAfterLanded = Model:GetAttribute("RemoveTrailSecondsAfterLanded") or 1
    local Height = Model:GetAttribute("Height") or 100
    local ControlPoint = (StartPoint.Position + EndPoint.Position) / 2 + Vector3.new(0, Height, 0)

    HumanoidStateModule.HumanoidRootPart.Anchored = true
    HumanoidStateModule.Inert = true

    local StartUpTime = Model:GetAttribute("StartUpTime") or 0
    if StartUpTime > 0 then
        HumanoidStateModule.Character:PivotTo(CFrame.lookAlong(HumanoidStateModule.HumanoidRootPart.Position, Part.CFrame.LookVector))
        task.wait(StartUpTime)
    end

    local LaunchSound: Sound = Model:FindFirstChild("LaunchSound")
    local PlayLaunchSound = Model:GetAttribute("PlayLaunchSound")
    if LaunchSound and PlayLaunchSound == true then
        LaunchSound:Play()
    end

    local AddTrail = Model:GetAttribute("AddTrail")
    if AddTrail == true then
        local NewTrail = Trail:Clone()
            NewTrail.Parent = HumanoidStateModule.HumanoidRootPart
            NewTrail.Attachment0 = HumanoidStateModule.Character.Torso.WaistCenterAttachment
            NewTrail.Attachment1 = HumanoidStateModule.Character.Torso.NeckAttachment

        Debris:AddItem(NewTrail, TeleportTime + RemoveTrailSecondsAfterLanded)
    end

    local Time = 0 -- should cap out at 1

    local function Run(DeltaTime)
        local Position, Rotation = FindPointOnCurve(Time, StartPoint.Position, ControlPoint, EndPoint.Position)
        HumanoidStateModule.Character:PivotTo(CFrame.lookAlong(Position, Rotation))

        Time += DeltaTime / TeleportTime
    end

    local CurveTeleportProcess = ProcessModule.new(0, Run, "RenderStepped")
    ProcessModule.InsertProcess(CurveTeleportProcess)
    
    task.wait(TeleportTime)

    ProcessModule.RemoveProcess(CurveTeleportProcess)

    local LandingSound: Sound = Model:FindFirstChild("LandingSound")
    local PlayLandingSound = Model:GetAttribute("PlayLandingSound")
    if LandingSound and PlayLandingSound == true then
        LandingSound:Play()
    end

    local LandingParticles: ParticleEmitter = Model:FindFirstChildOfClass("ParticleEmitter")
    local SpawnLandingParticles = Model:GetAttribute("SpawnLandingParticles")
    if LandingParticles and SpawnLandingParticles == true then
        local NewParticles = LandingParticles:Clone()
        NewParticles.Parent = HumanoidStateModule.HumanoidRootPart
        NewParticles:Emit(10)
        Debris:AddItem(NewParticles, 5)
    end

    HumanoidStateModule.HumanoidRootPart.Anchored = false
    HumanoidStateModule.Inert = false
    Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) -- removes possibility of ragdolling from noclip
end

function CurveTeleporterModule.BasicTeleport(Part: BasePart, Humanoid: Humanoid)
    local EndPart = (Part.Parent :: Instance):FindFirstChild("End") :: BasePart
    ((Humanoid.Parent) :: Model):PivotTo(EndPart.CFrame)
    Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) -- removes possibility of ragdolling from noclip 
end

return CurveTeleporterModule