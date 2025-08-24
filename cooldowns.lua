local addonName, addonNamespace = ...

local TRACKED_COOLDOWNS = {
    -- Mage
    [45438]  = {duration = 240},   -- Ice Block
    [11958]  = {duration = 180},   -- Cold Snap
    [12051]  = {duration = 90},    -- Evocation
    [113724] = {duration = 45},    -- Ring of Frost
    [66]     = {duration = 300},   -- Invisibility
    [86949]  = {duration = 60},    -- Cauterize (Fire)
    [198111] = {duration = 45},    -- Temporal Shield (Arcane PvP Talent)
    [212799] = {duration = 20},    -- Blink (Arcane/Frost/Fire)
    [157980] = {duration = 25},    -- Supernova (Arcane)
    [235219] = {duration = 45},    -- Cold Snap (Frost)
    [190319] = {duration = 120},   -- Combustion (Fire)
    [116]    = {duration = 12},    -- Frostbolt (Frost)
    [31661]  = {duration = 20},    -- Dragon's Breath (Fire)
    [61305]  = {duration = 30},    -- Polymorph

    -- Paladin
    [642]    = {duration = 210},   -- Divine Shield
    [498]    = {duration = 60},    -- Divine Protection
    [86659]  = {duration = 180},   -- Guardian of Ancient Kings
    [31850]  = {duration = 120},   -- Ardent Defender
    [31884]  = {duration = 120},   -- Avenging Wrath
    [6940]   = {duration = 60},    -- Blessing of Sacrifice
    [1022]   = {duration = 300},   -- Blessing of Protection
    [204018] = {duration = 180},   -- Blessing of Spellwarding
    [1044]   = {duration = 25},    -- Blessing of Freedom
    [853]    = {duration = 60},    -- Hammer of Justice
    [20066]  = {duration = 15},    -- Repentance
    [96231]  = {duration = 15},    -- Rebuke (Interrupt)
    [633]    = {duration = 600},   -- Lay on Hands

    -- Rogue
    [31224]  = {duration = 60},    -- Cloak of Shadows
    [1856]   = {duration = 120},   -- Vanish
    [5277]   = {duration = 120},   -- Evasion
    [1966]   = {duration = 24},    -- Feint
    [408]    = {duration = 20},    -- Kidney Shot
    [1766]   = {duration = 15},    -- Kick
    [13750]  = {duration = 180},   -- Adrenaline Rush
    [2094]   = {duration = 120},   -- Blind
    [31230]  = {duration = 90},    -- Cheat Death
    [1776]   = {duration = 10},    -- Gouge
    [36554]  = {duration = 30},    -- Shadowstep
    [79140]  = {duration = 60},    -- Vendetta (Assassination)
    [185311] = {duration = 30},    -- Crimson Vial
    [113952] = {duration = 180},   -- Grappling Hook (Outlaw)
    [408]    = {duration = 20},    -- Kidney Shot

    -- Death Knight
    [48792]  = {duration = 180},   -- Icebound Fortitude
    [48707]  = {duration = 60},    -- Anti-Magic Shell
    [51052]  = {duration = 120},   -- Anti-Magic Zone
    [55233]  = {duration = 90},    -- Vampiric Blood
    [61999]  = {duration = 600},   -- Raise Ally
    [221562] = {duration = 45},    -- Asphyxiate
    [47476]  = {duration = 60},    -- Strangulate (PvP Talent)
    [108194] = {duration = 45},    -- Asphyxiate (Unholy/Blood)
    [196770] = {duration = 20},    -- Remorseless Winter
    [207167] = {duration = 60},    -- Blinding Sleet (PvP Talent)
    [48743]  = {duration = 120},   -- Death Pact (Unholy/Blood)
    [49576]  = {duration = 25},    -- Death Grip
    [77606]  = {duration = 30},    -- Dark Simulacrum (PvP Talent)

    -- Hunter
    [186265] = {duration = 180},   -- Aspect of the Turtle
    [19263]  = {duration = 180},   -- Deterrence
    [781]    = {duration = 20},    -- Disengage
    [109304] = {duration = 120},   -- Exhilaration
    [53480]  = {duration = 60},    -- Roar of Sacrifice
    [19574]  = {duration = 90},    -- Bestial Wrath
    [34477]  = {duration = 30},    -- Misdirection
    [19577]  = {duration = 60},    -- Intimidation (Pet Stun)
    [213691] = {duration = 30},    -- Scatter Shot (PvP Talent)
    [187650] = {duration = 30},    -- Freezing Trap
    [147362] = {duration = 24},    -- Counter Shot (Interrupt)
    [19386]  = {duration = 45},    -- Wyvern Sting

    -- Druid
    [22812]  = {duration = 60},    -- Barkskin
    [61336]  = {duration = 180},   -- Survival Instincts
    [102342] = {duration = 60},    -- Ironbark
    [29166]  = {duration = 180},   -- Innervate
    [124974] = {duration = 90},    -- Nature's Vigil
    [33891]  = {duration = 180},   -- Incarnation: Tree of Life
    [99]     = {duration = 30},    -- Incapacitating Roar
    [5211]   = {duration = 60},    -- Mighty Bash
    [33786]  = {duration = 60},    -- Cyclone
    [8122]   = {duration = 60},    -- Fear (Priest, but tracked for Druids in Arena)
    [8936]   = {duration = 6},     -- Regrowth
    [18562]  = {duration = 15},    -- Swiftmend

    -- Priest
    [33206]  = {duration = 180},   -- Pain Suppression
    [47585]  = {duration = 120},   -- Dispersion
    [64843]  = {duration = 180},   -- Divine Hymn
    [47788]  = {duration = 180},   -- Guardian Spirit
    [19236]  = {duration = 90},    -- Desperate Prayer
    [586]    = {duration = 30},    -- Fade
    [213602] = {duration = 30},    -- Greater Fade
    [8122]   = {duration = 60},    -- Psychic Scream
    [15487]  = {duration = 45},    -- Silence
    [32375]  = {duration = 45},    -- Mass Dispel
    [64044]  = {duration = 40},    -- Psychic Horror (PvP Talent)
    [33206]  = {duration = 180},   -- Pain Suppression
    [62618]  = {duration = 180},   -- Power Word: Barrier

    -- Warlock
    [104773] = {duration = 180},   -- Unending Resolve
    [6789]   = {duration = 45},    -- Mortal Coil
    [20707]  = {duration = 600},   -- Soulstone
    [30283]  = {duration = 45},    -- Shadowfury
    [119910] = {duration = 24},    -- Spell Lock (interrupt, pet)
    [48020]  = {duration = 30},    -- Demonic Circle: Teleport
    [89751]  = {duration = 45},    -- Felstorm (pet stun)
    [171975] = {duration = 45},    -- Grimoire: Felguard (pet stun)
    [6358]   = {duration = 30},    -- Seduction (pet CC)
    [6789]   = {duration = 45},    -- Mortal Coil

    -- Shaman
    [98008]  = {duration = 180},   -- Spirit Link Totem
    [108271] = {duration = 90},    -- Astral Shift
    [79206]  = {duration = 60},    -- Spiritwalker's Grace
    [108281] = {duration = 90},    -- Ancestral Guidance
    [51514]  = {duration = 45},    -- Hex
    [57994]  = {duration = 12},    -- Wind Shear (Interrupt)
    [192058] = {duration = 60},    -- Capacitor Totem
    [204336] = {duration = 30},    -- Grounding Totem
    [51490]  = {duration = 45},    -- Thunderstorm

    -- Monk
    [122470] = {duration = 90},    -- Touch of Karma
    [116849] = {duration = 120},   -- Life Cocoon
    [115310] = {duration = 180},   -- Revival
    [115203] = {duration = 180},   -- Fortifying Brew
    [119381] = {duration = 35},    -- Leg Sweep
    [115080] = {duration = 90},    -- Touch of Death
    [123904] = {duration = 120},   -- Invoke Xuen, the White Tiger
    [115078] = {duration = 15},    -- Paralysis
    [116705] = {duration = 15},    -- Spear Hand Strike (Interrupt)
    [116844] = {duration = 45},    -- Ring of Peace

    -- Demon Hunter
    [196555] = {duration = 180},   -- Netherwalk
    [198589] = {duration = 60},    -- Blur
    [187827] = {duration = 180},   -- Metamorphosis
    [179057] = {duration = 60},    -- Chaos Nova
    [206804] = {duration = 60},    -- Rain from Above
    [211881] = {duration = 30},    -- Fel Eruption
    [217832] = {duration = 20},    -- Imprison
    [183752] = {duration = 15},    -- Disrupt (Interrupt)
    [204021] = {duration = 60},    -- Fiery Brand

    -- Evoker
    [363916] = {duration = 90},    -- Obsidian Scales
    [374348] = {duration = 90},    -- Stasis
    [357170] = {duration = 120},   -- Time Spiral
    [370553] = {duration = 120},   -- Tip the Scales
    [358385] = {duration = 60},    -- Eternity Surge
    [359073] = {duration = 90},    -- Deep Breath
    [360995] = {duration = 30},    -- Rescue
    [355936] = {duration = 30},    -- Oppressing Roar

    -- Warrior
    [23920]  = {duration = 25},    -- Spell Reflection
    [871]    = {duration = 240},   -- Shield Wall
    [12975]  = {duration = 180},   -- Last Stand
    [1719]   = {duration = 90},    -- Recklessness
    [118038] = {duration = 120},   -- Die by the Sword
    [46924]  = {duration = 60},    -- Bladestorm
    [107574] = {duration = 90},    -- Avatar
    [6544]   = {duration = 45},    -- Heroic Leap
    [6552]   = {duration = 15},    -- Pummel (Interrupt)
    [5246]   = {duration = 90},    -- Intimidating Shout
    [23922]  = {duration = 9},     -- Shield Slam (Interrupt, Prot)

    -- General (trinkets, racials, etc.)
    [59752]  = {duration = 120},   -- Every Man for Himself (Human)
    [7744]   = {duration = 120},   -- Will of the Forsaken (Undead)
    [20594]  = {duration = 120},   -- Stoneform (Dwarf)
    [28730]  = {duration = 90},    -- Arcane Torrent (Blood Elf)
    [68992]  = {duration = 120},   -- Darkflight (Worgen)
    [107079] = {duration = 120},   -- Quaking Palm (Pandaren)
    [255647] = {duration = 150},   -- Light's Judgment (Lightforged Draenei)
    [265221] = {duration = 120},   -- Fireblood (Dark Iron Dwarf)
    [336126] = {duration = 90},    -- Gladiator's Medallion (PvP Trinket)
    [214027] = {duration = 60},    -- Adaptation (PvP Talent)
    [208683] = {duration = 60},    -- Relentless (PvP Talent)
}

