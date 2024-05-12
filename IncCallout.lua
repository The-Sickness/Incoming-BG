-- IncCallout (Rebuild of Incoming-BG)
-- Made by Sharpedge_Gaming
-- v6.5 - 10.2.7

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
IncCalloutDB = IncCalloutDB or {}
addonNamespace.addon = addon
addonNamespace.db = IncDB

local defaults = {
    profile = {
        buttonColor = {r = 1, g = 0, b = 0, a = 1}, -- Default to red
        fontColor = {r = 1, g = 1, b = 1, a = 1},  -- Default to white
        opacity = 1,
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
		buffRequestIndex = 1,
		healRequestIndex = 1,
		efcRequestIndex = 1,
		fcRequestIndex = 1,
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

-- Main GUI Frame
local IncCallout = CreateFrame("Frame", "IncCalloutMainFrame", UIParent, "BackdropTemplate")
IncCallout:SetSize(225, 240)  
IncCallout:SetPoint("CENTER")
IncCallout:SetMovable(true)
IncCallout:EnableMouse(true)
IncCallout:RegisterForDrag("LeftButton")
IncCallout:SetScript("OnDragStart", IncCallout.StartMoving)
IncCallout:SetScript("OnDragStop", IncCallout.StopMovingOrSizing)

local closeButton = CreateFrame("Button", nil, IncCallout, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", IncCallout, "TOPRIGHT", -5, -5)
closeButton:SetSize(24, 24)  
closeButton:SetScript("OnClick", function()
PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    IncCallout:Hide()  
end)

closeButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Close the Window", nil, nil, nil, nil, true)
    GameTooltip:Show()
end)
closeButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Create the PVP Stats window frame
local pvpStatsFrame = CreateFrame("Frame", "PVPStatsFrame", UIParent, "BasicFrameTemplateWithInset")
pvpStatsFrame:SetSize(750, 75)  -- Increased size to accommodate scrolling
pvpStatsFrame:SetPoint("CENTER")
pvpStatsFrame:SetMovable(true)
pvpStatsFrame:EnableMouse(true)
pvpStatsFrame:RegisterForDrag("LeftButton")
pvpStatsFrame:SetScript("OnDragStart", pvpStatsFrame.StartMoving)
pvpStatsFrame:SetScript("OnDragStop", pvpStatsFrame.StopMovingOrSizing)
pvpStatsFrame:Hide()

pvpStatsFrame.playerNameValue = pvpStatsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
pvpStatsFrame.playerNameValue:SetPoint("TOP", pvpStatsFrame.title, "BOTTOM", 0, -10)  -- Adjust the offset as needed
pvpStatsFrame.playerNameValue:SetText("Character Name")

pvpStatsFrame.title = pvpStatsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
pvpStatsFrame.title:SetPoint("TOP", pvpStatsFrame, "TOP", 0, -3)
pvpStatsFrame.title:SetText("PvP Statistics")

local TOP_MARGIN = -25

local function createStatLabelAndValueHorizontal(parent, labelText, xOffset, textColor)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, TOP_MARGIN)
    label:SetText(labelText)
    label:SetTextColor(unpack(textColor))
    
    local value = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    value:SetPoint("TOP", label, "BOTTOM", 0, -2)  
    value:SetTextColor(1, 0.84, 0)
    return label, value
end

pvpStatsFrame.playerNameLabel, pvpStatsFrame.playerNameValue = createStatLabelAndValueHorizontal(pvpStatsFrame, "Player Name:", 10, {1, 1, 1})
pvpStatsFrame.conquestLabel, pvpStatsFrame.conquestValue = createStatLabelAndValueHorizontal(pvpStatsFrame, "Conquest Points:", 130, {0, 0.75, 1})
pvpStatsFrame.honorLabel, pvpStatsFrame.honorValue = createStatLabelAndValueHorizontal(pvpStatsFrame, "Honor Points:", 250, {1, 0.5, 0})
pvpStatsFrame.honorLevelLabel, pvpStatsFrame.honorLevelValue = createStatLabelAndValueHorizontal(pvpStatsFrame, "Honor Level:", 370, {0.58, 0, 0.82})
pvpStatsFrame.conquestCapLabel, pvpStatsFrame.conquestCapValue = createStatLabelAndValueHorizontal(pvpStatsFrame, "Conquest Cap:", 490, {1, 0, 0})
pvpStatsFrame.soloShuffleRatingLabel, pvpStatsFrame.soloShuffleRatingValue = createStatLabelAndValueHorizontal(pvpStatsFrame, "Solo Shuffle Rating:", 610, {0, 0.75, 1})

local SOLO_SHUFFLE_INDEX = 7

-- Update function to handle spec-specific PvP data
local function UpdatePvPStatsFrame()
    if not IsAddOnLoaded("Blizzard_PVPUI") then
        LoadAddOn("Blizzard_PVPUI")
    end

    local conquestInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CONQUEST_CURRENCY_ID)
    local honorInfo = C_CurrencyInfo.GetCurrencyInfo(HONOR_CURRENCY_ID)
    local honorLevel = UnitHonorLevel("player")

    -- Fetch current specialization index
    local specIndex = GetSpecialization()
    local specId = specIndex and select(1, GetSpecializationInfo(specIndex)) or nil
    local rating = specId and GetPersonalRatedInfo(SOLO_SHUFFLE_INDEX) or "N/A"

    -- Update conquest points
    local currentConquestPoints = conquestInfo.quantity
    local totalEarnedConquest = conquestInfo.totalEarned
    local weeklyEarnedConquest = conquestInfo.quantityEarnedThisWeek
    local conquestCap = conquestInfo.maxQuantity
    local displayedConquestProgress = math.min(totalEarnedConquest, conquestCap)

    -- Update PvP stats frame with fetched data
    pvpStatsFrame.conquestValue:SetText(currentConquestPoints)
    pvpStatsFrame.conquestCapValue:SetText(displayedConquestProgress .. " / " .. conquestCap)
    pvpStatsFrame.honorValue:SetText(honorInfo.quantity)
    pvpStatsFrame.honorLevelValue:SetText(honorLevel)
    pvpStatsFrame.soloShuffleRatingValue:SetText(rating)

    -- Adjust PvP UI buttons based on current PvP availability
    local canUseRated = C_PvP.CanPlayerUseRatedPVPUI()
    local canUsePremade = C_LFGInfo.CanPlayerUsePremadeGroup()

    if canUseRated then
        PVPQueueFrame_SetCategoryButtonState(PVPQueueFrame.CategoryButton2, true)
        PVPQueueFrame.CategoryButton2.tooltip = nil
    end

    if canUsePremade then
        PVPQueueFrame_SetCategoryButtonState(PVPQueueFrame.CategoryButton3, true)
        PVPQueueFrame.CategoryButton3.tooltip = nil
    end
