-- IncCallout (Rebuild of Incoming-BG)
-- Made by Sharpedge_Gaming
-- v6.0 - 10.2.6

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
local AceGUI = LibStub("AceGUI-3.0")

local addonName, addonNamespace = ...
IncDB = IncDB or {}

local IncDB, db 
local addon = AceAddon:NewAddon(addonName)

local defaults = {
    profile = {
        buttonColor = {r = 1, g = 0, b = 0, a = 1}, -- Default to red
        fontColor = {r = 1, g = 1, b = 1, a = 1},  -- Default to white
        opacity = 1,
        hmdIndex = 1,
		sendMoreIndex = 1,
        incIndex = 1,
        allClearIndex = 1,
        logoColor = {r = 1, g = 1, b = 1, a = 1}, -- Default logo color
        scale = 1,
        isLocked = false,
        worldMapScale = 1,
        conquestFont = "Friz Quadrata TT",
        conquestFontSize = 14,
        conquestFontColor = {r = 1, g = 1, b = 1, a = 1}, -- white
        honorFont = "Friz Quadrata TT",
        honorFontSize = 14,
        honorFontColor = {r = 1, g = 1, b = 1, a = 1}, -- white
        selectedLogo = "None", -- Default logo selection
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

SLASH_INC1 = "/inc"

local customRaidWarningFrame = CreateFrame("Frame", "CustomRaidWarningFrame", UIParent)
customRaidWarningFrame:SetHeight(50) 
customRaidWarningFrame:SetPoint("TOP", UIParent, "TOP", 0, -200) 
customRaidWarningFrame:SetWidth(UIParent:GetWidth()) 

customRaidWarningFrame.text = customRaidWarningFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
customRaidWarningFrame.text:SetAllPoints(true)
customRaidWarningFrame.text:SetJustifyH("CENTER")
customRaidWarningFrame.text:SetJustifyV("MIDDLE")

customRaidWarningFrame:Hide() 

local CONQUEST_CURRENCY_ID = 1602
local HONOR_CURRENCY_ID = 1792

-- Create the PVP Stats window frame
local pvpStatsFrame = CreateFrame("Frame", "PVPStatsFrame", UIParent, "BasicFrameTemplateWithInset")
pvpStatsFrame:SetSize(220, 200)
pvpStatsFrame:SetPoint("CENTER")
pvpStatsFrame:SetMovable(true)
pvpStatsFrame:EnableMouse(true)
pvpStatsFrame:RegisterForDrag("LeftButton")
pvpStatsFrame:SetScript("OnDragStart", pvpStatsFrame.StartMoving)
pvpStatsFrame:SetScript("OnDragStop", pvpStatsFrame.StopMovingOrSizing)
pvpStatsFrame:Hide()

-- Initialize UI elements
pvpStatsFrame.title = pvpStatsFrame:CreateFontString(nil, "OVERLAY")
pvpStatsFrame.title:SetFontObject("GameFontHighlight")
pvpStatsFrame.title:SetPoint("TOP", pvpStatsFrame, "TOP", 0, -7)
pvpStatsFrame.title:SetText("PVP Stats")

local LEFT_MARGIN = -70  
local VERTICAL_GAP = -15  

local function createStatLabelAndValue(parent, labelText, previousElement, yOffset)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    if previousElement == parent.title then
        label:SetPoint("TOPLEFT", previousElement, "BOTTOMLEFT", LEFT_MARGIN, yOffset)  
    else
        label:SetPoint("TOPLEFT", previousElement, "BOTTOMLEFT", 0, yOffset)  
    end
    label:SetText(labelText)
    label:SetTextColor(0, 1, 0)

    local value = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    value:SetPoint("LEFT", label, "RIGHT", 5, 0)  -- Small gap between label and value
    value:SetTextColor(1, 0.84, 0)

    return label, value
end

pvpStatsFrame.honorableKillsLabel, pvpStatsFrame.honorableKillsValue = createStatLabelAndValue(pvpStatsFrame, "Lifetime Honorable Kills:", pvpStatsFrame.title, VERTICAL_GAP)
pvpStatsFrame.conquestLabel, pvpStatsFrame.conquestValue = createStatLabelAndValue(pvpStatsFrame, "Conquest Points:", pvpStatsFrame.honorableKillsLabel, VERTICAL_GAP)
pvpStatsFrame.honorLabel, pvpStatsFrame.honorValue = createStatLabelAndValue(pvpStatsFrame, "Honor Points:", pvpStatsFrame.conquestLabel, VERTICAL_GAP)
pvpStatsFrame.honorLevelLabel, pvpStatsFrame.honorLevelValue = createStatLabelAndValue(pvpStatsFrame, "Honor Level:", pvpStatsFrame.honorLabel, VERTICAL_GAP)
pvpStatsFrame.conquestCapLabel, pvpStatsFrame.conquestCapValue = createStatLabelAndValue(pvpStatsFrame, "Conquest Cap:", pvpStatsFrame.honorLevelLabel, VERTICAL_GAP)

-- Function to update PvP stats
local function UpdatePvPStatsFrame()
    local conquestInfo = C_CurrencyInfo.GetCurrencyInfo(CONQUEST_CURRENCY_ID)
    local honorInfo = C_CurrencyInfo.GetCurrencyInfo(HONOR_CURRENCY_ID)
    local lifetimeHonorableKills, _ = GetPVPLifetimeStats()
    local honorLevel = UnitHonorLevel("player")

    pvpStatsFrame.honorableKillsValue:SetText(lifetimeHonorableKills)
    pvpStatsFrame.conquestValue:SetText(conquestInfo.quantity)
    pvpStatsFrame.honorValue:SetText(honorInfo.quantity)
    pvpStatsFrame.honorLevelValue:SetText(honorLevel)

    local weeklyMaxConquest = conquestInfo.maxWeeklyQuantity
    local conquestCapText = conquestInfo.quantity .. " / " .. weeklyMaxConquest
    pvpStatsFrame.conquestCapValue:SetText(conquestCapText)
end

-- Event handling
pvpStatsFrame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
pvpStatsFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
pvpStatsFrame:SetScript("OnEvent", UpdatePvPStatsFrame)
pvpStatsFrame:SetScript("OnShow", UpdatePvPStatsFrame)

pvpStatsFrame:SetScript("OnEvent", function(self, event, ...)
    UpdatePvPStatsFrame()
end)
pvpStatsFrame:SetScript("OnShow", UpdatePvPStatsFrame)

local function ShowRaidWarning(message, duration)
   
    if IncDB.enableRaidWarnings then
        customRaidWarningFrame.text:SetText(message)
        customRaidWarningFrame.text:SetTextColor(1, 0, 0) -- Set text color to red
        customRaidWarningFrame:Show()
    
        C_Timer.After(duration or 5, function() 
            customRaidWarningFrame:Hide()
        end)
    end
end

local colorOptions = {
    { name = "Semi-Transparent Black", color = {0, 0, 0, 0.5} },
    { name = "Solid Black", color = {0, 0, 0, 1} },
    { name = "Semi-Transparent White", color = {1, 1, 1, 0.5} },
    { name = "Solid White", color = {1, 1, 1, 1} },
    { name = "Semi-Transparent Red", color = {1, 0, 0, 0.5} },
    { name = "Solid Red", color = {1, 0, 0, 1} },
    { name = "Semi-Transparent Green", color = {0, 1, 0, 0.5} },
    { name = "Solid Green", color = {0, 1, 0, 1} },
    { name = "Semi-Transparent Blue", color = {0, 0, 1, 0.5} },
    { name = "Solid Blue", color = {0, 0, 1, 1} },
    { name = "Semi-Transparent Yellow", color = {1, 1, 0, 0.5} },
    { name = "Solid Yellow", color = {1, 1, 0, 1} },
    { name = "Semi-Transparent Cyan", color = {0, 1, 1, 0.5} },
    { name = "Solid Cyan", color = {0, 1, 1, 1} },
    { name = "Semi-Transparent Magenta", color = {1, 0, 1, 0.5} },
    { name = "Solid Magenta", color = {1, 0, 1, 1} },
    { name = "Semi-Transparent Orange", color = {1, 0.5, 0, 0.5} },
    { name = "Solid Orange", color = {1, 0.5, 0, 1} },
    { name = "Semi-Transparent Purple", color = {0.5, 0, 0.5, 0.5} },
    { name = "Solid Purple", color = {0.5, 0, 0.5, 1} },
    { name = "Semi-Transparent Grey", color = {0.5, 0.5, 0.5, 0.5} },
    { name = "Solid Grey", color = {0.5, 0.5, 0.5, 1} },
    { name = "Semi-Transparent Teal", color = {0, 0.5, 0.5, 0.5} },
    { name = "Solid Teal", color = {0, 0.5, 0.5, 1} },
    { name = "Semi-Transparent Pink", color = {1, 0.75, 0.8, 0.5} },
    { name = "Solid Pink", color = {1, 0.75, 0.8, 1} },
	
}

local borderOptions = {
    { name = "Azerite", file = "Interface/Tooltips/UI-Tooltip-Border-Azerite" },
    { name = "Classic", file = "Interface/Tooltips/UI-Tooltip-Border" },
    { name = "Sleek", file = "Interface/DialogFrame/UI-DialogBox-Border" },
    { name = "Corrupted", file = "Interface/Tooltips/UI-Tooltip-Border-Corrupted" },
    { name = "Maw", file = "Interface/Tooltips/UI-Tooltip-Border-Maw" },
    { name = "Smooth", file = "Interface/LFGFRAME/LFGBorder" },
	{ name = "Glass", file = "Interface/DialogFrame/UI-DialogBox-TestWatermark-Border" },
	{ name = "Gold", file = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border" },
	{ name = "Slide", file = "Interface\\FriendsFrame\\UI-Toast-Border" },
	{ name = "Glow", file = "Interface\\TutorialFrame\\UI-TutorialFrame-CalloutGlow" },
	{ name = "Glow 2", file = "Interface\\AddOns\\IncCallout\\Textures\\BG15.blp" },
	{ name = "Grey", file = "Interface\\Tooltips\\UI-Tooltip-Background" },
	{ name = "Blue", file = "Interface\\AddOns\\IncCallout\\Textures\\BG1.png" },
	{ name = "Black Gloss", file = "Interface\\AddOns\\IncCallout\\Textures\\BG2.blp" },
	{ name = "Silverish", file = "Interface\\AddOns\\IncCallout\\Textures\\BG3.blp" },
	{ name = "Bevel", file = "Interface\\AddOns\\IncCallout\\Textures\\BG4.blp" },
	{ name = "Bevel 2", file = "Interface\\AddOns\\IncCallout\\Textures\\BG5.blp" },
	{ name = "Fade", file = "Interface\\AddOns\\IncCallout\\Textures\\BG6.blp" },
	{ name = "Fade 2", file = "Interface\\AddOns\\IncCallout\\Textures\\BG7.blp" },
	{ name = "Thin Line", file = "Interface\\AddOns\\IncCallout\\Textures\\BG8.blp" },
	{ name = "2 Tone", file = "Interface\\AddOns\\IncCallout\\Textures\\BG9.blp" },
	{ name = "Bluish", file = "Interface\\AddOns\\IncCallout\\Textures\\BG10.blp" },
	{ name = "Neon Yellow", file = "Interface\\AddOns\\IncCallout\\Textures\\BG11.blp" },
	{ name = "Neon Red", file = "Interface\\AddOns\\IncCallout\\Textures\\BG12.blp" },
	{ name = "Neon Green", file = "Interface\\AddOns\\IncCallout\\Textures\\BG13.blp" },
	{ name = "Neon Blue", file = "Interface\\AddOns\\IncCallout\\Textures\\BG14.blp" },
	{ name = "Double Yellow", file = "Interface\\AddOns\\IncCallout\\Textures\\BG16.blp" },
			
}
 
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
        "[Incoming-BG] We need more peeps",
        "[Incoming-BG] Need help",
        "[Incoming-BG] We are outnumbered",
        "[Incoming-BG] Need a few more",
        "[Incoming-BG] Need more",
        "[Incoming-BG] Backup required",
        "[Incoming-BG] We could use some help",
        "[Incoming-BG] Calling for backup",
        "[Incoming-BG] Could use some backup",
        "[Incoming-BG] Reinforcements needed",
        "[Incoming-BG] In need of additional support",
        "[Incoming-BG] Calling all hands on deck",
        "[Incoming-BG] Require extra manpower",
        "[Incoming-BG] Assistance urgently needed",
        "[Incoming-BG] Requesting more participants",
        
    },
    inc = {
        "[Incoming-BG] Incoming",
        "[Incoming-BG] INC INC INC",
        "[Incoming-BG] INC",
        "[Incoming-BG] Gotta INC",
        "[Incoming-BG] BIG INC",
        "[Incoming-BG] Incoming enemy forces",
        "[Incoming-BG] Incoming threat",
        "[Incoming-BG] Enemy push incoming",
        "[Incoming-BG] Enemy blitz incoming",
        "[Incoming-BG] Enemy strike team inbound",
        "[Incoming-BG] Incoming attack alert",
        "[Incoming-BG] Enemy wave inbound",
        "[Incoming-BG] Enemy squad closing in",
        "[Incoming-BG] Anticipate enemy push",
        "[Incoming-BG] Enemy forces are closing in",
        
    },
    allClear = {
        "[Incoming-BG] We are all clear",
        "[Incoming-BG] All clear",
        "[Incoming-BG] Looks like a ghost town",
        "[Incoming-BG] All good",
        "[Incoming-BG] Looking good",
        "[Incoming-BG] Area secure",
        "[Incoming-BG] All quiet on the front",
        "[Incoming-BG] Situation is under control",
        "[Incoming-BG] All quiet here",
        "[Incoming-BG] We are looking good",
        "[Incoming-BG] Perimeter is secured",
        "[Incoming-BG] Situation is calm",
        "[Incoming-BG] No threats detected",
        "[Incoming-BG] All quiet on this end",
        "[Incoming-BG] Area is threat-free",
        
    },
    buffRequest = {
    "[Incoming-BG] Need buffs please!",
    "[Incoming-BG] Buff up, team!",
    "[Incoming-BG] Could use some buffs here!",
    "[Incoming-BG] Calling for all buffs, let's gear up!",
    "[Incoming-BG] Looking for that magical boost, buffs needed!",
    "[Incoming-BG] Time to get enchanted, where are those buffs?",
    "[Incoming-BG] Let’s get buffed for the battle ahead!",
    "[Incoming-BG] Buffs are our best friends, let’s have them!",
    "[Incoming-BG] Ready for buffs, let's enhance our strength!",
    "[Incoming-BG] Buffs needed for extra might and magic!",
    "[Incoming-BG] Gimme some buffs, let’s not fall behind!"
    
	},
	hmd = {
    "[Incoming-BG] Focus healers!",
    "[Incoming-BG] Take down healers!",
    "[Incoming-BG] Target healers to win!",
    "[Incoming-BG] Healers must die!",
    "[Incoming-BG] Eliminate healers fast!",
    "[Incoming-BG] Healers top priority!",
    "[Incoming-BG] Attack healers!",
    "[Incoming-BG] Healers spotted, engage!",
    "[Incoming-BG] Priority: healers!",
    "[Incoming-BG] Remove healers for win!"
    
   }
 } 
 
local IncCallout = CreateFrame("Frame", "IncCalloutMainFrame", UIParent, "BackdropTemplate")
IncCallout:SetSize(160, 255)
IncCallout:SetPoint("CENTER")
IncCallout:SetMovable(true)
IncCallout:EnableMouse(true)
IncCallout:RegisterForDrag("LeftButton")
IncCallout:SetScript("OnDragStart", IncCallout.StartMoving)
IncCallout:SetScript("OnDragStop", IncCallout.StopMovingOrSizing)

-- Define available logos
local logos = {
    None = "",
    BearClaw = "Interface\\AddOns\\IncCallout\\Textures\\BearClaw.png",
    BreatheFire = "Interface\\AddOns\\IncCallout\\Textures\\BreatheFire.png",
    Bloody = "Interface\\AddOns\\IncCallout\\Textures\\Bloody.png",
    Impact = "Interface\\AddOns\\IncCallout\\Textures\\Impact.png",
    Shock = "Interface\\AddOns\\IncCallout\\Textures\\Shock.png",
    Rifle = "Interface\\AddOns\\IncCallout\\Textures\\Rifle.png",
    Condiment = "Interface\\AddOns\\IncCallout\\Textures\\Condiment.png",
    Duplex = "Interface\\AddOns\\IncCallout\\Textures\\Duplex.png",
    Eraser = "Interface\\AddOns\\IncCallout\\Textures\\Eraser.png",
    Ogre = "Interface\\AddOns\\IncCallout\\Textures\\Ogre.png",
	Seagram = "Interface\\AddOns\\IncCallout\\Textures\\Seagram.png",
	SuperSunday = "Interface\\AddOns\\IncCallout\\Textures\\SuperSunday.png",
	Minion = "Interface\\AddOns\\IncCallout\\Textures\\Minion.png",
	Fire = "Interface\\AddOns\\IncCallout\\Textures\\Fire.png",
	GOW = "Interface\\AddOns\\IncCallout\\Textures\\GOW.png",
	Maiden = "Interface\\AddOns\\IncCallout\\Textures\\Maiden.png",
	Metal = "Interface\\AddOns\\IncCallout\\Textures\\Metal.png",
	Alligator = "Interface\\AddOns\\IncCallout\\Textures\\Alligator.png",
	SourceCode = "Interface\\AddOns\\IncCallout\\Textures\\SourceCode.png",
	InkFree = "Interface\\AddOns\\IncCallout\\Textures\\InkFree.png",
}

-- Initial logo setup
local logo = IncCallout:CreateTexture(nil, "ARTWORK")
logo:SetSize(180, 30)
logo:SetPoint("TOP", IncCallout, "TOP", -5, 30)
logo:SetTexture(logos.BearClaw) -- Default logo

function IncCallout:SetLogo(selectedLogo)
    if selectedLogo == "None" then
        logo:Hide()  
    else
        local path = logos[selectedLogo]
        if path then
            logo:SetTexture(path)
            logo:Show()
        else
            print("Logo path not found for:", selectedLogo)
        end
    end
end

local fontSize = 14

local bgTexture = IncCallout:CreateTexture(nil, "BACKGROUND")
bgTexture:SetColorTexture(0, 0, 0)
bgTexture:SetAllPoints(IncCallout)

IncCallout:SetScript("OnDragStart", function(self)
    if not IncDB.isLocked then
        self:StartMoving()
    end
end)

IncCallout:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    
    if not IncDB.isLocked then
               
    end
end)

