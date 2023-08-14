-- IncCallout (Rebuild of Incoming-BG)
-- Made by Sharpedge_Gaming
-- v2.0 - 10.1.5
 
-- Load embedded libraries
local LibStub = LibStub or _G.LibStub
--local AceDB = LibStub("AceDB-3.0")
local AceDB = LibStub:GetLibrary("AceDB-3.0")
--local AceAddon = LibStub("AceAddon-3.0")
local AceAddon = LibStub:GetLibrary("AceAddon-3.0")
--local AceConfig = LibStub("AceConfig-3.0")
local AceConfig = LibStub:GetLibrary("AceConfig-3.0")
--local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigDialog = LibStub:GetLibrary("AceConfigDialog-3.0")
--local icon = LibStub("LibDBIcon-1.0")
local icon = LibStub:GetLibrary("LibDBIcon-1.0")
--local LDB = LibStub("LibDataBroker-1.1")
local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
 
local addonName, addonNamespace = ...
 
local IncDB, db 
-- Initialize your addon using AceAddon-3.0
local addon = AceAddon:NewAddon(addonName)
 
local defaults = {
    profile = {
        buttonColor = {r = 1, g = 0, b = 0, a = 1}, -- Default to red
        fontColor = {r=1, g=1, b=1, a=1},  -- Default to white 
        opacity = 1,  -- Default to fully opaque
    },
}
 
local buttonTexts = {}
local buttons = {}
 
local playerFaction
 
local buttonMessageIndices = {
    sendMore = 1,
    inc = 1,
    allClear = 1
}
 
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
        "In need of additional support",
        "Calling all hands on deck",
        "Require extra manpower",
        "Assistance urgently needed",
        "Requesting more participants",
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
        "Incoming attack alert",
        "Enemy wave inbound",
        "Enemy squad closing in",
        "Anticipate enemy push",
        "Enemy forces are closing in",
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
        "Perimeter is secured",
        "Situation is calm",
        "No threats detected",
        "All quiet on this end",
        "Area is threat-free",
        -- Add more custom messages if needed...
    },
}
 
-- Create the main frame
local IncCallout = CreateFrame("Frame", "IncCalloutMainFrame", UIParent, "BackdropTemplate")
IncCallout:SetSize(160, 155)
IncCallout:SetPoint("CENTER")
 
-- Create a background texture for the main frame
local bgTexture = IncCallout:CreateTexture(nil, "BACKGROUND")
bgTexture:SetColorTexture(0, 0, 0)
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
 
local fontSize = 15
 
-- Function to create a button
local function createButton(name, width, height, text, anchor, xOffset, yOffset, onClick)
    local button = CreateFrame("Button", nil, IncCallout, "UIPanelButtonTemplate, BackdropTemplate")
    button:SetSize(width, height)
    button:SetText(text)
    if type(anchor) == "table" then
        button:SetPoint(anchor[1], anchor[2], anchor[3], xOffset, yOffset)
    else
        button:SetPoint(anchor, xOffset, yOffset)
    end
    button:SetScript("OnClick", onClick)
    button:GetFontString():SetTextColor(1, 1, 1, 1)
--    button:SetBackdrop({
--        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
--        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
--        tile = true,
--        tileSize = 16,
--        edgeSize = 16,
--        insets = { left = 4, right = 4, top = 4, bottom = 4 }
--    })
    table.insert(buttonTexts, button:GetFontString())
    table.insert(buttons, button)
    return button
end
 
local function applyButtonColor()
    local r, g, b, a
    if IncDB.buttonColor then
        r, g, b, a = IncDB.buttonColor.r, IncDB.buttonColor.g, IncDB.buttonColor.b, IncDB.buttonColor.a
    else
        r, g, b, a = 1, 0, 0, 1 -- Default to red
    end
    for _, button in ipairs(buttons) do
        button:SetBackdropColor(r, g, b, a)
        button.Left:SetColorTexture(r, g, b, a)
        button.Right:SetColorTexture(r, g, b, a)
        button.Middle:SetColorTexture(r, g, b, a)
        
    end
end

-- This function will be triggered every time IncCallout is shown
IncCallout:SetScript("OnShow", function()
    applyButtonColor()
    -- You can also apply other settings here, if needed.
end)