end

local function GetDefaultClassColor()
    local _, class = UnitClass("player")
    if class then
        return RAID_CLASS_COLORS[class]
    end
end

local function CreateCharacterDropdown()

    local dropdown = CreateFrame("FRAME", "SelectCharacterDropdown", pvpStatsFrame, "UIDropDownMenuTemplate")
    dropdown:SetPoint("BOTTOMLEFT", pvpStatsFrame, "BOTTOMLEFT", -15, -30)

    UIDropDownMenu_SetWidth(dropdown, 150)
    UIDropDownMenu_SetText(dropdown, "Select Character")

local function OnClick(self)
    UIDropDownMenu_SetSelectedID(dropdown, self:GetID(), true)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    local characterFullName = self:GetText()
    local characterNameOnly = string.match(characterFullName, "^[^%-]+")  -- Extracting the character name before the hyphen
    local stats = IncCalloutDB[characterFullName]

    if stats then
        local classColor = RAID_CLASS_COLORS[stats.class]
        pvpStatsFrame.playerNameValue:SetText(characterNameOnly)
        pvpStatsFrame.playerNameValue:SetTextColor(classColor.r, classColor.g, classColor.b)

        pvpStatsFrame.conquestValue:SetText(stats.conquestValue or "N/A")
        pvpStatsFrame.conquestCapValue:SetText(stats.conquestCapValue or "N/A")
        pvpStatsFrame.honorValue:SetText(stats.honorValue or "N/A")
        pvpStatsFrame.honorLevelValue:SetText(stats.honorLevelValue or "N/A")
        pvpStatsFrame.soloShuffleRatingValue:SetText(stats.soloShuffleRatingValue or "N/A")
    else
        pvpStatsFrame.playerNameValue:SetText(characterNameOnly)
        pvpStatsFrame.playerNameValue:SetTextColor(1, 1, 1)  -- Default white color
        pvpStatsFrame.conquestValue:SetText("N/A")
        pvpStatsFrame.conquestCapValue:SetText("N/A")
        pvpStatsFrame.honorValue:SetText("N/A")
        pvpStatsFrame.honorLevelValue:SetText("N/A")
        pvpStatsFrame.soloShuffleRatingValue:SetText("N/A")
    end
