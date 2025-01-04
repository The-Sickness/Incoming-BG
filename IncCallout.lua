-- Made by Sharpedge_Gaming
-- v8.4  11.0.7

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
LSM:Register("statusbar", "Blizzard", "Interface\\TargetingFrame\\UI-StatusBar")

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
        customMessages = {
            sendMore = "",
            inc = "",
            allClear = "",
            buffRequest = "",
            healRequest = "",
            efcRequest = "",
            fcRequest = "",
        },
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

local CONQUEST_CURRENCY_ID = 1602
local HONOR_CURRENCY_ID = 1792
local blitzHonorGained = 0

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
pvpStatsFrame:SetSize(700, 320)  -- Adjusted size to fit to the left margin
pvpStatsFrame:SetPoint("CENTER")
pvpStatsFrame:SetMovable(true)
pvpStatsFrame:EnableMouse(true)
pvpStatsFrame:RegisterForDrag("LeftButton")
pvpStatsFrame:SetScript("OnDragStart", pvpStatsFrame.StartMoving)
pvpStatsFrame:SetScript("OnDragStop", pvpStatsFrame.StopMovingOrSizing)
pvpStatsFrame:Hide()

pvpStatsFrame.title = pvpStatsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
pvpStatsFrame.title:SetPoint("TOP", pvpStatsFrame, "TOP", 0, -3)
pvpStatsFrame.title:SetText("PvP Statistics")

local TOP_MARGIN = -25

local function createStatLabelAndValueHorizontal(parent, labelText, xOffset, yOffset, labelTextColor)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, yOffset)
    label:SetText(labelText)
    label:SetTextColor(unpack(labelTextColor))
    
    local value = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    value:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -2)
    value:SetTextColor(1, 0.84, 0) -- Default color for the value text
    return label, value
end

local tabs = {}

local function HideAllTabs()
    for _, tabFrame in pairs(tabs) do
        tabFrame:Hide()
    end
end

-- Create the tab frame
local tabFrame = CreateFrame("Frame", nil, pvpStatsFrame)
tabFrame:SetPoint("TOP", pvpStatsFrame, "TOP", 0, -30)
tabFrame:SetSize(700, 25)
tabFrame.tabButtons = {}

local function ResetTabColors()
    for _, tabButton in pairs(tabFrame.tabButtons) do
        tabButton:SetNormalFontObject("GameFontNormal")
    end
end

-- Create a function to create tabs
local function CreateTabButton(parent, text, id)
    local tab = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    tab:SetText(text)
    tab:SetID(id)
    tab:SetSize(120, 25)
    tab:SetScript("OnClick", function(self)
        HideAllTabs()
        tabs[self:GetID()]:Show()
        ResetTabColors()
        self:SetNormalFontObject("GameFontHighlight")
    end)
    return tab
end

-- Create the tabs
local generalTab = CreateTabButton(tabFrame, "General", 1)
generalTab:SetPoint("LEFT", tabFrame, "LEFT", 10, 0)
table.insert(tabFrame.tabButtons, generalTab)

local otherTab = CreateTabButton(tabFrame, "BG's", 2)
otherTab:SetPoint("LEFT", generalTab, "RIGHT", 5, 0)
table.insert(tabFrame.tabButtons, otherTab)

local soloRBGTab = CreateTabButton(tabFrame, "Solo RBG", 3)
soloRBGTab:SetPoint("LEFT", otherTab, "RIGHT", 5, 0)
table.insert(tabFrame.tabButtons, soloRBGTab)

local soloShuffleTab = CreateTabButton(tabFrame, "Solo Shuffle", 4)
soloShuffleTab:SetPoint("LEFT", soloRBGTab, "RIGHT", 5, 0)
table.insert(tabFrame.tabButtons, soloShuffleTab)

local miscTab = CreateTabButton(tabFrame, "Misc", 5)
miscTab:SetPoint("LEFT", soloShuffleTab, "RIGHT", 5, 0)
table.insert(tabFrame.tabButtons, miscTab)

-- Create tab frames
tabs[1] = CreateFrame("Frame", nil, pvpStatsFrame)
tabs[1]:SetSize(700, 300)
tabs[1]:SetPoint("TOP", tabFrame, "BOTTOM", 0, -10)
tabs[1]:Show()

tabs[2] = CreateFrame("Frame", nil, pvpStatsFrame)
tabs[2]:SetSize(700, 300)
tabs[2]:SetPoint("TOP", tabFrame, "BOTTOM", 0, -10)
tabs[2]:Hide()

tabs[3] = CreateFrame("Frame", nil, pvpStatsFrame)
tabs[3]:SetSize(700, 300)
tabs[3]:SetPoint("TOP", tabFrame, "BOTTOM", 0, -10)
tabs[3]:Hide()

tabs[4] = CreateFrame("Frame", nil, pvpStatsFrame)
tabs[4]:SetSize(700, 300)
tabs[4]:SetPoint("TOP", tabFrame, "BOTTOM", 0, -10)
tabs[4]:Hide()

tabs[5] = CreateFrame("Frame", nil, pvpStatsFrame)
tabs[5]:SetSize(700, 300)
tabs[5]:SetPoint("TOP", tabFrame, "BOTTOM", 0, -10)
tabs[5]:Hide()

HideAllTabs()
tabs[1]:Show()
generalTab:SetNormalFontObject("GameFontHighlight")

-- Add PvP Stats to the General Tab
local generalStats = {
    {"Player Name:", "playerNameValue", {0, 1, 0}},
    {"Conquest Points:", "conquestValue", {1, 0, 0}},
    {"Honor Points:", "honorValue", {0, 0.75, 1}},
    {"Honor Level:", "honorLevelValue", {0.58, 0, 0.82}},
    {"Conquest Cap:", "conquestCapValue", {1, 0.5, 0}},
    {"Solo Shuffle Rating:", "soloShuffleRatingValue", {0, 0.75, 1}},
}

for i, stat in ipairs(generalStats) do
    local label, value = createStatLabelAndValueHorizontal(tabs[1], stat[1], 10, -10 - (i - 1) * 40, stat[3])
    tabs[1][stat[2]] = value
end

-- Add BG Stats to the BG Tab
local bgStats = {
    {"BGs Played:", "bgPlayedValue", {0, 1, 0}},
    {"BGs Won:", "bgWonValue", {1, 0, 0}},
    {"BGs Lost:", "bgLostValue", {0, 0.75, 1}},
    {"Total Honorable Kills:", "totalHonorableKillsValue", {0.58, 0, 0.82}},
    {"Battleground Honorable Kills:", "battlegroundHonorableKillsValue", {1, 0.5, 0}},
}

for i, stat in ipairs(bgStats) do
    local label, value = createStatLabelAndValueHorizontal(tabs[2], stat[1], 10, -10 - (i - 1) * 40, stat[3])
    tabs[2][stat[2]] = value
end

