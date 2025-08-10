-- IncCallout (Rebuild of Incoming-BG)
-- Made by Sharpedge_Gaming
-- v9.0 - 10.2.5

if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
    print("Running in Retail WoW")
elseif WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
    print("Running in Classic WoW (MoP)")
end

-- Load embedded libraries
local LibStub = LibStub or _G.LibStub
local AceDB = LibStub:GetLibrary("AceDB-3.0")
local AceAddon = LibStub:GetLibrary("AceAddon-3.0")
local AceConfig = LibStub:GetLibrary("AceConfig-3.0")
local AceConfigDialog = LibStub:GetLibrary("AceConfigDialog-3.0")
local icon = LibStub:GetLibrary("LibDBIcon-1.0")
local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local LSM = LibStub("LibSharedMedia-3.0")

local addonName, addonNamespace = ...

local IncDB, db
local addon = AceAddon:NewAddon(addonName)

local defaults = {
    profile = {
        buttonColor = {r = 1, g = 0, b = 0, a = 1},
        fontColor = {r = 1, g = 1, b = 1, a = 1},
        opacity = 1,
        sendMoreIndex = 1,
        incIndex = 1,
        allClearIndex = 1,
    },
}

local buttonTexts = {}
local buttons = {}

local playerFaction

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
    },
}

local IncCallout = CreateFrame("Frame", "IncCalloutMainFrame", UIParent, "BackdropTemplate")
IncCallout:SetSize(160, 180)
IncCallout:SetPoint("CENTER")

local bgTexture = IncCallout:CreateTexture(nil, "BACKGROUND")
bgTexture:SetColorTexture(0, 0, 0)
bgTexture:SetAllPoints(IncCallout)

local BorderFrame = CreateFrame("Frame", nil, IncCallout, "BackdropTemplate")
BorderFrame:SetFrameLevel(IncCallout:GetFrameLevel() - 1)
BorderFrame:SetSize(IncCallout:GetWidth() + 4, IncCallout:GetHeight() + 4)
BorderFrame:SetPoint("CENTER", IncCallout, "CENTER")

local borderTexture = BorderFrame:CreateTexture(nil, "OVERLAY")
borderTexture:SetColorTexture(1, 1, 1)
borderTexture:SetAllPoints(BorderFrame)

IncCallout:SetMovable(true)
IncCallout:EnableMouse(true)
IncCallout:RegisterForDrag("LeftButton")
IncCallout:SetScript("OnDragStart", IncCallout.StartMoving)
IncCallout:SetScript("OnDragStop", IncCallout.StopMovingOrSizing)

local mapSizeOptions = {
    { name = "Very Small", value = 0.4 },
    { name = "Small", value = 0.5 },
    { name = "Medium Small", value = 0.65 },
    { name = "Medium", value = 0.75 },
    { name = "Medium Large", value = 0.85 },
    { name = "Large", value = 1.0 },
    { name = "Very Large", value = 1.15 },
    { name = "Huge", value = 1.3 },
    { name = "Gigantic", value = 1.45 },
    { name = "Colossal", value = 1.6 }
}

local function ResizeWorldMap()
    if not IncCalloutDB then IncCalloutDB = {} end
    if not IncCalloutDB.settings then
        IncCalloutDB.settings = {
            mapScale = 0.75,
            mapPosition = {
                point = "CENTER",
                relativePoint = "CENTER",
                xOfs = 0,
                yOfs = 0,
            },
            resizeInPvPOnly = false,
        }
    end

    local scale = IncCalloutDB.settings.mapScale or 0.75
    local resizeInPvPOnly = IncCalloutDB.settings.resizeInPvPOnly
    local inInstance, instanceType = IsInInstance()

    if resizeInPvPOnly then
        if inInstance and (instanceType == "pvp" or instanceType == "arena") then
            if WorldMapFrame and WorldMapFrame.SetScale then
                WorldMapFrame:SetScale(scale)
            end
        else
            if WorldMapFrame and WorldMapFrame.SetScale then
                WorldMapFrame:SetScale(1.0)
            end
        end
    else
        if WorldMapFrame and WorldMapFrame.SetScale then
            WorldMapFrame:SetScale(scale)
        end
    end
end

if WorldMapFrame and WorldMapFrame.HookScript then
    WorldMapFrame:HookScript("OnShow", ResizeWorldMap)
end

local function MapResizer_OnPlayerLogin()
    if WorldMapFrame and WorldMapFrame.HookScript then
        if not WorldMapFrame._IncCalloutHooked then
            WorldMapFrame:HookScript("OnShow", ResizeWorldMap)
            WorldMapFrame._IncCalloutHooked = true
        end
        ResizeWorldMap()
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", MapResizer_OnPlayerLogin)