end

local function Initialize(self, level)
    local info = UIDropDownMenu_CreateInfo()
    local selectedCharacter = UIDropDownMenu_GetText(dropdown)  

    for k, v in pairs(IncCalloutDB) do
        if string.match(k, "^[%w]+%-[%w]+$") then
            info.text = k
            info.menuList = k
            info.func = OnClick
            info.checked = (k == selectedCharacter)  
            info.isNotRadio = true  
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

    UIDropDownMenu_Initialize(dropdown, Initialize)
end

CreateCharacterDropdown()

local function SavePvPStats()
    IncCalloutDB = IncCalloutDB or {}
    local character = UnitName("player") .. "-" .. GetRealmName()
    local _, class = UnitClass("player")

    if not IncCalloutDB[character] then
        IncCalloutDB[character] = { class = class }  -- Store class info
    end

    local SavedSettings = IncCalloutDB[character]

    if IsAddOnLoaded("Blizzard_PVPUI") or LoadAddOn("Blizzard_PVPUI") then
        local conquestInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CONQUEST_CURRENCY_ID)
        local honorInfo = C_CurrencyInfo.GetCurrencyInfo(HONOR_CURRENCY_ID)
        local honorLevel = UnitHonorLevel("player")  

        SavedSettings.conquestValue = conquestInfo.quantity
        SavedSettings.conquestCapValue = math.min(conquestInfo.totalEarned, conquestInfo.maxQuantity) .. " / " .. conquestInfo.maxQuantity
        SavedSettings.honorValue = honorInfo.quantity
        SavedSettings.honorLevelValue = honorLevel  
        SavedSettings.soloShuffleRatingValue = GetPersonalRatedInfo(SOLO_SHUFFLE_INDEX) or "N/A"
    end
end

pvpStatsFrame:SetScript("OnShow", function()
    pvpStatsFrame.playerNameValue:SetText(UnitName("player") or "Unknown")
    local classColor = GetDefaultClassColor()
    if classColor then
        pvpStatsFrame.playerNameValue:SetTextColor(classColor.r, classColor.g, classColor.b)
    end
    local character = UnitName("player") .. "-" .. GetRealmName()
    local stats = IncCalloutDB[character]
    if stats then
        pvpStatsFrame.conquestValue:SetText(stats.conquestValue)
        pvpStatsFrame.conquestCapValue:SetText(stats.conquestCapValue)
        pvpStatsFrame.honorValue:SetText(stats.honorValue)
        pvpStatsFrame.honorLevelValue:SetText(stats.honorLevelValue)  
        pvpStatsFrame.soloShuffleRatingValue:SetText(stats.soloShuffleRatingValue)
    end
    UpdatePvPStatsFrame()
end)

-- Register event handlers
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
frame:RegisterEvent("HONOR_XP_UPDATE")
frame:RegisterEvent("PVP_RATED_STATS_UPDATE") 
frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" or event == "PVP_RATED_STATS_UPDATE" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
        UpdatePvPStatsFrame()  -- Updates stats on relevant events
    elseif event == "PLAYER_LOGOUT" or event == "CURRENCY_DISPLAY_UPDATE" or event == "HONOR_XP_UPDATE" then
        SavePvPStats()  -- Saves stats on logout or when currency/honor updates
    end
