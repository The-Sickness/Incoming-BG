-- Incoming-BG
-- Made by Sharpedge_Gaming
-- v11.3

local addonName, addonNamespace = ...

-- Libraries
local LibStub           = LibStub
local AceDB             = LibStub:GetLibrary("AceDB-3.0")
local AceConfig         = LibStub:GetLibrary("AceConfig-3.0")
local AceConfigDialog   = LibStub:GetLibrary("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub:GetLibrary("AceConfigRegistry-3.0")
local LDB               = LibStub:GetLibrary("LibDataBroker-1.1")
local LDBIcon           = LibStub:GetLibrary("LibDBIcon-1.0")
local LSM               = LibStub:GetLibrary("LibSharedMedia-3.0")
LSM:Register("statusbar", "Blizzard", "Interface\\TargetingFrame\\UI-StatusBar")

local APP_NAME       = "Incoming-BG"
local ICON_NAME      = "IncCallout"
local CHAT_TAG       = "|cffff9900[Incoming-BG]|r "
local MAX_CHAT_BYTES = 255

local CONQUEST_CURRENCY_ID = (Constants and Constants.CurrencyConsts and Constants.CurrencyConsts.CONQUEST_CURRENCY_ID) or 1602
local HONOR_CURRENCY_ID    = 1792
local SOLO_SHUFFLE_INDEX   = 7
local SOLO_RBG_INDEX       = 9

local db  -- AceDB object, created on ADDON_LOADED

local defaults = {
    profile = {
        buttonColor      = { r = 1, g = 0, b = 0, a = 1 },
        fontColor        = { r = 1, g = 1, b = 1, a = 1 },
        logoColor        = { r = 1, g = 1, b = 1, a = 1 },
        font             = "Friz Quadrata TT",
        fontSize         = 14,
        statusbarTexture = "Blizzard",
        selectedBorderIndex = 1,
        selectedColorIndex  = 1,
        selectedLogo     = "None",
        scale            = 1,
        isLocked         = false,
        enemySpecLabels  = true,
        minimap          = { hide = false, minimapPos = 45 },
        sendMoreIndex    = 1,
        incIndex         = 1,
        allClearIndex    = 1,
        buffRequestIndex = 1,
        healRequestIndex = 1,
        efcRequestIndex  = 1,
        fcRequestIndex   = 1,
        customMessages = {
            sendMore    = "",
            inc         = "",
            allClear    = "",
            buffRequest = "",
            healRequest = "",
            efcRequest  = "",
            fcRequest   = "",
        },
    },
    global = {
        characters = {},
    },
}

-- Helpers

-- Cuts a string to a byte limit without splitting a multibyte character
local function Utf8Truncate(s, maxBytes)
    if #s <= maxBytes then return s end
    local out, len = {}, 0
    for ch in s:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        if len + #ch > maxBytes then break end
        out[#out + 1] = ch
        len = len + #ch
    end
    return table.concat(out)
end

local function IsInPvP()
    local inInstance, instanceType = IsInInstance()
    return inInstance and (instanceType == "pvp" or instanceType == "arena")
end

local function IsInBattleground()
    local inInstance, instanceType = IsInInstance()
    return inInstance and instanceType == "pvp"
end

local function GetCurrentLocation()
    local subzone = GetSubZoneText()
    if subzone and subzone ~= "" then return subzone end
    local zone = GetZoneText()
    if zone and zone ~= "" then return zone end
    return "Unknown Location"
end

local function GetInstanceChatCmd()
    if IsInPvP() then
        return "/i"
    elseif IsInRaid() then
        return "/raid"
    elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
        return "/p"
    end
    return "/i"
end

local function GetShareChatCmd()
    if IsInPvP() then
        if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then return "/i" end
        if IsInGroup(LE_PARTY_CATEGORY_HOME) then return "/p" end
    end
    return "/say"
end

local function GetCharacterKey()
    local name = UnitName("player")
    local realm = GetNormalizedRealmName and GetNormalizedRealmName()
    if not realm or realm == "" then
        realm = (GetRealmName() or ""):gsub("%s+", "")
    end
    if not name or realm == "" then return nil end
    return name .. "-" .. realm
end

-- Messages

local buttonMessages = {
    sendMore = {
        "We need more peeps", "Need help", "We are outnumbered", "Need a few more", "Need more",
        "Backup required", "We could use some help", "Calling for backup", "Could use some backup",
        "Reinforcements needed", "In need of additional support", "Calling all hands on deck",
        "Require extra manpower", "Assistance urgently needed", "Requesting more participants",
    },
    inc = {
        "Incoming", "INC INC INC", "INC", "Gotta INC", "BIG INC",
        "Incoming enemy forces", "Incoming threat", "Enemy push incoming", "Enemy blitz incoming",
        "Enemy strike team inbound", "Incoming attack alert", "Enemy wave inbound",
        "Enemy squad closing in", "Anticipate enemy push", "Enemy forces are closing in",
    },
    allClear = {
        "We are all clear", "All clear", "Looks like a ghost town", "All good", "Looking good",
        "Area secure", "All quiet on the front", "Situation is under control", "All quiet here",
        "We are looking good", "Perimeter is secured", "Situation is calm", "No threats detected",
        "All quiet on this end", "Area is threat-free",
    },
    buffRequest = {
        "Need buffs please!", "Buff up, team!", "Could use some buffs here!",
        "Calling for all buffs, lets gear up!", "Looking for that magical boost, buffs needed!",
        "Time to get enchanted, where are those buffs?", "Lets get buffed for the battle ahead!",
        "Buffs are our best friends, lets have them!", "Ready for buffs, lets enhance our strength!",
        "Buffs needed for extra might and magic!", "Gimme some buffs, lets not fall behind!",
    },
    healRequest = {
        "Need heals ASAP!", "Healing needed at my position!", "Can someone heal me, please?",
        "Healers, your assistance is required!", "I'm in dire need of healing!",
        "Could use some healing here!", "Healers, please focus on our location!",
        "Urgent healing needed to stay in the fight!", "Heal me up to keep the pressure on!",
        "Healers, attention needed here now!",
    },
    efcRequest = {
        "Get the EFC!!", "EFC spotted, group up to kill and recover our flag!",
        "Kill the EFC on sight, lets bring that flag home!", "EFC is vulnerable, kill them now!",
        "Everyone on the EFC!", "Close in and kill the EFC, no escape allowed!",
        "EFC heading towards their base, kill them before they cap!", "The EFC is weak, finish them off!",
        "Kill the EFC now, they're almost at their base!",
        "Its a race against time, kill the EFC and secure our victory!",
    },
    fcRequest = {
        "Protect our FC!", "FC needs help!!", "Heals on FC!",
        "Need some help with the FC.", "Someone needs to get the flag.",
    },
}

local function GetMessage(messageType, fallback)
    local custom = IncDB and IncDB.customMessages and IncDB.customMessages[messageType]
    if custom and custom ~= "" then return custom end
    local list = buttonMessages[messageType]
    local index = IncDB and IncDB[messageType .. "Index"] or 1
    return (list and list[index]) or fallback
end

function addonNamespace.getPreviewText(messageType)
    return "|cff00ff00[Incoming-BG] " .. (GetMessage(messageType, "") or "") .. "|r"
end

-- Appearance option lists

local colorOptions = {
    { name = "Semi-Transparent Black",   color = {0, 0, 0, 0.5} },
    { name = "Solid Black",              color = {0, 0, 0, 1} },
    { name = "Semi-Transparent White",   color = {1, 1, 1, 0.5} },
    { name = "Solid White",              color = {1, 1, 1, 1} },
    { name = "Semi-Transparent Red",     color = {1, 0, 0, 0.5} },
    { name = "Solid Red",                color = {1, 0, 0, 1} },
    { name = "Semi-Transparent Green",   color = {0, 1, 0, 0.5} },
    { name = "Solid Green",              color = {0, 1, 0, 1} },
    { name = "Semi-Transparent Blue",    color = {0, 0, 1, 0.5} },
    { name = "Solid Blue",               color = {0, 0, 1, 1} },
    { name = "Semi-Transparent Yellow",  color = {1, 1, 0, 0.5} },
    { name = "Solid Yellow",             color = {1, 1, 0, 1} },
    { name = "Semi-Transparent Cyan",    color = {0, 1, 1, 0.5} },
    { name = "Solid Cyan",               color = {0, 1, 1, 1} },
    { name = "Semi-Transparent Magenta", color = {1, 0, 1, 0.5} },
    { name = "Solid Magenta",            color = {1, 0, 1, 1} },
    { name = "Semi-Transparent Orange",  color = {1, 0.5, 0, 0.5} },
    { name = "Solid Orange",             color = {1, 0.5, 0, 1} },
    { name = "Semi-Transparent Purple",  color = {0.5, 0, 0.5, 0.5} },
    { name = "Solid Purple",             color = {0.5, 0, 0.5, 1} },
    { name = "Semi-Transparent Grey",    color = {0.5, 0.5, 0.5, 0.5} },
    { name = "Solid Grey",               color = {0.5, 0.5, 0.5, 1} },
    { name = "Semi-Transparent Teal",    color = {0, 0.5, 0.5, 0.5} },
    { name = "Solid Teal",               color = {0, 0.5, 0.5, 1} },
    { name = "Semi-Transparent Pink",    color = {1, 0.75, 0.8, 0.5} },
    { name = "Solid Pink",               color = {1, 0.75, 0.8, 1} },
}

local borderOptions = {
    { name = "Azerite",       file = "Interface/Tooltips/UI-Tooltip-Border-Azerite" },
    { name = "Classic",       file = "Interface/Tooltips/UI-Tooltip-Border" },
    { name = "Sleek",         file = "Interface/DialogFrame/UI-DialogBox-Border" },
    { name = "Corrupted",     file = "Interface/Tooltips/UI-Tooltip-Border-Corrupted" },
    { name = "Maw",           file = "Interface/Tooltips/UI-Tooltip-Border-Maw" },
    { name = "Smooth",        file = "Interface/LFGFRAME/LFGBorder" },
    { name = "Glass",         file = "Interface/DialogFrame/UI-DialogBox-TestWatermark-Border" },
    { name = "Gold",          file = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border" },
    { name = "Slide",         file = "Interface\\FriendsFrame\\UI-Toast-Border" },
    { name = "Glow",          file = "Interface\\TutorialFrame\\UI-TutorialFrame-CalloutGlow" },
    { name = "Glow 2",        file = "Interface\\AddOns\\IncCallout\\Textures\\BG15.blp" },
    { name = "Grey",          file = "Interface\\Tooltips\\UI-Tooltip-Background" },
    { name = "Blue",          file = "Interface\\AddOns\\IncCallout\\Textures\\BG1.png" },
    { name = "Black Gloss",   file = "Interface\\AddOns\\IncCallout\\Textures\\BG2.blp" },
    { name = "Silverish",     file = "Interface\\AddOns\\IncCallout\\Textures\\BG3.blp" },
    { name = "Bevel",         file = "Interface\\AddOns\\IncCallout\\Textures\\BG4.blp" },
    { name = "Bevel 2",       file = "Interface\\AddOns\\IncCallout\\Textures\\BG5.blp" },
    { name = "Fade",          file = "Interface\\AddOns\\IncCallout\\Textures\\BG6.blp" },
    { name = "Fade 2",        file = "Interface\\AddOns\\IncCallout\\Textures\\BG7.blp" },
    { name = "Thin Line",     file = "Interface\\AddOns\\IncCallout\\Textures\\BG8.blp" },
    { name = "2 Tone",        file = "Interface\\AddOns\\IncCallout\\Textures\\BG9.blp" },
    { name = "Bluish",        file = "Interface\\AddOns\\IncCallout\\Textures\\BG10.blp" },
    { name = "Neon Yellow",   file = "Interface\\AddOns\\IncCallout\\Textures\\BG11.blp" },
    { name = "Neon Red",      file = "Interface\\AddOns\\IncCallout\\Textures\\BG12.blp" },
    { name = "Neon Green",    file = "Interface\\AddOns\\IncCallout\\Textures\\BG13.blp" },
    { name = "Neon Blue",     file = "Interface\\AddOns\\IncCallout\\Textures\\BG14.blp" },
    { name = "Double Yellow", file = "Interface\\AddOns\\IncCallout\\Textures\\BG16.blp" },
}

local logos = {
    None        = "",
    BearClaw    = "Interface\\AddOns\\IncCallout\\Textures\\BearClaw.png",
    BreatheFire = "Interface\\AddOns\\IncCallout\\Textures\\BreatheFire.png",
    Bloody      = "Interface\\AddOns\\IncCallout\\Textures\\Bloody.png",
    Impact      = "Interface\\AddOns\\IncCallout\\Textures\\Impact.png",
    Shock       = "Interface\\AddOns\\IncCallout\\Textures\\Shock.png",
    Rifle       = "Interface\\AddOns\\IncCallout\\Textures\\Rifle.png",
    Condiment   = "Interface\\AddOns\\IncCallout\\Textures\\Condiment.png",
    Duplex      = "Interface\\AddOns\\IncCallout\\Textures\\Duplex.png",
    Eraser      = "Interface\\AddOns\\IncCallout\\Textures\\Eraser.png",
    Ogre        = "Interface\\AddOns\\IncCallout\\Textures\\Ogre.png",
    SuperSunday = "Interface\\AddOns\\IncCallout\\Textures\\SuperSunday.png",
    GOW         = "Interface\\AddOns\\IncCallout\\Textures\\GOW.png",
    Maiden      = "Interface\\AddOns\\IncCallout\\Textures\\Maiden.png",
    Metal       = "Interface\\AddOns\\IncCallout\\Textures\\Metal.png",
    Alligator   = "Interface\\AddOns\\IncCallout\\Textures\\Alligator.png",
    SourceCode  = "Interface\\AddOns\\IncCallout\\Textures\\SourceCode.png",
    InkFree     = "Interface\\AddOns\\IncCallout\\Textures\\InkFree.png",
}

local logoValues = {}
for key in pairs(logos) do
    logoValues[key] = (key == "None") and "NONE" or key
end

-- Main window

local IncCallout = CreateFrame("Frame", "IncCallout", UIParent, "BackdropTemplate")
IncCallout:SetSize(225, 280)
IncCallout:SetPoint("CENTER")
IncCallout:Hide()
IncCallout:SetMovable(true)
IncCallout:EnableMouse(true)
IncCallout:RegisterForDrag("LeftButton")
IncCallout:SetScript("OnDragStart", function(self)
    if not (IncDB and IncDB.isLocked) and not InCombatLockdown() then
        self:StartMoving()
    end
end)
IncCallout:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

local closeButton = CreateFrame("Button", nil, IncCallout, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", IncCallout, "TOPRIGHT", -5, -5)
closeButton:SetSize(24, 24)
closeButton:SetScript("OnClick", function()
    if InCombatLockdown() then
        print(CHAT_TAG .. "The window can't be closed during combat.")
        return
    end
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    IncCallout:Hide()
end)
closeButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Close the Window", nil, nil, nil, nil, true)
    GameTooltip:Show()
end)
closeButton:SetScript("OnLeave", GameTooltip_Hide)

local logo = IncCallout:CreateTexture(nil, "ARTWORK")
logo:SetSize(180, 30)
logo:SetPoint("TOP", IncCallout, "TOP", -5, 30)
logo:Hide()

function IncCallout:SetLogo(selectedLogo)
    local path = logos[selectedLogo]
    if not path or path == "" then
        logo:Hide()
        return
    end
    logo:SetTexture(path)
    logo:Show()
end

-- Live location indicator
-- Secure button text is frozen during combat. This label is a plain FontString,
-- so it can update in combat and tell the player what the buttons will actually say.

local bakedLocation = nil
local locationStale = false

local locationArea = CreateFrame("Frame", nil, IncCallout)
locationArea:SetPoint("TOP", IncCallout, "TOP", 0, -18)
locationArea:SetSize(170, 16)
locationArea:EnableMouse(true)
locationArea:RegisterForDrag("LeftButton")
locationArea:SetScript("OnDragStart", function()
    if not (IncDB and IncDB.isLocked) and not InCombatLockdown() then
        IncCallout:StartMoving()
    end
end)
locationArea:SetScript("OnDragStop", function()
    IncCallout:StopMovingOrSizing()
end)

local locationText = locationArea:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
locationText:SetAllPoints(locationArea)
locationText:SetJustifyH("CENTER")
locationText:SetWordWrap(false)

local function UpdateLocationLabel()
    if not bakedLocation then
        locationText:SetText("")
        locationStale = false
        return
    end
    if GetCurrentLocation() == bakedLocation then
        locationStale = false
        locationText:SetText("|cffaaaaaaCalling:|r |cff00ff00" .. bakedLocation .. "|r")
    else
        locationStale = true
        locationText:SetText("|cffff3333Outdated:|r |cffffaa00" .. bakedLocation .. "|r")
    end
end

locationArea:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText("Callout Location", 1, 1, 1)
    if locationStale then
        GameTooltip:AddLine("You moved during combat. WoW locks button messages while you are in combat, so your callouts will still say:", 1, 0.3, 0.3, true)
        GameTooltip:AddLine(bakedLocation or "", 1, 0.67, 0, true)
        GameTooltip:AddLine("This updates automatically as soon as combat ends.", 1, 1, 1, true)
    else
        GameTooltip:AddLine("This is the location your buttons will send to your team.", 1, 1, 1, true)
    end
    GameTooltip:Show()
end)
locationArea:SetScript("OnLeave", GameTooltip_Hide)

-- Buttons

local buttons     = {}  -- every button on the main window
local buttonTexts = {}  -- their font strings

-- All button labels share one font object. When WoW finishes loading a font file
-- (which can lag behind on a cold game start), it refreshes every label attached
-- to the font object, so text never gets stuck blank.
local buttonFont = CreateFont("IncCalloutButtonFont")
buttonFont:CopyFontObject(GameFontHighlight)

-- Every button gets its own label using the shared font object.
local function AttachLabel(button, text)
    local label = button:CreateFontString(nil, "OVERLAY")
    label:SetFontObject(buttonFont)
    label:SetPoint("CENTER", button, "CENTER", 0, 0)
    label:SetWordWrap(false)
    button:SetFontString(label)
    button:SetText(text)
end

local function StyleButton(button)
    button:GetFontString():SetTextColor(1, 1, 1, 1)
    button:SetBackdrop({
        bgFile   = LSM:Fetch("statusbar", "Blizzard"),
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile     = true, tileSize = 12, edgeSize = 7,
        insets   = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    buttonTexts[#buttonTexts + 1] = button:GetFontString()
    buttons[#buttons + 1] = button
end

local function Place(button, anchor, xOffset, yOffset)
    button:SetPoint(anchor[1], anchor[2], anchor[3], xOffset, yOffset)
end

-- Chat buttons are secure macro buttons. Their macrotext is written out of combat
-- by RebuildMacros, and Blizzard's secure code sends the message on click.
local secureButtons = {}

local function CreateSecureButton(name, width, height, text, anchor, xOffset, yOffset)
    local button = CreateFrame("Button", name, IncCallout, "SecureActionButtonTemplate,BackdropTemplate")
    button:SetSize(width, height)
    AttachLabel(button, text)
    button:SetAttribute("type", "macro")
    button:SetAttribute("macrotext", "")
    button:RegisterForClicks("AnyDown")
    Place(button, anchor, xOffset, yOffset)
    StyleButton(button)
    secureButtons[#secureButtons + 1] = button
    return button
end

local function CreatePlainButton(width, height, text, anchor, xOffset, yOffset)
    local button = CreateFrame("Button", nil, IncCallout, "BackdropTemplate")
    button:SetSize(width, height)
    AttachLabel(button, text)
    Place(button, anchor, xOffset, yOffset)
    StyleButton(button)
    return button
end

local button1        = CreateSecureButton("IncCalloutBtn1",        20, 22, "1",         {"TOPLEFT", IncCallout, "TOPLEFT"},  35, -40)
local button2        = CreateSecureButton("IncCalloutBtn2",        20, 22, "2",         {"LEFT", button1, "RIGHT"},          10,   0)
local button3        = CreateSecureButton("IncCalloutBtn3",        20, 22, "3",         {"LEFT", button2, "RIGHT"},          10,   0)
local button4        = CreateSecureButton("IncCalloutBtn4",        20, 22, "4",         {"LEFT", button3, "RIGHT"},          10,   0)
local buttonZerg     = CreateSecureButton("IncCalloutBtnZerg",     40, 22, "Zerg",      {"LEFT", button4, "RIGHT"},          10,   0)
local incButton      = CreateSecureButton("IncCalloutBtnInc",      95, 22, "Inc",       {"TOP", button3, "BOTTOM"},         -45, -10)
local sendMoreButton = CreateSecureButton("IncCalloutBtnSendMore", 95, 22, "Send More", {"LEFT", incButton, "RIGHT"},        10,   0)
local allClearButton = CreateSecureButton("IncCalloutBtnAllClear", 95, 22, "All Clear", {"TOP", incButton, "BOTTOM"},         0, -10)
local healsButton    = CreateSecureButton("IncCalloutBtnHeals",    95, 22, "Heals",     {"LEFT", allClearButton, "RIGHT"},   10,   0)
local efcButton      = CreateSecureButton("IncCalloutBtnEFC",      95, 22, "EFC",       {"TOP", allClearButton, "BOTTOM"},    0, -10)
local fcButton       = CreateSecureButton("IncCalloutBtnFC",       95, 22, "FC",        {"LEFT", efcButton, "RIGHT"},        10,   0)
local buffButton     = CreateSecureButton("IncCalloutBtnBuff",     95, 22, "Buffs",     {"TOP", efcButton, "BOTTOM"},         0, -10)
local healerButton   = CreateSecureButton("IncCalloutBtnHealers",  95, 22, "Healers",   {"TOP", buffButton, "BOTTOM"},        0, -10)
local shareButton    = CreateSecureButton("IncCalloutBtnShare",    95, 22, "Share",     {"BOTTOM", IncCallout, "BOTTOM"},     0,  10)

local markHealersButton = CreatePlainButton(95, 22, "Mark Healers", {"LEFT", buffButton, "RIGHT"},   10, 0)
local pvpStatsButton    = CreatePlainButton(95, 22, "PVP Stats",    {"LEFT", healerButton, "RIGHT"}, 10, 0)

-- Location callouts: "<prefix> Incoming at <location>"
local locationButtons = {
    { button = button1,    prefix = "1" },
    { button = button2,    prefix = "2" },
    { button = button3,    prefix = "3" },
    { button = button4,    prefix = "4" },
    { button = buttonZerg, prefix = "Zerg" },
}

-- Message callouts. locationJoin is nil for messages that don't include a location.
local messageButtons = {
    { button = incButton,      type = "inc",         fallback = "Incoming",           locationJoin = " at " },
    { button = sendMoreButton, type = "sendMore",    fallback = "Need more",          locationJoin = " at " },
    { button = allClearButton, type = "allClear",    fallback = "All clear",          locationJoin = " at " },
    { button = healsButton,    type = "healRequest", fallback = "Need heals ASAP!",   locationJoin = " Needed at " },
    { button = efcButton,      type = "efcRequest",  fallback = "Get the EFC!!" },
    { button = fcButton,       type = "fcRequest",   fallback = "Protect our FC!" },
    { button = buffButton,     type = "buffRequest", fallback = "Need buffs please!" },
}

-- Healer roster
-- Built out of combat, where role info is readable. Used by the Healers button
-- and as a fallback for nameplate marks when role checks are blocked in combat.

local healerNameList  = {}
local healerNameCache = {}

local function ConsiderHealer(unit)
    pcall(function()
        if not UnitExists(unit) then return end
        if UnitGroupRolesAssigned(unit) ~= "HEALER" then return end
        local name = GetUnitName(unit, true)
        if name and not healerNameCache[name] then
            healerNameCache[name] = true
            healerNameList[#healerNameList + 1] = name
        end
    end)
end

local function RebuildHealerCache()
    wipe(healerNameList)
    wipe(healerNameCache)
    local count = GetNumGroupMembers()
    if IsInRaid() then
        for i = 1, count do ConsiderHealer("raid" .. i) end
    elseif IsInGroup() then
        ConsiderHealer("player")
        for i = 1, count - 1 do ConsiderHealer("party" .. i) end
    end
end

-- Fits as many healer names as possible into one chat message
local function BuildHealerMessage()
    local total = #healerNameList
    if total == 0 then
        return "[Incoming-BG] We have no healers. Good luck!"
    end
    local prefix = "[Incoming-BG] Healers on our team: "
    local suffix = ". Now you know who to peel for."
    local shown = {}
    for i = 1, total do
        local remaining = total - i
        local more = (remaining > 0) and (" +" .. remaining .. " more") or ""
        local candidate = prefix .. table.concat(shown, ", ") .. ((#shown > 0) and ", " or "") .. healerNameList[i] .. more .. suffix
        if #candidate > MAX_CHAT_BYTES then break end
        shown[#shown + 1] = healerNameList[i]
    end
    local remaining = total - #shown
    local more = (remaining > 0) and (" +" .. remaining .. " more") or ""
    return Utf8Truncate(prefix .. table.concat(shown, ", ") .. more .. suffix, MAX_CHAT_BYTES)
end

-- Macro building

local function ChatMacro(cmd, body)
    return cmd .. " " .. Utf8Truncate(body, MAX_CHAT_BYTES)
end

local SHARE_MESSAGE = "Try Incoming-BG! It adds a GUI for fast battleground calls, just click a button for INC, Send More, FC, and more. No typing needed. Get it and help your team!"

-- Writes every chat button's macrotext. Only possible out of combat.
local function RebuildMacros()
    if InCombatLockdown() or not IncDB then return false end

    local loc = GetCurrentLocation()
    local cmd = GetInstanceChatCmd()

    for i = 1, #locationButtons do
        local spec = locationButtons[i]
        spec.button:SetAttribute("macrotext", ChatMacro(cmd, spec.prefix .. " Incoming at " .. loc))
    end

    for i = 1, #messageButtons do
        local spec = messageButtons[i]
        local body = GetMessage(spec.type, spec.fallback)
        if spec.locationJoin then
            body = body .. spec.locationJoin .. loc
        end
        spec.button:SetAttribute("macrotext", ChatMacro(cmd, body))
    end

    if IsInGroup() then
        healerButton:SetAttribute("macrotext", ChatMacro(cmd, BuildHealerMessage()))
    else
        healerButton:SetAttribute("macrotext", "/run print('|cffff9900[Incoming-BG]|r Not in a group.')")
    end

    shareButton:SetAttribute("macrotext", ChatMacro(GetShareChatCmd(), SHARE_MESSAGE))

    bakedLocation = loc
    UpdateLocationLabel()
    return true
end

-- Appearance

local function ApplyButtonColor()
    if InCombatLockdown() or not IncDB then return end
    local c = IncDB.buttonColor or defaults.profile.buttonColor
    local bg = LSM:Fetch("statusbar", IncDB.statusbarTexture or "Blizzard")
    for i = 1, #buttons do
        local button = buttons[i]
        button:SetBackdrop({
            bgFile = bg, edgeFile = nil, tile = false, tileSize = 0, edgeSize = 16,
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
        })
        button:SetBackdropColor(c.r, c.g, c.b, c.a)
        button:SetBackdropBorderColor(0, 0, 0, 0)
    end
end

local function ApplyFontSettings()
    if not IncDB then return end
    local path = LSM:Fetch("font", IncDB.font or "Friz Quadrata TT") or STANDARD_TEXT_FONT
    local size = IncDB.fontSize or 14
    local c = IncDB.fontColor or defaults.profile.fontColor
    -- If the chosen font fails to load, fall back to the game's default font
    if buttonFont:SetFont(path, size, "") == false then
        buttonFont:SetFont(STANDARD_TEXT_FONT, size, "")
    end
    for i = 1, #buttonTexts do
        local label = buttonTexts[i]
        label:SetFontObject(buttonFont)
        label:SetTextColor(c.r, c.g, c.b, c.a or 1)
        label:SetText(label:GetText())  -- forces a redraw with the new font
    end
end

local function ApplyBorder()
    if InCombatLockdown() or not IncDB then return end
    local option = borderOptions[IncDB.selectedBorderIndex or 1] or borderOptions[1]
    IncCallout:SetBackdrop({
        bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = option.file,
        tile     = false, tileSize = 16, edgeSize = 8,
        insets   = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    local color = (colorOptions[IncDB.selectedColorIndex or 1] or colorOptions[1]).color
    IncCallout:SetBackdropColor(unpack(color))
end

local function ApplyScale()
    if InCombatLockdown() or not IncDB then return end
    IncCallout:SetScale(IncDB.scale or 1)
end

local function ApplyLogo()
    if not IncDB then return end
    IncCallout:SetLogo(IncDB.selectedLogo or "None")
    local c = IncDB.logoColor or defaults.profile.logoColor
    logo:SetVertexColor(c.r, c.g, c.b, c.a)
end

local appearancePending = false

local function ApplyAllAppearance()
    if not IncDB then return end
    ApplyFontSettings()
    ApplyLogo()
    if InCombatLockdown() then
        appearancePending = true
        return
    end
    appearancePending = false
    ApplyBorder()
    ApplyScale()
    ApplyButtonColor()
end

IncCallout:SetScript("OnShow", function()
    if not InCombatLockdown() then ApplyButtonColor() end
    UpdateLocationLabel()
end)

-- PvP stats window

local pvpStatsFrame = CreateFrame("Frame", "IncCalloutPvPStatsFrame", UIParent, "BasicFrameTemplateWithInset")
pvpStatsFrame:SetSize(700, 320)
pvpStatsFrame:SetPoint("CENTER")
pvpStatsFrame:SetMovable(true)
pvpStatsFrame:EnableMouse(true)
pvpStatsFrame:RegisterForDrag("LeftButton")
pvpStatsFrame:SetScript("OnDragStart", pvpStatsFrame.StartMoving)
pvpStatsFrame:SetScript("OnDragStop", pvpStatsFrame.StopMovingOrSizing)
pvpStatsFrame:SetFrameStrata("HIGH")
pvpStatsFrame:Hide()
tinsert(UISpecialFrames, "IncCalloutPvPStatsFrame")

pvpStatsFrame.title = pvpStatsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
pvpStatsFrame.title:SetPoint("TOP", pvpStatsFrame, "TOP", 0, -3)
pvpStatsFrame.title:SetText("PvP Statistics")

-- Each tab lists its rows as { label, saved field, label color }
local STAT_TABS = {
    { name = "General", rows = {
        { "Player Name:",         "playerName",             {0, 1, 0} },
        { "Conquest Points:",     "conquestValue",          {1, 0, 0} },
        { "Honor Points:",        "honorValue",             {0, 0.75, 1} },
        { "Honor Level:",         "honorLevelValue",        {0.58, 0, 0.82} },
        { "Conquest Cap:",        "conquestCapValue",       {1, 0.5, 0} },
        { "Solo Shuffle Rating:", "soloShuffleRatingValue", {0, 0.75, 1} },
    }},
    { name = "BG's", rows = {
        { "BGs Played:",                   "bgPlayed",                   {0, 1, 0} },
        { "BGs Won:",                      "bgWon",                      {1, 0, 0} },
        { "BGs Lost:",                     "bgLost",                     {0, 0.75, 1} },
        { "Total Honorable Kills:",        "totalHonorableKills",        {0.58, 0, 0.82} },
        { "Battleground Honorable Kills:", "battlegroundHonorableKills", {1, 0.5, 0} },
    }},
    { name = "Solo RBG", rows = {
        { "Season Best Rating:", "bestRatingValue",     {0, 1, 0} },
        { "Games Won:",          "gamesWonValue",       {1, 0, 0} },
        { "Games Played:",       "gamesPlayedValue",    {0, 0.75, 1} },
        { "Most Played Spec:",   "mostPlayedSpecValue", {0.58, 0, 0.82} },
        { "Played the Most:",    "playedMostValue",     {1, 0.5, 0} },
        { "Current Rank:",       "currentRankValue",    {0, 1, 0} },
    }},
    { name = "Solo Shuffle", rows = {
        { "Season Best Rating:", "shuffleBestRatingValue",     {0, 1, 0} },
        { "Rounds Won:",         "shuffleRoundsWonValue",      {0, 0.75, 1} },
        { "Rounds Played:",      "shuffleRoundsPlayedValue",   {1, 0, 0} },
        { "Most Played Spec:",   "shuffleMostPlayedSpecValue", {0.58, 0, 0.82} },
    }},
    { name = "Misc", rows = {
        { "Total Kills (Exp or Honor):", "totalKillsValue",               {0, 1, 0} },
        { "Total Killing Blows:",        "totalKillingBlowsValue",        {1, 0, 0} },
        { "Battleground Killing Blows:", "battlegroundKillingBlowsValue", {0, 0.75, 1} },
        { "Total Deaths:",               "totalDeathsValue",              {0.58, 0, 0.82} },
        { "Battleground Deaths:",        "battlegroundDeathsValue",       {1, 0.5, 0} },
    }},
}

local tabFrame = CreateFrame("Frame", nil, pvpStatsFrame)
tabFrame:SetPoint("TOP", pvpStatsFrame, "TOP", 0, -30)
tabFrame:SetSize(700, 25)

local tabPages   = {}
local tabButtons = {}

local function SelectTab(index)
    for i = 1, #tabPages do
        tabPages[i]:SetShown(i == index)
        tabButtons[i]:SetNormalFontObject((i == index) and "GameFontHighlight" or "GameFontNormal")
    end
end

for index, tab in ipairs(STAT_TABS) do
    local tabButton = CreateFrame("Button", nil, tabFrame, "UIPanelButtonTemplate")
    tabButton:SetText(tab.name)
    tabButton:SetSize(120, 25)
    if index == 1 then
        tabButton:SetPoint("LEFT", tabFrame, "LEFT", 10, 0)
    else
        tabButton:SetPoint("LEFT", tabButtons[index - 1], "RIGHT", 5, 0)
    end
    tabButton:SetScript("OnClick", function() SelectTab(index) end)
    tabButtons[index] = tabButton

    local page = CreateFrame("Frame", nil, pvpStatsFrame)
    page:SetSize(700, 300)
    page:SetPoint("TOP", tabFrame, "BOTTOM", 0, -10)
    page.values = {}
    for row, def in ipairs(tab.rows) do
        local label = page:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", page, "TOPLEFT", 10, -10 - (row - 1) * 40)
        label:SetText(def[1])
        label:SetTextColor(unpack(def[3]))
        local value = page:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        value:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -2)
        value:SetTextColor(1, 0.84, 0)
        page.values[def[2]] = value
    end
    tabPages[index] = page
end
SelectTab(1)

local selectedCharacterKey = nil

local function RenderStats(key)
    local stats = key and db and db.global.characters[key]
    local shortName = key and key:match("^[^%-]+") or "N/A"
    for index, tab in ipairs(STAT_TABS) do
        local values = tabPages[index].values
        for _, def in ipairs(tab.rows) do
            local field = def[2]
            local fontString = values[field]
            if field == "playerName" then
                local c = stats and stats.classColor
                fontString:SetText(shortName)
                fontString:SetTextColor(c and c.r or 1, c and c.g or 1, c and c.b or 1)
            else
                local v = stats and stats[field]
                fontString:SetText((v ~= nil) and tostring(v) or "N/A")
            end
        end
    end
end

-- Stats collection

local function GetPvpRank(rating)
    if rating < 1000 then return "Unranked"
    elseif rating < 1200 then return "Combatant I"
    elseif rating < 1400 then return "Combatant II"
    elseif rating < 1600 then return "Challenger I"
    elseif rating < 1800 then return "Challenger II"
    elseif rating < 1950 then return "Rival I"
    elseif rating < 2100 then return "Rival II"
    elseif rating < 2400 then return "Duelist"
    else return "Elite" end
end

local function GetSpecName(specID)
    if specID and specID > 0 then
        return GetSpecializationNameForSpecID(specID) or "N/A"
    end
    return "N/A"
end

local function Stat(id)
    return GetStatistic(id) or "N/A"
end

local function CollectCurrencyStats(s)
    local conquest = C_CurrencyInfo.GetCurrencyInfo(CONQUEST_CURRENCY_ID)
    local honor    = C_CurrencyInfo.GetCurrencyInfo(HONOR_CURRENCY_ID)
    s.conquestValue = conquest and conquest.quantity or "N/A"
    if conquest then
        local cap = (conquest.maxQuantity and conquest.maxQuantity > 0) and conquest.maxQuantity or "No Cap"
        s.conquestCapValue = (conquest.totalEarned or 0) .. " / " .. cap
    else
        s.conquestCapValue = "N/A"
    end
    s.honorValue      = honor and honor.quantity or "N/A"
    s.honorLevelValue = UnitHonorLevel("player")

    local shuffleRating = GetPersonalRatedInfo(SOLO_SHUFFLE_INDEX)
    s.soloShuffleRatingValue = shuffleRating or "N/A"

    local weekly = C_WeeklyRewards.GetConquestWeeklyProgress()
    s.greatVaultSlots = weekly and weekly.unlocksCompleted or 0
end

local function CollectBGStats(s)
    local played, won = Stat(839), Stat(840)
    s.bgPlayed = played
    s.bgWon    = won
    if tonumber(played) and tonumber(won) then
        s.bgLost = tonumber(played) - tonumber(won)
    else
        s.bgLost = "N/A"
    end
    s.totalHonorableKills        = Stat(588)
    s.battlegroundHonorableKills = Stat(382)
end

local function CollectRatedStats(s)
    s.gamesPlayedValue = Stat(40199)
    s.gamesWonValue    = Stat(40201)
    s.playedMostValue  = Stat(40200)

    local rbgRating, rbgSeasonBest = GetPersonalRatedInfo(SOLO_RBG_INDEX)
    if rbgRating then
        local specStats = C_PvP.GetPersonalRatedBGBlitzSpecStats() or {}
        s.bestRatingValue     = rbgSeasonBest or "N/A"
        s.mostPlayedSpecValue = GetSpecName(specStats.seasonMostPlayedSpecID)
        s.currentRankValue    = GetPvpRank(rbgRating)
    else
        s.bestRatingValue, s.mostPlayedSpecValue, s.currentRankValue = "N/A", "N/A", "N/A"
    end

    local _, shuffleSeasonBest, _, _, _, _, _, _, _, _, _, roundsPlayed, roundsWon = GetPersonalRatedInfo(SOLO_SHUFFLE_INDEX)
    local shuffleSpecStats = C_PvP.GetPersonalRatedSoloShuffleSpecStats() or {}
    s.shuffleBestRatingValue     = shuffleSeasonBest or "N/A"
    s.shuffleRoundsPlayedValue   = roundsPlayed or "N/A"
    s.shuffleRoundsWonValue      = roundsWon or "N/A"
    s.shuffleMostPlayedSpecValue = GetSpecName(shuffleSpecStats.seasonMostPlayedSpecID)
end

local function CollectMiscStats(s)
    s.totalKillsValue               = Stat(1198)
    s.totalKillingBlowsValue        = Stat(1487)
    s.battlegroundKillingBlowsValue = Stat(1491)
    s.totalDeathsValue              = Stat(60)
    s.battlegroundDeathsValue       = Stat(14786)
end

local pvpUILoaded = false
local statsErrorReported = false

local function SavePvPStats()
    if InCombatLockdown() or not db then return false end
    local key = GetCharacterKey()
    if not key then return false end

    if not pvpUILoaded then
        local _, loaded = C_AddOns.IsAddOnLoaded("Blizzard_PVPUI")
        if not loaded then C_AddOns.LoadAddOn("Blizzard_PVPUI") end
        pvpUILoaded = true
    end

    local chars = db.global.characters
    local s = chars[key] or {}
    chars[key] = s

    local ok, err = pcall(function()
        local _, class = UnitClass("player")
        s.class = class
        local cc = RAID_CLASS_COLORS[class]
        s.classColor = { r = cc and cc.r or 1, g = cc and cc.g or 1, b = cc and cc.b or 1 }
        CollectCurrencyStats(s)
        CollectBGStats(s)
        CollectRatedStats(s)
        CollectMiscStats(s)
        s.lastUpdated = time()
    end)
    if not ok and not statsErrorReported then
        statsErrorReported = true
        geterrorhandler()(err)
    end
    return ok
end

-- Character list and migration

local characterList = {}

local function RebuildCharacterList()
    wipe(characterList)
    if not db then return end
    for key in pairs(db.global.characters) do
        characterList[#characterList + 1] = key
    end
    table.sort(characterList)
end

-- Older versions stored stats directly in IncCalloutDB, keyed by name only.
-- Move them into AceDB's global section, and give the current character its realm.
local ACEDB_KEYS = {
    profileKeys = true, profiles = true, global = true, char = true, realm = true,
    class = true, race = true, faction = true, factionrealm = true, locale = true,
    namespaces = true, settings = true,
}

local function MigrateOldStats()
    if not db or type(IncCalloutDB) ~= "table" then return end
    local chars = db.global.characters
    for key, value in pairs(IncCalloutDB) do
        if type(key) == "string" and type(value) == "table" and not ACEDB_KEYS[key]
            and (value.class ~= nil or value.conquestValue ~= nil or value.bgPlayed ~= nil) then
            if not chars[key] then chars[key] = value end
            IncCalloutDB[key] = nil
        end
    end
    local shortName = UnitName("player")
    local fullKey = GetCharacterKey()
    if shortName and fullKey and chars[shortName] and not chars[fullKey] then
        chars[fullKey] = chars[shortName]
        chars[shortName] = nil
    end
end

-- Character dropdown

local characterDropdown = CreateFrame("Frame", "IncCalloutCharacterDropdown", pvpStatsFrame, "UIDropDownMenuTemplate")
characterDropdown:SetPoint("BOTTOMLEFT", pvpStatsFrame, "BOTTOMLEFT", -15, -30)
UIDropDownMenu_SetWidth(characterDropdown, 170)

local function SelectCharacter(key)
    selectedCharacterKey = key
    UIDropDownMenu_SetText(characterDropdown, key or "Characters")
    RenderStats(key)
end

UIDropDownMenu_Initialize(characterDropdown, function(self, level)
    local info = UIDropDownMenu_CreateInfo()
    for i = 1, #characterList do
        local key = characterList[i]
        info.text       = key
        info.arg1       = key
        info.checked    = (key == selectedCharacterKey)
        info.isNotRadio = true
        info.func       = function(_, arg1)
            PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
            SelectCharacter(arg1)
            CloseDropDownMenus()
        end
        UIDropDownMenu_AddButton(info, level)
    end
end)

-- Throttled stats refresh
-- Collapses bursts of events into one save, and defers until combat ends.

local statsRefreshPending = false
local statsSaveDeferred   = false

local function RequestStatsRefresh(delay)
    if statsRefreshPending then return end
    statsRefreshPending = true
    C_Timer.After(delay or 1, function()
        statsRefreshPending = false
        if InCombatLockdown() then
            statsSaveDeferred = true
            return
        end
        statsSaveDeferred = false
        SavePvPStats()
        RebuildCharacterList()
        if pvpStatsFrame:IsShown() then
            RenderStats(selectedCharacterKey)
        end
    end)
end

pvpStatsFrame:SetScript("OnShow", function()
    RebuildCharacterList()
    SelectCharacter(GetCharacterKey())
    RequestStatsRefresh(0)
end)

-- Healer nameplate marks
-- Client side textures on friendly healer nameplates. Only you can see them.

local HEALER_ICON = "Interface\\AddOns\\IncCallout\\res\\Heal.png"
local healerMarkingEnabled = false
local healerMarkTextures = {}
local forbiddenPlateWarned = false

local function IsFriendlyHealer(unit)
    local ok, result = pcall(function()
        if not UnitIsPlayer(unit) then return false end
        if not UnitIsFriend("player", unit) then return false end
        if UnitGroupRolesAssigned(unit) == "HEALER" then return true end
        return false
    end)
    if ok then return result end
    -- Role checks can be blocked in combat. Fall back to the roster built out of combat.
    local okCache, cached = pcall(function()
        local name = GetUnitName(unit, true)
        if name and healerNameCache[name] then return true end
        return false
    end)
    return okCache and cached or false
end

local function GetOrCreateMark(unitFrame)
    local tex = healerMarkTextures[unitFrame]
    if not tex then
        tex = unitFrame:CreateTexture(nil, "OVERLAY")
        tex:SetSize(36, 36)
        tex:SetPoint("TOP", unitFrame, "TOP", 0, 14)
        tex:SetTexture(HEALER_ICON)
        tex:Hide()
        healerMarkTextures[unitFrame] = tex
    end
    return tex
end

local function WarnForbiddenPlate(unit)
    if forbiddenPlateWarned then return end
    local ok, friendly = pcall(function()
        if UnitIsFriend("player", unit) then return true end
        return false
    end)
    if ok and friendly then
        forbiddenPlateWarned = true
        print(CHAT_TAG .. "Blizzard doesn't allow addons to mark friendly nameplates here, so healer marks can't be shown in this zone.")
    end
end

local function UpdateNameplateMark(unit)
    local plate = C_NamePlate.GetNamePlateForUnit(unit)
    if not plate or not plate.UnitFrame then
        if healerMarkingEnabled then WarnForbiddenPlate(unit) end
        return
    end
    local tex = GetOrCreateMark(plate.UnitFrame)
    tex:SetShown(healerMarkingEnabled and IsInPvP() and IsFriendlyHealer(unit))
end

local function ClearAllHealerMarks()
    for _, tex in pairs(healerMarkTextures) do
        tex:Hide()
    end
end

local function RefreshAllHealerMarks()
    if not healerMarkingEnabled or not IsInPvP() then
        ClearAllHealerMarks()
        return
    end
    for i = 1, 40 do
        local unit = "nameplate" .. i
        if UnitExists(unit) then
            UpdateNameplateMark(unit)
        end
    end
end

local function SetHealerMarking(enabled)
    healerMarkingEnabled = enabled
    markHealersButton:SetText(enabled and "Unmark" or "Mark Healers")
    if enabled then
        RefreshAllHealerMarks()
    else
        ClearAllHealerMarks()
    end
end

local nameplateFrame = CreateFrame("Frame")
nameplateFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
nameplateFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
nameplateFrame:SetScript("OnEvent", function(_, event, unit)
    if event == "NAME_PLATE_UNIT_ADDED" then
        if healerMarkingEnabled and IsInPvP() then
            UpdateNameplateMark(unit)
        end
    else
        local plate = C_NamePlate.GetNamePlateForUnit(unit)
        local tex = plate and plate.UnitFrame and healerMarkTextures[plate.UnitFrame]
        if tex then tex:Hide() end
    end
end)

markHealersButton:SetScript("OnClick", function()
    if not IsInPvP() then
        print(CHAT_TAG .. "Healer marking only works in battlegrounds and arenas.")
        return
    end
    SetHealerMarking(not healerMarkingEnabled)
end)

markHealersButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Mark Healers", 1, 1, 1)
    GameTooltip:AddLine("Shows a healer icon over friendly healers' nameplates. Only you can see it.", 1, 1, 1, true)
    GameTooltip:AddLine("Friendly nameplates must be turned on in your game settings.", 1, 0.82, 0, true)
    GameTooltip:Show()
end)
markHealersButton:SetScript("OnLeave", GameTooltip_Hide)

-- Other button scripts

pvpStatsButton:SetScript("OnClick", function()
    pvpStatsFrame:SetShown(not pvpStatsFrame:IsShown())
end)

pvpStatsButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("PVP Stats", nil, nil, nil, nil, true)
    GameTooltip:AddLine("Honor, Conquest, ratings, and battleground records for all your characters.", 1, 1, 1, true)
    GameTooltip:Show()
end)
pvpStatsButton:SetScript("OnLeave", GameTooltip_Hide)

shareButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText("Share Incoming-BG Addon", 1, 1, 1)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Let your teammates know about Incoming-BG!", 0, 1, 0, true)
    GameTooltip:AddLine("In a BG or Arena: sends to instance chat.", 1, 1, 1, true)
    GameTooltip:AddLine("Outside PvP: sends in /say.", 1, 1, 1, true)
    GameTooltip:Show()
end)
shareButton:SetScript("OnLeave", GameTooltip_Hide)

-- Minimap and settings panel

local settingsCategoryID = nil

local function ResolveSettingsCategoryID()
    if settingsCategoryID ~= nil then return settingsCategoryID end
    if SettingsPanel and SettingsPanel.GetAllCategories then
        local ok, categories = pcall(SettingsPanel.GetAllCategories, SettingsPanel)
        if ok and type(categories) == "table" then
            for _, category in ipairs(categories) do
                local name = (category.GetName and category:GetName()) or category.name
                if name == APP_NAME then
                    settingsCategoryID = (category.GetID and category:GetID()) or category.ID
                    return settingsCategoryID
                end
            end
        end
    end
    return nil
end

local function OpenSettings()
    local id = ResolveSettingsCategoryID()
    if id ~= nil and Settings and Settings.OpenToCategory then
        if pcall(Settings.OpenToCategory, id) then return end
    end
    AceConfigDialog:Open(APP_NAME)
end

local function ToggleMainWindow()
    if InCombatLockdown() then
        print(CHAT_TAG .. "The window can't be shown or hidden during combat.")
        return
    end
    IncCallout:SetShown(not IncCallout:IsShown())
end

local ldbObject = LDB:NewDataObject(APP_NAME, {
    type = "data source",
    text = APP_NAME,
    icon = "Interface\\AddOns\\IncCallout\\Icon\\INC.png",
    OnClick = function(_, button)
        if button == "LeftButton" then
            ToggleMainWindow()
        else
            OpenSettings()
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("|cff00ff00Incoming-BG|r")
        tooltip:AddLine("|cffffff00Left Click:|r Toggle the main window", 1, 1, 1)
        tooltip:AddLine("|cffffff00Right Click:|r Open settings", 1, 1, 1)
    end,
})

local function ApplyMinimapVisibility()
    if not IncDB or not LDBIcon:IsRegistered(ICON_NAME) then return end
    LDBIcon:Refresh(ICON_NAME, IncDB.minimap)
    if IncDB.minimap.hide then
        LDBIcon:Hide(ICON_NAME)
    else
        LDBIcon:Show(ICON_NAME)
    end
end

-- Options

local function NotifyOptions()
    AceConfigRegistry:NotifyChange(APP_NAME)
end

local function MessageChanged()
    RebuildMacros()
    NotifyOptions()
end

local MESSAGE_GROUPS = {
    { key = "sendMore",    name = "Send More Message",    button = "Send More" },
    { key = "inc",         name = "INC Message",          button = "Inc" },
    { key = "allClear",    name = "All Clear Message",    button = "All Clear" },
    { key = "buffRequest", name = "Buff Request Message", button = "Buffs" },
    { key = "healRequest", name = "Heal Request Message", button = "Heals" },
    { key = "efcRequest",  name = "EFC Request Message",  button = "EFC" },
    { key = "fcRequest",   name = "FC Request Message",   button = "FC" },
}

local messageArgs = {}
for order, group in ipairs(MESSAGE_GROUPS) do
    local key = group.key
    messageArgs[key] = {
        type = "group", name = group.name, inline = true, order = order,
        args = {
            predefined = {
                type = "select", name = "Predefined", order = 1,
                desc = "Select the message for the '" .. group.button .. "' button.",
                values = buttonMessages[key],
                get = function() return IncDB[key .. "Index"] end,
                set = function(_, v)
                    IncDB[key .. "Index"] = v
                    MessageChanged()
                end,
            },
            custom = {
                type = "input", name = "Custom", order = 2,
                desc = "Overrides the predefined message. Chat messages are limited to 255 characters, including the location, so very long messages are shortened.",
                get = function() return IncDB.customMessages[key] end,
                set = function(_, v)
                    IncDB.customMessages[key] = v or ""
                    MessageChanged()
                end,
            },
            clear = {
                type = "execute", name = "Clear", order = 3,
                func = function()
                    IncDB.customMessages[key] = ""
                    MessageChanged()
                end,
            },
            preview = {
                type = "description", order = 4, fontSize = "medium",
                name = function() return addonNamespace.getPreviewText(key) end,
            },
        },
    }
end

local function ResetProfile()
    if db then
        db:ResetProfile()
        print(CHAT_TAG .. "Settings reset to defaults.")
    end
end

local options = {
    name = APP_NAME,
    type = "group",
    args = {
        messageSettings = {
            type = "group", name = "Message Settings", order = 1,
            args = messageArgs,
        },
        appearanceSettings = {
            type = "group", name = "Appearance Settings", order = 2,
            args = {
                fontColor = {
                    type = "color", name = "Button Font Color", hasAlpha = true, order = 1,
                    get = function()
                        local c = IncDB.fontColor
                        return c.r, c.g, c.b, c.a
                    end,
                    set = function(_, r, g, b, a)
                        IncDB.fontColor = { r = r, g = g, b = b, a = a }
                        ApplyFontSettings()
                    end,
                },
                buttonColor = {
                    type = "color", name = "Button Color", hasAlpha = true, order = 2,
                    get = function()
                        local c = IncDB.buttonColor
                        return c.r, c.g, c.b, c.a
                    end,
                    set = function(_, r, g, b, a)
                        IncDB.buttonColor = { r = r, g = g, b = b, a = a }
                        ApplyAllAppearance()
                    end,
                },
                borderStyle = {
                    type = "select", name = "Border Style", style = "dropdown", order = 3,
                    values = function()
                        local v = {}
                        for i, o in ipairs(borderOptions) do v[i] = o.name end
                        return v
                    end,
                    get = function() return IncDB.selectedBorderIndex end,
                    set = function(_, v)
                        IncDB.selectedBorderIndex = v
                        ApplyAllAppearance()
                    end,
                },
                backdropColor = {
                    type = "select", name = "Backdrop Color", style = "dropdown", order = 4,
                    values = function()
                        local v = {}
                        for i, o in ipairs(colorOptions) do v[i] = o.name end
                        return v
                    end,
                    get = function() return IncDB.selectedColorIndex end,
                    set = function(_, v)
                        IncDB.selectedColorIndex = v
                        ApplyAllAppearance()
                    end,
                },
                statusbarTexture = {
                    type = "select", name = "Button Texture", order = 5,
                    dialogControl = "LSM30_Statusbar",
                    values = function() return LSM:HashTable("statusbar") end,
                    get = function() return IncDB.statusbarTexture end,
                    set = function(_, v)
                        IncDB.statusbarTexture = v
                        ApplyAllAppearance()
                    end,
                },
                scaleOption = {
                    type = "range", name = "GUI Window Scale", order = 6, min = 0.5, max = 2.0, step = 0.05,
                    get = function() return IncDB.scale end,
                    set = function(_, v)
                        IncDB.scale = v
                        ApplyAllAppearance()
                    end,
                },
                lockGUI = {
                    type = "toggle", name = "Lock GUI Window", order = 7,
                    get = function() return IncDB.isLocked end,
                    set = function(_, v) IncDB.isLocked = v end,
                },
                logoSelection = {
                    type = "select", name = "Logo Selection", style = "dropdown", order = 8,
                    values = logoValues,
                    get = function() return IncDB.selectedLogo end,
                    set = function(_, v)
                        IncDB.selectedLogo = v
                        ApplyLogo()
                    end,
                },
                logoColor = {
                    type = "color", name = "Logo Color", hasAlpha = true, order = 9,
                    get = function()
                        local c = IncDB.logoColor
                        return c.r, c.g, c.b, c.a
                    end,
                    set = function(_, r, g, b, a)
                        IncDB.logoColor = { r = r, g = g, b = b, a = a }
                        ApplyLogo()
                    end,
                },
                enemySpecLabels = {
                    type = "toggle", name = "Show Enemy Specs", order = 11, width = "full",
                    desc = "In battlegrounds and arenas, shows each enemy player's spec above their nameplate so you can spot healers. Enemy nameplates must be turned on.",
                    get = function() return IncDB.enemySpecLabels end,
                    set = function(_, v)
                        IncDB.enemySpecLabels = v
                        if addonNamespace.RefreshSpecLabels then addonNamespace.RefreshSpecLabels() end
                    end,
                },
                minimapButtonEnable = {
                    type = "toggle", name = "Enable MiniMap Button", order = 10,
                    get = function() return not IncDB.minimap.hide end,
                    set = function(_, v)
                        IncDB.minimap.hide = not v
                        ApplyMinimapVisibility()
                    end,
                },
            },
        },
        fontSettings = {
            type = "group", name = "Font Settings", order = 4,
            args = {
                font = {
                    type = "select", name = "Font", order = 1,
                    dialogControl = "LSM30_Font",
                    values = function() return LSM:HashTable("font") end,
                    get = function() return IncDB.font end,
                    set = function(_, v)
                        IncDB.font = v
                        ApplyFontSettings()
                    end,
                },
                fontSize = {
                    type = "range", name = "Font Size", order = 2, min = 8, max = 24, step = 1,
                    get = function() return IncDB.fontSize end,
                    set = function(_, v)
                        IncDB.fontSize = v
                        ApplyFontSettings()
                    end,
                },
            },
        },
        resetSettings = {
            type = "group", name = "Reset", order = 100,
            args = {
                resetToDefaults = {
                    type = "execute", name = "Reset to Defaults",
                    desc = "Reset all Incoming-BG settings to their default values. Your saved PvP stats are kept.",
                    confirm = function() return "Are you sure you want to reset Incoming-BG settings to defaults? This cannot be undone." end,
                    func = ResetProfile,
                },
            },
        },
    },
}

AceConfig:RegisterOptionsTable(APP_NAME, options)

-- Lifecycle

local function OnProfileChanged()
    IncDB = db.profile
    addonNamespace.db = IncDB
    ApplyAllAppearance()
    ApplyMinimapVisibility()
    RebuildMacros()
    NotifyOptions()
end

local rosterPending      = false
local rosterUpdateQueued = false
local showWindowPending  = false

local function ProcessRosterUpdate()
    rosterUpdateQueued = false
    if InCombatLockdown() then
        rosterPending = true
        RefreshAllHealerMarks()
        return
    end
    rosterPending = false
    RebuildHealerCache()
    RebuildMacros()
    RefreshAllHealerMarks()
end

local handlers = {}

function handlers.ADDON_LOADED(loadedName)
    if loadedName ~= addonName then return end

    db = AceDB:New("IncCalloutDB", defaults, true)
    IncDB = db.profile
    addonNamespace.db = IncDB

    db.RegisterCallback(addonNamespace, "OnProfileChanged", OnProfileChanged)
    db.RegisterCallback(addonNamespace, "OnProfileCopied",  OnProfileChanged)
    db.RegisterCallback(addonNamespace, "OnProfileReset",   OnProfileChanged)

    LDBIcon:Register(ICON_NAME, ldbObject, IncDB.minimap)
    ApplyMinimapVisibility()

    local _, categoryID = AceConfigDialog:AddToBlizOptions(APP_NAME, APP_NAME)
    if categoryID ~= nil then settingsCategoryID = categoryID end

    ApplyAllAppearance()
end

function handlers.PLAYER_LOGIN()
    MigrateOldStats()
    RebuildCharacterList()
    RebuildHealerCache()
    RebuildMacros()
    if not InCombatLockdown() then RequestRatedInfo() end
    RequestStatsRefresh(2)
end

function handlers.PLAYER_ENTERING_WORLD()
    -- Reapply fonts once more after the client has settled, as a cold start safety net
    C_Timer.After(1, ApplyFontSettings)
    forbiddenPlateWarned = false
    ClearAllHealerMarks()
    if IsInBattleground() then
        if InCombatLockdown() then
            showWindowPending = true
        else
            IncCallout:Show()
        end
    end
    ApplyAllAppearance()
    RebuildHealerCache()
    RebuildMacros()
    if not InCombatLockdown() then RequestRatedInfo() end
    RequestStatsRefresh(2)
end

function handlers.PLAYER_LEAVING_WORLD()
    SetHealerMarking(false)
    showWindowPending = false
    if not InCombatLockdown() then IncCallout:Hide() end
end

function handlers.PLAYER_REGEN_ENABLED()
    if rosterPending then RebuildHealerCache() rosterPending = false end
    RebuildMacros()
    if appearancePending then ApplyAllAppearance() end
    if showWindowPending then
        showWindowPending = false
        if IsInBattleground() then IncCallout:Show() end
    end
    if statsSaveDeferred then RequestStatsRefresh(1) end
end

local function OnZoneChanged()
    if InCombatLockdown() then
        UpdateLocationLabel()  -- shows "Outdated" until combat ends
    else
        RebuildMacros()
    end
end

handlers.ZONE_CHANGED         = OnZoneChanged
handlers.ZONE_CHANGED_INDOORS = OnZoneChanged

function handlers.ZONE_CHANGED_NEW_AREA()
    OnZoneChanged()
    RequestStatsRefresh(2)
end

function handlers.GROUP_ROSTER_UPDATE()
    -- Roster events arrive in bursts in battlegrounds, so handle them once per half second
    if rosterUpdateQueued then return end
    rosterUpdateQueued = true
    C_Timer.After(0.5, ProcessRosterUpdate)
end

local function OnRatedStatsChanged()
    RequestStatsRefresh(1)
end

handlers.PVP_RATED_STATS_UPDATE      = OnRatedStatsChanged
handlers.PVP_REWARDS_UPDATE          = OnRatedStatsChanged
handlers.WEEKLY_REWARDS_UPDATE       = OnRatedStatsChanged
handlers.ACTIVE_TALENT_GROUP_CHANGED = OnRatedStatsChanged

local function OnCurrencyChanged()
    -- Currency events fire constantly; only refresh while the stats window is open
    if pvpStatsFrame:IsShown() then
        RequestStatsRefresh(1)
    end
end

handlers.CURRENCY_DISPLAY_UPDATE = OnCurrencyChanged
handlers.HONOR_XP_UPDATE         = OnCurrencyChanged

local eventFrame = CreateFrame("Frame")
for event in pairs(handlers) do
    eventFrame:RegisterEvent(event)
end
eventFrame:SetScript("OnEvent", function(_, event, ...)
    local handler = handlers[event]
    if handler then handler(...) end
end)

-- Button hover recolor safety net (restores the flat button look after clicks)
C_Timer.After(0, function()
    for i = 1, #buttons do
        buttons[i]:HookScript("PostClick", function()
            if not InCombatLockdown() then ApplyButtonColor() end
        end)
    end
end)

-- Slash commands

SLASH_INC1 = "/inc"
SlashCmdList["INC"] = function()
    ToggleMainWindow()
end

SLASH_INCOMINGBGMSG1 = "/incmsg"
SlashCmdList["INCOMINGBGMSG"] = function()
    print(CHAT_TAG .. "Use the Share button on the Incoming-BG window to tell your team about the addon.")
end

SLASH_INCDEBUG1 = "/incdebug"
SlashCmdList["INCDEBUG"] = function()
    print(CHAT_TAG .. "Callout location: " .. tostring(bakedLocation) .. (locationStale and " (outdated)" or ""))
    for i, button in ipairs(secureButtons) do
        print(i, button:GetName(), button:IsVisible(), button:GetAttribute("macrotext"))
    end
    for i, button in ipairs(buttons) do
        local label = button:GetFontString()
        local font, size = label:GetFont()
        local _, _, _, alpha = label:GetTextColor()
        print("Label", i, tostring(label:GetText()), tostring(font), tostring(size), "alpha", tostring(alpha))
    end
end

-- Enemy spec labels
-- Shows each enemy player's spec above their nameplate in their class color, taken
-- from the battleground scoreboard. Blizzard keeps enemy specs secret in Midnight,
-- so the addon never reads the spec. It matches the plate to the scoreboard by name
-- and hands the secret value straight to a text label, which the game then draws.

local SPEC_SCORE_REFRESH = 10

local enemyScoreCache   = {}  -- short name -> { spec = <secret value>, class = class token }
local ambiguousNames    = {}  -- short names shared by two enemies, skipped to avoid wrong labels
local specLabels        = {}  -- keyed by nameplate UnitFrame
local specLabelsBlocked = false
local scoreTicker

local function SpecLabelsActive()
    return IncDB and IncDB.enemySpecLabels and not specLabelsBlocked and IsInPvP()
end

local function SpecMyFaction()
    if GetBattlefieldArenaFaction then
        local ok, faction = pcall(GetBattlefieldArenaFaction)
        if ok and type(faction) == "number" then return faction end
    end
    return (UnitFactionGroup("player") == "Alliance") and 1 or 0
end

-- Builds a fresh cache and only swaps it in if it found enemies, so a read that
-- fails mid combat never wipes good data.
local function RebuildEnemyScoreCache()
    local okCount, count = pcall(GetNumBattlefieldScores)
    if not okCount or type(count) ~= "number" or count == 0 then return false end
    local myFaction = SpecMyFaction()
    local fresh, dupes, added = {}, {}, 0
    for i = 1, count do
        pcall(function()
            local info = C_PvP.GetScoreInfo(i)
            if type(info) ~= "table" or info.faction == myFaction then return end
            local short = info.name:gsub("%-.*$", "")
            if short == "" then return end
            if fresh[short] then dupes[short] = true end
            fresh[short] = { spec = info.talentSpec, class = info.classToken }
            added = added + 1
        end)
    end
    if added == 0 then return false end
    enemyScoreCache = fresh
    ambiguousNames = dupes
    return true
end

local function GetSpecLabel(unitFrame)
    local label = specLabels[unitFrame]
    if not label then
        label = unitFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("BOTTOM", unitFrame, "TOP", 0, 2)
        local font, size = label:GetFont()
        if font then label:SetFont(font, (size or 10) + 1, "OUTLINE") end
        label:Hide()
        specLabels[unitFrame] = label
    end
    return label
end

local function HideSpecLabel(unitFrame)
    local label = specLabels[unitFrame]
    if label then label:Hide() end
end

local function UpdateSpecLabel(unit)
    local plate = C_NamePlate.GetNamePlateForUnit(unit)
    if not plate or not plate.UnitFrame then return end
    local unitFrame = plate.UnitFrame

    if not SpecLabelsActive() then
        HideSpecLabel(unitFrame)
        return
    end

    local okEnemy, isEnemy = pcall(function()
        if UnitIsPlayer(unit) and UnitCanAttack("player", unit) then return true end
        return false
    end)
    if not okEnemy or not isEnemy then
        HideSpecLabel(unitFrame)
        return
    end

    -- Fails quietly if the name is ever secret, for example during combat
    local okName, short = pcall(function()
        return (UnitName(unit):gsub("%-.*$", ""))
    end)
    if not okName or not short or short == "" then
        HideSpecLabel(unitFrame)
        return
    end

    local entry = enemyScoreCache[short]
    if not entry or ambiguousNames[short] then
        HideSpecLabel(unitFrame)
        return
    end

    local label = GetSpecLabel(unitFrame)
    local okSet = pcall(function()
        label:SetText(entry.spec)
        local c = entry.class and RAID_CLASS_COLORS[entry.class]
        if c then
            label:SetTextColor(c.r, c.g, c.b)
        else
            label:SetTextColor(1, 1, 1)
        end
    end)
    if not okSet then
        -- Only happens if a future patch blocks displaying enemy specs
        specLabelsBlocked = true
        label:Hide()
        print(CHAT_TAG .. "Blizzard blocks showing enemy specs, so spec labels have been turned off.")
        return
    end
    label:Show()
end

local function HideAllSpecLabels()
    for _, label in pairs(specLabels) do
        label:Hide()
    end
end

local function RefreshAllSpecLabels()
    if not SpecLabelsActive() then
        HideAllSpecLabels()
        return
    end
    for i = 1, 40 do
        local unit = "nameplate" .. i
        if UnitExists(unit) then
            UpdateSpecLabel(unit)
        end
    end
end
addonNamespace.RefreshSpecLabels = RefreshAllSpecLabels

local function RequestScores()
    if IsInPvP() and RequestBattlefieldScoreData then
        pcall(RequestBattlefieldScoreData)
    end
end

local specFrame = CreateFrame("Frame")
specFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
specFrame:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
specFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
specFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
specFrame:SetScript("OnEvent", function(_, event, unit)
    if event == "NAME_PLATE_UNIT_ADDED" then
        UpdateSpecLabel(unit)
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local plate = C_NamePlate.GetNamePlateForUnit(unit)
        if plate and plate.UnitFrame then HideSpecLabel(plate.UnitFrame) end
    elseif event == "UPDATE_BATTLEFIELD_SCORE" then
        if RebuildEnemyScoreCache() then
            RefreshAllSpecLabels()
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        wipe(enemyScoreCache)
        wipe(ambiguousNames)
        HideAllSpecLabels()
        specLabelsBlocked = false
        if scoreTicker then
            scoreTicker:Cancel()
            scoreTicker = nil
        end
        if IsInPvP() then
            RequestScores()
            scoreTicker = C_Timer.NewTicker(SPEC_SCORE_REFRESH, RequestScores)
        end
    end
end)

SLASH_INCSPEC1 = "/incspec"
SlashCmdList["INCSPEC"] = function()
    if not IncDB then return end
    IncDB.enemySpecLabels = not IncDB.enemySpecLabels
    print(CHAT_TAG .. "Enemy spec labels " .. (IncDB.enemySpecLabels and "ON" or "OFF") .. ".")
    RefreshAllSpecLabels()
end
