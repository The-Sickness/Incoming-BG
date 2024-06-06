-- IncCallout (Rebuild of Incoming-BG)
-- Made by Sharpedge_Gaming
-- v7.0 - 11.0.0

local AceTimer = LibStub("AceTimer-3.0")
local LBS = LibStub("LibBabble-SubZone-3.0"):GetReverseLookupTable()

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

    local inInstance, instanceType = IsInInstance()
    local isPvPEnvironment = inInstance and (instanceType == "pvp" or instanceType == "arena")

    local scale = IncCalloutDB.settings.resizeInPvPOnly and isPvPEnvironment and IncCalloutDB.settings.mapScale or 1

    if WorldMapFrame then
        WorldMapFrame:SetScale(scale)
        local pos = IncCalloutDB.settings.mapPosition
        WorldMapFrame:ClearAllPoints()
        WorldMapFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    end
end

local function InitializeMapFeatures()
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    eventFrame:SetScript("OnEvent", ResizeWorldMap)
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






































