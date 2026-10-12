-- load services
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")


-- load modules
local TurretModule = require(script.Parent:WaitForChild("ClientObjects"):WaitForChild("TurretModule"))
local MusicZoneModule = require(script.Parent:WaitForChild("ClientObjects"):WaitForChild("MusicZoneModule"))
local PulsePartModule = require(script.Parent:WaitForChild("ClientObjects"):WaitForChild("PulseModule"))
local FallingPlatformModule = require(script.Parent:WaitForChild("ClientObjects"):WaitForChild("FallingPlatformModule"))
local StudioOnlyModule = require(script:WaitForChild("StudioOnlyModule"))


local function InitializeInstance(Instance: Instance)
    if not Instance:HasTag("Initialize") then return end

    local Clone = Instance:Clone()
    Clone:RemoveTag("Initialize")
    Clone.Parent = Instance.Parent

    Instance:Destroy()
    print("Initialized new client object.")
end

local AllClientObjects = CollectionService:GetTagged("Initialize")
for _, Instance in ipairs(AllClientObjects) do
    InitializeInstance(Instance)
end

CollectionService:GetInstanceAddedSignal("Initialize"):Connect(InitializeInstance)

-- hide parts only for studio 
StudioOnlyModule.HideParts()

-- client object initialization
local InitializeActions = {
    ["TurretSpawner"] = function(TurretPart: BasePart) TurretModule.InitializeTurret(TurretPart) end,
    ["GlobalSound"] = function(Sound: Sound) MusicZoneModule.LoadMusic(Sound) end,
    ["Pulse"] = function(Instance: Instance) PulsePartModule.Initialize(Instance) end,
    ["FallingPart"] = function(Part: BasePart) FallingPlatformModule.InitializePart(Part) end
}

for TagName, Action in pairs(InitializeActions) do
    for _, Instance: Instance in ipairs(CollectionService:GetTagged(TagName)) do
        if Instance:HasTag("Initialize") then continue end
        task.spawn(Action, Instance)
    end

    CollectionService:GetInstanceAddedSignal(TagName):Connect(function(Instance: Instance)
        if Instance:HasTag("Initialize") then return end
        task.spawn(Action, Instance)
    end)
end


-- more modules
local NoclipModule = require(script.Parent:WaitForChild("Gears"):WaitForChild("NoclipModule"))
local GodmodeModule = require(script.Parent:WaitForChild("Gears"):WaitForChild("GodmodeModule"))


-- handles code for when character dies / spawns
local function OnCharacterAdded(Character: Model)
    local Player = Players.LocalPlayer
    local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid

    NoclipModule.GiveTool(Player, Character)
    GodmodeModule.GiveTool(Player, Character)

    Humanoid.Died:Connect(function()
        NoclipModule.Reset(Player, Character)
        GodmodeModule.Reset(Player, Character)

        MusicZoneModule.CurrentSong = nil
    end)
end

Players.LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

if Players.LocalPlayer.Character then
    task.spawn(OnCharacterAdded, Players.LocalPlayer.Character)
end