-- Function to create a button
local function createButton(name, width, height, text, anchor, xOffset, yOffset, onClick)
    local button = CreateFrame("Button", nil, IncCallout, "BackdropTemplate")
    button:SetSize(width, height)
    button:SetText(text)
    if type(anchor) == "table" then
        button:SetPoint(anchor[1], anchor[2], anchor[3], xOffset, yOffset)
    else
        button:SetPoint(anchor, xOffset, yOffset)
    end
    button:GetFontString():SetTextColor(1, 1, 1, 1)
    button:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 12,
        edgeSize = 7,  
        insets = {left = 1, right = 1, top = 1, bottom = 1}
    })

    table.insert(buttonTexts, button:GetFontString())
    table.insert(buttons, button)
	
    button:SetScript("OnMouseDown", function(self)
        self:SetBackdropColor(0, 0, 0, 0) 
    end)
    button:SetScript("OnMouseUp", function(self, mouseButton)
        if mouseButton == "LeftButton" then
            self:SetBackdropColor(0, 0, 0, 0)
        end
    end)
    
    button:SetScript("OnClick", function(self, mouseButton, down)
        if mouseButton == "LeftButton" and not down then
            if useCustomSound then
                if IncDB.raidWarningSound and type(IncDB.raidWarningSound) == "number" then
                    PlaySound(IncDB.raidWarningSound, "master")
                else
                    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
                end
            end

            if onClick then 
                onClick(self)
            end
        end
    end)

    return button