local function applyButtonColor()
    local r, g, b, a
    if IncDB.buttonColor then
        r, g, b, a = IncDB.buttonColor.r, IncDB.buttonColor.g, IncDB.buttonColor.b, IncDB.buttonColor.a
    else
        r, g, b, a = 1, 0, 0, 1
    end
    for _, button in ipairs(buttons) do
        button:SetBackdropColor(r, g, b, a)
    end
end

IncCallout:SetScript("OnShow", function()
    applyButtonColor()
end)

local function RegisterIncCalloutOptions()
    local panel = CreateFrame("Frame", "IncCalloutOptionsPanel", InterfaceOptionsFramePanelContainer)
    panel.name = "IncCallout"

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("IncCallout Settings")

    panel:SetScript("OnShow", function(self)
        if not self.initialized then
            self.initialized = true
        end
    end)

    tinsert(UISpecialFrames, panel)
end

RegisterIncCalloutOptions()

local IncCalloutLDB = LibStub("LibDataBroker-1.1"):NewDataObject("IncCallout", {
    type = "data source",
    text = "IncCallout",
    icon = "Interface\\AddOns\\IncCallout\\Icon\\INC.png",

    OnClick = function(_, button)
        if button == "RightButton" then
            if IncCallout:IsShown() then
                IncCallout:Hide()
            else
                IncCallout:Show()
            end
        else
            AceConfigDialog:Open("IncCallout")
        end
    end,

    OnMouseDown = function(self, button)
        if button == "LeftButton" and IncCallout then
            IncCallout:StartMoving()
        end
    end,

    OnMouseUp = function(self, button)
        if button == "LeftButton" and IncCallout then
            IncCallout:StopMovingOrSizing()
            local point, _, _, x, y = IncCallout:GetPoint()
            local centerX, centerY = Minimap:GetCenter()
            local scale = Minimap:GetEffectiveScale()
            x, y = (x - centerX) / scale, (y - centerY) / scale
            if IncDB and IncDB.minimap then
                IncDB.minimap.minimapPos = math.deg(math.atan2(y, x)) % 360
            end
        end
    end,

    OnTooltipShow = function(tooltip)
        tooltip:AddLine("|cffff0000IncCallout|r")
        tooltip:AddLine("Left Click: Open Options")
        tooltip:AddLine("Right Click: Show/Hide GUI")
        tooltip:Show()
    end,
})

local options = {
    name = "IncCallout",
    type = "group",
    args = {
        sendMore = {
            type = "select",
            name = "Send More Message",
            desc = "Select the message for the 'Send More' button",
            values = buttonMessages.sendMore,
            get = function() return IncDB.sendMoreIndex or 1 end,
            set = function(_, newValue)
                IncDB.sendMoreIndex = newValue
            end,
            order = 1,
        },
        inc = {
            type = "select",
            name = "INC Message",
            desc = "Select the message for the 'INC' button",
            values = buttonMessages.inc,
            get = function() return IncDB.incIndex or 1 end,
            set = function(_, newValue)
                IncDB.incIndex = newValue
            end,
            order = 2,
        },
        allClear = {
            type = "select",
            name = "All Clear Message",
            desc = "Select the message for the 'All Clear' button",
            values = buttonMessages.allClear,
            get = function() return IncDB.allClearIndex or 1 end,
            set = function(_, newValue)
                IncDB.allClearIndex = newValue
            end,
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
            order = 5,
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
            order = 6,
        },
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
            order = 7,
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
            order = 8,
        },
        mapHeader = {
            type = "header",
            name = "Map Settings",
            order = 20,
        },
        mapSizeChoice = {
            type = "select",
            name = "Map Size",
            desc = "Select the preferred size of the WorldMap.",
            order = 21,
            style = "dropdown",
            values = function()
                local values = {}
                for _, sizeOption in ipairs(mapSizeOptions) do
                    values[sizeOption.value] = sizeOption.name
                end
                return values
            end,
            get = function()
                if not IncCalloutDB or not IncCalloutDB.settings then
                    return 0.75
                end
                return IncCalloutDB.settings.mapScale
            end,
            set = function(_, selectedValue)
                if not IncCalloutDB then IncCalloutDB = {} end
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
                IncCalloutDB.settings.mapScale = selectedValue
                if addonNamespace.ResizeWorldMap then
                    addonNamespace.ResizeWorldMap()
                end
            end,
        },
        resizeInPvPOnly = {
            type = "toggle",
            name = "Resize Map in PvP Only",
            desc = "Enable to resize the WorldMap only in PvP scenarios.",
            order = 22,
            get = function()
                if not IncCalloutDB or not IncCalloutDB.settings then
                    return true
                end
                return IncCalloutDB.settings.resizeInPvPOnly
            end,
            set = function(_, value)
                if not IncCalloutDB then IncCalloutDB = {} end
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
                IncCalloutDB.settings.resizeInPvPOnly = value
                if addonNamespace.ResizeWorldMap then
                    addonNamespace.ResizeWorldMap()
                end
            end,
        },
    },
}