local options = {
    name = "IncCallout",
    type = "group",
    args = {
        sendMore = {
            type = "select",
            name = "Send More message",
            desc = "Select the message for the 'Send More' button",
            values = buttonMessages.sendMore,
            get = function() return buttonMessageIndices.sendMore end,
            set = function(_, newValue) buttonMessageIndices.sendMore = newValue end,
            order = 1,
        },
        inc = {
            type = "select",
            name = "INC message",
            desc = "Select the message for the 'INC' button",
            values = buttonMessages.inc,
            get = function() return buttonMessageIndices.inc end,
            set = function(_, newValue) buttonMessageIndices.inc = newValue end,
            order = 2,
        },
        allClear = {
            type = "select",
            name = "All Clear message",
            desc = "Select the message for the 'All Clear' button",
            values = buttonMessages.allClear,
            get = function() return buttonMessageIndices.allClear end,
            set = function(_, newValue) buttonMessageIndices.allClear = newValue end,
            order = 3,
        },
        opacity = {
            type = "range",
            name = "Opacity",
            desc = "Adjust the transparency of the IncCallout frame.",
            min = 0, max = 1, step = 0.05,
            get = function() return IncDB.opacity or 1 end,
            set = function(_, newValue)
                bgTexture:SetAlpha(newValue)
                borderTexture:SetAlpha(newValue)
                IncDB.opacity = newValue
            end,
            order = 4,
        },
        fontColor = {
        type = "color",
        name = "Button Font Color",
        desc = "Set the color of the button text.",
        hasAlpha = true,
        get = function()
            local color = IncDB.fontColor or {r = 1, g = 1, b = 1, a = 1} -- Default to white
            return color.r, color.g, color.b, color.a
        end,
        set = function(_, r, g, b, a)
            IncDB.fontColor.r = r
            IncDB.fontColor.g = g
            IncDB.fontColor.b = b
            IncDB.fontColor.a = a
            for _, text in ipairs(buttonTexts) do
                text:SetTextColor(r, g, b, a)
            end
        end,
        order = 5,
        },
        buttonColor = {
            type = "color",
            name = "Button Color",
            desc = "Set the color of the buttons.",
            hasAlpha = true,
            get = function()
                local color = IncDB.buttonColor or {r = 1, g = 0, b = 0, a = 1} -- Default to red
                return color.r, color.g, color.b, color.a
            end,
            set = function(_, r, g, b, a)
                IncDB.buttonColor.r = r  
                IncDB.buttonColor.g = g 
                IncDB.buttonColor.b = b 
                IncDB.buttonColor.a = a 
            applyButtonColor() 
--                
            end,
            order = 6,
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
 
    local currentLocation = GetSubZoneText()
    local playerFaction = UnitFactionGroup("player") or ""
    local enemyFaction = playerFaction == "Alliance" and "Horde" or "Alliance"
    local message = self:GetText() .. " " .. enemyFaction .. " incoming at " .. currentLocation
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
 
-- Function to handle the All Clear button click event
local function AllClearButtonOnClick()
    local location = GetSubZoneText()
 
    -- Check if location is in the defined battleground locations
    if not location then
    print("You are not in a BattleGround.")
    return
end
 
local message = buttonMessages.allClear[buttonMessageIndices.allClear] .. " at " .. location
SendChatMessage(message, "INSTANCE_CHAT")
end
 
 
-- Function to handle the Send More button click event
local function SendMoreButtonOnClick()
    local location = GetSubZoneText()
 
    -- Check if location is in the defined battleground locations
    if not location then
    print("You are not in a BattleGround.")
    return
end
 
local message = buttonMessages.sendMore[buttonMessageIndices.sendMore] .. " at " .. location
SendChatMessage(message, "INSTANCE_CHAT")
end
 
-- Function to handle the INC button click event
local function IncButtonOnClick()
    local location = GetSubZoneText()
 
    -- Check if location is in the defined battleground locations
    if not location then
    print("You are not in a BattleGround.")
    return
end
 
local message = buttonMessages.inc[buttonMessageIndices.inc] .. " at " .. location
SendChatMessage(message, "INSTANCE_CHAT")
end
 
-- Register the slash command
SLASH_INC1 = "/inc"
SlashCmdList["INC"] = function()
    if IncCallout:IsShown() then
        IncCallout:Hide()
    end
end
 
local function OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        local inInstance, instanceType = IsInInstance()
        if inInstance and (instanceType == "pvp" or instanceType == "arena") then
    
        else
            print("|cFFFF0000You need to queue up for PvP|r")
        end
        
        if inInstance and instanceType == "pvp" then
            IncCalloutMainFrame:Show() 
        end
 
    elseif event == "PLAYER_LOGIN" then

db = LibStub("AceDB-3.0"):New(addonName.."DB", defaults, true)
IncDB = db.profile
playerFaction = UnitFactionGroup("player")
 
-- Create the buttons
local button1 = createButton("button1", 20, 22, "1", {"TOPLEFT", IncCallout, "TOPLEFT"}, 15, -20, ButtonOnClick)
local button2 = createButton("button2", 20, 22, "2", {"LEFT", button1, "RIGHT"}, 3, 0, ButtonOnClick)
local button3 = createButton("button3", 20, 22, "3", {"LEFT", button2, "RIGHT"}, 3, 0, ButtonOnClick)
local button4 = createButton("button4", 20, 22, "4", {"LEFT", button3, "RIGHT"}, 3, 0, ButtonOnClick)
local buttonZerg = createButton("buttonZerg", 40, 22, "Zerg", {"LEFT", button4, "RIGHT"}, 3, 0, ButtonOnClick)
local incButton = createButton("incButton", 60, 22, "Inc", {"TOP", IncCallout, "TOP"}, 0, -45, ButtonOnClick)
local sendMoreButton = createButton("sendMoreButton", 80, 22, "Send More", {"TOP", incButton, "BOTTOM"}, 0, -5, SendMoreButtonOnClick)
local allClearButton = createButton("allClearButton", 60, 22, "All Clear", {"TOP", sendMoreButton, "BOTTOM"}, 0, -5, AllClearButtonOnClick)
local exitButton = createButton("exitButton", 60, 22, "Exit", {"TOP", allClearButton, "BOTTOM"}, 0, -5, function() IncCallout:Hide() end)

-- Apply the PostClick script to each button
for _, button in ipairs(buttons) do
    button:SetScript("PostClick", function()
        applyButtonColor()
    end)
end

allClearButton:SetScript("OnClick", AllClearButtonOnClick)
sendMoreButton:SetScript("OnClick", SendMoreButtonOnClick)
incButton:SetScript("OnClick", IncButtonOnClick)
-- Apply the color to all the buttons
applyButtonColor()
 
-- Initialize IncDB.minimap if it's not already initialized
if not IncDB.minimap then
    IncDB.minimap = {
        hide = false,
        minimapPos = 45, -- Default position angle (in degrees)
    }
end
  
    -- Load saved button messages indices
    buttonMessageIndices.sendMore = IncDB.sendMoreIndex or 1
    buttonMessageIndices.inc = IncDB.incIndex or 1
    buttonMessageIndices.allClear = IncDB.allClearIndex or 1
 
    -- Load the opacity setting
    bgTexture:SetAlpha(IncDB.opacity or 1)
    borderTexture:SetAlpha(IncDB.opacity or 1)
 
    -- Load the button color
    local color = IncDB.buttonColor or {r = 1, g = 0, b = 0, a = 1} -- Default to red
    local r, g, b, a = color.r, color.g, color.b, color.a
    applyButtonColor() 

 
    -- Load the font color
    local savedColor = IncDB.fontColor or {r = 1, g = 1, b = 1, a = 1}  -- Default to white
    local r, g, b, a = savedColor.r, savedColor.g, savedColor.b, savedColor.a
    for _, text in ipairs(buttonTexts) do
        text:SetTextColor(r, g, b, a)
    end
 
    -- Load the font
    local defaultSize = 15  -- Default font size
    local font = IncDB.font or "Fonts\\ARIALN.ttf"  -- Default to Arial
    for _, text in ipairs(buttonTexts) do
        local _, size = text:GetFont()
        size = size or defaultSize
        text:SetFont(font, size)  -- Preserve the font size
    end
 
    -- Load the minimap icon settings
    icon:Register("IncCallout", IncCalloutLDB, IncDB.minimap)
 
    elseif event == "PLAYER_LOGOUT" then

end
 
 
end
 
IncCallout:SetScript("OnEvent", OnEvent)
 
-- Register the events
IncCallout:RegisterEvent("PLAYER_ENTERING_WORLD")
IncCallout:RegisterEvent("PLAYER_LOGIN")
IncCallout:RegisterEvent("PLAYER_LOGOUT")
IncCallout:SetScript("OnEvent", OnEvent)












