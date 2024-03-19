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
    
    if WorldMapFrame and IncCalloutDB.settings.mapScale then
       
        if not IncCalloutDB.settings.resizeInPvPOnly or (IncCalloutDB.settings.resizeInPvPOnly and UnitIsPVP("player")) then
            WorldMapFrame:SetScale(IncCalloutDB.settings.mapScale)
            local pos = IncCalloutDB.settings.mapPosition
            WorldMapFrame:ClearAllPoints()
            WorldMapFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
        else
            WorldMapFrame:SetScale(1) 
        end
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
  
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD") 
   
    eventFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
    
    eventFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_FLAGS_CHANGED" then
          
            ResizeWorldMap()
        end
    end)
end

addonNamespace.ResizeWorldMap = ResizeWorldMap
InitializeMapFeatures()















