-- IncCallout (Rebuild of Incoming-BG)
-- Made by Sharpedge_Gaming
-- v3.3 - 10.2.5

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
--local LSM = LibStub ("LibSharedMedia-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local addonName, addonNamespace = ...
 
local IncDB, db 
local addon = AceAddon:NewAddon(addonName)
 
local defaults = {
    profile = {
        buttonColor = {r = 1, g = 0, b = 0, a = 1}, -- Default to red
        fontColor = {r = 1, g = 1, b = 1, a = 1},  -- Default to white 
        opacity = 1,
		hmdIndex = 1,
        conquestFont = "Friz Quadrata TT",
        conquestFontSize = 14,
        conquestFontColor = {r = 1, g = 1, b = 1, a = 1}, -- white
        honorFont = "Friz Quadrata TT",
        honorFontSize = 14,
        honorFontColor = {r = 1, g = 1, b = 1, a = 1}, -- white
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

local predefinedColors = {
    { text = "White", value = {r = 1, g = 1, b = 1, a = 1} },
    { text = "Red", value = {r = 1, g = 0, b = 0, a = 1} },
    { text = "Green", value = {r = 0, g = 1, b = 0, a = 1} },
    { text = "Blue", value = {r = 0, g = 0, b = 1, a = 1} },
    { text = "Yellow", value = {r = 1, g = 1, b = 0, a = 1} },
    { text = "Cyan", value = {r = 0, g = 1, b = 1, a = 1} },
    { text = "Magenta", value = {r = 1, g = 0, b = 1, a = 1} },
    { text = "Orange", value = {r = 1, g = 0.5, b = 0, a = 1} },
    { text = "Purple", value = {r = 0.5, g = 0, b = 0.5, a = 1} },
    { text = "Pink", value = {r = 1, g = 0.75, b = 0.8, a = 1} },
    { text = "Lime", value = {r = 0.5, g = 1, b = 0, a = 1} },
    { text = "Sky Blue", value = {r = 0, g = 0.75, b = 1, a = 1} },
    { text = "Brown", value = {r = 0.6, g = 0.4, b = 0.2, a = 1} },
    { text = "Grey", value = {r = 0.5, g = 0.5, b = 0.5, a = 1} },
    { text = "Dark Green", value = {r = 0, g = 0.5, b = 0, a = 1} },
    { text = "Teal", value = {r = 0, g = 0.5, b = 0.5, a = 1} },
    { text = "Maroon", value = {r = 0.5, g = 0, b = 0, a = 1} },
    { text = "Olive", value = {r = 0.5, g = 0.5, b = 0, a = 1} },
    { text = "Navy", value = {r = 0, g = 0, b = 0.5, a = 1} },
    { text = "Coral", value = {r = 1, g = 0.5, b = 0.3, a = 1} },
}

SLASH_INC1 = "/inc"
 
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
    "Ashran", "StormShield", "The Ringing Deeps",   
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
    buffRequest = {
    "Need buffs please!",
    "Buff up, team!",
    "Could use some buffs here!",
    "Calling for all buffs, let's gear up!",
    "Looking for that magical boost, buffs needed!",
    "Time to get enchanted, where are those buffs?",
    "Let’s get buffed for the battle ahead!",
    "Buffs are our best friends, let’s have them!",
    "Ready for buffs, let's enhance our strength!",
    "Buffs needed for extra might and magic!",
    "Gimme some buffs, let’s not fall behind!"
    -- Add more custom messages if needed...
	},
	hmd = {
    "Focus healers!",
    "Take down healers!",
    "Target healers to win!",
    "Healers must die!",
    "Eliminate healers fast!",
    "Healers top priority!",
    "Attack healers!",
    "Healers spotted, engage!",
    "Priority: healers!",
    "Remove healers for win!"
    -- Add more messages as needed...
   }
 } 
   
-- Create the main frame
local IncCallout = CreateFrame("Frame", "IncCalloutMainFrame", UIParent, "BackdropTemplate")
IncCallout:SetSize(160, 230)
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

local xOffsetConquest =45 
local yOffsetConquest = 15 
local xOffsetHonor = 45 
local yOffsetHonor = -5 

-- Create a container frame for the Conquest Points label
local conquestContainer = CreateFrame("Frame", "ConquestContainerFrame", IncCallout, "BackdropTemplate")
conquestContainer:SetPoint("BOTTOMLEFT", IncCallout, "BOTTOMLEFT", xOffsetConquest, yOffsetConquest)
conquestContainer:SetSize(85, 40) 
conquestContainer:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background"
    
})
conquestContainer:SetBackdropColor(0, 0, 0, 0) 