AceConfig:RegisterOptionsTable("IncCallout", options)

local configPanel = AceConfigDialog:AddToBlizOptions(addonName, "IncCallout")
configPanel.default = function()
    IncDB.sendMoreIndex = 1
    IncDB.incIndex = 1
    IncDB.allClearIndex = 1
end

local locationTable = {}
for _, location in ipairs(battlegroundLocations) do
    locationTable[location] = location
end

local function isInBattleground()
    local inInstance, instanceType = IsInInstance()
    return inInstance and (instanceType == "pvp" or instanceType == "arena")
end

-- Improved location detection for broader flag area reporting
local function getFlagArea()
    local subZone = GetSubZoneText() or ""
    local zone = GetZoneText() or ""
    local realZone = GetRealZoneText() or ""

    -- Try subzone first by substring match
    for _, area in ipairs(battlegroundLocations) do
        if subZone:lower():find(area:lower(), 1, true) then
            return area
        end
    end

    -- Try zone name by substring match
    for _, area in ipairs(battlegroundLocations) do
        if zone:lower():find(area:lower(), 1, true) then
            return area
        end
    end

    -- Try real zone name by substring match
    for _, area in ipairs(battlegroundLocations) do
        if realZone:lower():find(area:lower(), 1, true) then
            return area
        end
    end

    -- Fallbacks
    if subZone ~= "" then return subZone end
    if zone ~= "" then return zone end
    return realZone
end

local function ButtonOnClick(self)
    if not isInBattleground() then
        print("You are not in a battleground.")
        return
    end

    local location = getFlagArea()
    local message = self:GetText() .. " Incoming at " .. location
    SendChatMessage(message, "INSTANCE_CHAT")
end

local f = CreateFrame("Frame")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")

f:SetScript("OnEvent", function(self, event, ...)
    if event == "ZONE_CHANGED_NEW_AREA" then
        local currentLocation = GetRealZoneText() .. " - " .. GetSubZoneText()
        local location = locationTable[currentLocation]

        if location then
            IncCallout:Show()
        else
            -- Hide or do nothing
        end
    end
end)

local function AllClearButtonOnClick()
    local location = getFlagArea()
    if not location or location == "" then
        print("You are not in a BattleGround.")
        return
    end
    local message = buttonMessages.allClear[IncDB.allClearIndex or 1] .. " at " .. location
    SendChatMessage(message, "INSTANCE_CHAT")
end

local function SendMoreButtonOnClick()
    local location = getFlagArea()
    if not location or location == "" then
        print("You are not in a BattleGround.")
        return
    end
    local message = buttonMessages.sendMore[IncDB.sendMoreIndex or 1] .. " at " .. location
    SendChatMessage(message, "INSTANCE_CHAT")
end

local function IncButtonOnClick()
    local location = getFlagArea()
    if not location or location == "" then
        print("You are not in a BattleGround.")
        return
    end
    local message = buttonMessages.inc[IncDB.incIndex or 1] .. " at " .. location
    SendChatMessage(message, "INSTANCE_CHAT")
end