end

local function applyButtonColor()

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
    end
end

IncCallout:SetScript("OnShow", function()
    if IncDB then
        applyButtonColor()
    end
end)

local function applyBorderChange()
    local selectedIndex = IncDB.selectedBorderIndex or 1
    local selectedBorder = borderOptions[selectedIndex].file

    local backdropSettings = {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = selectedBorder,
        tile = false,
        tileSize = 16,
        edgeSize = 8,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    }

    IncCallout:SetBackdrop(backdropSettings)
	
end

local function applyColorChange()
    local selectedIndex = IncDB.selectedColorIndex or 1
    local selectedColor = colorOptions[selectedIndex].color

    IncCallout:SetBackdropColor(unpack(selectedColor))
end

local function ScaleGUI()
    local scaleFactor = IncDB.scale or 1; -- Default scale is 1
    IncCallout:SetScale(scaleFactor);
    
    local adjustedFontSize = math.floor(fontSize * scaleFactor);
      
    for _, buttonText in ipairs(buttonTexts) do
        buttonText:SetFont("Fonts\\FRIZQT__.TTF", adjustedFontSize);
    end
end

local mapSizeOptions = {
    { name = "Very Small", value = 0.4 },
    { name = "Small", value = 0.5 },
    { name = "Medium Small", value = 0.65 },
    { name = "Medium", value = 0.75 }, -- Assuming this is the current default
    { name = "Medium Large", value = 0.85 },
    { name = "Large", value = 1.0 },
    { name = "Very Large", value = 1.15 },
    { name = "Huge", value = 1.3 },
    { name = "Gigantic", value = 1.45 },
    { name = "Colossal", value = 1.6 }
}