-- Add Solo RBG Stats to the Solo RBG Tab
local soloRBGStats = {
    {"Best Rating:", "bestRatingValue", {0, 1, 0}},
    {"Games Won:", "gamesWonValue", {1, 0, 0}},
    {"Games Played:", "gamesPlayedValue", {0, 0.75, 1}},
    {"Most Played Spec:", "mostPlayedSpecValue", {0.58, 0, 0.82}},
    {"Played the Most:", "playedMostValue", {1, 0.5, 0}},
    {"Current Rank:", "currentRankValue", {0, 1, 0}}
}

for i, stat in ipairs(soloRBGStats) do
    local label, value = createStatLabelAndValueHorizontal(tabs[3], stat[1], 10, -10 - (i - 1) * 40, stat[3])
    tabs[3][stat[2]] = value
end

-- Add Solo Shuffle Stats to the Solo Shuffle Tab
local soloShuffleStats = {
    {"Best Rating:", "shuffleBestRatingValue", {0, 1, 0}},
    {"Rounds Won:", "shuffleRoundsWonValue", {0, 0.75, 1}},
    {"Rounds Played:", "shuffleRoundsPlayedValue", {1, 0, 0}},
    {"Most Played Spec:", "shuffleMostPlayedSpecValue", {0.58, 0, 0.82}},
}

for i, stat in ipairs(soloShuffleStats) do
    local label, value = createStatLabelAndValueHorizontal(tabs[4], stat[1], 10, -10 - (i - 1) * 40, stat[3])
    tabs[4][stat[2]] = value
end

-- Add Misc Stats to the Misc Tab
local miscStats = {
    {"Total Kills (Exp or Honor):", "totalKillsValue", {0, 1, 0}},
    {"Total Killing Blows:", "totalKillingBlowsValue", {1, 0, 0}},
    {"Battleground Killing Blows:", "battlegroundKillingBlowsValue", {0, 0.75, 1}},
    {"Total Deaths:", "totalDeathsValue", {0.58, 0, 0.82}},
    {"Battleground Deaths:", "battlegroundDeathsValue", {1, 0.5, 0}},
}

for i, stat in ipairs(miscStats) do
    local label, value = createStatLabelAndValueHorizontal(tabs[5], stat[1], 10, -10 - (i - 1) * 40, stat[3])
    tabs[5][stat[2]] = value
end

local SOLO_RBG_INDEX = 9
local SOLO_SHUFFLE_INDEX = 7

local function GetPvpRank(rating)
    if rating < 1000 then
        return "Unranked"
    elseif rating < 1200 then
        return "Combatant 1"
    elseif rating < 1400 then
        return "Combatant 2"
    elseif rating < 1600 then
        return "Challenger 1"
    elseif rating < 1800 then
        return "Challenger 2"
    elseif rating < 2100 then
        return "Rival"
    elseif rating < 2400 then
        return "Duelist"
    else
        return "Elite"
    end
end

-- Function to fetch BG stats
local function FetchBGStats()
    local bgPlayed = GetStatistic(839) or "N/A"
    local bgWon = GetStatistic(840) or "N/A"
    local bgLost
    if tonumber(bgPlayed) and tonumber(bgWon) then
        bgLost = tonumber(bgPlayed) - tonumber(bgWon)
    else
        bgLost = "N/A"
    end
    local totalHonorableKills = GetStatistic(588) or "N/A"
    local battlegroundHonorableKills = GetStatistic(382) or "N/A"

    return bgPlayed, bgWon, bgLost, totalHonorableKills, battlegroundHonorableKills
end

-- Function to fetch Great Vault slots
local function FetchGreatVaultSlots()
    local weeklyProgress = C_WeeklyRewards.GetConquestWeeklyProgress()
    return weeklyProgress and weeklyProgress.unlocksCompleted or 0
end

-- Function to get spec name safely
local function GetSpecName(specID)
    if specID and specID > 0 then
        return GetSpecializationNameForSpecID(specID) or "N/A"
    end
    return "N/A"
end

-- Function to fetch Solo RBG stats
local function FetchSoloRBGStats()
    local gamesPlayed = GetStatistic(40199) or "N/A"
    local gamesWon = GetStatistic(40201) or "N/A"
    local playedMost = GetStatistic(40200) or "N/A"
    local rating, seasonBest, weeklyBest, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon, lastWeeksBest, hasWon, pvpTier, ranking, roundsSeasonPlayed, roundsSeasonWon, roundsWeeklyPlayed, roundsWeeklyWon = GetPersonalRatedInfo(SOLO_RBG_INDEX) -- Use the correct bracketIndex

    if rating then
        local specStats = C_PvP.GetPersonalRatedBGBlitzSpecStats() or {}
        local mostPlayedSpecID = specStats.seasonMostPlayedSpecID or 0
        local mostPlayedSpec = GetSpecName(mostPlayedSpecID)
        local currentRank = GetPvpRank(rating)
        return rating, gamesPlayed, gamesWon, mostPlayedSpec, playedMost, currentRank
    else
        return "N/A", gamesPlayed, gamesWon, "N/A", playedMost, "N/A"
    end
end

-- Function to fetch Solo Shuffle stats
local function FetchSoloShuffleStats()
    local shuffleRating, shuffleSeasonBest, shuffleWeeklyBest, shuffleSeasonPlayed, shuffleSeasonWon, shuffleWeeklyPlayed, shuffleWeeklyWon, shuffleLastWeeksBest, shuffleHasWon, shufflePvpTier, shuffleRanking, shuffleRoundsSeasonPlayed, shuffleRoundsSeasonWon, shuffleRoundsWeeklyPlayed, shuffleRoundsWeeklyWon = GetPersonalRatedInfo(SOLO_SHUFFLE_INDEX)
    local shuffleSpecStats = C_PvP.GetPersonalRatedSoloShuffleSpecStats() or {}
    local shuffleMostPlayedSpecID = shuffleSpecStats.seasonMostPlayedSpecID or 0
    local shuffleMostPlayedSpecName = GetSpecName(shuffleMostPlayedSpecID)
    return shuffleSeasonBest, shuffleRoundsSeasonPlayed, shuffleRoundsSeasonWon, shuffleMostPlayedSpecName
end

