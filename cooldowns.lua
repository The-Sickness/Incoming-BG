local addonName, addonNamespace = ...

local cooldownTracker = {} -- [unitGUID] = { [spellID] = expirationTime }
local healerIcons = {}     -- [nameplate] = healer icon

local HEALER_ICON_PATH = "Interface\\AddOns\\IncCallout\\Textures\\Heal.png"
local ICON_SIZE = 24
local TIMER_FONT = "Fonts\\FRIZQT__.TTF"
local TIMER_FONT_SIZE = 10

local healingSpells = {
    -- Druid
    [132158] = true, [18562] = true, [33763] = true, [740] = true,
    -- Priest
    [33076] = true, [34861] = true, [2050] = true, [194509] = true, [47540] = true, [372835] = true,
    -- Paladin
    [20473] = true, [223306] = true, [85222] = true, [183998] = true,
    -- Shaman
    [73920] = true, [61295] = true, [98008] = true, [108280] = true, [1064] = true,
    -- Monk
    [191837] = true, [124682] = true, [116849] = true, [115151] = true,
    -- Evoker
    [355941] = true, [367226] = true, [366155] = true, [359816] = true,
}

local healerGUIDs = {}
local announcedHealers = {}

local function IsInPvPInstance()
    local inInstance, instanceType = IsInInstance()
    return inInstance and (instanceType == "pvp" or instanceType == "arena")
end

local function IsGUIDEnemyHealer(guid)
    return healerGUIDs[guid]
end

function AnnounceEnemyHealer(guid, unit)
    if not announcedHealers[guid] then
        announcedHealers[guid] = true

        -- PvP type checks
        local isBattleground = C_PvP.IsBattleground and C_PvP.IsBattleground()
        local isRatedBattleground = C_PvP.IsRatedBattleground and C_PvP.IsRatedBattleground()
        local isBlitz = C_PvP.IsSoloRBG and C_PvP.IsSoloRBG()
        local isSoloShuffle = C_PvP.IsSoloShuffle and C_PvP.IsSoloShuffle()
        local isRatedArena = C_PvP.IsRatedArena and C_PvP.IsRatedArena()

        -- Only announce in BGs, Rated BGs, and Blitz!
        if not (isBattleground or isRatedBattleground or isBlitz) then
            return
        end

        -- Respect user setting
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

function UpdateCooldownIcons()
    if IncDB and IncDB.enableCooldownTracker == false then
        HideAllCooldownIcons()
        return
    end

    local target = "target"
    local guid = UnitGUID(target)
    if UnitExists(target) and UnitIsEnemy("player", target) and UnitIsPlayer(target) and guid then
        for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
            local plateUnit = plate.namePlateUnitToken
            if plateUnit and UnitGUID(plateUnit) == guid then
                if cooldownTracker[guid] then
                    local maxIcons = IncDB.maxCooldownIcons or 4
                    local index = 1
                    for spellID, expiration in pairs(cooldownTracker[guid]) do
                        if index > maxIcons then break end
                        local remaining = expiration - GetTime()
                        if remaining > 0 and TRACKED_COOLDOWNS[spellID] then
                            ShowCooldownIcon(plate, spellID, index, remaining)
                            index = index + 1
                        end
                    end
                end
                break
            end
        end
    end
    UpdateHealerIcons()
end

function ShowHealerIcon(nameplate)
    if IncDB and IncDB.enableHealerIcon == false then
        -- If healer icon tracker is disabled, do not show icon
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

local function OnCombatLogEvent()
    if not IsInPvPInstance() then return end

    -- CombatLogGetCurrentEventInfo returns many fields; we only need the ones used here
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
          destGUID, destName, destFlags, destRaidFlags, spellID = CombatLogGetCurrentEventInfo()

    -- Detect healers: if they cast or heal with a tracked healing spell, mark them
    if (subevent == "SPELL_HEAL" or subevent == "SPELL_PERIODIC_HEAL" or subevent == "SPELL_CAST_SUCCESS")
        and healingSpells[spellID] then

        -- Only consider hostile player sources
        if bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) ~= 0
           and bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) ~= 0 then

            healerGUIDs[sourceGUID] = true

            -- Try to find a visible nameplate matching this GUID and announce immediately (best-effort)
            for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
                local unit = plate.namePlateUnitToken
                if unit and UnitExists(unit) and UnitGUID(unit) == sourceGUID then
                    -- Announce using the unit token we found (AnnounceEnemyHealer should be safe/defensive)
                    pcall(AnnounceEnemyHealer, sourceGUID, unit)
                    break
                end
            end

            -- Update visuals (healer icons)
            pcall(UpdateHealerIcons)
        end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("PLAYER_LEAVING_WORLD")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_LEAVING_WORLD" then
        announcedHealers = {}
        healerGUIDs = {}
        UpdateCooldownIcons()
        UpdateHealerIcons()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        OnCombatLogEvent()
        UpdateHealerIcons()
    else
        UpdateCooldownIcons()
        UpdateHealerIcons()
    end
end)