local soundOptions = {
    [8959] = "Raid Warning", 
    [8459] = "PVP Que ", 
    [15266] = "Whistle", 
    [12867] = "Horn", 
    [9656] = "Laughing", 
	[888] = "Level Up", 
	[8960] = "Ready Check", 
	[880] = "Drums", 
	[9379] = "PVP Flag", 
	[89880] = "Fireworks", 
	[176304] = "Launcher", 
	[34154] = "Challenge", 
	[12867] = "Alarm", 
	[161485] = "Lightning", 
	["none"] = "No sound",
}

local options = {
    name = "Incoming-BG",
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
    get = function() return IncDB.sendMoreIndex end,  -- Directly use IncDB to get the current value
    set = function(_, newValue)
        IncDB.sendMoreIndex = newValue  -- Directly use IncDB to save the new value
        LibStub("AceConfigRegistry-3.0"):NotifyChange("IncCallout")
    end,
    order = 1,
},
previewSendMore = {
    type = "description",
    name = function() return "|cff00ff00Preview: " .. addonNamespace.getPreviewText("sendMore") .. "|r" end,
    fontSize = "medium",
    order = 1.1,
},
inc = {
    type = "select",
    name = "INC Message",
    desc = "Select the message for the 'INC' button",
    values = buttonMessages.inc,
    get = function() return IncDB.incIndex end,  -- Directly use IncDB to get the current value
    set = function(_, newValue)
        IncDB.incIndex = newValue  -- Directly use IncDB to save the new value
        LibStub("AceConfigRegistry-3.0"):NotifyChange("IncCallout")
    end,
    order = 2,
},
previewInc = {
    type = "description",
    name = function() return "|cff00ff00Preview: " .. addonNamespace.getPreviewText("inc") .. "|r" end,
    fontSize = "medium",
    order = 2.1,
},
allClear = {
    type = "select",
    name = "All Clear Message",
    desc = "Select the message for the 'All Clear' button",
    values = buttonMessages.allClear,
    get = function() return IncDB.allClearIndex end,  -- Directly use IncDB to get the current value
    set = function(_, newValue)
        IncDB.allClearIndex = newValue  -- Directly use IncDB to save the new value
        LibStub("AceConfigRegistry-3.0"):NotifyChange("IncCallout")
    end,
    order = 3,
},
previewAllClear = {
    type = "description",
    name = function() return "|cff00ff00Preview: " .. addonNamespace.getPreviewText("allClear") .. "|r" end,
    fontSize = "medium",
    order = 3.1,
                },
                buffRequest = {
    type = "select",
    name = "Buff Request Message",
    desc = "Select the message for the 'Request Buffs' button",
    values = buttonMessages.buffRequest,
    get = function() return IncDB.buffRequestIndex end,
    set = function(_, newValue)
        buttonMessageIndices.buffRequest = newValue
        IncDB.buffRequestIndex = newValue
        LibStub("AceConfigRegistry-3.0"):NotifyChange("IncCallout")
    end,
    order = 4,
},
previewBuffRequest = {
    type = "description",
    name = function() return addonNamespace.getPreviewText("buffRequest") end,
    fontSize = "medium",
    order = 4.1,
},
hmd = {
    type = "select",
    name = "H.M.D. Message",
    desc = "Select the message for the 'H.M.D.' button",
    values = buttonMessages.hmd,
    get = function() return IncDB.hmdIndex end,
    set = function(_, newValue)
        buttonMessageIndices.hmd = newValue
        IncDB.hmdIndex = newValue
        LibStub("AceConfigRegistry-3.0"):NotifyChange("IncCallout")
    end,
    order = 5,
},
previewHMD = {
    type = "description",
    name = function() return addonNamespace.getPreviewText("hmd") end,
    fontSize = "medium",
    order = 5.1, 
                },
            },
        },
        appearanceSettings = {
    type = "group",
    name = "Appearance Settings",
    order = 2,
    args = {
        fontColor = {
    type = "color",
    name = "Button Font Color",
    desc = "Set the color of the button text.",
    hasAlpha = true,
    get = function()
        local color = IncDB.fontColor or {r = 1, g = 1, b = 1, a = 1} -- default white
        return color.r, color.g, color.b, color.a
    end,
    set = function(_, r, g, b, a)
        IncDB.fontColor = {r = r, g = g, b = b, a = a}
        -- Apply the color immediately
        for _, buttonText in ipairs(buttonTexts) do
            buttonText:SetTextColor(r, g, b, a)
        end
    end, 
    order = 1, 	
                                    },
                    buttonColor = {
                                type = "color",
                                name = "Button Color",
                                desc = "Select the color of the buttons.",
                                order = 2,
                                hasAlpha = true, 
                                get = function()
                                    local currentColor = IncDB.buttonColor or {r = 1, g = 0, b = 0, a = 1} -- Default to red
                                    return currentColor.r, currentColor.g, currentColor.b, currentColor.a
                                 end,
                                 set = function(_, r, g, b, a)
                                 local color = {r = r, g = g, b = b, a = a}
                                 IncDB.buttonColor = color
                                 applyButtonColor()
                                 end,
        },
        scaleOption = {
                    type = "range",
                    name = "GUI Window Scale",
                    desc = "Adjust the scale of the GUI.",
                    min = 0.5, 
                    max = 2.0, 
                    step = 0.05, 
                    get = function()
                    return IncDB.scale or 1 
                 end,
                   set = function(_, value)
                   IncDB.scale = value
                   ScaleGUI(value) 
                end,
        },
        borderStyle = {
            type = "select",
            name = "Border Style",
            desc = "Select the border style for the frame.",
            style = "dropdown",
            order = 3,
            values = function()
                local values = {}
                for i, option in ipairs(borderOptions) do
                    values[i] = option.name
                end
                return values
            end,
            get = function()
                return IncDB.selectedBorderIndex or 1
            end,
            set = function(_, selectedIndex)
                IncDB.selectedBorderIndex = selectedIndex
                applyBorderChange()
                applyColorChange()
            end,
        },
        backdropColor = {
            type = "select",
            name = "Backdrop Color",
            desc = "Select the backdrop color and transparency for the frame.",
            style = "dropdown",
            order = 4,
            values = function()
                local values = {}
                for i, option in ipairs(colorOptions) do
                    values[i] = option.name
                end
                return values
            end,
            get = function()
                return IncDB.selectedColorIndex or 1
            end,
            set = function(_, selectedIndex)
                IncDB.selectedColorIndex = selectedIndex
                applyColorChange()
            end,
        },
        enableRaidWarnings = {
            type = "toggle",
            name = "Enable Raid Warnings",
            desc = "Toggle Raid Warning Messages on or off.",
            order = 5,
            get = function() return IncDB.enableRaidWarnings end,
            set = function(_, value)
                IncDB.enableRaidWarnings = value
                -- Function to toggle raid warnings
            end,
        },
        raidWarningSound = {
            type = "select",
            name = "Raid Warning Sound",
            desc = "Select the sound to play for Raid Warnings.",
            order = 6,
            values = soundOptions,
            get = function() return IncDB.raidWarningSound end,
            set = function(_, selectedValue)
                IncDB.raidWarningSound = selectedValue
                -- Play the sound here as a preview using SoundKit ID
                if selectedValue and type(selectedValue) == "number" then
                    PlaySound(selectedValue, "master")
                end
            end,
        },
        lockGUI = {
            type = "toggle",
            name = "Lock GUI Window",
            desc = "Lock or unlock the GUI window's position.",
            order = 7,
            get = function() return IncDB.isLocked end,
            set = function(_, value)
                IncDB.isLocked = value
                -- Function to lock or unlock the GUI window
            end,
			},
			logoSelection = {
    type = "select",
    name = "Logo Selection",
    desc = "Choose a logo to display at the top of the frame.",
    style = "dropdown",
    order = 8,
    values = {
        ["None"] = "None",
        ["BearClaw"] = "BearClaw",
        ["BreatheFire"] = "BreatheFire",
        ["Bloody"] = "Bloody",
        ["Impact"] = "Impact",
        ["Shock"] = "Shock",
        ["Rifle"] = "Rifle",
        ["Condiment"] = "Condiment",
        ["Duplex"] = "Duplex",
        ["Eraser"] = "Eraser",
        ["Ogre"] = "Ogre",
        ["Seagram"] = "Seagram",
		["SuperSunday"] = "SuperSunday",
		["Minion"] = "Minion",
		["Alligator"] = "Alligator",
		["Fire"] = "Fire",
		["GOW"] = "GOW",
		["Maiden"] = "Maiden",
		["Metal"] = "Metal",
		["SourceCode"] = "SourceCode",
		["InkFree"] = "InkFree",
    },
    get = function(info) return IncDB.selectedLogo end,
    set = function(info, value)
        IncDB.selectedLogo = value
        IncCallout:SetLogo(value)  
    end,
	},
	logoColor = {
    type = "color",
    name = "Logo Color",
    desc = "Set the color of the title logo.",
    hasAlpha = true, 
    get = function(info)
        local color = IncDB.logoColor or {1, 1, 1, 1} -- Default to white if not set
        return color.r, color.g, color.b, color.a
    end,
    set = function(info, r, g, b, a)
        IncDB.logoColor = {r = r, g = g, b = b, a = a}
        
        logo:SetVertexColor(r, g, b, a)
    end,
    order = 9, 
        },
    },
},

        mapSettings = {
            type = "group",
            name = "Map Settings",
            order = 3,
            args = {
                	mapSizeChoice = {
                    type = "select",
                    name = "Map Size",
                    desc = "Select the preferred size of the WorldMap.",
                    order = 6,
                    style = "dropdown",
                    values = function()
                        local values = {}
                        for _, sizeOption in ipairs(mapSizeOptions) do
                            values[sizeOption.value] = sizeOption.name
                        end
                        return values
                    end,
                    get = function() return IncCalloutDB.settings.mapScale end,
                    set = function(_, selectedValue)
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
                    order = 7,
                    get = function() return IncCalloutDB.settings.resizeInPvPOnly end,
                    set = function(_, value)
                        IncCalloutDB.settings.resizeInPvPOnly = value
                        if addonNamespace.ResizeWorldMap then
                            addonNamespace.ResizeWorldMap()
                        end
                    end,
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
            },
        },
    },
}
-- Register the options table
AceConfig:RegisterOptionsTable(addonName, options)