end)

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
     healRequest = {
    "[Incoming-BG] Need heals ASAP!",
    "[Incoming-BG] Healing needed at my position!",
    "[Incoming-BG] Can someone heal me, please?",
    "[Incoming-BG] Healers, your assistance is required!",
    "[Incoming-BG] I'm in dire need of healing!",
    "[Incoming-BG] Could use some healing here!",
    "[Incoming-BG] Healers, please focus on our location!",
    "[Incoming-BG] Urgent healing needed to stay in the fight!",
    "[Incoming-BG] Heal me up to keep the pressure on!",
    "[Incoming-BG] Healers, attention needed here now!"	 
	},
	efcRequest = {
    "[Incoming-BG] Get the EFC!!",
    "[Incoming-BG] EFC spotted, group up to kill and recover our flag!",
    "[Incoming-BG] Kill the EFC on sight, let's bring that flag home!",
    "[Incoming-BG] EFC is vulnerable, kill them now!",
    "[Incoming-BG] Everyone on the EFC!",
    "[Incoming-BG] Close in and kill the EFC, no escape allowed!",
    "[Incoming-BG] EFC heading towards their base—kill them before they cap!",
    "[Incoming-BG] The EFC is weak, finish them off!",
    "[Incoming-BG] Kill the EFC now, they're almost at their base!",
    "[Incoming-BG] It’s a race against time, kill the EFC and secure our victory!"
	},
	fcRequest = {
    "[Incoming-BG] Protect our FC!",
    "[Incoming-BG] FC needs help!!",
    "[Incoming-BG] Heals on FC!",
    "[Incoming-BG] Need some help with the FC.",
    "[Incoming-BG] Someone needs to get the flag.",
    
   }
 } 
 
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
    get = function() return IncDB.incIndex end,  
    set = function(_, newValue)
        IncDB.incIndex = newValue  
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
    get = function() return IncDB.allClearIndex end,  
    set = function(_, newValue)
        IncDB.allClearIndex = newValue  
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
	healRequest = {
    type = "select",
    name = "Heal Request Message",
    desc = "Select the message for the 'Need Heals' button",
    values = buttonMessages.healRequest,
    get = function() return IncDB.healRequestIndex end,
    set = function(_, newValue)
        buttonMessageIndices.healRequest = newValue
        IncDB.healRequestIndex = newValue
        LibStub("AceConfigRegistry-3.0"):NotifyChange("IncCallout")
    end,
    order = 5,
},
previewHealRequest = {
    type = "description",
    name = function() return addonNamespace.getPreviewText("healRequest") end,
    fontSize = "medium",
    order = 5.1,
},
efcRequest = {
    type = "select",
    name = "EFC Request Message",
    desc = "Select the message for the 'EFC' button",
    values = buttonMessages.efcRequest,
    get = function() return IncDB.efcRequestIndex end,
    set = function(_, newValue)
        buttonMessageIndices.efcRequest = newValue
        IncDB.efcRequestIndex = newValue
        LibStub("AceConfigRegistry-3.0"):NotifyChange("IncCallout")
    end,
    order = 6,
},
previewEFCRequest = {
    type = "description",
    name = function() return addonNamespace.getPreviewText("efcRequest") end,
    fontSize = "medium",
    order = 6.1,
	},
	fcRequest = {
    type = "select",
    name = "FC Request Message",
    desc = "Select the message for the 'FC' button",
    values = buttonMessages.fcRequest,
    get = function() return IncDB.fcRequestIndex end,
    set = function(_, newValue)
        buttonMessageIndices.fcRequest = newValue
        IncDB.fcRequestIndex = newValue
        LibStub("AceConfigRegistry-3.0"):NotifyChange("IncCallout")
    end,
    order = 7,
},
previewFCRequest = {
    type = "description",
    name = function() return addonNamespace.getPreviewText("fcRequest") end,
    fontSize = "medium",
    order = 7.1,
 
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
    elseif messageType == "healRequest" and IncDB.healRequestIndex and buttonMessages.healRequest[IncDB.healRequestIndex] then
        previewText = previewText .. buttonMessages.healRequest[IncDB.healRequestIndex]
    elseif messageType == "efcRequest" and IncDB.efcRequestIndex and buttonMessages.efcRequest[IncDB.efcRequestIndex] then
        previewText = previewText .. buttonMessages.efcRequest[IncDB.efcRequestIndex]
    elseif messageType == "fcRequest" and IncDB.fcRequestIndex and buttonMessages.fcRequest[IncDB.fcRequestIndex] then
        previewText = previewText .. buttonMessages.fcRequest[IncDB.fcRequestIndex]
    end

    return previewText .. "|r"
end


local messageQueue = {}
local timeLastMessageSent = 0
local MESSAGE_DELAY = 1.5 -- Delay in seconds between messages

local function SendMessage()
    if #messageQueue == 0 then return end
    if time() - timeLastMessageSent < MESSAGE_DELAY then return end -- Check if delay has passed

    local message = table.remove(messageQueue, 1)
    SendChatMessage(message.text, message.channel)
    timeLastMessageSent = time()
end

local function QueueMessage(text, channel)
    table.insert(messageQueue, {text = text, channel = channel})
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
        QueueMessage("[Incoming-BG] Healers on our team: " .. healerList .. ". Now you know who to peel for.", "INSTANCE_CHAT")
    else
        if IsInGroup() or IsInRaid() then
            QueueMessage("[Incoming-BG] We have no heals, lol..", "INSTANCE_CHAT")
        end
    end
end

-- Setup a frame to periodically attempt to send messages
local frame = CreateFrame("Frame")
frame:SetScript("OnUpdate", function(self, elapsed)
    SendMessage()
end)


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

-- Define the OnClick function for EFC
local function EFCButtonOnClick()
    if not InCombatLockdown() then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    end
    
    local inInstance, instanceType = IsInInstance()
    local chatType

    if inInstance and (instanceType == "pvp" or instanceType == "arena") then
        chatType = "INSTANCE_CHAT"
    elseif IsInRaid() then
        chatType = "RAID"
    elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
        chatType = "PARTY"
    else
        print("You're not in a PvP instance or any group.")
        return
    end

    local message = buttonMessages.efcRequest[IncDB.efcRequestIndex]
    SendChatMessage(message, chatType)
	ShowRaidWarning(message, 2)
end

-- Define the OnClick function for FC
local function FCButtonOnClick()
    if not InCombatLockdown() then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    end
    
    local inInstance, instanceType = IsInInstance()
    local chatType

    if inInstance and (instanceType == "pvp" or instanceType == "arena") then
        chatType = "INSTANCE_CHAT"
    elseif IsInRaid() then
        chatType = "RAID"
    elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
        chatType = "PARTY"
    else
        print("You're not in a PvP instance or any group.")
        return
    end

    local message = buttonMessages.fcRequest[IncDB.fcRequestIndex]
    SendChatMessage(message, chatType)
	ShowRaidWarning(message, 2)
end


local function HealsButtonOnClick()
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

    if not IncDB.healRequestIndex or not buttonMessages.healRequest[IncDB.healRequestIndex] then
        print("Heal request message not set.")
        return
    end

    local message = buttonMessages.healRequest[IncDB.healRequestIndex] .. " Needed at " .. location
    SendChatMessage(message, "INSTANCE_CHAT")
    ShowRaidWarning(message, 2)
end

local function BuffRequestButtonOnClick()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)

    local messageIndex = buttonMessageIndices.buffRequest or 1
    local message = buttonMessages.buffRequest[messageIndex]
    
    if not message then
        print("No buff request message available.")
        return
    end

    local inInstance, instanceType = IsInInstance()
    local chatType

    if inInstance and (instanceType == "pvp" or instanceType == "arena") then
        chatType = "INSTANCE_CHAT"
    elseif IsInRaid() then
        chatType = "RAID"
    elseif IsInGroup() then
        chatType = "PARTY"
    else
        print("You're not in a PvP instance.")
        return
    end

    -- Send the chat message
    SendChatMessage(message, chatType)
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

   
end

	local function OnEvent(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20)
    if event == "ADDON_LOADED" and arg1 == "IncCallout" then
        
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
IncCallout:RegisterEvent("WEEKLY_REWARDS_UPDATE")

pvpStatsFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
pvpStatsFrame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
pvpStatsFrame:RegisterEvent("WEEKLY_REWARDS_UPDATE")	


local button1 = createButton("button1", 20, 22, "1", {"TOPLEFT", IncCallout, "TOPLEFT"}, 35, -40, ButtonOnClick)
local button2 = createButton("button2", 20, 22, "2", {"LEFT", button1, "RIGHT"}, 10, 0, ButtonOnClick)
local button3 = createButton("button3", 20, 22, "3", {"LEFT", button2, "RIGHT"}, 10, 0, ButtonOnClick)
local button4 = createButton("button4", 20, 22, "4", {"LEFT", button3, "RIGHT"}, 10, 0, ButtonOnClick)
local buttonZerg = createButton("buttonZerg", 40, 22, "Zerg", {"LEFT", button4, "RIGHT"}, 10, 0, ButtonOnClick)
local incButton = createButton("incButton", 95, 22, "Inc", {"TOP", button3, "BOTTOM"}, -45, -10, IncButtonOnClick)
local sendMoreButton = createButton("sendMoreButton", 95, 22, "Send More", {"LEFT", incButton, "RIGHT"}, 10, 0, SendMoreButtonOnClick)
local allClearButton = createButton("allClearButton", 95, 22, "All Clear", {"TOP", incButton, "BOTTOM"}, 0, -10, AllClearButtonOnClick)
local healsButton = createButton("healsButton", 95, 22, "Heals", {"LEFT", allClearButton, "RIGHT"}, 10, 0, HealsButtonOnClick)
local efcButton = createButton("efcButton", 95, 22, "EFC", {"TOP", allClearButton, "BOTTOM"}, 0, -10, EFCButtonOnClick)
local fcButton = createButton("fcButton", 95, 22, "FC", {"LEFT", efcButton, "RIGHT"}, 10, 0, FCButtonOnClick)
local buffButton = createButton("buffButton", 95, 22, "Buffs", {"TOP", efcButton, "BOTTOM"}, 0, -10, BuffRequestButtonOnClick)
local mapButton = createButton("mapButton", 95, 22, "Map", {"LEFT", buffButton, "RIGHT"}, 10, 0, function()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    ToggleWorldMap()
end)