local cooldownTracker = {} -- [unitGUID] = { [spellID] = expirationTime }
local cooldownIcons = {}   -- [nameplate] = { icon frames }
local healerIcons = {}     -- [nameplate] = healer icon

local HEALER_ICON_PATH = "Interface\\AddOns\\IncCallout\\Textures\\Heal.png"
local ICON_SIZE = 24
local TIMER_FONT = "Fonts\\FRIZQT__.TTF"
local TIMER_FONT_SIZE = 10

-- Healing spells used for healer detection (by GUID)
local healingSpells = {
    -- Druid (Restoration only)
    [132158] = true, -- Nature's Swiftness
    [18562]  = true, -- Swiftmend
    [33763]  = true, -- Lifebloom
    [740]    = true, -- Tranquility

    -- Priest (Holy and Discipline)
    [33076]  = true, -- Prayer of Mending
    [34861]  = true, -- Holy Word: Sanctify
    [2050]   = true, -- Holy Word: Serenity
    [194509] = true, -- Power Word: Radiance
    [47540]  = true, -- Penance
    [372835] = true, -- Lightwell

    -- Paladin (Holy only)
    [20473]  = true, -- Holy Shock
    [223306] = true, -- Bestow Faith
    [85222]  = true, -- Light of Dawn
    [183998] = true, -- Light of the Martyr

    -- Shaman (Restoration only)
    [73920]  = true, -- Healing Rain
    [61295]  = true, -- Riptide
    [98008]  = true, -- Spirit Link Totem
    [108280] = true, -- Healing Tide Totem
    [1064]   = true, -- Chain Heal

    -- Monk (Mistweaver only)
    [191837] = true, -- Essence Font
    [124682] = true, -- Enveloping Mist
    [116849] = true, -- Life Cocoon
    [115151] = true, -- Renewing Mist

    -- Evoker (Preservation only)
    [355941] = true, -- Dream Breath
    [367226] = true, -- Spiritbloom
    [366155] = true, -- Reversion
    [359816] = true, -- Dream Flight
}