-- Function to save PvP stats
local function SavePvPStats()
    IncCalloutDB = IncCalloutDB or {}
    local character = UnitName("player")
    local _, class = UnitClass("player")

    if not IncCalloutDB[character] then
        IncCalloutDB[character] = { class = class }
    end

    local SavedSettings = IncCalloutDB[character]

    local loadedOrLoading, loaded = C_AddOns.IsAddOnLoaded("Blizzard_PVPUI")
    if not loaded then
        C_AddOns.LoadAddOn("Blizzard_PVPUI")
    end

    local conquestInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CONQUEST_CURRENCY_ID)
    local honorInfo = C_CurrencyInfo.GetCurrencyInfo(HONOR_CURRENCY_ID)
    local honorLevel = UnitHonorLevel("player")
    local soloShuffleRating = select(2, GetPersonalRatedInfo(SOLO_SHUFFLE_INDEX)) or "N/A"

    SavedSettings.conquestValue = conquestInfo and conquestInfo.quantity or 0
    SavedSettings.conquestCapValue = conquestInfo and (conquestInfo.totalEarned .. " / " .. (conquestInfo.maxQuantity > 0 and conquestInfo.maxQuantity or "No Cap")) or "N/A"
    SavedSettings.honorValue = honorInfo and honorInfo.quantity or "N/A"
    SavedSettings.honorLevelValue = honorLevel
    SavedSettings.soloShuffleRatingValue = soloShuffleRating

    -- Save BG Stats
    local bgPlayed, bgWon, bgLost, totalHonorableKills, battlegroundHonorableKills = FetchBGStats()
    SavedSettings.bgPlayed = bgPlayed
    SavedSettings.bgWon = bgWon
    SavedSettings.bgLost = bgLost
    SavedSettings.totalHonorableKills = totalHonorableKills
    SavedSettings.battlegroundHonorableKills = battlegroundHonorableKills

    -- Save Great Vault slots unlocked
    SavedSettings.greatVaultSlots = FetchGreatVaultSlots()

    -- Save Solo RBG Stats
    local bestRating, gamesPlayed, gamesWon, mostPlayedSpec, playedMost, currentRank = FetchSoloRBGStats()
    SavedSettings.bestRatingValue = bestRating
    SavedSettings.gamesPlayedValue = gamesPlayed
    SavedSettings.gamesWonValue = gamesWon
    SavedSettings.mostPlayedSpecValue = mostPlayedSpec
    SavedSettings.playedMostValue = playedMost
    SavedSettings.currentRankValue = currentRank

    -- Save Solo Shuffle Stats
    local shuffleBestRating, shuffleRoundsPlayed, shuffleRoundsWon, shuffleMostPlayedSpec = FetchSoloShuffleStats()
    SavedSettings.shuffleBestRatingValue = shuffleBestRating or "N/A"
    SavedSettings.shuffleRoundsWonValue = shuffleRoundsWon or "N/A"
    SavedSettings.shuffleRoundsPlayedValue = shuffleRoundsPlayed or "N/A"
    SavedSettings.shuffleMostPlayedSpecValue = shuffleMostPlayedSpec

    -- Save Misc Stats
    local totalKills = GetStatistic(1198) or "N/A"
    local totalKillingBlows = GetStatistic(1487) or "N/A"
    local battlegroundKillingBlows = GetStatistic(1491) or "N/A"
    local totalDeaths = GetStatistic(60) or "N/A"
    local battlegroundDeaths = GetStatistic(14786) or "N/A"

    SavedSettings.totalKillsValue = totalKills
    SavedSettings.totalKillingBlowsValue = totalKillingBlows
    SavedSettings.battlegroundKillingBlowsValue = battlegroundKillingBlows
    SavedSettings.totalDeathsValue = totalDeaths
    SavedSettings.battlegroundDeathsValue = battlegroundDeaths
end

-- Update the Solo RBG Stats
local function UpdateSoloRBGStatsFrame(character)
    local stats = IncCalloutDB[character]
    if stats then
        tabs[3].bestRatingValue:SetText(stats.bestRatingValue or "N/A")
        tabs[3].gamesWonValue:SetText(stats.gamesWonValue or "N/A")
        tabs[3].gamesPlayedValue:SetText(stats.gamesPlayedValue or "N/A")
        tabs[3].mostPlayedSpecValue:SetText(stats.mostPlayedSpecValue or "N/A")
        tabs[3].playedMostValue:SetText(stats.playedMostValue or "N/A")
        tabs[3].currentRankValue:SetText(stats.currentRankValue or "N/A")
    end
end

-- Function to update Solo Shuffle stats frame
local function UpdateSoloShuffleStatsFrame(character)
    local stats = IncCalloutDB[character]
    if stats then
        tabs[4].shuffleBestRatingValue:SetText(stats.shuffleBestRatingValue or "N/A")
        tabs[4].shuffleRoundsWonValue:SetText(stats.shuffleRoundsWonValue or "N/A")
        tabs[4].shuffleRoundsPlayedValue:SetText(stats.shuffleRoundsPlayedValue or "N/A")
        tabs[4].shuffleMostPlayedSpecValue:SetText(stats.shuffleMostPlayedSpecValue or "N/A")
    end
end

-- Function to update Misc stats frame
local function UpdateMiscStatsFrame(character)
    local stats = IncCalloutDB[character]
    if stats then
        tabs[5].totalKillsValue:SetText(stats.totalKillsValue or "N/A")
        tabs[5].totalKillingBlowsValue:SetText(stats.totalKillingBlowsValue or "N/A")
        tabs[5].battlegroundKillingBlowsValue:SetText(stats.battlegroundKillingBlowsValue or "N/A")
        tabs[5].totalDeathsValue:SetText(stats.totalDeathsValue or "N/A")
        tabs[5].battlegroundDeathsValue:SetText(stats.battlegroundDeathsValue or "N/A")
    end
end

-- Function to update tab values
local function UpdateTabValues(tab, stats)
    tab.playerNameValue:SetText(stats.playerName or "N/A")
    tab.playerNameValue:SetTextColor(stats.playerColor.r or 1, stats.playerColor.g or 1, stats.playerColor.b or 1)
    tab.conquestValue:SetText(stats.conquestValue or "N/A")
    tab.conquestCapValue:SetText(stats.conquestCapValue or "N/A")
    tab.honorValue:SetText(stats.honorValue or "N/A")
    tab.honorLevelValue:SetText(stats.honorLevelValue or "N/A")
    tab.soloShuffleRatingValue:SetText(stats.soloShuffleRatingValue or "N/A")
end

-- Function to update PvP stats frame
local function UpdatePvPStatsFrame(character)
    local loadedOrLoading, loaded = C_AddOns.IsAddOnLoaded("Blizzard_PVPUI")
    if not loaded then
        C_AddOns.LoadAddOn("Blizzard_PVPUI")
    end

    local stats = IncCalloutDB[character]
    if stats then
        local name = string.match(character, "^[^%-]+")
        local classColor = RAID_CLASS_COLORS[stats.class] or {r = 1, g = 1, b = 1}
        local tabStats = {
            playerName = name,
            playerColor = classColor,
            conquestValue = stats.conquestValue,
            conquestCapValue = stats.conquestCapValue,
            honorValue = stats.honorValue,
            honorLevelValue = stats.honorLevelValue,
            soloShuffleRatingValue = stats.soloShuffleRatingValue
        }
        UpdateTabValues(tabs[1], tabStats)
    end

    -- Adjust PvP UI buttons based on current PvP availability
    local canUseRated = C_PvP.CanPlayerUseRatedPVPUI()
    local canUsePremade = C_LFGInfo.CanPlayerUsePremadeGroup()

    if (canUseRated) then
        PVPQueueFrame_SetCategoryButtonState(PVPQueueFrame.CategoryButton2, true)
        PVPQueueFrame.CategoryButton2.tooltip = nil
    end

    if (canUsePremade) then
        PVPQueueFrame_SetCategoryButtonState(PVPQueueFrame.CategoryButton3, true)
        PVPQueueFrame.CategoryButton3.tooltip = nil
    end
