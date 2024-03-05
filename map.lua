local addonName, addonNamespace = ...


local function UpdateTeamPlayerIndicators()

    for i = 1, GetNumGroupMembers() do
        local unit = "party"..i
        if UnitIsUnit(unit, "player") then
           
        else
 
            local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i)
            
        end
    end
end

-- Initialize map features and setup event handlers
local function InitializeMapFeatures()
     
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE") 
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD") 
    
    eventFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
            UpdateTeamPlayerIndicators()
        end
    end)
end

addonNamespace.InitializeMapFeatures = InitializeMapFeatures

local function ResizeWorldMap()
    if WorldMapFrame then
        WorldMapFrame:SetScale(0.75)         
        WorldMapFrame:ClearAllPoints()
        WorldMapFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end

WorldMapFrame:HookScript("OnShow", ResizeWorldMap)

WorldMapFrame:SetMovable(true)
WorldMapFrame:EnableMouse(true)
WorldMapFrame:RegisterForDrag("LeftButton") 
WorldMapFrame:SetScript("OnDragStart", WorldMapFrame.StartMoving)
WorldMapFrame:SetScript("OnDragStop", WorldMapFrame.StopMovingOrSizing)