local HEALER_CLASS_COLORS = {
    DRUID       = "ff7d0a", -- Restoration Druid
    MONK        = "00ff96", -- Mistweaver Monk
    PALADIN     = "f58cba", -- Holy Paladin
    PRIEST      = "ffffff", -- Discipline/Holy Priest
    SHAMAN      = "0070de", -- Restoration Shaman
    EVOKER      = "33937f", -- Preservation Evoker
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

function HideAllCooldownIcons()
    for nameplate, icons in pairs(cooldownIcons) do
        for spellID, iconFrame in pairs(icons) do
            iconFrame:Hide()
            if iconFrame.timerText then
                iconFrame.timerText:Hide()
            end
            iconFrame:SetScript("OnUpdate", nil)
        end
    end
end

function UpdateCooldownIcons()
    if IncDB and IncDB.enableCooldownTracker == false then
        HideAllCooldownIcons()
        return
    end

    HideAllCooldownIcons()
    if not IsInPvPInstance() then return end

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

function AnnounceEnemyHealer(guid, unit)
    if not announcedHealers[guid] then
        announcedHealers[guid] = true
        local name = UnitName(unit)
        local className = select(1, UnitClass(unit))
        SendChatMessage(
            string.format("[IncCallout] Enemy healer detected: %s (%s)", name or "Unknown", className or "Unknown"),
            "INSTANCE_CHAT"
        )
    end
end

function ShowHealerIcon(nameplate)
    if not healerIcons[nameplate] then
        local icon = nameplate:CreateTexture(nil, "OVERLAY")
        icon:SetTexture(HEALER_ICON_PATH)
        healerIcons[nameplate] = icon
    end
    -- Always update size in case the setting changed
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
    for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
        local unit = plate.namePlateUnitToken
        if unit and UnitIsPlayer(unit) and UnitIsEnemy("player", unit) then
            local guid = UnitGUID(unit)
            if guid and IsGUIDEnemyHealer(guid) then
                ShowHealerIcon(plate)
				AnnounceEnemyHealer(guid, unit)
            else
                HideHealerIcon(plate)
            end
        else
            HideHealerIcon(plate)
        end
    end
end

function ShowCooldownIcon(nameplate, spellID, index, remaining)
    cooldownIcons[nameplate] = cooldownIcons[nameplate] or {}
    local iconFrame = cooldownIcons[nameplate][spellID]
    local size = IncDB.cooldownIconSize or 24
    if not iconFrame then
        iconFrame = CreateFrame("Frame", nil, nameplate)
        iconFrame.icon = iconFrame:CreateTexture(nil, "ARTWORK")
        iconFrame.icon:SetAllPoints(iconFrame)
        iconFrame.cooldown = CreateFrame("Cooldown", nil, iconFrame, "CooldownFrameTemplate")
        iconFrame.cooldown:SetAllPoints(iconFrame)
        iconFrame.cooldown:SetSwipeColor(0, 0, 0, 0.3)
        iconFrame.cooldown:SetHideCountdownNumbers(true)
        iconFrame.timerText = iconFrame:CreateFontString(nil, "OVERLAY")
        iconFrame.timerText:SetFont(TIMER_FONT, TIMER_FONT_SIZE, "OUTLINE")
        iconFrame.timerText:SetPoint("CENTER", iconFrame, "CENTER", 0, 0)
        iconFrame.timerText:SetTextColor(1, 1, 1, 1)
        iconFrame.timerText:Hide()
        cooldownIcons[nameplate][spellID] = iconFrame
    end
    -- Always update size in case the setting changed
    iconFrame:SetSize(size, size)
    local spellInfo = C_Spell.GetSpellInfo(spellID)
    local texture = spellInfo and spellInfo.iconID
    iconFrame.icon:SetTexture(texture)
    iconFrame:ClearAllPoints()
    iconFrame:SetPoint("LEFT", nameplate, "RIGHT", (index-1)*size, 0)
    iconFrame:Show()
    if remaining and remaining > 0 then
        iconFrame.cooldown:SetCooldown(GetTime(), remaining)
        iconFrame.timerText:Show()
        iconFrame:SetScript("OnUpdate", nil)
        iconFrame:SetScript("OnUpdate", function(self, elapsed)
            local start, duration = self.cooldown:GetCooldownTimes()
            local seconds = (start + duration) / 1000 - GetTime()
            if seconds > 0 then
                self.timerText:SetText(math.ceil(seconds))
            else
                self.timerText:Hide()
                self:SetScript("OnUpdate", nil)
            end
        end)
    else
        iconFrame.cooldown:SetCooldown(0, 0)
        iconFrame.timerText:Hide()
        iconFrame:SetScript("OnUpdate", nil)
    end
end

local function OnCombatLogEvent()
    if not IsInPvPInstance() then return end
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
    if subevent == "SPELL_CAST_SUCCESS" and TRACKED_COOLDOWNS[spellID] then
        if bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 and bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
            cooldownTracker[sourceGUID] = cooldownTracker[sourceGUID] or {}
            cooldownTracker[sourceGUID][spellID] = GetTime() + TRACKED_COOLDOWNS[spellID].duration
            UpdateCooldownIcons()
        end
    end

    if (subevent == "SPELL_HEAL" or subevent == "SPELL_PERIODIC_HEAL" or subevent == "SPELL_CAST_SUCCESS") and healingSpells[spellID] then
        if bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) ~= 0 and bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) ~= 0 then
            healerGUIDs[sourceGUID] = true
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

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
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