-- Create a config panel
local configPanel = AceConfigDialog:AddToBlizOptions(addonName, "Incoming-BG")
configPanel.default = function()
    buttonMessageIndices.sendMore = 1
    buttonMessageIndices.inc = 1
    buttonMessageIndices.allClear = 1
	buttonMessageIndices.buffRequest = 1
	buttonMessageIndices.hmd = IncDB.hmdIndex or 1
	IncDB.selectedBorderIndex = 1

end

function addonNamespace.getPreviewText(messageType)
    local previewText = "|cff00ff00[Incoming-BG] "

    if messageType == "sendMore" and IncDB.sendMoreIndex and buttonMessages.sendMore[IncDB.sendMoreIndex] then
        previewText = previewText .. buttonMessages.sendMore[IncDB.sendMoreIndex]
    elseif messageType == "inc" and IncDB.incIndex and buttonMessages.inc[IncDB.incIndex] then
        previewText = previewText .. buttonMessages.inc[IncDB.incIndex]
    elseif messageType == "allClear" and IncDB.allClearIndex and buttonMessages.allClear[IncDB.allClearIndex] then
        previewText = previewText .. buttonMessages.allClear[IncDB.allClearIndex]
    elseif messageType == "buffRequest" and IncDB.buffRequestIndex and buttonMessages.buffRequest[IncDB.buffRequestIndex] then
        previewText = previewText .. buttonMessages.buffRequest[IncDB.buffRequestIndex]
    elseif messageType == "hmd" and IncDB.hmdIndex and buttonMessages.hmd[IncDB.hmdIndex] then
        previewText = previewText .. buttonMessages.hmd[IncDB.hmdIndex]
    end

    return previewText .. "|r"  