local healerButton = createButton("healerButton", 95, 22, "Healers", {"TOP", buffButton, "BOTTOM"}, 0, -10, function()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    ListHealers()
end)

local pvpStatsButton = createButton("pvpStatsButton", 95, 22, "PVP Stats", {"LEFT", healerButton, "RIGHT"}, 10, 0, function()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    pvpStatsFrame:Show()
end)

-- Tooltip setup for the pvpStatsButton with Conquest Cap included
pvpStatsButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("PVP Stats Information", nil, nil, nil, nil, true)
    GameTooltip:AddLine(" \nDisplays the following stats:\n", 1, 1, 1, true)  -- Extra line breaks for spacing
    GameTooltip:AddLine("• Honor Points: ", 1, 0.5, 0, true)  -- Orange for title
    GameTooltip:AddLine("Your current total.", 1, 1, 1, true)  -- White for description
    GameTooltip:AddLine("• Conquest Points: ", 1, 0.5, 0, true)
    GameTooltip:AddLine("Your current total.", 1, 1, 1, true)
    GameTooltip:AddLine("• Conquest Cap: ", 1, 0.5, 0, true)
    GameTooltip:AddLine("The maximum Conquest points you can earn this week.", 1, 1, 1, true)
    GameTooltip:AddLine("• Honor Level: ", 1, 0.5, 0, true)
    GameTooltip:AddLine("Your current level in the Honor system.", 1, 1, 1, true)   
    GameTooltip:AddLine("• Solo Shuffle Rating: ", 1, 0.5, 0, true)
    GameTooltip:AddLine("Your current rating in Solo Shuffle.", 1, 1, 1, true)
    GameTooltip:Show()
end)

pvpStatsButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

-- Apply the color to all the buttons
applyButtonColor()

-- Set OnClick functions for the buttons
allClearButton:SetScript("OnClick", AllClearButtonOnClick)
sendMoreButton:SetScript("OnClick", SendMoreButtonOnClick)
incButton:SetScript("OnClick", IncButtonOnClick)

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