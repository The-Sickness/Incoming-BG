local addonName, addonNamespace = ...

local healerIcons = {}
local HEALER_ICON_PATH = "Interface\\AddOns\\IncCallout\\Textures\\Heal.png"

local HEALER_BUFF_IDS = {
    -- Druid (Restoration)
    [774] = true,        -- Rejuvenation
    [48438] = true,      -- Wild Growth
    -- Priest
    [41635] = true,      -- Prayer of Mending
    [17] = true,         -- Power Word: Shield
    -- Paladin
    [53563] = true,      -- Beacon of Light
    -- Monk
    [119611] = true,     -- Renewing Mist
    -- Shaman
    [61295] = true,      -- Riptide
    -- Evoker (Preservation)
    [364342] = true,     -- Echo
}

local healerClasses = {
    DRUID = true,
    MONK = true,
    PRIEST = true,
    PALADIN = true,
    SHAMAN = true,
    EVOKER = true,
}

local healerGUIDs = {}
local announcedHealers = {}

local function IsInPvPInstance()
    local inInstance, instanceType = IsInInstance()
    return inInstance and instanceType == "pvp"
end

-- Use C_UnitAuras.GetBuffDataByIndex to scan for healer buffs
local function DetectHealerByBuff(unit)
    local class = select(2, UnitClass(unit))
    if not healerClasses[class] then return false end
    for i = 1, 40 do
        local aura = C_UnitAuras.GetBuffDataByIndex(unit, i, "HELPFUL")
        if not aura then break end
        if aura.spellId and HEALER_BUFF_IDS[aura.spellId] then
            return true
        end
    end
    return false
end

local function IsGUIDEnemyHealer(guid)
    return healerGUIDs[guid]
end

function AnnounceEnemyHealer(guid, unit)
    if not announcedHealers[guid] then
        announcedHealers[guid] = true

        local isBattleground = C_PvP.IsBattleground and C_PvP.IsBattleground()
        local isRatedBattleground = C_PvP.IsRatedBattleground and C_PvP.IsRatedBattleground()
        local isBlitz = C_PvP.IsSoloRBG and C_PvP.IsSoloRBG()

        if not (isBattleground or isRatedBattleground or isBlitz) then
            return
        end

        if IncDB and IncDB.enableHealerMessage == false then
            return
        end

        local name = UnitName(unit)
        local className = select(1, UnitClass(unit))
        SendChatMessage(
            string.format("[IncCallout] Enemy healer detected: %s (%s)", name or "Unknown", className or "Unknown"),
            "INSTANCE_CHAT"
        )
    end
end

function ShowHealerIcon(nameplate)
    if IncDB and IncDB.enableHealerIcon == false then
        HideHealerIcon(nameplate)
        return
    end
    if not healerIcons[nameplate] then
        local icon = nameplate:CreateTexture(nil, "OVERLAY")
        icon:SetTexture(HEALER_ICON_PATH)
        healerIcons[nameplate] = icon
    end
    local size = IncDB.healerIconSize or 24
    healerIcons[nameplate]:SetSize(size, size)
    healerIcons[nameplate]:SetPoint("RIGHT", nameplate, "LEFT", -2, 0)
    healerIcons[nameplate]:Show()
end

function HideHealerIcon(nameplate)
    if healerIcons[nameplate] then
        healerIcons[nameplate]:Hide()
    end
end

function UpdateHealerIcons()
    local enableIcons = IncDB and IncDB.enableHealerIcon ~= false
    for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
        local unit = plate.namePlateUnitToken
        if unit and UnitIsPlayer(unit) and UnitIsEnemy("player", unit) then
            local guid = UnitGUID(unit)
            if DetectHealerByBuff(unit) then
                healerGUIDs[guid] = true
            end
            if guid and IsGUIDEnemyHealer(guid) then
                if enableIcons then
                    ShowHealerIcon(plate)
                else
                    HideHealerIcon(plate)
                end
                if not announcedHealers[guid] then
                    AnnounceEnemyHealer(guid, unit)
                end
            else
                HideHealerIcon(plate)
            end
        else
            HideHealerIcon(plate)
        end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("PLAYER_LEAVING_WORLD")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_LEAVING_WORLD" then
        announcedHealers = {}
        healerGUIDs = {}
        UpdateHealerIcons()
    else
        UpdateHealerIcons()
    end
end)