end

local function ListHealers()
    local groupType, groupSize
    if IsInRaid() then
        groupType = "raid"
        groupSize = GetNumGroupMembers()
    elseif IsInGroup() then
        groupType = "party"
        groupSize = GetNumGroupMembers() 
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
        SendChatMessage("[Incoming-BG] Healers on our team: " .. healerList .. ". Now you know who to peel for.", "INSTANCE_CHAT")

    else
        if IsInGroup() or IsInRaid() then
            SendChatMessage("[Incoming-BG] We have no heals, lol..", "INSTANCE_CHAT")
        end
    end
end

local healerButton = createButton(
    "healerButton",
    70, 22,
    "Healers",
    {"BOTTOMLEFT", IncCallout, "BOTTOMLEFT"},
    0, -27,
    function(self, button)
       
        PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
        
        ListHealers()
    end
    
)

local healsButton = createButton(
    "healsButton",
    70, 22,
    "H.M.D.",
    {"BOTTOMLEFT", healerButton, "BOTTOMRIGHT"},
    20, 0,
    function() 
        
        PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    end,
    false 
)

local function HMDButtonOnClick()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    local message = buttonMessages.hmd[buttonMessageIndices.hmd]
       
    local isInInstance, instanceType = IsInInstance()
    
    if isInInstance then
       
        local chatType = IsInRaid(LE_PARTY_CATEGORY_INSTANCE) and "RAID" or "PARTY"
        SendChatMessage(message, chatType)
    else
        print("You're not in an instance group.")
    end
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

    if IncDB.raidWarningSound and type(IncDB.raidWarningSound) == "number" then
        PlaySound(IncDB.raidWarningSound, "master")
    end

    local currentLocation = GetSubZoneText()
   
    local message = "[Incoming-BG] " .. self:GetText() .. " Incoming at " .. currentLocation
    SendChatMessage(message, "INSTANCE_CHAT")
    ShowRaidWarning(message, 2)
