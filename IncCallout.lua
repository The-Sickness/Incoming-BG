-- IncCallout (Rebuild of Incoming-BG)
-- Made by Sharpedge_Gaming
-- v1.7 - 10.1

local addonName, addonNamespace = ...

-- Load embedded libraries
local LibStub = LibStub or _G.LibStub
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local icon = LibStub("LibDBIcon-1.0")
local LDB = LibStub("LibDataBroker-1.1")

local playerFaction
playerFaction = UnitFactionGroup("player")

local buttonMessageIndices = {
    sendMore = 1,
    inc = 1,
    allClear = 1
}

-- Register an event listener for when the player enters the world
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")

f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        local inInstance, instanceType = IsInInstance()
        if inInstance and (instanceType == "pvp" or instanceType == "arena") then
            print("Don't forget to call INC's")
            
        else
            print("|cFFFF0000You need to queue up for PvP|r")
            
        end
    end
end)

-- Define the battleground locations
local battlegroundLocations = {
    "Stables", "Blacksmith", "Lumber Mill", "Gold Mine", "Mine", "Trollbane Hall", "Defiler's Den", "Farm",
    "Mage Tower", "Draenei Ruins", "Blood Elf Tower", "Fel Reaver Ruins", 
    "The Broken Temple", "Cauldron of Flames", "Central Bridge", "The Chilled Quagemire",
    "Eastern Bridge", "Flamewatch Tower", "The Forest of Shadows", "Glacial Falls", "The Steppe of Life",
    "The Sunken Ring", "Western Bridge", "Winter's Edge Tower", "Wintergrasp Fortress", "Eastpark Workshop", "Westpark Workshop ",
    "Lighthouse", "Waterworks", "Mines", "Docks", "Workshop", "Horde Keep", "Alliance Keep", "Market",
    "Hangar", "Refinery", "Quarry", "Wildhammer Stronghold", "Dragonmaw Stronghold",
    "Silverwing Hold", "Warsong Flag Room", "Baradin Base Camp", "Rustberg Village",
    "The Restless Front", "Wellson Shipyard", "Largo's Overlook", "Farson Hold",
    "Forgotten Hill", "Hellscream's Grasp","Stormpike Graveyard", "Irondeep Mine", "Dun Baldar",
    "Hall of the Stormpike", "Icewing Pass", "Stonehearth Outpost", "Iceblood Graveyard", 
    "Iceblood Garrison", "Tower Point", "Coldtooth Mine", "Dun Baldar Pass", "Icewing Bunker",
    "Field of Strife", "Stonehearth Graveyard", "Stonehearth Bunker", "Frost Dagger Pass", 
    "Snowfall Graveyard", "Winterax Hold", "Frostwolf Graveyard", "Frostwolf Village", 
    "Deepwind Gorge", "Frostwolf Keep", "Hall of the Frostwolf","Temple of Kotmogu",  "Silvershard Mines", "Southshore vs. Tauren Mill", "Alterac Valley",
    "Ashran", "StormShield",	
}

local buttonMessages = {
    sendMore = {
        "We need more peeps",
        "Need help",
        "We are outnumbered",
		"Need a few more",
		"Need more",
		"Backup required",
		"We could use some help",
		"Calling for backup",
		"Could use some backup",
		"Reinforcements needed",
        -- Add more custom messages if needed...
    },
    inc = {
        "Incoming",
        "INC INC INC",
        "INC",
		"Gotta INC",
		"BIG INC",
		"Incoming enemy forces",
		"Incoming threat",
		"Enemy push incoming",
		"Enemy blitz incoming",
		"Enemy strike team inbound",
        -- Add more custom messages if needed...
    },
    allClear = {
        "We are all clear",
        "All clear",
        "Looks like a ghost town",
		"All good",
		"Looking good",
		"Area secure",
		"All quiet on the front",
		"Situation is under control",
		"All quiet here",
		"We are looking good",
        -- Add more custom messages if needed...
    },
}