end

-- Function to update BG stats frame
local function UpdateBGStatsFrame(character)
    local stats = IncCalloutDB[character]
    if stats then
        tabs[2].bgPlayedValue:SetText(stats.bgPlayed or "N/A")
        tabs[2].bgWonValue:SetText(stats.bgWon or "N/A")
        tabs[2].bgLostValue:SetText(stats.bgLost or "N/A")
        tabs[2].totalHonorableKillsValue:SetText(stats.totalHonorableKills or "N/A")
        tabs[2].battlegroundHonorableKillsValue:SetText(stats.battlegroundHonorableKills or "N/A")
    end
end

-- Function to create character dropdown
local function CreateCharacterDropdown()
    local dropdown = CreateFrame("FRAME", "SelectCharacterDropdown", pvpStatsFrame, "UIDropDownMenuTemplate")
    dropdown:SetPoint("BOTTOMLEFT", pvpStatsFrame, "BOTTOMLEFT", -15, -30)

    UIDropDownMenu_SetWidth(dropdown, 150)
    UIDropDownMenu_SetText(dropdown, "Characters")

    local function OnClick(self)
        UIDropDownMenu_SetSelectedID(dropdown, self:GetID(), true)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
        local characterFullName = self:GetText()
        local characterNameOnly = string.match(characterFullName, "^[^%-]+")
        local stats = IncCalloutDB[characterFullName]

        if stats then
            local classColor = RAID_CLASS_COLORS[stats.class]
            tabs[1].playerNameValue:SetText(characterNameOnly)
            tabs[1].playerNameValue:SetTextColor(classColor.r, classColor.g, classColor.b)

            tabs[1].conquestValue:SetText(stats.conquestValue or "N/A")
            tabs[1].conquestCapValue:SetText(stats.conquestCapValue or "N/A")
            tabs[1].honorValue:SetText(stats.honorValue or "N/A")
            tabs[1].honorLevelValue:SetText(stats.honorLevelValue or "N/A")
            tabs[1].soloShuffleRatingValue:SetText(stats.soloShuffleRatingValue or "N/A")

            tabs[2].bgPlayedValue:SetText(stats.bgPlayed or "N/A")
            tabs[2].bgWonValue:SetText(stats.bgWon or "N/A")
            tabs[2].bgLostValue:SetText(stats.bgLost or "N/A")
            tabs[2].totalHonorableKillsValue:SetText(stats.totalHonorableKills or "N/A")
            tabs[2].battlegroundHonorableKillsValue:SetText(stats.battlegroundHonorableKills or "N/A")

            tabs[3].bestRatingValue:SetText(stats.bestRatingValue or "N/A")
            tabs[3].gamesWonValue:SetText(stats.gamesWonValue or "N/A")
            tabs[3].gamesPlayedValue:SetText(stats.gamesPlayedValue or "N/A")
            tabs[3].mostPlayedSpecValue:SetText(stats.mostPlayedSpecValue or "N/A")
            tabs[3].playedMostValue:SetText(stats.playedMostValue or "N/A")
            tabs[3].currentRankValue:SetText(stats.currentRankValue or "N/A")

            tabs[4].shuffleBestRatingValue:SetText(stats.shuffleBestRatingValue or "N/A")
            tabs[4].shuffleRoundsWonValue:SetText(stats.shuffleRoundsWonValue or "N/A")
            tabs[4].shuffleRoundsPlayedValue:SetText(stats.shuffleRoundsPlayedValue or "N/A")
            tabs[4].shuffleMostPlayedSpecValue:SetText(stats.shuffleMostPlayedSpecValue or "N/A")

            tabs[5].totalKillsValue:SetText(stats.totalKillsValue or "N/A")
            tabs[5].totalKillingBlowsValue:SetText(stats.totalKillingBlowsValue or "N/A")
            tabs[5].battlegroundKillingBlowsValue:SetText(stats.battlegroundKillingBlowsValue or "N/A")
            tabs[5].totalDeathsValue:SetText(stats.totalDeathsValue or "N/A")
            tabs[5].battlegroundDeathsValue:SetText(stats.battlegroundDeathsValue or "N/A")

            UpdateSoloRBGStatsFrame(characterFullName)
            UpdateSoloShuffleStatsFrame(characterFullName)
            UpdateMiscStatsFrame(characterFullName)
        else
            tabs[1].playerNameValue:SetText(characterNameOnly)
            tabs[1].playerNameValue:SetTextColor(1, 1, 1)

            tabs[1].conquestValue:SetText("N/A")
            tabs[1].conquestCapValue:SetText("N/A")
            tabs[1].honorValue:SetText("N/A")
            tabs[1].honorLevelValue:SetText("N/A")
            tabs[1].soloShuffleRatingValue:SetText("N/A")

            tabs[2].bgPlayedValue:SetText("N/A")
            tabs[2].bgWonValue:SetText("N/A")
            tabs[2].bgLostValue:SetText("N/A")
            tabs[2].totalHonorableKillsValue:SetText("N/A")
            tabs[2].battlegroundHonorableKillsValue:SetText("N/A")

            tabs[3].bestRatingValue:SetText("N/A")
            tabs[3].gamesWonValue:SetText("N/A")
            tabs[3].gamesPlayedValue:SetText("N/A")
            tabs[3].mostPlayedSpecValue:SetText("N/A")
            tabs[3].playedMostValue:SetText("N/A")
            tabs[3].currentRankValue:SetText("N/A")

            tabs[4].shuffleBestRatingValue:SetText("N/A")
            tabs[4].shuffleRoundsWonValue:SetText("N/A")
            tabs[4].shuffleRoundsPlayedValue:SetText("N/A")
            tabs[4].shuffleMostPlayedSpecValue:SetText("N/A")

            tabs[5].totalKillsValue:SetText("N/A")
            tabs[5].totalKillingBlowsValue:SetText("N/A")
            tabs[5].battlegroundKillingBlowsValue:SetText("N/A")
            tabs[5].totalDeathsValue:SetText("N/A")
            tabs[5].battlegroundDeathsValue:SetText("N/A")

            UpdateSoloRBGStatsFrame(characterFullName)
            UpdateSoloShuffleStatsFrame(characterFullName)
            UpdateMiscStatsFrame(characterFullName)
        end
    end

    local function Initialize(self, level)
        local info = UIDropDownMenu_CreateInfo()
        local selectedCharacter = UIDropDownMenu_GetText(dropdown)

        for k, v in pairs(IncCalloutDB) do
            if type(k) == "string" and k ~= "profileKeys" and k ~= "settings" and k ~= "profiles" then
                info.text = k
                info.menuList = k
                info.func = OnClick
                info.checked = (k == selectedCharacter)
                info.isNotRadio = true
                UIDropDownMenu_AddButton(info, level)
            end
        end
        UIDropDownMenu_SetText(dropdown, "Characters")
    end

    UIDropDownMenu_Initialize(dropdown, Initialize)
    UIDropDownMenu_SetText(dropdown, "Characters")