local function OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        local inInstance, instanceType = IsInInstance()
        if not (inInstance and (instanceType == "pvp" or instanceType == "arena")) then
            IncCallout:Hide()
        end
        if inInstance and instanceType == "pvp" then
            IncCallout:Show()
        end
    elseif event == "PLAYER_LOGIN" then
        db = LibStub("AceDB-3.0"):New(addonName.."DB", defaults, true)
        IncDB = db.profile
        playerFaction = UnitFactionGroup("player")

        local function BuffRequestButtonOnClick()
            local message = "Need buffs please!"
            SendChatMessage(message, "INSTANCE_CHAT")
        end

        local function createButton(name, width, height, text, pointTable, x, y, onClick)
            local button = CreateFrame("Button", name, IncCallout, "BackdropTemplate")
            button:SetSize(width, height)
            button:SetPoint(pointTable[1], pointTable[2], pointTable[3], x, y)
            button:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background" })
            button:SetBackdropColor(0.2, 0.2, 0.2, 1)
            local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            buttonText:SetPoint("CENTER", button, "CENTER")
            buttonText:SetText(text)
            button:SetFontString(buttonText)
            if onClick then button:SetScript("OnClick", onClick) end
            table.insert(buttons, button)
            table.insert(buttonTexts, buttonText)
            return button
        end

        local button1 = createButton("button1", 20, 22, "1", {"TOPLEFT", IncCallout, "TOPLEFT"}, 15, -20, ButtonOnClick)
        local button2 = createButton("button2", 20, 22, "2", {"LEFT", button1, "RIGHT"}, 3, 0, ButtonOnClick)
        local button3 = createButton("button3", 20, 22, "3", {"LEFT", button2, "RIGHT"}, 3, 0, ButtonOnClick)
        local button4 = createButton("button4", 20, 22, "4", {"LEFT", button3, "RIGHT"}, 3, 0, ButtonOnClick)
        local buttonZerg = createButton("buttonZerg", 40, 22, "Zerg", {"LEFT", button4, "RIGHT"}, 3, 0, ButtonOnClick)
        local incButton = createButton("incButton", 110, 22, "Inc", {"TOP", IncCallout, "TOP"}, 0, -45, ButtonOnClick)
        local sendMoreButton = createButton("sendMoreButton", 110, 22, "Send More", {"TOP", incButton, "BOTTOM"}, 0, -5, SendMoreButtonOnClick)
        local allClearButton = createButton("allClearButton", 110, 22, "All Clear", {"TOP", sendMoreButton, "BOTTOM"}, 0, -5, AllClearButtonOnClick)
        local buffRequestButton = createButton("buffRequestButton", 110, 22, "Request Buffs", {"TOP", allClearButton, "BOTTOM"}, 0, -5, BuffRequestButtonOnClick)
        local exitButton = createButton("exitButton", 110, 22, "Exit", {"TOP", buffRequestButton, "BOTTOM"}, 0, -5, function() IncCallout:Hide() end)

        applyButtonColor()

        for _, button in ipairs(buttons) do
            button:SetScript("PostClick", function()
                applyButtonColor()
            end)
        end

        allClearButton:SetScript("OnClick", AllClearButtonOnClick)
        sendMoreButton:SetScript("OnClick", SendMoreButtonOnClick)
        incButton:SetScript("OnClick", IncButtonOnClick)

        applyButtonColor()

        if not IncDB.minimap then
            IncDB.minimap = {
                hide = false,
                minimapPos = 45,
            }
        end

        -- Load the opacity setting
        bgTexture:SetAlpha(IncDB.opacity or 1)
        borderTexture:SetAlpha(IncDB.opacity or 1)

        -- Load the button color
        applyButtonColor()

        -- Load the font color
        local savedColor = IncDB.fontColor or {r = 1, g = 1, b = 1, a = 1}
        for _, text in ipairs(buttonTexts) do
            text:SetTextColor(savedColor.r, savedColor.g, savedColor.b, savedColor.a)
        end

        local font = IncDB.font or "Friz Quadrata TT"
        local fontSize = IncDB.fontSize or 15
        for _, text in ipairs(buttonTexts) do
            text:SetFont(LSM:Fetch("font", font), fontSize)
        end

        icon:Register("IncCallout", IncCalloutLDB, IncDB.minimap)
    elseif event == "PLAYER_LOGOUT" then
        -- No need to do anything, AceDB saves automatically
    end
end

SLASH_INC1 = "/inc"
SlashCmdList["INC"] = function()
    if IncCallout:IsShown() then
        IncCallout:Hide()
    else
        IncCallout:Show()
    end
end

local function IncomingBGMessageCommandHandler(msg)
    local messageType = "INSTANCE_CHAT"
    local message = "Peeps, yall need to get the addon Incoming-BG. It has a GUI to where all you have to do is click a button to call an INC. Beats having to type anything out. Just sayin'."
    SendChatMessage(message, messageType)
end

SLASH_INCOMINGBGMSG1 = "/incmsg"
SlashCmdList["INCOMINGBGMSG"] = IncomingBGMessageCommandHandler

IncCallout:SetScript("OnEvent", OnEvent)

IncCallout:RegisterEvent("PLAYER_ENTERING_WORLD")
IncCallout:RegisterEvent("PLAYER_LOGIN")
IncCallout:RegisterEvent("PLAYER_LOGOUT")
IncCallout:SetScript("OnEvent", OnEvent)