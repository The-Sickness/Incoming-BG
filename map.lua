-- IncCallout (Rebuild of Incoming-BG)
-- Made by Sharpedge_Gaming
-- v6.2 - 10.2.6

local addonName, addonNamespace = ...

addonNamespace = addonNamespace or {}

local function EnsureDBSettings()
    if not IncCalloutDB.settings then
        IncCalloutDB.settings = {
            mapScale = 0.75, 
            mapPosition = { 
                point = "CENTER",
                relativePoint = "CENTER",
                xOfs = 0,
                yOfs = 0,
            },
            resizeInPvPOnly = true, 
        }
    end
end

local function SaveMapPosition()
    local point, _, relativePoint, xOfs, yOfs = WorldMapFrame:GetPoint()
    IncCalloutDB.settings.mapPosition = {
        point = point,
        relativePoint = relativePoint,
        xOfs = xOfs,
        yOfs = yOfs,
    }
end

local function ResizeWorldMap()
    EnsureDBSettings()

    -- Check PvP status
    local inInstance, instanceType = IsInInstance()
    local isPvPEnvironment = inInstance and (instanceType == "pvp" or instanceType == "arena")

    -- Determine the scale to apply based on settings and context
    local scale = 1  
    if IncCalloutDB.settings.resizeInPvPOnly then
        if isPvPEnvironment then
            scale = IncCalloutDB.settings.mapScale
        end
    else
        scale = IncCalloutDB.settings.mapScale
    end

    -- Apply the determined scale
    if WorldMapFrame then
        WorldMapFrame:SetScale(scale)
        local pos = IncCalloutDB.settings.mapPosition
        WorldMapFrame:ClearAllPoints()
        WorldMapFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    end
end

-- Initialize and register events
local function InitializeMapFeatures()
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    eventFrame:SetScript("OnEvent", function(self, event, ...)
        ResizeWorldMap()
        
    end)
end

WorldMapFrame:HookScript("OnShow", ResizeWorldMap)
WorldMapFrame:SetMovable(true)
WorldMapFrame:EnableMouse(true)
WorldMapFrame:RegisterForDrag("LeftButton")
WorldMapFrame:SetScript("OnDragStart", WorldMapFrame.StartMoving)
WorldMapFrame:SetScript("OnDragStop", function()
    WorldMapFrame:StopMovingOrSizing()
    SaveMapPosition()
end)

addonNamespace.ResizeWorldMap = ResizeWorldMap
InitializeMapFeatures()





