end

CreateCharacterDropdown()

-- Function to handle the OnShow event for the PvP stats frame
pvpStatsFrame:SetScript("OnShow", function()
    local character = UnitName("player")
    UIDropDownMenu_SetText(SelectCharacterDropdown, character)
    UIDropDownMenu_SetSelectedValue(SelectCharacterDropdown, character)
    local stats = IncCalloutDB[character]
    if stats then
        tabs[1].playerNameValue:SetText(character or "Unknown")
        local classColor = RAID_CLASS_COLORS[stats.class]
        if classColor then
            tabs[1].playerNameValue:SetTextColor(classColor.r, classColor.g, classColor.b)
        end

        tabs[1].conquestValue:SetText(stats.conquestValue or "N/A")
        tabs[1].conquestCapValue:SetText(stats.conquestCapValue or "N/A")
        tabs[1].honorValue:SetText(stats.honorValue or "N/A")
        tabs[1].honorLevelValue:SetText(stats.honorLevelValue or "N/A")
        tabs[1].soloShuffleRatingValue:SetText(stats.soloShuffleRatingValue or "N/A")

        tabs[2].bgPlayedValue:SetText(stats.bgPlayed or "N/A")
        tabs[2].bgWonValue:SetText(stats.bgWon or "N/A")
        tabs[2].bgLostValue:SetText(stats.bgLost or "N/A")
        tabs[2].totalHonorableKillsValue:SetText(stats.totalHonorableKills or "N/A")
        tabs[2].battlegroundHonorableKillsValue:SetText(stats.battlegroundHonorableKills or "N/A")

        tabs[3].bestRatingValue:SetText(stats.bestRatingValue or "N/A")
        tabs[3].gamesWonValue:SetText(stats.gamesWonValue or "N/A")
        tabs[3].gamesPlayedValue:SetText(stats.gamesPlayedValue or "N/A")
        tabs[3].mostPlayedSpecValue:SetText(stats.mostPlayedSpecValue or "N/A")
        tabs[3].playedMostValue:SetText(stats.playedMostValue or "N/A")
        tabs[3].currentRankValue:SetText(stats.currentRankValue or "N/A")

        tabs[4].shuffleBestRatingValue:SetText(stats.shuffleBestRatingValue or "N/A")
        tabs[4].shuffleRoundsWonValue:SetText(stats.shuffleRoundsWonValue or "N/A")
        tabs[4].shuffleRoundsPlayedValue:SetText(stats.shuffleRoundsPlayedValue or "N/A")
        tabs[4].shuffleMostPlayedSpecValue:SetText(stats.shuffleMostPlayedSpecValue or "N/A")

        tabs[5].totalKillsValue:SetText(stats.totalKillsValue or "N/A")
        tabs[5].totalKillingBlowsValue:SetText(stats.totalKillingBlowsValue or "N/A")
        tabs[5].battlegroundKillingBlowsValue:SetText(stats.battlegroundKillingBlowsValue or "N/A")
        tabs[5].totalDeathsValue:SetText(stats.totalDeathsValue or "N/A")
        tabs[5].battlegroundDeathsValue:SetText(stats.battlegroundDeathsValue or "N/A")

        UpdateSoloRBGStatsFrame(character)
        UpdateSoloShuffleStatsFrame(character)
        UpdateMiscStatsFrame(character)
    end
    SavePvPStats()
    UpdatePvPStatsFrame(character)
    UpdateBGStatsFrame(character)
    UpdateSoloRBGStatsFrame(character)
    UpdateSoloShuffleStatsFrame(character)
    UpdateMiscStatsFrame(character)
    UIDropDownMenu_SetText(SelectCharacterDropdown, "Characters")
end)

local function DelayedSaveAndUpdate()
    C_Timer.After(2, function()
        RequestRatedInfo()
        SavePvPStats()
        local character = UnitName("player")
        UpdatePvPStatsFrame(character)
        UpdateBGStatsFrame(character)
        UpdateSoloRBGStatsFrame(character)
        UpdateSoloShuffleStatsFrame(character)
        UpdateMiscStatsFrame(character)
    end)
end

local eventHandlers = {
    ["PVP_RATED_STATS_UPDATE"] = function()
        local character = UnitName("player")
        SavePvPStats()
        UpdatePvPStatsFrame(character)
        UpdateBGStatsFrame(character)
        UpdateSoloRBGStatsFrame(character)
        UpdateSoloShuffleStatsFrame(character)
        UpdateMiscStatsFrame(character)
    end,
    ["PVP_REWARDS_UPDATE"] = function()
        local character = UnitName("player")
        SavePvPStats()
        UpdatePvPStatsFrame(character)
        UpdateBGStatsFrame(character)
        UpdateSoloRBGStatsFrame(character)
        UpdateSoloShuffleStatsFrame(character)
        UpdateMiscStatsFrame(character)
    end,
    ["ZONE_CHANGED_NEW_AREA"] = DelayedSaveAndUpdate,
    ["PLAYER_ENTERING_WORLD"] = function()
        DelayedSaveAndUpdate()
        C_Timer.After(2, function()
            local character = UnitName("player")
            UIDropDownMenu_SetText(SelectCharacterDropdown, character)
            UIDropDownMenu_SetSelectedValue(SelectCharacterDropdown, character)
        end)
    end,
    ["ADDON_LOADED"] = function(addonName)
        if addonName == "IncCallout" then
            DelayedSaveAndUpdate()
            C_Timer.After(2, function()
                local character = UnitName("player")
                UIDropDownMenu_SetText(SelectCharacterDropdown, character)
                UIDropDownMenu_SetSelectedValue(SelectCharacterDropdown, character)
            end)
        end
    end,
    ["PLAYER_LOGIN"] = function()
        DelayedSaveAndUpdate()
        C_Timer.After(2, function()
            local character = UnitName("player")
            UIDropDownMenu_SetText(SelectCharacterDropdown, character)
            UIDropDownMenu_SetSelectedValue(SelectCharacterDropdown, character)
        end)
    end,
    ["CHAT_MSG_COMBAT_HONOR_GAIN"] = function(honorGained)
        if isInBGBlitz then
            local character = UnitName("player")
            if IncCalloutDB[character] then
                IncCalloutDB[character].blitzHonor = (IncCalloutDB[character].blitzHonor or 0) + tonumber(honorGained)
                UpdateSoloRBGStatsFrame(character)
            end
        end
    end
}

local function EventHandler(self, event, ...)
    if eventHandlers[event] then
        eventHandlers[event](...)
    else
        SavePvPStats()
        local character = UnitName("player")
        UpdatePvPStatsFrame(character)
        UpdateBGStatsFrame(character)
        UpdateSoloRBGStatsFrame(character)
        UpdateSoloShuffleStatsFrame(character)
        UpdateMiscStatsFrame(character)
    end
end

local frame = CreateFrame("Frame")
for event in pairs(eventHandlers) do
    frame:RegisterEvent(event)