local fontSize = 14

-- Create the Conquest Points label within its container
local conquestPointsLabel = conquestContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
conquestPointsLabel:SetPoint("CENTER", conquestContainer, "CENTER", 0, 0)
conquestPointsLabel:SetFont("Fonts\\FRIZQT__.TTF", fontSize)  -- Set font and size
conquestPointsLabel:SetText("Conquest: 0")

-- Create a container frame for the Honor Points label
local honorContainer = CreateFrame("Frame", "HonorContainerFrame", IncCallout, "BackdropTemplate")
honorContainer:SetPoint("BOTTOMLEFT", IncCallout, "BOTTOMLEFT", xOffsetHonor, yOffsetHonor)
honorContainer:SetSize(85, 40) 
honorContainer:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background"
    
})
honorContainer:SetBackdropColor(0, 0, 0, 0) 

-- Create the Honor Points label within its container
local honorPointsLabel = honorContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
honorPointsLabel:SetPoint("CENTER", honorContainer, "CENTER", 0, 0)
honorPointsLabel:SetFont("Fonts\\FRIZQT__.TTF", fontSize)  
honorPointsLabel:SetText("Honor: 0")

IncCallout:SetMovable(true)
IncCallout:EnableMouse(true)
IncCallout:RegisterForDrag("LeftButton")
IncCallout:SetScript("OnDragStart", IncCallout.StartMoving)
IncCallout:SetScript("OnDragStop", IncCallout.StopMovingOrSizing)
 
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
    button:SetBackdrop({
      bgFile = "Interface/Tooltips/UI-Tooltip-Background",
      edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
      tile = true,
      tileSize = 12,
      edgeSize = 7,  
      insets = { left = 1, right = 1, top = 1, bottom = 1 }
})

    table.insert(buttonTexts, button:GetFontString())
    table.insert(buttons, button)
    return button
end
 
local function applyButtonColor()
    -- Check if IncDB is initialized
    if not IncDB then
        return
    end

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

IncCallout:SetScript("OnShow", function()
    if IncDB then
        applyButtonColor()
    end
end)

