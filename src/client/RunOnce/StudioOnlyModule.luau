-- load services
local CollectionService = game:GetService("CollectionService")


local function hasProperty(instance: Instance, propertyName: string): boolean
    local success = pcall(function()
        local _ = instance[propertyName]
    end)
    return success
end


StudioOnlyModule = {}

function StudioOnlyModule.HideParts()
    local StudioOnlyParts = CollectionService:GetTagged("StudioOnly")

    for _, Instance in StudioOnlyParts do
        if hasProperty(Instance, "Transparency") then
            Instance.Transparency = 1
        end
        if hasProperty(Instance, "CanCollide") then
            Instance.CanCollide = false
        end
    end

    CollectionService:GetInstanceAddedSignal("StudioOnly"):Connect(function(Instance)
        if hasProperty(Instance, "Transparency") then
            Instance.Transparency = 1
        end
        if hasProperty(Instance, "CanCollide") then
            Instance.CanCollide = false
        end
    end)
end

return StudioOnlyModule 