end
frame:SetScript("OnEvent", EventHandler)



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
    "Ashran", "StormShield", "The Ringing Deeps", "Deephaul Ravine",  
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
    },
    healRequest = {
        "Need heals ASAP!",
        "Healing needed at my position!",
        "Can someone heal me, please?",
        "Healers, your assistance is required!",
        "I'm in dire need of healing!",
        "Could use some healing here!",
        "Healers, please focus on our location!",
        "Urgent healing needed to stay in the fight!",
        "Heal me up to keep the pressure on!",
        "Healers, attention needed here now!"
    },
    efcRequest = {
        "Get the EFC!!",
        "EFC spotted, group up to kill and recover our flag!",
        "Kill the EFC on sight, let's bring that flag home!",
        "EFC is vulnerable, kill them now!",
        "Everyone on the EFC!",
        "Close in and kill the EFC, no escape allowed!",
        "EFC heading towards their base—kill them before they cap!",
        "The EFC is weak, finish them off!",
        "Kill the EFC now, they're almost at their base!",
        "It’s a race against time, kill the EFC and secure our victory!"
    },
    fcRequest = {
        "Protect our FC!",
        "FC needs help!!",
        "Heals on FC!",
        "Need some help with the FC.",
        "Someone needs to get the flag.",
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
	SuperSunday = "Interface\\AddOns\\IncCallout\\Textures\\SuperSunday.png",	
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
        bgFile = LSM:Fetch("statusbar", IncDB.statusbarTexture or "Blizzard"),
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
            PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
            if onClick then 
                onClick(self)
            end
        end
    end)

    return button
end

-- Function to handle chat messages
local function onChatMessage(message)
    if string.find(message, "%[Incoming%-BG%]") then
        
    end
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
        button:SetBackdrop({
            bgFile = LSM:Fetch("statusbar", IncDB.statusbarTexture),
            edgeFile = nil, 
            tile = false, 
            tileSize = 0, 
            edgeSize = 16, 
            insets = {left = 0, right = 0, top = 0, bottom = 0} 
        })
        button:SetBackdropColor(r, g, b, a)
        button:SetBackdropBorderColor(0, 0, 0, 0) 
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

local function applyStatusbarTexture()
    local texture = LSM:Fetch("statusbar", IncDB.statusbarTexture or "Blizzard")
    for _, button in ipairs(buttons) do
        button:SetBackdrop({
            bgFile = texture,
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true,
            tileSize = 12,
            edgeSize = 7,
            insets = {left = 1, right = 1, top = 1, bottom = 1}
        })
        -- Reapply the color overlay after setting the backdrop
        applyButtonColor()
    end
