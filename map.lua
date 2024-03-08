local addonName, addonNamespace = ...

addonNamespace = addonNamespace or {}

local function EnsureDBSettings()
    if not IncCalloutDB.settings then
        IncCalloutDB.settings = {
            mapScale = 0.75, -- Default scale value
            mapPosition = { -- Default position settings
                point = "CENTER",
                relativePoint = "CENTER",
                xOfs = 0,
                yOfs = 0,
            },
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
    if WorldMapFrame and IncCalloutDB.settings.mapScale then
        WorldMapFrame:SetScale(IncCalloutDB.settings.mapScale)
        
        local pos = IncCalloutDB.settings.mapPosition
        WorldMapFrame:ClearAllPoints()
        WorldMapFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    end
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

local function InitializeMapFeatures()
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE") 
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD") 
    
    eventFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
            
        end
    end)
end

addonNamespace.ResizeWorldMap = ResizeWorldMap
InitializeMapFeatures()