local options = {
    name = "IncCallout",
    type = "group",
    args = {
        messageSettings = {
            type = "group",
            name = "Message Settings",
            order = 1,
            args = {
                sendMore = {
                    type = "select",
                    name = "Send More Message",
                    desc = "Select the message for the 'Send More' button",
                    values = buttonMessages.sendMore,
                    get = function() return buttonMessageIndices.sendMore end,
                    set = function(_, newValue)
                        buttonMessageIndices.sendMore = newValue
                        IncDB.sendMoreIndex = newValue
                    end,
                    order = 1,
                },
                inc = {
                    type = "select",
                    name = "INC Message",
                    desc = "Select the message for the 'INC' button",
                    values = buttonMessages.inc,
                    get = function() return buttonMessageIndices.inc end,
                    set = function(_, newValue)
                        buttonMessageIndices.inc = newValue
                        IncDB.incIndex = newValue
                    end,
                    order = 2,
                },
                allClear = {
                    type = "select",
                    name = "All Clear Message",
                    desc = "Select the message for the 'All Clear' button",
                    values = buttonMessages.allClear,
                    get = function() return buttonMessageIndices.allClear end,
                    set = function(_, newValue)
                        buttonMessageIndices.allClear = newValue
                        IncDB.allClearIndex = newValue
                    end,
                    order = 3,
                },
                buffRequest = {
                    type = "select",
                    name = "Buff Request Message",
                    desc = "Select the message for the 'Request Buffs' button",
                    values = buttonMessages.buffRequest,
                    get = function() return buttonMessageIndices.buffRequest end,
                    set = function(_, newValue)
                        buttonMessageIndices.buffRequest = newValue
                        IncDB.buffRequestIndex = newValue
                    end,
                    order = 4,
					}, 
				hmd = {
                    type = "select",
                    name = "H.M.D. Message",
                    desc = "Select the message for the 'H.M.D.' button",
                    values = buttonMessages.hmd,
                    get = function() return buttonMessageIndices.hmd end,
                    set = function(_, newValue)
                    buttonMessageIndices.hmd = newValue
                    IncDB.hmdIndex = newValue -- Ensure this is saving correctly
                    end,
                    order = 5, 
                },
            },
        },
        appearanceSettings = {
            type = "group",
            name = "Appearance Settings",
            order = 2,
            args = {
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
                    order = 1,
                },
                fontColor = {
                    type = "select",
                    name = "Button Font Color",
                    desc = "Set the color of the button text.",
                    values = function()
                        local colorValues = {}
                        for i, color in ipairs(predefinedColors) do
                            colorValues[i] = color.text
                        end
                        return colorValues
                    end,
                    get = function()
                        local currentColor = IncDB.fontColor or {r = 1, g = 1, b = 1, a = 1}
                        for index, color in ipairs(predefinedColors) do
                            if color.value.r == currentColor.r and color.value.g == currentColor.g and color.value.b == currentColor.b and color.value.a == currentColor.a then
                                return index
                            end
                        end
                        return 1
                    end,
                    set = function(_, selectedValue)
                        local color = predefinedColors[selectedValue].value
                        IncDB.fontColor = color
                        for _, text in ipairs(buttonTexts) do
                            text:SetTextColor(color.r, color.g, color.b, color.a)
                        end
                    end,
                    style = "dropdown",
                    order = 2,
                },
                buttonColor = {
                    type = "select",
                    name = "Button Color",
                    desc = "Select the color of the buttons.",
                    values = function()
                        local colorValues = {}
                        for i, color in ipairs(predefinedColors) do
                            colorValues[i] = color.text
                        end
                        return colorValues
                    end,
                    get = function()
                        local currentColor = IncDB.buttonColor
                        for index, color in ipairs(predefinedColors) do
                            if color.value.r == currentColor.r and color.value.g == currentColor.g and color.value.b == currentColor.b and color.value.a == currentColor.a then
                                return index
                            end
                        end
                        return 1
                    end,
                    set = function(_, selectedValue)
                        local color = predefinedColors[selectedValue].value
                        IncDB.buttonColor = color
                        applyButtonColor()
                    end,
                    style = "dropdown",
                    order = 3,
                },
            },
        },
        fontSettings = {
            type = "group",
            name = "Font Settings",
            order = 3,
            args = {
                font = {
                    type = "select",
                    name = "Font",
                    desc = "Select the font for the buttons.",
                    dialogControl = "LSM30_Font",
                    values = LSM:HashTable("font"),
                    get = function()
                        return IncDB.font or "Friz Quadrata TT"
                    end,
                    set = function(_, newValue)
                        IncDB.font = newValue
                        local size = IncDB.fontSize or 14
                        for _, text in ipairs(buttonTexts) do
                            text:SetFont(LSM:Fetch("font", newValue), size)
                        end
                    end,
                    order = 1,
                },
                fontSize = {
                    type = "range",
                    name = "Font Size",
                    desc = "Adjust the font size for the buttons.",
                    min = 8, max = 24, step = 1,
                    get = function() return IncDB.fontSize or 14 end,
                    set = function(_, newValue)
                        IncDB.fontSize = newValue
                        local font = IncDB.font or "Friz Quadrata TT"
                        for _, text in ipairs(buttonTexts) do
                            text:SetFont(LSM:Fetch("font", font), newValue)
                        end
                    end,
                    order = 2,
                },
                conquestFont = {
                    type = "select",
                    name = "Conquest Font",
                    desc = "Select the font for Conquest Points",
                    dialogControl = "LSM30_Font",
                    values = LSM:HashTable("font"),
                    get = function() return IncDB.conquestFont end,
                    set = function(_, newValue)
                        IncDB.conquestFont = newValue
                        conquestPointsLabel:SetFont(LSM:Fetch("font", newValue), IncDB.conquestFontSize)
                    end,
                    order = 3,
                },
                conquestFontColor = {
                    type = "color",
                    name = "Conquest Font Color",
                    desc = "Select the color for Conquest Points font",
                    hasAlpha = true,
                    get = function()
                        local color = IncDB.conquestFontColor
                        return color.r, color.g, color.b, color.a
                    end,
                    set = function(_, r, g, b, a)
                        IncDB.conquestFontColor = { r = r, g = g, b = b, a = a }
                        conquestPointsLabel:SetTextColor(r, g, b, a)
                    end,
                    order = 4,
                },
                honorFont = {
                    type = "select",
                    name = "Honor Font",
                    desc = "Select the font for Honor Points",
                    dialogControl = "LSM30_Font",
                    values = LSM:HashTable("font"),
                    get = function() return IncDB.honorFont end,
                    set = function(_, newValue)
                        IncDB.honorFont = newValue
                        honorPointsLabel:SetFont(LSM:Fetch("font", newValue), IncDB.honorFontSize)
                    end,
                    order = 5,
                },
                honorFontColor = {
                    type = "color",
                    name = "Honor Font Color",
                    desc = "Select the color for Honor Points font",
                    hasAlpha = true,
                    get = function()
                        local color = IncDB.honorFontColor
                        return color.r, color.g, color.b, color.a
                    end,
                    set = function(_, r, g, b, a)
                        IncDB.honorFontColor = { r = r, g = g, b = b, a = a }
                        honorPointsLabel:SetTextColor(r, g, b, a)
                    end,
                    order = 6,
					},
					conquestFontSize = {
                    type = "range",
                    name = "Conquest Font Size",
                    desc = "Adjust the font size for Conquest Points.",
                    min = 8, max = 24, step = 1,
                    get = function() return IncDB.conquestFontSize or 14 end,
                    set = function(_, newValue)
                        IncDB.conquestFontSize = newValue
                        conquestPointsLabel:SetFont(LSM:Fetch("font", IncDB.conquestFont), newValue)
                    end,
                    order = 7,
                },
                honorFontSize = {
                    type = "range",
                    name = "Honor Font Size",
                    desc = "Adjust the font size for Honor Points.",
                    min = 8, max = 24, step = 1,
                    get = function() return IncDB.honorFontSize or 14 end,
                    set = function(_, newValue)
                        IncDB.honorFontSize = newValue
                        honorPointsLabel:SetFont(LSM:Fetch("font", IncDB.honorFont), newValue)
                    end,
                    order = 8,
                },
            },
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
	buttonMessageIndices.buffRequest = 1
	buttonMessageIndices.hmd = IncDB.hmdIndex or 1

end

local function ListHealers()
    local groupType, groupSize
    if IsInRaid() then
        groupType = "raid"
        groupSize = GetNumGroupMembers()
    elseif IsInGroup() then
        groupType = "party"
        groupSize = GetNumGroupMembers() -- Include the player
    else
        print("You are not in a group.")
        return
    end

    local healerNames = {}
    for i = 1, groupSize do
        local unit = groupType..i
        local role = UnitGroupRolesAssigned(unit)
        if role == "HEALER" then
            table.insert(healerNames, GetUnitName(unit, true))
        end
    end

    if #healerNames > 0 then
        local healerList = table.concat(healerNames, ", ")
        SendChatMessage("Healers on our team: " .. healerList, "INSTANCE_CHAT")
    else
        if IsInGroup() or IsInRaid() then
            SendChatMessage("We have no heals, lol..", "INSTANCE_CHAT")
        end
    end
end

local healerButton = createButton("healerButton", 70, 22, "Healers", {"BOTTOMLEFT", IncCallout, "BOTTOMLEFT"}, 0, -27, ListHealers)
local healsButton = createButton("healsButton", 70, 22, "H.M.D.", {"BOTTOMLEFT", healerButton, "BOTTOMRIGHT"}, 20, 0, function()
end)

local function HMDButtonOnClick()
    local message = buttonMessages.hmd[buttonMessageIndices.hmd]
    SendChatMessage(message, "INSTANCE_CHAT")  
end

healsButton:SetScript("OnClick", HMDButtonOnClick)

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
local message = self:GetText() .. " Incoming at " .. currentLocation
SendChatMessage(message, "INSTANCE_CHAT")
end
 
-- Register an event listener for when the player enters a new zone or subzone
local f = CreateFrame("Frame")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")

-- Constants for the IDs
local CONQUEST_CURRENCY_ID = 1602
local HONOR_CURRENCY_ID = 1792

local function UpdatePoints()

    if not IncDB then
        return
    end

    local conquestInfo = C_CurrencyInfo.GetCurrencyInfo(CONQUEST_CURRENCY_ID)
    local honorInfo = C_CurrencyInfo.GetCurrencyInfo(HONOR_CURRENCY_ID)

    -- Update Conquest Points Label
    conquestPointsLabel:SetText("Conquest: " .. (conquestInfo and conquestInfo.quantity or 0))
    conquestPointsLabel:SetFont(LSM:Fetch("font", IncDB.conquestFont), IncDB.conquestFontSize)
    conquestPointsLabel:SetTextColor(IncDB.conquestFontColor.r, IncDB.conquestFontColor.g, IncDB.conquestFontColor.b, IncDB.conquestFontColor.a)

    -- Update Honor Points Label
    honorPointsLabel:SetText("Honor: " .. (honorInfo and honorInfo.quantity or 0))
    honorPointsLabel:SetFont(LSM:Fetch("font", IncDB.honorFont), IncDB.honorFontSize)
    honorPointsLabel:SetTextColor(IncDB.honorFontColor.r, IncDB.honorFontColor.g, IncDB.honorFontColor.b, IncDB.honorFontColor.a)
end

IncCallout:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
IncCallout:RegisterEvent("HONOR_XP_UPDATE")
IncCallout:SetScript("OnEvent", function(self, event, ...)
    if event == "CURRENCY_DISPLAY_UPDATE" or event == "HONOR_XP_UPDATE" then
        UpdatePoints()
    end
end)

UpdatePoints()

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
 
local function OnEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
        db = LibStub("AceDB-3.0"):New(addonName.."DB", defaults, true)
        IncDB = db.profile
        playerFaction = UnitFactionGroup("player")
        isDBInitialized = true  -- Set the flag here
		buttonMessageIndices.hmd = IncDB.hmdIndex or 1

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
        buttonMessageIndices.buffRequest = IncDB.buffRequestIndex or 1

        -- Load the opacity setting
        bgTexture:SetAlpha(IncDB.opacity or 1)
        borderTexture:SetAlpha(IncDB.opacity or 1)

        -- Load the button color
        local color = IncDB.buttonColor or {r = 1, g = 0, b = 0, a = 1} -- Default to red
        applyButtonColor()

        -- Load the font color
        local savedColor = IncDB.fontColor or {r = 1, g = 1, b = 1, a = 1}  -- Default to white
        for _, text in ipairs(buttonTexts) do
            text:SetTextColor(savedColor.r, savedColor.g, savedColor.b, savedColor.a)
        end

        -- Load the font and font size
        local font = IncDB.font or "Friz Quadrata TT"  -- Default font
        local fontSize = IncDB.fontSize or 15  -- Default font size
        for _, text in ipairs(buttonTexts) do
            text:SetFont(LSM:Fetch("font", font), fontSize)
        end

        -- Load the minimap icon settings
        icon:Register("IncCallout", IncCalloutLDB, IncDB.minimap)

        -- Now safe to call UpdatePoints
        UpdatePoints()

    elseif event == "PLAYER_ENTERING_WORLD" then
        local inInstance, instanceType = IsInInstance()
        if inInstance and (instanceType == "pvp" or instanceType == "arena") then
            IncCallout:Show()
        else
            IncCallout:Hide()
        end
        UpdatePoints()  -- Call UpdatePoints here as well

    elseif event == "CURRENCY_DISPLAY_UPDATE" or event == "HONOR_XP_UPDATE" then
        -- These events are fired when currency (conquest points) or honor points are updated
        UpdatePoints()
    end

end

-- Register the event handling function for the appropriate events
IncCallout:RegisterEvent("PLAYER_LOGIN")
IncCallout:RegisterEvent("PLAYER_ENTERING_WORLD")
IncCallout:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
IncCallout:RegisterEvent("HONOR_XP_UPDATE")
IncCallout:RegisterEvent("PLAYER_LOGOUT")
IncCallout:SetScript("OnEvent", OnEvent)

-- Buff Request Button OnClick Function
local function BuffRequestButtonOnClick()
    local message = buttonMessages.buffRequest[buttonMessageIndices.buffRequest]
    SendChatMessage(message, "INSTANCE_CHAT")  
end

-- Create the buttons
local button1 = createButton("button1", 20, 22, "1", {"TOPLEFT", IncCallout, "TOPLEFT"}, 15, -20, ButtonOnClick)
local button2 = createButton("button2", 20, 22, "2", {"LEFT", button1, "RIGHT"}, 3, 0, ButtonOnClick)
local button3 = createButton("button3", 20, 22, "3", {"LEFT", button2, "RIGHT"}, 3, 0, ButtonOnClick)
local button4 = createButton("button4", 20, 22, "4", {"LEFT", button3, "RIGHT"}, 3, 0, ButtonOnClick)
local buttonZerg = createButton("buttonZerg", 40, 22, "Zerg", {"LEFT", button4, "RIGHT"}, 3, 0, ButtonOnClick)
local incButton = createButton("incButton", 110, 22, "Inc", {"TOP", IncCallout, "TOP"}, 0, -45, ButtonOnClick)
local sendMoreButton = createButton("sendMoreButton", 110, 22, "Send More", {"TOP", incButton, "BOTTOM"}, 0, -5, SendMoreButtonOnClick)
local allClearButton = createButton("allClearButton", 110, 22, "All Clear", {"TOP", sendMoreButton, "BOTTOM"}, 0, -5, AllClearButtonOnClick)
local buffRequestButton = createButton("buffRequestButton", 110, 22, "Request Buffs", {"TOP", allClearButton, "BOTTOM"}, 0, -5, BuffRequestButtonOnClick)
local exitButton = createButton("exitButton", 50, 22, "Exit", {"TOP", buffRequestButton, "BOTTOM"}, 0, -5, function() IncCallout:Hide() end)

-- Apply the color to all the buttons
applyButtonColor()

-- Set OnClick functions for the buttons
allClearButton:SetScript("OnClick", AllClearButtonOnClick)
sendMoreButton:SetScript("OnClick", SendMoreButtonOnClick)
incButton:SetScript("OnClick", IncButtonOnClick)
buffRequestButton:SetScript("OnClick", BuffRequestButtonOnClick)

-- Apply the PostClick script to each button
for _, button in ipairs(buttons) do
    button:SetScript("PostClick", function()
        applyButtonColor()
    end)
end

-- Slash command registration
SLASH_INC1 = "/inc"
SlashCmdList["INC"] = function()
    if IncCallout:IsShown() then
        IncCallout:Hide()
    else
        IncCallout:Show()
    end
end

-- New function to handle the '/incmsg' command
local function IncomingBGMessageCommandHandler(msg)
    local messageType = "INSTANCE_CHAT"  
    local message = "Peeps, yall need to get the addon Incoming-BG. It has a GUI to where all you have to do is click a button to call an INC. Beats having to type anything out. Just sayin'."  

    -- Send the message
    SendChatMessage(message, messageType)
end

SLASH_INCOMINGBGMSG1 = "/incmsg"
SlashCmdList["INCOMINGBGMSG"] = IncomingBGMessageCommandHandler
 
IncCallout:SetScript("OnEvent", OnEvent)
 
-- Register the events
IncCallout:RegisterEvent("PLAYER_ENTERING_WORLD")
IncCallout:RegisterEvent("PLAYER_LOGIN")
IncCallout:RegisterEvent("PLAYER_LOGOUT")
IncCallout:SetScript("OnEvent", OnEvent)