end

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
                    type = "group",
                    name = "Send More Message",
                    inline = true,
                    order = 1,
                    args = {
                        predefined = {
                            type = "select",
                            name = "Predefined",
                            desc = "Select the message for the 'Send More' button",
                            values = buttonMessages.sendMore,
                            get = function() return IncDB.sendMoreIndex end,
                            set = function(_, newValue)
                                IncDB.sendMoreIndex = newValue
                                LibStub("AceConfigRegistry-3.0"):NotifyChange("IncCallout")
                            end,
                            order = 1,
                        },
                        custom = {
                            type = "input",
                            name = "Custom",
                            desc = "Enter a custom message for the 'Send More' button",
                            get = function() return IncDB.customMessages.sendMore end,
                            set = function(_, value)
                                IncDB.customMessages.sendMore = value
                            end,
                            order = 2,
                        },
                        clear = {
                            type = "execute",
                            name = "Clear",
                            desc = "Clear custom message for 'Send More'",
                            func = function()
                                IncDB.customMessages.sendMore = ""
                                LibStub("AceConfigRegistry-3.0"):NotifyChange("IncCallout")
                            end,
                            order = 3,
                        },
                        previewSendMore = {
                            type = "description",
                            name = function() return "|cff00ff00Preview: " .. addonNamespace.getPreviewText("sendMore") .. "|r" end,
                            fontSize = "medium",
                            order = 4,
                        },
                    },
                },
                inc = {
                    type = "group",
                    name = "INC Message",
                    inline = true,
                    order = 2,
                    args = {
                        predefined = {
                            type = "select",
                            name = "Predefined",
                            desc = "Select the message for the 'INC' button",
                            values = buttonMessages.inc,
                            get = function() return IncDB.incIndex end,
                            set = function(_, newValue)
                                IncDB.incIndex = newValue
                                LibStub("AceConfigRegistry-3.0"):NotifyChange("IncCallout")
                            end,
                            order = 1,
                        },
                        custom = {
                            type = "input",
                            name = "Custom",
                            desc = "Enter a custom message for the 'INC' button",
                            get = function() return IncDB.customMessages.inc end,
                            set = function(_, value)
                                IncDB.customMessages.inc = value
                            end,
                            order = 2,
                        },
                        clear = {
                            type = "execute",
                            name = "Clear",
                            desc = "Clear custom message for 'INC'",
                            func = function()
                                IncDB.customMessages.inc = ""
                                LibStub("AceConfigRegistry-3.0"):NotifyChange("IncCallout")
                            end,
                            order = 3,
                        },
                        previewInc = {
                            type = "description",
                            name = function() return "|cff00ff00Preview: " .. addonNamespace.getPreviewText("inc") .. "|r" end,
                            fontSize = "medium",
                            order = 4,
                        },
                    },
                },
                allClear = {
                    type = "group",
                    name = "All Clear Message",
                    inline = true,
                    order = 3,
                    args = {
                        predefined = {
                            type = "select",
                            name = "Predefined",
                            desc = "Select the message for the 'All Clear' button",
                            values = buttonMessages.allClear,
                            get = function() return IncDB.allClearIndex end,
                            set = function(_, newValue)
                                IncDB.allClearIndex = newValue
                                LibStub("AceConfigRegistry-3.0"):NotifyChange("IncCallout")
                            end,
                            order = 1,
                        },
                        custom = {
                            type = "input",
                            name = "Custom",
                            desc = "Enter a custom message for the 'All Clear' button",
                            get = function() return IncDB.customMessages.allClear end,
                            set = function(_, value)
                                IncDB.customMessages.allClear = value
                            end,
                            order = 2,
                        },
                        clear = {
                            type = "execute",
                            name = "Clear",
                            desc = "Clear custom message for 'All Clear'",
                            func = function()
                                IncDB.customMessages.allClear = ""
                                LibStub("AceConfigRegistry-3.0"):NotifyChange("IncCallout")
                            end,
                            order = 3,
                        },
                        previewAllClear = {
                            type = "description",
                            name = function() return "|cff00ff00Preview: " .. addonNamespace.getPreviewText("allClear") .. "|r" end,
                            fontSize = "medium",
                            order = 4,
                        },
                    },
                },
                buffRequest = {
                    type = "group",
                    name = "Buff Request Message",
                    inline = true,
                    order = 4,
                    args = {
                        predefined = {
                            type = "select",
                            name = "Predefined",
                            desc = "Select the message for the 'Request Buffs' button",
                            values = buttonMessages.buffRequest,
                            get = function() return IncDB.buffRequestIndex end,
                            set = function(_, newValue)
                                buttonMessageIndices.buffRequest = newValue
                                IncDB.buffRequestIndex = newValue
                                LibStub("AceConfigRegistry-3.0"):NotifyChange("IncCallout")
                            end,
                            order = 1,
                        },
                        custom = {
                            type = "input",
                            name = "Custom",
                            desc = "Enter a custom message for the 'Request Buffs' button",
                            get = function() return IncDB.customMessages.buffRequest end,
                            set = function(_, value)
                                IncDB.customMessages.buffRequest = value
                            end,
                            order = 2,
                        },
                        clear = {
                            type = "execute",
                            name = "Clear",
                            desc = "Clear custom message for 'Request Buffs'",
                            func = function()
                                IncDB.customMessages.buffRequest = ""
                                LibStub("AceConfigRegistry-3.0"):NotifyChange("IncCallout")
                            end,
                            order = 3,
                        },
                        previewBuffRequest = {
                            type = "description",
                            name = function() return addonNamespace.getPreviewText("buffRequest") end,
                            fontSize = "medium",
                            order = 4,
                        },
                    },
                },
                healRequest = {
                    type = "group",
                    name = "Heal Request Message",
                    inline = true,
                    order = 5,
                    args = {
                        predefined = {
                            type = "select",
                            name = "Predefined",
                            desc = "Select the message for the 'Need Heals' button",
                            values = buttonMessages.healRequest,
                            get = function() return IncDB.healRequestIndex end,
                            set = function(_, newValue)
                                buttonMessageIndices.healRequest = newValue
                                IncDB.healRequestIndex = newValue
                                LibStub("AceConfigRegistry-3.0"):NotifyChange("IncCallout")
                            end,
                            order = 1,
                        },
                        custom = {
                            type = "input",
                            name = "Custom",
                            desc = "Enter a custom message for the 'Need Heals' button",
                            get = function() return IncDB.customMessages.healRequest end,
                            set = function(_, value)
                                IncDB.customMessages.healRequest = value
                            end,
                            order = 2,
                        },
                        clear = {
                            type = "execute",
                            name = "Clear",
                            desc = "Clear custom message for 'Need Heals'",
                            func = function()
                                IncDB.customMessages.healRequest = ""
                                LibStub("AceConfigRegistry-3.0"):NotifyChange("IncCallout")
                            end,
                            order = 3,
                        },
                        previewHealRequest = {
                            type = "description",
                            name = function() return addonNamespace.getPreviewText("healRequest") end,
                            fontSize = "medium",
                            order = 4,
                        },
                    },
                },
                efcRequest = {
                    type = "group",
                    name = "EFC Request Message",
                    inline = true,
                    order = 6,
                    args = {
                        predefined = {
                            type = "select",
                            name = "Predefined",
                            desc = "Select the message for the 'EFC' button",
                            values = buttonMessages.efcRequest,
                            get = function() return IncDB.efcRequestIndex end,
                            set = function(_, newValue)
                                buttonMessageIndices.efcRequest = newValue
                                IncDB.efcRequestIndex = newValue
                                LibStub("AceConfigRegistry-3.0"):NotifyChange("IncCallout")
                            end,
                            order = 1,
                        },
                        custom = {
                            type = "input",
                            name = "Custom",
                            desc = "Enter a custom message for the 'EFC' button",
                            get = function() return IncDB.customMessages.efcRequest end,
                            set = function(_, value)
                                IncDB.customMessages.efcRequest = value
                            end,
                            order = 2,
                        },
                        clear = {
                            type = "execute",
                            name = "Clear",
                            desc = "Clear custom message for 'EFC'",
                            func = function()
                                IncDB.customMessages.efcRequest = ""
                                LibStub("AceConfigRegistry-3.0"):NotifyChange("IncCallout")
                            end,
                            order = 3,
                        },
                        previewEFCRequest = {
                            type = "description",
                            name = function() return addonNamespace.getPreviewText("efcRequest") end,
                            fontSize = "medium",
                            order = 4,
                        },
                    },
                },
                fcRequest = {
                    type = "group",
                    name = "FC Request Message",
                    inline = true,
                    order = 7,
                    args = {
                        predefined = {
                            type = "select",
                            name = "Predefined",
                            desc = "Select the message for the 'FC' button",
                            values = buttonMessages.fcRequest,
                            get = function() return IncDB.fcRequestIndex end,
                            set = function(_, newValue)
                                buttonMessageIndices.fcRequest = newValue
                                IncDB.fcRequestIndex = newValue
                                LibStub("AceConfigRegistry-3.0"):NotifyChange("IncCallout")
                            end,
                            order = 1,
                        },
                        custom = {
                            type = "input",
                            name = "Custom",
                            desc = "Enter a custom message for the 'FC' button",
                            get = function() return IncDB.customMessages.fcRequest end,
                            set = function(_, value)
                                IncDB.customMessages.fcRequest = value
                            end,
                            order = 2,
                        },
                        clear = {
                            type = "execute",
                            name = "Clear",
                            desc = "Clear custom message for 'FC'",
                            func = function()
                                IncDB.customMessages.fcRequest = ""
                                LibStub("AceConfigRegistry-3.0"):NotifyChange("IncCallout")
                            end,
                            order = 3,
                        },
                        previewFCRequest = {
                            type = "description",
                            name = function() return addonNamespace.getPreviewText("fcRequest") end,
                            fontSize = "medium",
                            order = 4,
                        },
                    },
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
                statusbarTexture = {
                    type = "select",
                    name = "Statusbar Texture",
                    desc = "Select the texture for the statusbar.",
                    dialogControl = 'LSM30_Statusbar',
                    values = LSM:HashTable("statusbar"),
                    get = function() return IncDB.statusbarTexture or "Blizzard" end,
                    set = function(_, newValue)
                        IncDB.statusbarTexture = newValue
                        applyButtonColor()
					order = 5	
              end,
                 
                },
                lockGUI = {
                    type = "toggle",
                    name = "Lock GUI Window",
                    desc = "Lock or unlock the GUI window's position.",
                    order = 6,
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
                    order = 7,
                    values = {
                        ["None"] = "NONE",
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
                        ["SuperSunday"] = "SuperSunday",
                        ["Alligator"] = "Alligator",
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
                    order = 8, 
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

-- Register the options table using AceConfig
AceConfig:RegisterOptionsTable("Incoming-BG", options)

local optionsFrame = AceConfigDialog:AddToBlizOptions("Incoming-BG", "Incoming-BG")

if Settings then
    local function RegisterOptionsPanel(panel)
        local category = Settings.GetCategory(panel.name)
        if not category then
            category, layout = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
            category.ID = panel.name
            Settings.RegisterAddOnCategory(category)
        end
    end

    RegisterOptionsPanel(optionsFrame)
end

function addonNamespace.getPreviewText(messageType)
    local previewText = "|cff00ff00[Incoming-BG] "

    if messageType == "sendMore" and IncDB.customMessages.sendMore ~= "" then
        previewText = previewText .. IncDB.customMessages.sendMore
    elseif messageType == "sendMore" and IncDB.sendMoreIndex and buttonMessages.sendMore[IncDB.sendMoreIndex] then
        previewText = previewText .. buttonMessages.sendMore[IncDB.sendMoreIndex]
    elseif messageType == "inc" and IncDB.customMessages.inc ~= "" then
        previewText = previewText .. IncDB.customMessages.inc
    elseif messageType == "inc" and IncDB.incIndex and buttonMessages.inc[IncDB.incIndex] then
        previewText = previewText .. buttonMessages.inc[IncDB.incIndex]
    elseif messageType == "allClear" and IncDB.customMessages.allClear ~= "" then
        previewText = previewText .. IncDB.customMessages.allClear
    elseif messageType == "allClear" and IncDB.allClearIndex and buttonMessages.allClear[IncDB.allClearIndex] then
        previewText = previewText .. buttonMessages.allClear[IncDB.allClearIndex]
    elseif messageType == "buffRequest" and IncDB.customMessages.buffRequest ~= "" then
        previewText = previewText .. IncDB.customMessages.buffRequest
    elseif messageType == "buffRequest" and IncDB.buffRequestIndex and buttonMessages.buffRequest[IncDB.buffRequestIndex] then
        previewText = previewText .. buttonMessages.buffRequest[IncDB.buffRequestIndex]
    elseif messageType == "healRequest" and IncDB.customMessages.healRequest ~= "" then
        previewText = previewText .. IncDB.customMessages.healRequest
    elseif messageType == "healRequest" and IncDB.healRequestIndex and buttonMessages.healRequest[IncDB.healRequestIndex] then
        previewText = previewText .. buttonMessages.healRequest[IncDB.healRequestIndex]
    elseif messageType == "efcRequest" and IncDB.customMessages.efcRequest ~= "" then
        previewText = previewText .. IncDB.customMessages.efcRequest
    elseif messageType == "efcRequest" and IncDB.efcRequestIndex and buttonMessages.efcRequest[IncDB.efcRequestIndex] then
        previewText = previewText .. buttonMessages.efcRequest[IncDB.efcRequestIndex]
    elseif messageType == "fcRequest" and IncDB.customMessages.fcRequest ~= "" then
        previewText = previewText .. IncDB.customMessages.fcRequest
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

    local currentLocation = GetSubZoneText()
   
    local message = self:GetText() .. " Incoming at " .. currentLocation
    SendChatMessage(message, "INSTANCE_CHAT")
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
            if Settings.OpenToCategory then
                Settings.OpenToCategory("Incoming-BG")
            else
                print("Options frame function not available")
            end
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
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    local location = GetSubZoneText()
    if not location then
        print("You are not in a Battleground.")
        return
    end
    local message = IncDB.customMessages.allClear ~= "" and IncDB.customMessages.allClear or buttonMessages.allClear[buttonMessageIndices.allClear]
    message = message .. " at " .. location
    SendChatMessage(message, "INSTANCE_CHAT")
end

-- Function to handle the Send More button click event
local function SendMoreButtonOnClick()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    local location = GetSubZoneText()
    if not location then
        print("You are not in a Battleground.")
        return
    end
    local message = IncDB.customMessages.sendMore ~= "" and IncDB.customMessages.sendMore or buttonMessages.sendMore[buttonMessageIndices.sendMore]
    message = message .. " at " .. location
    SendChatMessage(message, "INSTANCE_CHAT")
end

-- Function to handle the INC button click event
local function IncButtonOnClick()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    local location = GetSubZoneText()
    if not location then
        print("You are not in a Battleground.")
        return
    end
    local message = IncDB.customMessages.inc ~= "" and IncDB.customMessages.inc or buttonMessages.inc[buttonMessageIndices.inc]
    message = message .. " at " .. location
    SendChatMessage(message, "INSTANCE_CHAT")
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

    local message = IncDB.customMessages.efcRequest ~= "" and IncDB.customMessages.efcRequest or buttonMessages.efcRequest[IncDB.efcRequestIndex]
    SendChatMessage(message, chatType)
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

    local message = IncDB.customMessages.fcRequest ~= "" and IncDB.customMessages.fcRequest or buttonMessages.fcRequest[IncDB.fcRequestIndex]
    SendChatMessage(message, chatType)
end

-- Function to handle the Heals button click event
local function HealsButtonOnClick()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    local location = GetSubZoneText()
    if not location then
        print("You are not in a Battleground.")
        return
    end

    local message = IncDB.customMessages.healRequest ~= "" and IncDB.customMessages.healRequest or buttonMessages.healRequest[IncDB.healRequestIndex]
    message = message .. " Needed at " .. location
    SendChatMessage(message, "INSTANCE_CHAT")
end

-- Function to handle the Buff Request button click event
local function BuffRequestButtonOnClick()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)

    local messageIndex = buttonMessageIndices.buffRequest or 1
    local message = IncDB.customMessages.buffRequest ~= "" and IncDB.customMessages.buffRequest or buttonMessages.buffRequest[messageIndex]
    
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

-- Create a single frame to handle all events
local frame = CreateFrame("Frame", "IncCalloutFrame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_LEAVING_WORLD")
frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
frame:RegisterEvent("HONOR_XP_UPDATE")
frame:RegisterEvent("CHAT_MSG_INSTANCE_CHAT")
frame:RegisterEvent("WEEKLY_REWARDS_UPDATE")
frame:RegisterEvent("PVP_RATED_STATS_UPDATE")
frame:RegisterEvent("PVP_REWARDS_UPDATE")
frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
frame:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("PVP_BRAWL_INFO_UPDATED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("COMBAT_RATING_UPDATE")
frame:RegisterEvent("ARENA_SEASON_WORLD_STATE")
frame:RegisterEvent("PLAYER_PVP_RANK_CHANGED")
frame:SetScript("OnEvent", EventHandler)

local function OnEvent(self, event, arg1, ...)
    
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

    elseif event == "PLAYER_LOGIN" then
        SavePvPStats()
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

    elseif event == "PLAYER_LOGOUT" or event == "CURRENCY_DISPLAY_UPDATE" or event == "HONOR_XP_UPDATE" then
        UpdatePvPStatsFrame()
        UpdatePoints()

    elseif event == "PLAYER_ENTERING_WORLD" then
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

    elseif event == "CHAT_MSG_INSTANCE_CHAT" then
        local message = arg1
        onChatMessage(message)

    elseif event == "PVP_RATED_STATS_UPDATE" or event == "ACTIVE_TALENT_GROUP_CHANGED" then        
        local index = 7  
        local rating = select(2, GetPersonalRatedInfo(index))  
        
        UpdatePvPStatsFrame(rating)
    end
end

-- Register the function to the frame and events
frame:SetScript("OnEvent", OnEvent)

-- Register additional events for pvpStatsFrame
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