end

local f = CreateFrame("Frame")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")



local function UpdatePoints()

    if not IncDB then
        return
    end

    local conquestInfo = C_CurrencyInfo.GetCurrencyInfo(CONQUEST_CURRENCY_ID)
    local honorInfo = C_CurrencyInfo.GetCurrencyInfo(HONOR_CURRENCY_ID)

   
end

IncCallout:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
IncCallout:RegisterEvent("HONOR_XP_UPDATE")
IncCallout:SetScript("OnEvent", function(self, event, ...)
    if event == "CURRENCY_DISPLAY_UPDATE" or event == "HONOR_XP_UPDATE" then
        UpdatePoints()
		ApplyFontSettings()
    end
end)

UpdatePoints()

f:SetScript("OnEvent", function(self, event, ...)
    if event == "ZONE_CHANGED_NEW_AREA" then
        local currentLocation = GetRealZoneText() .. " - " .. GetSubZoneText()
        local location = locationTable[currentLocation]
 
        if location then
            IncCallout:Show()  
        else
            
        end
    end
end)

local IncCalloutLDB = LibStub("LibDataBroker-1.1"):NewDataObject("Incoming-BG", {
    type = "data source",
    text = "Incoming-BG",
    icon = "Interface\\AddOns\\IncCallout\\Icon\\INC.png",
    OnClick = function(_, button)
        if button == "LeftButton" then
            if IncCallout:IsShown() then
                IncCallout:Hide()
            else
                IncCallout:Show()
            end
        else
            InterfaceOptionsFrame_OpenToCategory("Incoming-BG")
            InterfaceOptionsFrame_OpenToCategory("Incoming-BG") -- Call it twice to ensure the correct category is selected
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
        tooltip:AddLine("|cffff0000Incoming-BG|r")
        tooltip:AddLine("Left Click: GUI")
        tooltip:AddLine("Right Click: Options")
        tooltip:Show()
    end,
})
 
-- Function to handle the All Clear button click event
local function AllClearButtonOnClick()
    
    if IncDB.raidWarningSound and IncDB.raidWarningSound ~= "none" and type(IncDB.raidWarningSound) == "number" then
        PlaySound(IncDB.raidWarningSound, "master")
    else
        PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    end

    local location = GetSubZoneText()
    if not location then
        print("You are not in a Battleground.")
        return
    end

    local message = buttonMessages.allClear[buttonMessageIndices.allClear] .. " at " .. location
    SendChatMessage(message, "INSTANCE_CHAT")
    ShowRaidWarning(message, 2)
end

-- Function to handle the Send More button click event
local function SendMoreButtonOnClick()
    
    if IncDB.raidWarningSound and IncDB.raidWarningSound ~= "none" and type(IncDB.raidWarningSound) == "number" then
        PlaySound(IncDB.raidWarningSound, "master")
    else
        PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    end

    local location = GetSubZoneText()
    if not location then
        print("You are not in a Battleground.")
        return
    end

    local message = buttonMessages.sendMore[buttonMessageIndices.sendMore] .. " at " .. location
    SendChatMessage(message, "INSTANCE_CHAT")
    ShowRaidWarning(message, 2)
end

-- Function to handle the INC button click event
local function IncButtonOnClick()
    
    if IncDB.raidWarningSound and IncDB.raidWarningSound ~= "none" and type(IncDB.raidWarningSound) == "number" then
        PlaySound(IncDB.raidWarningSound, "master")
    else
        PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    end

    local location = GetSubZoneText()
    if not location then
        print("You are not in a Battleground.")
        return
    end

    local message = buttonMessages.inc[buttonMessageIndices.inc] .. " at " .. location
    SendChatMessage(message, "INSTANCE_CHAT")
    ShowRaidWarning(message, 2)
end

local function onChatMessage(message)
    if string.find(message, "%[Incoming%-BG%]") then
        PlaySound(SOUNDKIT.RAID_WARNING, "master")
    end
end

local function ApplyFontSettings()
    if not IncDB then return end

    IncDB.font = IncDB.font or "Friz Quadrata TT"  
    IncDB.fontSize = IncDB.fontSize or 14  -- Default font size

    local fontPath = LSM:Fetch("font", IncDB.font) or STANDARD_TEXT_FONT  -- Fallback to a default font if nil
    local fontSize = IncDB.fontSize

    for _, text in ipairs(buttonTexts) do
        if fontPath and fontSize then
            text:SetFont(fontPath, fontSize)
        end
    end

    -- Check for valid conquest and honor font settings
    local conquestFontPath = LSM:Fetch("font", IncDB.conquestFont) or STANDARD_TEXT_FONT
    local honorFontPath = LSM:Fetch("font", IncDB.honorFont) or STANDARD_TEXT_FONT

    if conquestPointsLabel and conquestFontPath and IncDB.conquestFontSize then
        conquestPointsLabel:SetFont(conquestFontPath, IncDB.conquestFontSize)
        conquestPointsLabel:SetTextColor(IncDB.conquestFontColor.r, IncDB.conquestFontColor.g, IncDB.conquestFontColor.b, IncDB.conquestFontColor.a)
    end

    if honorPointsLabel and honorFontPath and IncDB.honorFontSize then
        honorPointsLabel:SetFont(honorFontPath, IncDB.honorFontSize)
        honorPointsLabel:SetTextColor(IncDB.honorFontColor.r, IncDB.honorFontColor.g, IncDB.honorFontColor.b, IncDB.honorFontColor.a)
    end