local options = {
    name = "IncCallout",
    type = "group",
    args = {
        sendMore = {
            type = "select",
            name = "Send More message",
            desc = "Select the message for the 'Send More' button",
            values = buttonMessages.sendMore,
            get = function()
                return buttonMessageIndices.sendMore
            end,
            set = function(_, newValue)
                buttonMessageIndices.sendMore = newValue
            end,
            order = 1,
        },
        inc = {
            type = "select",
            name = "INC message",
            desc = "Select the message for the 'INC' button",
            values = buttonMessages.inc,
            get = function()
                return buttonMessageIndices.inc
            end,
            set = function(_, newValue)
                buttonMessageIndices.inc = newValue
            end,
            order = 2,
        },
        allClear = {
            type = "select",
            name = "All Clear message",
            desc = "Select the message for the 'All Clear' button",
            values = buttonMessages.allClear,
            get = function()
                return buttonMessageIndices.allClear
            end,
            set = function(_, newValue)
                buttonMessageIndices.allClear = newValue
            end,
            order = 3, 		
        
        
        },
    },
}

-- Register the options table
AceConfig:RegisterOptionsTable(addonName, options)

-- Create a config panel
local configPanel = AceConfigDialog:AddToBlizOptions(addonName, "IncCallout")
configPanel.default = function()
    -- Reset the options to default values
    buttonMessageIndices.sendMore = 1
    buttonMessageIndices.inc = 1
    buttonMessageIndices.allClear = 1
end

-- Create a table to map each location to itself
local locationTable = {}
for _, location in ipairs(battlegroundLocations) do
    locationTable[location] = location
end

local function isInBattleground()
    local inInstance, instanceType = IsInInstance()
    return inInstance and (instanceType == "pvp" or instanceType == "arena")
end

local function ButtonOnClick(self)
    if not isInBattleground() then
        print("You are not in a battleground.")
        return
    end

    local currentLocation = GetRealZoneText() .. " - " .. GetSubZoneText()
    local enemyFaction = playerFaction == "Hordie" and "Alliance" or "Hordie"
    local message = self:GetText() .. " " .. enemyFaction .. " coming in fast at " .. currentLocation
    SendChatMessage(message, "INSTANCE_CHAT")
end

-- Register an event listener for when the player enters a new zone or subzone
local f = CreateFrame("Frame")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")

f:SetScript("OnEvent", function(self, event, ...)
    if event == "ZONE_CHANGED_NEW_AREA" then
        local currentLocation = GetRealZoneText() .. " - " .. GetSubZoneText()
        local location = locationTable[currentLocation]

        -- Check if location is in the defined battleground locations
        if location then
            IncCallout:Show()  -- Show the GUI
        else
            
        end
    end
end)

-- Create the main frame
local IncCallout = CreateFrame("Frame", "IncCalloutMainFrame", UIParent, "BackdropTemplate")
IncCallout:SetSize(160, 155)
IncCallout:SetPoint("CENTER")

-- Create buttons and assign the button click event handlers
local button1 = CreateFrame("Button", nil, IncCallout, "UIPanelButtonTemplate")
button1:SetSize(20, 22)
button1:SetText("1")
button1:SetPoint("TOPLEFT", IncCallout, "TOPLEFT", 15, -20)
button1:SetScript("OnClick", ButtonOnClick)

local button2 = CreateFrame("Button", nil, IncCallout, "UIPanelButtonTemplate")
button2:SetSize(20, 22)
button2:SetText("2")
button2:SetPoint("LEFT", button1, "RIGHT", 3, 0)
button2:SetScript("OnClick", ButtonOnClick)

local button3 = CreateFrame("Button", nil, IncCallout, "UIPanelButtonTemplate")
button3:SetSize(20, 22)
button3:SetText("3")
button3:SetPoint("LEFT", button2, "RIGHT", 3, 0)
button3:SetScript("OnClick", ButtonOnClick)

local button4 = CreateFrame("Button", nil, IncCallout, "UIPanelButtonTemplate")
button4:SetSize(20, 22)
button4:SetText("4")
button4:SetPoint("LEFT", button3, "RIGHT", 3, 0)
button4:SetScript("OnClick", ButtonOnClick)

local buttonZerg = CreateFrame("Button", nil, IncCallout, "UIPanelButtonTemplate")
buttonZerg:SetSize(40, 22)
buttonZerg:SetText("Zerg")
buttonZerg:SetPoint("LEFT", button4, "RIGHT", 3, 0)
buttonZerg:SetScript("OnClick", ButtonOnClick)

local incButton = CreateFrame("Button", nil, IncCallout, "UIPanelButtonTemplate")
incButton:SetSize(60, 22)
incButton:SetText("Inc")
incButton:SetPoint("TOP", IncCallout, "TOP", 0, -45)
incButton:SetScript("OnClick", ButtonOnClick)

local sendMoreButton = CreateFrame("Button", nil, IncCallout, "UIPanelButtonTemplate")
sendMoreButton:SetSize(80, 22)
sendMoreButton:SetText("Send More")
sendMoreButton:SetPoint("TOP", incButton, "BOTTOM", 0, -5)
sendMoreButton:SetScript("OnClick", SendMoreButtonOnClick)

local allClearButton = CreateFrame("Button", nil, IncCallout, "UIPanelButtonTemplate")
allClearButton:SetSize(60, 22)
allClearButton:SetText("All Clear")
allClearButton:SetPoint("TOP", sendMoreButton, "BOTTOM", 0, -5)
allClearButton:SetScript("OnClick", AllClearButtonOnClick)

-- Create Exit button
local exitButton = CreateFrame("Button", nil, IncCallout, "UIPanelButtonTemplate")
exitButton:SetSize(60, 22)
exitButton:SetText("Exit")
exitButton:SetPoint("TOP", allClearButton, "BOTTOM", 0, -5)
exitButton:SetScript("OnClick", function() IncCallout:Hide() end)

-- Create a background texture for the main frame
local bgTexture = IncCallout:CreateTexture(nil, "BACKGROUND")
bgTexture:SetColorTexture(0.1, 0.1, 0.1)
bgTexture:SetAllPoints(IncCallout)

-- Create a border frame
local BorderFrame = CreateFrame("Frame", nil, IncCallout, "BackdropTemplate")
BorderFrame:SetFrameLevel(IncCallout:GetFrameLevel() - 1) -- Ensure it's behind the main frame
BorderFrame:SetSize(IncCallout:GetWidth() + 4, IncCallout:GetHeight() + 4) -- Adjust these values for border thickness
BorderFrame:SetPoint("CENTER", IncCallout, "CENTER")

-- Create a border texture for the border frame
local borderTexture = BorderFrame:CreateTexture(nil, "OVERLAY")
borderTexture:SetColorTexture(1, 1, 1)
borderTexture:SetAllPoints(BorderFrame)

IncCallout:SetMovable(true)
IncCallout:EnableMouse(true)
IncCallout:RegisterForDrag("LeftButton")
IncCallout:SetScript("OnDragStart", IncCallout.StartMoving)
IncCallout:SetScript("OnDragStop", IncCallout.StopMovingOrSizing)

-- Initialize IncDB if it's not already initialized
if not IncDB then
    IncDB = {}
end

-- Initialize IncDB.minimap if it's not already initialized
if not IncDB.minimap then
    IncDB.minimap = {
        hide = false,
        minimapPos = 45, -- Default position angle (in degrees)
    }
end