end

local function OnEvent(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20)
    if event == "ADDON_LOADED" and arg1 == "IncCallout" then
        -- Ensure db and IncDB are initialized properly
        db = LibStub("AceDB-3.0"):New("IncCalloutDB", defaults, true)
        IncDB = db.profile or {}
        
        -- Initialize IncDB if it doesn't exist
        if not IncDB then
            IncDB = {
                -- Set your default values here
                buttonColor = {r = 1, g = 0, b = 0, a = 1},
                fontColor = {r = 1, g = 1, b = 1, a = 1},
                -- Add other default settings as needed
            }
        end

        if IncCallout.SetLogo then
            IncCallout:SetLogo(IncDB.selectedLogo or "BearClaw")
        end

        if IncDB.logoColor then
            local color = IncDB.logoColor
            logo:SetVertexColor(color.r, color.g, color.b, color.a)
        end

        if IncDB.fontColor then
            local color = IncDB.fontColor
            for _, buttonText in ipairs(buttonTexts) do
                buttonText:SetTextColor(color.r, color.g, color.b, color.a)
            end
        end

        applyBorderChange()
        applyColorChange()
        ApplyFontSettings()

        if not IncDB.minimap then
            IncDB.minimap = { hide = false, minimapPos = 45 }
        end

        icon:Register("IncCallout", IncCalloutLDB, IncDB.minimap)

    elseif event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        local inInstance, instanceType = IsInInstance()
        if inInstance and (instanceType == "pvp" or instanceType == "arena") then
            IncCallout:Show()
        else
            IncCallout:Hide()
        end
        UpdatePoints()
        ScaleGUI()
        ApplyFontSettings()
        applyButtonColor()

    elseif event == "PLAYER_LEAVING_WORLD" then
        IncCallout:Hide()
        applyButtonColor()

    elseif event == "CURRENCY_DISPLAY_UPDATE" or event == "HONOR_XP_UPDATE" then
        UpdatePoints()

    elseif event == "CHAT_MSG_INSTANCE_CHAT" then
        local message = arg1
        onChatMessage(message)
    end
end

-- Register the function to the frame and events
IncCallout:SetScript("OnEvent", OnEvent)
IncCallout:RegisterEvent("ADDON_LOADED")
IncCallout:RegisterEvent("PLAYER_LOGIN")
IncCallout:RegisterEvent("PLAYER_ENTERING_WORLD")
IncCallout:RegisterEvent("PLAYER_LEAVING_WORLD")  
IncCallout:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
IncCallout:RegisterEvent("HONOR_XP_UPDATE")
IncCallout:RegisterEvent("CHAT_MSG_INSTANCE_CHAT")


local function BuffRequestButtonOnClick()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    local message = buttonMessages.buffRequest[buttonMessageIndices.buffRequest]
  
    local chatType
    if IsInRaid() then
        chatType = "RAID"
    elseif IsInGroup() then
        chatType = "PARTY"
    else
        print("You're not in a group.")
        return 
    end

    SendChatMessage(message, chatType)
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
local showMapButton = createButton("showMapButton", 100, 22, "Show Map", {"TOP", buffRequestButton, "BOTTOM"}, 0, -5, function()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    ToggleWorldMap()
end, false)

local exitButton = createButton("exitButton", 100, 22, "Exit", {"BOTTOM", IncCallout, "BOTTOM"}, 0, 10, function()
    IncCallout:Hide() -- Function to hide the GUI
end)

local pvpStatsButton = createButton("pvpStatsButton", 100, 22, "PVP Stats", {"BOTTOM", exitButton, "TOP"}, 0, 20, function()
    local conquestInfo = C_CurrencyInfo.GetCurrencyInfo(CONQUEST_CURRENCY_ID)
    local honorInfo = C_CurrencyInfo.GetCurrencyInfo(HONOR_CURRENCY_ID)
    local conquestPoints = conquestInfo and conquestInfo.quantity or 0
    local honorPoints = honorInfo and honorInfo.quantity or 0
    print(format("Conquest Points: %s, Honor Points: %s", conquestPoints, honorPoints)) -- Example output
end)

pvpStatsButton:SetScript("OnClick", function()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    local conquestInfo = C_CurrencyInfo.GetCurrencyInfo(CONQUEST_CURRENCY_ID)
    local honorInfo = C_CurrencyInfo.GetCurrencyInfo(HONOR_CURRENCY_ID)
    local conquestPoints = conquestInfo and conquestInfo.quantity or 0
    local honorPoints = honorInfo and honorInfo.quantity or 0
    local honorLevel = UnitHonorLevel("player")
    local lifetimeHonorableKills, _ = GetPVPLifetimeStats()

    -- Set the numeric values
    pvpStatsFrame.honorableKillsValue:SetText(lifetimeHonorableKills)
    pvpStatsFrame.conquestValue:SetText(conquestPoints)
    pvpStatsFrame.honorValue:SetText(honorPoints)
    pvpStatsFrame.honorLevelValue:SetText(honorLevel)  -- Update honor level value here

    -- Show the PVP Stats window
    pvpStatsFrame:Show()
end)
   


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

local function OnAddonLoaded(self, event, loadedAddonName)
    if loadedAddonName == addonName then
        EnsureDBSettings() 
        RestoreMapPositionAndScale()  
        
        if addonNamespace.ResizeWorldMap then
            addonNamespace.ResizeWorldMap()
        end
    end
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