-- Now that IncCallout is defined, you can create IncCalloutLDB
local IncCalloutLDB = LibStub("LibDataBroker-1.1"):NewDataObject("IncCallout", {
    type = "data source",
    text = "IncCallout",
    icon = "Interface\\AddOns\\IncCallout\\Icon\\INC.png",
    OnClick = function(_, button)
        if button == "LeftButton" then
            if IncCallout:IsShown() then
                IncCallout:Hide()
            else
                IncCallout:Show()
            end
        else
            InterfaceOptionsFrame_OpenToCategory("IncCallout")
            InterfaceOptionsFrame_OpenToCategory("IncCallout") -- Call it twice to ensure the correct category is selected
        end
    end,
    OnMouseDown = function(self, button)
        if button == "LeftButton" then
            IncCallout:StartMoving()
        end
    end,
    OnMouseUp = function(self, button)
        if button == "LeftButton" then
            IncCallout:StopMovingOrSizing()
            local point, _, _, x, y = IncCallout:GetPoint()
            local centerX, centerY = Minimap:GetCenter()
            local scale = Minimap:GetEffectiveScale()
            x, y = (x - centerX) / scale, (y - centerY) / scale
            IncDB.minimap.minimapPos = math.deg(math.atan2(y, x)) % 360
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("|cffff0000IncCallout|r")
        tooltip:AddLine("Left Click: GUI")
        tooltip:AddLine("Right Click: Options")
        tooltip:Show()
    end,
})

local frame = CreateFrame("Frame") -- create a new frame to listen to events

-- this function is called when an event occurs
local function eventHandler(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        local isInInstance, instanceType = IsInInstance()
        if isInInstance and instanceType == "pvp" then
 
            IncCalloutMainFrame:Show() 
        end
    end
end

-- Register the PLAYER_ENTERING_WORLD event with your frame
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Set the frame's script to call your event handler function when an event is fired
frame:SetScript("OnEvent", eventHandler)


-- Function to handle player login and logout
local function OnEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
        -- Load saved button messages indices
        buttonMessageIndices.sendMore = IncDB.sendMoreIndex or 1
        buttonMessageIndices.inc = IncDB.incIndex or 1
        buttonMessageIndices.allClear = IncDB.allClearIndex or 1

        -- Load the minimap icon settings
        icon:Register("IncCallout", IncCalloutLDB, IncDB.minimap)
    elseif event == "PLAYER_LOGOUT" then
        -- Save button messages indices
        IncDB.sendMoreIndex = buttonMessageIndices.sendMore
        IncDB.incIndex = buttonMessageIndices.inc
        IncDB.allClearIndex = buttonMessageIndices.allClear
    end
end

-- Register the events
IncCallout:RegisterEvent("PLAYER_LOGIN")
IncCallout:RegisterEvent("PLAYER_LOGOUT")
IncCallout:SetScript("OnEvent", OnEvent)

-- Function to handle the All Clear button click event
local function AllClearButtonOnClick()
    local location = GetRealZoneText() .. " - " .. GetSubZoneText()

    -- Check if location is in the defined battleground locations
    if not location then
        print("You are not in a BattleGround.")
        return
    end

    local message = buttonMessages.allClear[buttonMessageIndices.allClear] .. " at " .. location
    SendChatMessage(message, "INSTANCE_CHAT")
end
allClearButton:SetScript("OnClick", AllClearButtonOnClick)

-- Function to handle the Send More button click event
local function SendMoreButtonOnClick()
    local location = GetRealZoneText() .. " - " .. GetSubZoneText()

    -- Check if location is in the defined battleground locations
    if not location then
        print("You are not in a BattleGround.")
        return
    end

    local message = buttonMessages.sendMore[buttonMessageIndices.sendMore] .. " at " .. location
    SendChatMessage(message, "INSTANCE_CHAT")
end
sendMoreButton:SetScript("OnClick", SendMoreButtonOnClick)

-- Function to handle the INC button click event
local function IncButtonOnClick()
    local location = GetRealZoneText() .. " - " .. GetSubZoneText()

    -- Check if location is in the defined battleground locations
    if not location then
        print("You are not in a BattleGround.")
        return
    end

    local message = buttonMessages.inc[buttonMessageIndices.inc] .. " at " .. location
    SendChatMessage(message, "INSTANCE_CHAT")
end
incButton:SetScript("OnClick", IncButtonOnClick)

-- Register the slash command
SLASH_INC1 = "/inc"
SlashCmdList["INC"] = function()
    if IncCallout:IsShown() then
        IncCallout:Hide()
    end
end












