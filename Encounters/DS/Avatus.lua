----------------------------------------------------------------------------------------------------
-- Client Lua Script for RaidCore Addon on WildStar Game.
--
-- Copyright (C) 2015 RaidCore
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Description:
--
-- Avatus fight is split in 3 major phases, they start on threshold healh pourcent of Avatus:
--  * From 100% to 75%: Avatus itself, with all players.
--  * At 75%, there is the small labyrinth and green and blue teleporter.
--  * From 75% to 50: Avatus itself, with all players.
--  * At 50%, again the labyrinth with red and yellow teleporter.
--  * From 50% to 25%: Avatus itself, with all players.
--  * From 25% to death: Enrage phase.
--
-- In "Green" phase, there are 24 pillars. An number will be add between two pillars.
-- So 12 numbers will be displayed like this:
--
--        9
--     A     8
--   B         7
--  .     +     6
--   1         5
--     2     4
--        3
--
-- The center is { x = 618.21, z =-174.2 }, and the unit called "Unstoppable Object Simulation"
-- start on West, on the dot so. The dot Pillars are unusable.
--
-- With n from 1 to 12, coordonates are:
-- {{{
--   Angle(n) = PI + (n - 1) * PI / 6
--   Position(n) = {
--       x = 618.21 + 70 * cos(Angle(n)),
--       z = -174.2 + 70 * sin(Angle(n))
--   }
-- }}}
-- Results are stored in GREEN_ROOM_MARKERS constant.
--
-- Extra Informations. Few pillars positions collected:
-- {
--     { x = 671.276489, z = -174.475327 },
--     { x = 565.161865, z = -174.289658 },
--     { x = 618.183533, z = -227.125458 },
--     { x = 661.742126, z = -249.719589 },
--     { x = 574.576834, z = -98.386374 },
--     { x = 530.910645, z = -174.166290 },
--     { x = 645.375183, z = -128.802170 },
--     { x = 663.878540, z = -201.568573 },
--     { x = 591.531921, z = -128.216736 },
--     { x = 693.861572, z = -218.121765 },
--     { x = 705.460144, z = -174.510483 },
--     { x = 618.322693, z = -86.674301 },
--     { x = 618.349182, z = -121.058273 },
--     { x = 644.759949, z = -220.22229 },
--     { x = 542.987549, z = -129.588684 },
-- }
----------------------------------------------------------------------------------------------------
local core = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("RaidCore")
local mod = core:NewEncounter("Avatus", 52, 98, 104)
if not mod then return end

----------------------------------------------------------------------------------------------------
-- Registering combat.
----------------------------------------------------------------------------------------------------
mod:RegisterTrigMob("ANY", { "Avatus" })
mod:RegisterEnglishLocale({
    -- Unit names.
    ["Avatus"] = "Avatus",
    ["Holo Hand"] = "Holo Hand",
    ["Mobius Physics Constructor"] = "Mobius Physics Constructor",
    ["Unstoppable Object Simulation"] = "Unstoppable Object Simulation",
    ["Holo Cannon"] = "Holo Cannon",
    ["Shock Sphere"] = "Shock Sphere",
    ["Support Cannon"] = "Support Cannon",
    ["Infinite Logic Loop"] = "Infinite Logic Loop",
    ["Tower Platform"] = "Tower Platform",
    ["Augmented Rowsdower"] = "Augmented Rowsdower",
    ["Excessive Force Protocol"] = "Excessive Force Protocol",
    ["Fragmented Data Chunk"] = "Fragmented Data Chunk",
    -- Datachron messages.
    ["Portals have opened!"] = "Avatus' power begins to surge! Portals have opened!",
    ["Gun Grid Activated"] = "SECURITY PROTOCOL: Gun Grid Activated.",
    ["The Excessive Force Protocol's protective barrier has fallen."] = "The Excessive Force Protocol's protective barrier has fallen.",
    ["The Excessive Force Protocol has been terminated."] = "The Excessive Force Protocol has been terminated.",
    ["Escalating defense matrix system"] = "Escalating defense matrix system to level (.*) protocols",
    -- Cast.
    ["Crushing Blow"] = "Crushing Blow",
    ["Data Flare"] = "Data Flare",
    ["Obliteration Beam"] = "Obliteration Beam",
    -- BuffName with many ID.
    ["Red Empowerment Matrix"] = "Red Empowerment Matrix",
    ["Blue Disruption Matrix"] = "Blue Disruption Matrix",
    ["Green Reconstitution Matrix"] = "Green Reconstitution Matrix",
    -- Bar and messages.
    ["Holo Hand Spawned"] = "Holo Hand Spawned",
    ["P2 SOON !"] = "P2 SOON !",
    ["P3 SOON !"] = "P3 SOON !",
    ["INTERRUPT CRUSHING BLOW!"] = "INTERRUPT CRUSHING BLOW!",
    ["BLIND! TURN AWAY FROM BOSS"] = "BLIND! TURN AWAY FROM BOSS",
    ["Blind"] = "Blind",
    ["Gun Grid NOW!"] = "Gun Grid NOW!",
    ["~Gun Grid"] = "~Gun Grid",
    ["Hand %u"] = "Hand %u",
    ["MARKER North"] = "North",
    ["MARKER South"] = "South",
    ["MARKER Est"] = "Est",
    ["MARKER West"] = "West",
    ["%s. PURGE BLUE (%s)"] = "%s. PURGE BLUE (%s)",
    ["%s. PURGE RED (%s)"] = "%s. PURGE RED (%s)",
    ["%s. PURGE GREEN (%s)"] = "%s. PURGE GREEN (%s)",
    ["Yellow Room: Combat started"] = "Yellow Room: Combat started",
    ["Mobius health: %d%%"] = "Mobius health: %d%%",
    ["Next increase of number of purge"] = "Next increase of number of purge",
    ["Next purge cycle"] = "Next purge cycle",
    ["Next support cannon"] = "Next support cannon",
})
mod:RegisterFrenchLocale({
    -- Unit names.
    ["Avatus"] = "Avatus",
    ["Holo Hand"] = "Holo-main",
    ["Mobius Physics Constructor"] = "Constructeur de physique de Möbius",
    ["Unstoppable Object Simulation"] = "Simulacre invincible",
    ["Holo Cannon"] = "Holocanon",
    ["Shock Sphere"] = "Sphère de choc",
    ["Support Cannon"] = "Canon d'appui",
    ["Infinite Logic Loop"] = "Boucle de logique infinie",
    ["Tower Platform"] = "Plateforme de la tour",
    ["Augmented Rowsdower"] = "Tamarou augmenté",
    ["Excessive Force Protocol"] = "Protocole de force excessive",
    ["Fragmented Data Chunk"] = "Données fragmentées",
    -- Datachron messages.
    ["Portals have opened!"] = "L'énergie d'Avatus commence à déferler ! Des portails se sont ouverts !",
    ["Gun Grid Activated"] = "PROTOCOLE DE SÉCURITÉ : pétoires activées.",
    --TODO ["The Excessive Force Protocol's protective barrier has fallen."] = "",
    ["The Excessive Force Protocol has been terminated."] = "Le Protocole de force excessive a été abandonné.",
    ["Escalating defense matrix system"] = "Passage de la matrice de défense aux protocoles de niveau (.*)",
    -- Cast.
    ["Crushing Blow"] = "Coup écrasant",
    ["Data Flare"] = "Signal de données",
    ["Obliteration Beam"] = "Rayon de suppression",
    -- BuffName with many ID.
    ["Red Empowerment Matrix"] = "Matrice de renforcement rouge",
    ["Blue Disruption Matrix"] = "Matrice disruptive bleue",
    ["Green Reconstitution Matrix"] = "Matrice de reconstitution verte",
    -- Bar and messages.
    ["Holo Hand Spawned"] = "Holo-main Apparition",
    ["P2 SOON !"] = "P2 BIENTÔT !",
    ["P3 SOON !"] = "P3 BIENTÔT !",
    ["INTERRUPT CRUSHING BLOW!"] = "INTERROMPRE COUP ÉCRASANT!",
    ["BLIND! TURN AWAY FROM BOSS"] = "AVEUGLER! DOS AU BOSS",
    ["Blind"] = "Aveugler",
    ["Gun Grid NOW!"] = "pétoires MAINTENANT!",
    ["~Gun Grid"] = "~Pétoires Grille",
    ["Hand %u"] = "Main %u",
    ["MARKER North"] = "Nord",
    ["MARKER South"] = "Sud",
    ["MARKER Est"] = "Est",
    ["MARKER West"] = "Ouest",
    ["%s. PURGE BLUE (%s)"] = "%s. PURGE BLEUE (%s)",
    ["%s. PURGE RED (%s)"] = "%s. PURGE ROUGE (%s)",
    ["%s. PURGE GREEN (%s)"] = "%s. PURGE VERT (%s)",
    ["Yellow Room: Combat started"] = "Salle Jaune: Combat démarré",
    ["Mobius health: %d%%"] = "Mobius santé: %d%%",
    ["Next increase of number of purge"] = "Prochaine augmentation du nombre de purge",
    ["Next purge cycle"] = "Prochain cycle de purge",
    ["Next support cannon"] = "Prochain canon d'appui",
})
mod:RegisterGermanLocale({
    -- Unit names.
    ["Avatus"] = "Avatus",
    ["Holo Hand"] = "Holohand",
    ["Mobius Physics Constructor"] = "Mobius Physikkonstrukteur",
    ["Unstoppable Object Simulation"] = "Unaufhaltbare Objektsimulation",
    ["Holo Cannon"] = "Holokanone",
    ["Shock Sphere"] = "Schocksphäre",
    ["Support Cannon"] = "Hilfskanone",
    ["Infinite Logic Loop"] = "Unendliche Logikschleife",
    --["Tower Platform"] = "Tower Platform", -- TODO: German translation missing !!!!
    --["Augmented Rowsdower"] = "Augmented Rowsdower", -- TODO: German translation missing !!!!
    -- Datachron messages.
    --["Portals have opened!"] = "Portals have opened!", -- TODO: German translation missing !!!!
    --["Gun Grid Activated"] = "Gun Grid Activated", -- TODO: German translation missing !!!!
    -- Cast.
    ["Crushing Blow"] = "Vernichtender Schlag",
    ["Data Flare"] = "Daten-Leuchtsignal",
    ["Obliteration Beam"] = "Vernichtungsstrahl",
    -- Bar and messages.
    --["Holo Hand Spawned"] = "Holo Hand Spawned", -- TODO: German translation missing !!!!
    ["P2 SOON !"] = "GLEICH PHASE 2 !",
    --["INTERRUPT CRUSHING BLOW!"] = "INTERRUPT CRUSHING BLOW!", -- TODO: German translation missing !!!!
    --["BLIND! TURN AWAY FROM BOSS"] = "BLIND! TURN AWAY FROM BOSS", -- TODO: German translation missing !!!!
    ["Blind"] = "Geblendet",
    --["Gun Grid NOW!"] = "Gun Grid NOW!", -- TODO: German translation missing !!!!
    --["~Gun Grid"] = "~Gun Grid", -- TODO: German translation missing !!!!
    --["Hand %u"] = "Hand %u", -- TODO: German translation missing !!!!
    ["MARKER North"] = "Nord",
    ["MARKER South"] = "Süd",
    ["MARKER Est"] = "Ost",
    ["MARKER West"] = "West",
})
-- Default settings.
mod:RegisterDefaultSetting("LineCleaveBoss")
mod:RegisterDefaultSetting("LineCleaveHands")
mod:RegisterDefaultSetting("LineCleaveYellowRoomBoss")
mod:RegisterDefaultSetting("LineCannons")
mod:RegisterDefaultSetting("LineOrbsYellowRoom")
mod:RegisterDefaultSetting("SoundObliterationBeam")
mod:RegisterDefaultSetting("SoundBlueInterrupt")
mod:RegisterDefaultSetting("SoundPortalPhase")
mod:RegisterDefaultSetting("SoundHandInterrupt")
mod:RegisterDefaultSetting("SoundBlindYellowRoom")
mod:RegisterDefaultSetting("SoundGunGrid")
mod:RegisterDefaultSetting("OtherHandSpawnMarkers")
mod:RegisterDefaultSetting("OtherDirectionMarkers")
mod:RegisterDefaultSetting("OtherGreenRoomMarkers")
mod:RegisterDefaultSetting("OtherPurgeList")
mod:RegisterDefaultSetting("OtherPurgeMessages")
mod:RegisterDefaultSetting("OtherMobiusHealthMessages")
-- Timers default configs.
mod:RegisterDefaultTimerBarConfigs({
    ["OBBEAM"] = { sColor = "xkcdBloodRed" },
    ["BLIND"] = { sColor = "xkcdBurntYellow" },
    ["GGRID"] = { sColor = "xkcdBlue" },
    ["HHAND"] = { sColor = "xkcdOrangeyRed" },
    ["PURGE_CYCLE"] = { sColor = "xkcdBluishGreen" },
    ["PURGE_INCREASE"] = { sColor = "xkcdBoringGreen" },
    ["SUPPORT_CANNON"] = { sColor = "xkcdBrightLilac" },
})

local PURGE_BLUE = 1
local PURGE_RED = 2
local PURGE_GREEN = 3
local PURGE_LIST_IN_BLUE_ROOM = {
    ["Icon_SkillEnergy_UI_srcr_shckcntrp"] = PURGE_BLUE,
    ["Icon_SkillFire_UI_ss_srngblst"] = PURGE_RED,
    ["Icon_SkillEnergy_UI_srcr_surgeengine"] = PURGE_GREEN,
}
local PURGE_COOLDOWNS = 15

----------------------------------------------------------------------------------------------------
-- Constants.
----------------------------------------------------------------------------------------------------
local next = next
local NO_BREAK_SPACE = string.char(194, 160)
local MAIN_PHASE = 1
local LABYRINTH_PHASE = 2
local GREEN_PHASE = 3
local YELLOW_PHASE = 4
local RED_PHASE = 5
local BLUE_PHASE = 6

local CARDINAL_MARKERS = {
    ["north"] = { x = 618, y = -198, z = -235 },
    ["south"] = { x = 618, y = -198, z = -114 },
    ["est"] = { x = 678, y = -198, z = -174 },
    ["west"] = { x = 557, y = -198, z = -174 },
}
local GREEN_ROOM_MARKERS = {
   ["1"] = { y = -198, x = 557.58, z = -139.2 },
   ["2"] = { y = -198, x = 583.21, z = -113.5 },
   ["3"] = { y = -198, x = 618.21, z = -104.2 },
   ["4"] = { y = -198, x = 653.21, z = -113.5 },
   ["5"] = { y = -198, x = 678.83, z = -139.2 },
   ["6"] = { y = -198, x = 688.21, z = -174.2 },
   ["7"] = { y = -198, x = 678.83, z = -209.2 },
   ["8"] = { y = -198, x = 653.21, z = -234.8 },
   ["9"] = { y = -198, x = 618.21, z = -244.2 },
   ["10"] = { y = -198, x = 583.21, z = -234.8 },
   ["11"] = { y = -198, x = 557.58, z = -209.2 },
}
-- Protective Barrier win by Avatus on each end of main phase.
local BUFFID_PROTECTIVE_BARRIER = 45304
-- Buff win by Avatus, which will enable obliteration beam.
local BUFFID_HOLO_CANNONS_ACTIVE = 44756
-- Holo cannons duration per main phase.
local HOLO_CANNONS_DURATION = {
    [1] = 93,
    [2] = 93,
    [3] = 64,
}

----------------------------------------------------------------------------------------------------
-- locals.
----------------------------------------------------------------------------------------------------
local GetGameTime = GameLib.GetGameTime
local GetSpell = GameLib.GetSpell
local GetPlayerUnit = GameLib.GetPlayerUnit
local SetTargetUnit = GameLib.SetTargetUnit
local GetPlayerUnitByName = GameLib.GetPlayerUnitByName
local nCurrentPhase
local tBlueRoomPurgeList
local tHoloHandsList
local bIsHoloHand
local nPurgeCount
local nPurgeCycleCount
local nPurgeCycleCountPerColor
local bWarningSwitchPhaseDone
local nMobiusId
local nMobiusHealthPourcent
local bDisplayHandsPictures
local nAvatusId
local nMainPhaseCount
local nHoloCannonActivationTime
local nEscalatingMax
local nLastSupportCannonPopTime

local function SetMarkersByPhase(nNewPhase)
    -- Remove previous markers
    core:DropWorldMarker("NORTH")
    core:DropWorldMarker("SOUTH")
    core:DropWorldMarker("EST")
    core:DropWorldMarker("WEST")

    -- Set markers
    if MAIN_PHASE == nNewPhase or YELLOW_PHASE == nNewPhase or LABYRINTH_PHASE == nNewPhase then
        if mod:GetSetting("OtherDirectionMarkers") then
            core:SetWorldMarker("NORTH", mod.L["MARKER North"], CARDINAL_MARKERS["north"])
            core:SetWorldMarker("SOUTH", mod.L["MARKER South"], CARDINAL_MARKERS["south"])
            if YELLOW_PHASE == nNewPhase then
                core:SetWorldMarker("EST", mod.L["MARKER Est"], CARDINAL_MARKERS["est"])
                core:SetWorldMarker("WEST", mod.L["MARKER West"], CARDINAL_MARKERS["west"])
            end
        end
    end
    nCurrentPhase = nNewPhase
end

local function RefreshHoloHandPictures()
    if mod:GetSetting("OtherHandSpawnMarkers") and bDisplayHandsPictures then
        core:AddPicture("HAND1", nAvatusId, "RaidCore_Draw:AvatusLeftHand", -60, 17)
        core:AddPicture("HAND2", nAvatusId, "RaidCore_Draw:AvatusRightHand", 60, 17)
    else
        core:RemovePicture("HAND1")
        core:RemovePicture("HAND2")
    end
end

local function DisplayPurgeList()
    if mod:GetSetting("OtherPurgeList") then
        for ePurgeType = PURGE_BLUE, PURGE_GREEN do
            local tCopy = {}
            for k, v in next, tBlueRoomPurgeList[ePurgeType] do
                tCopy[k] = v
            end

            local tOrdered = {}
            while next(tCopy) do
                local f = nil
                for key, val in next, tCopy do
                    if f == nil or tCopy[f] > val then
                        f = key
                    end
                end
                table.insert(tOrdered, f:gmatch("%a+")())
                tCopy[f] = nil
            end

            local sPlayers = table.concat(tOrdered, ", ")
            if ePurgeType == PURGE_BLUE then
                core:Print(mod.L["%s. PURGE BLUE (%s)"]:format("a", sPlayers))
            elseif ePurgeType == PURGE_RED then
                core:Print(mod.L["%s. PURGE RED (%s)"]:format("b", sPlayers))
            elseif ePurgeType == PURGE_GREEN then
                core:Print(mod.L["%s. PURGE GREEN (%s)"]:format("c", sPlayers))
            end
        end
    end
end

local function Spell2PurgeType(nSpellId)
    local sSpellName = GetSpell(nSpellId):GetName()

    if sSpellName == self.L["Green Reconstitution Matrix"] then
        return PURGE_GREEN
    elseif sSpellName == self.L["Blue Disruption Matrix"] then
        return PURGE_BLUE
    elseif sSpellName == self.L["Red Empowerment Matrix"] then
        return PURGE_RED
    end
    return nil
end

----------------------------------------------------------------------------------------------------
-- Encounter description.
----------------------------------------------------------------------------------------------------
function mod:OnBossEnable()
    Apollo.RegisterEventHandler("RC_UnitCreated", "OnUnitCreated", self)
    Apollo.RegisterEventHandler("RC_UnitDestroyed", "OnUnitDestroyed", self)
    Apollo.RegisterEventHandler("RC_UnitStateChanged", "OnEnteredCombat", self)
    Apollo.RegisterEventHandler("SPELL_CAST_START", "OnSpellCastStart", self)
    Apollo.RegisterEventHandler("CHAT_DATACHRON", "OnChatDC", self)
    Apollo.RegisterEventHandler("CHAT_NPCSAY", "OnChatNPCSay", self)
    Apollo.RegisterEventHandler("BUFF_APPLIED", "OnBuffApplied", self)
    Apollo.RegisterEventHandler("BUFF_DEL", "OnBuffDel", self)
    Apollo.RegisterEventHandler("SHORTCUT_BAR", "OnShowShortcutBar", self)

    SetMarkersByPhase(MAIN_PHASE)
    bWarningSwitchPhaseDone = false
    tBlueRoomPurgeList = {
        [PURGE_BLUE] = {},
        [PURGE_RED] = {},
        [PURGE_GREEN] = {},
    }
    tHoloHandsList = {}
    bGreenRoomMarkerDisplayed = false
    bIsHoloHand = true
    nPurgeCount = 0
    nPurgeCycleCount = 0
    nPurgeCycleCountPerColor = {
        [PURGE_BLUE] = 0,
        [PURGE_RED] = 0,
        [PURGE_GREEN] = 0,
    }
    nMobiusId = nil
    nMobiusHealthPourcent = 100
    nAvatusId = nil
    nMainPhaseCount = 1
    nEscalatingMax = nil
    nHoloCannonActivationTime = nil
    bDisplayHandsPictures = false
    nLastSupportCannonPopTime = 0

    mod:AddTimerBar("GGRID", "~Gun Grid", 21, mod:GetSetting("SoundGunGrid"))
end

function mod:OnUnitCreated(unit, sName)
    local nUnitId = unit:GetId()
    local nHealth = unit:GetHealth()

    if self.L["Avatus"] == sName then
        SetMarkersByPhase(MAIN_PHASE)
        core:AddUnit(unit)
        core:WatchUnit(unit)
        if mod:GetSetting("LineCleaveBoss") then
            core:AddPixie(unit:GetId(), 2, unit, nil, "Green", 10, 22, 0)
        end
        nAvatusId = nUnitId
        RefreshHoloHandPictures()
    elseif self.L["Augmented Rowsdower"] == sName then
        SetMarkersByPhase(LABYRINTH_PHASE)
        mod:AddMsg("Rowsdower", "Augmented Rowsdower", 3)
        SetTargetUnit(unit)
    elseif sName == self.L["Mobius Physics Constructor"] then
        -- Portals have same name, actual boss has HP, portals have nil value.
        if nHealth then
            SetMarkersByPhase(YELLOW_PHASE)
            core:AddUnit(unit)
            core:WatchUnit(unit)
            if mod:GetSetting("LineCleaveYellowRoomBoss") then
                core:AddPixie(nUnitId, 2, unit, nil, "Red", 5, 35, 0)
            end
        else
            -- Draw a line to the yellow portal.
            core:AddPixie(nUnitId, 1, unit, GetPlayerUnit(), "xkcdBananaYellow")
        end
    elseif sName == self.L["Unstoppable Object Simulation"] then
        -- Portals have same name, actual boss has HP, portals have nil value.
        if nHealth then
            SetMarkersByPhase(GREEN_PHASE)
            core:AddUnit(unit)
            core:WatchUnit(unit)
        else
            -- Draw a line to the green portal.
            core:AddPixie(nUnitId, 1, unit, GetPlayerUnit(), "green")
        end
    elseif sName == self.L["Infinite Logic Loop"] then
        if nHealth then
            -- Blue room.
            SetMarkersByPhase(BLUE_PHASE)
            core:AddUnit(unit)
            core:WatchUnit(unit)
            -- When player from red room come to blue room, the event EnteringInCombat is not
            -- received.
            if unit:IsInCombat() then
                DisplayPurgeList()
            end
        else
            -- Draw a line to the blue portal.
            core:AddPixie(nUnitId, 1, unit, GetPlayerUnit(), "blue")
        end
    elseif sName == self.L["Holo Hand"] then
        bDisplayHandsPictures = false
        RefreshHoloHandPictures()
        core:AddUnit(unit)
        core:WatchUnit(unit)
        table.insert(tHoloHandsList, nUnitId, { ["unit"] = unit} )
        mod:AddMsg("HHAND", "Holo Hand Spawned", 5, "Info")
        if mod:GetSetting("LineCleaveHands") then
            core:AddPixie(nUnitId .. "_1", 2, unit, nil, "Blue", 7, 25, 0)
            core:AddPixie(nUnitId .. "_2", 2, unit, nil, "xkcdBluegrey", 3, 7, 60)
            core:AddPixie(nUnitId .. "_3", 2, unit, nil, "xkcdBluegrey", 3, 7, 300)
        end
    elseif self.L["Excessive Force Protocol"] == sName then
        if nHealth then
            -- Red room.
            SetMarkersByPhase(RED_PHASE)
            core:AddUnit(unit)
            core:WatchUnit(unit)
        else
            -- Draw a line to the red portal.
            core:AddPixie(nUnitId, 1, unit, GetPlayerUnit(), "red")
        end
    elseif sName == self.L["Holo Cannon"] and mod:GetSetting("LineCannons") then
        core:AddPixie(unit:GetId(), 2, unit, nil, "Blue", 5, 100, 0)
    elseif sName == self.L["Shock Sphere"] and mod:GetSetting("LineOrbsYellowRoom") then
        -- Yellow room orbs.
        core:AddPixie(unit:GetId(), 2, unit, nil, "Blue", 5, -7, 0)
    elseif sName == self.L["Support Cannon"] then
        core:AddUnit(unit)
        local nCurrentTime = GetGameTime()
        if nLastSupportCannonPopTime + 20 < nCurrentTime then
            nLastSupportCannonPopTime = nCurrentTime
            mod:AddTimerBar("SUPPORT_CANNON", "Next support cannon", 23)
        end
    elseif sName == self.L["Tower Platform"] then
        if not bGreenRoomMarkerDisplayed and mod:GetSetting("OtherGreenRoomMarkers") then
            bGreenRoomMarkerDisplayed = true
            for k, tPosition in next, GREEN_ROOM_MARKERS do
                core:SetWorldMarker("GREEN_ROOM_MARKERS_" .. k, k, tPosition)
            end
        end
    elseif self.L["Fragmented Data Chunk"] == sName then
        if mod:GetSetting("LineCleaveHands") then
            core:AddSimpleLine(nUnitId .. "_1", nUnitId, 0, 25, 0, 5, "Blue")
            core:AddSimpleLine(nUnitId .. "_2", nUnitId, 0, 7, 60, 3, "xkcdBluegrey")
            core:AddSimpleLine(nUnitId .. "_3", nUnitId, 0, 7, -60, 3,  "xkcdBluegrey")
        end
    end
end

function mod:OnUnitDestroyed(unit, sName)
    local nUnitId = unit:GetId()

    if sName == self.L["Holo Hand"] then
        core:DropPixie(nUnitId .. "_1")
        core:DropPixie(nUnitId .. "_2")
        core:DropPixie(nUnitId .. "_3")
        if tHoloHandsList[nUnitId] then
            tHoloHandsList[nUnitId] = nil
        end
    elseif sName == self.L["Holo Cannon"] then
        core:DropPixie(nUnitId)
    elseif sName == self.L["Avatus"] then
        core:DropPixie(nUnitId)
        core:RemovePicture("HAND1")
        core:RemovePicture("HAND2")
    elseif sName == self.L["Shock Sphere"] then
        core:DropPixie(nUnitId)
    elseif sName == self.L["Infinite Logic Loop"] then
        core:DropPixie(nUnitId)
        mod:RemoveTimerBar("PURGE_CYCLE")
        mod:RemoveTimerBar("PURGE_INCREASE")
    elseif sName == self.L["Mobius Physics Constructor"] then
        core:DropPixie(nUnitId)
        if unit:GetHealth() then
            -- Send information about the miniboss, not the portal.
            mod:SendIndMessage("MOBIUS_DEATH")
        end
    elseif self.L["Unstoppable Object Simulation"] == sName then
        core:DropPixie(nUnitId)
    elseif self.L["Excessive Force Protocol"] == sName then
        core:DropPixie(nUnitId)
    elseif sName == self.L["Tower Platform"] then
        if bGreenRoomMarkerDisplayed then
            bGreenRoomMarkerDisplayed = false
            for k, tPosition in next, GREEN_ROOM_MARKERS do
                core:DropWorldMarker("GREEN_ROOM_MARKERS_" .. k)
            end
        end
    elseif self.L["Fragmented Data Chunk"] == sName then
        core:RemoveSimpleLine(nUnitId .. "_1")
        core:RemoveSimpleLine(nUnitId .. "_2")
        core:RemoveSimpleLine(nUnitId .. "_3")
    end
end

function mod:OnEnteredCombat(tUnit, bInCombat, sName)
    if unitName == self.L["Infinite Logic Loop"] then
        if bInCombat then
            DisplayPurgeList()
        end
    elseif sName == self.L["Mobius Physics Constructor"] then
        mod:SendIndMessage("MOBIUS_IN_COMBAT", tUnit:GetId())
    end
end

function mod:OnBuffApplied(unitName, splId, unit)
    local nId = unit:GetId()
    if unitName == self.L["Infinite Logic Loop"] then
        local ePurgeType = Spell2PurgeType(splId)

        if ePurgeType then
            nPurgeCount = nPurgeCount + 1
            if nEscalatingMax then
                nPurgeCycleCount = nPurgeCycleCount + 1
                nPurgeCycleCountPerColor[ePurgeType] = nPurgeCycleCountPerColor[ePurgeType] + 1
                if nPurgeCycleCount == 1 then
                    mod:AddTimerBar("PURGE_CYCLE", "Next purge cycle", 20)
                end
            end
            if nCurrentPhase == BLUE_PHASE and mod:GetSetting("OtherPurgeMessages") then
                local a = nEscalatingMax and nPurgeCycleCount or nPurgeCount
                local b = nEscalatingMax and nPurgeCycleCountPerColor[ePurgeType] or "NA"
                a = tostring(a)
                b = tostring(b)
                if ePurgeType == PURGE_GREEN then
                    mod:AddMsg("PURGE", self.L["%s. PURGE GREEN (%s)"]:format(a, b), 3, nil, "green")
                elseif ePurgeType == PURGE_BLUE then
                    mod:AddMsg("PURGE", self.L["%s. PURGE BLUE (%s)"]:format(a, b), 3, nil, "blue")
                elseif ePurgeType == PURGE_RED then
                    mod:AddMsg("PURGE", self.L["%s. PURGE RED (%s)"]:format(a, b), 3, nil, "red")
                end
            end
            if nEscalatingMax and nPurgeCycleCount >= nEscalatingMax then
                nPurgeCycleCount = 0
                nPurgeCycleCountPerColor[PURGE_BLUE] = 0
                nPurgeCycleCountPerColor[PURGE_RED] = 0
                nPurgeCycleCountPerColor[PURGE_GREEN] = 0
            end
        end
    elseif nAvatusId == nId then
        if BUFFID_HOLO_CANNONS_ACTIVE == splId then
            if not nHoloCannonActivationTime then
                nHoloCannonActivationTime = GetGameTime()
                mod:AddTimerBar("OBBEAM", "Obliteration Beam", 26, mod:GetSetting("SoundObliterationBeam"))
            end
        elseif BUFFID_PROTECTIVE_BARRIER == splId then
            -- End of one main phase.
            nHoloCannonActivationTime = nil
            bWarningSwitchPhaseDone = false
            if nMainPhaseCount >= 3 then
                mod:RemoveTimerBar("GGRID")
                mod:RemoveTimerBar("OBBEAM")
                mod:RemoveTimerBar("HOLO")
            end
        end
    end
end

function mod:OnBuffDel(nId, nSpellId)
    if nAvatusId == nId then
        if BUFFID_PROTECTIVE_BARRIER == nSpellId then
            -- New main phase.
            nMainPhaseCount = nMainPhaseCount < 3 and nMainPhaseCount + 1 or 3
        end
    end
end

function mod:OnHealthChanged(nId, nPourcent, sName)
    if sName == self.L["Avatus"] then
        if not bWarningSwitchPhaseDone then
            if nPourcent >= 75 and nPourcent <= 76 then
                bWarningSwitchPhaseDone = true
                mod:AddMsg("AVAP2", "P2 SOON !", 5, mod:GetSetting("SoundPortalPhase") and "Info")
            elseif nPourcent >= 50 and nPourcent <= 52 then
                bWarningSwitchPhaseDone = true
                mod:AddMsg("AVAP2", "P2 SOON!", 5, mod:GetSetting("SoundPortalPhase") and "Info")
            elseif nPourcent >= 25 and nPourcent <= 27 then
                bWarningSwitchPhaseDone = true
                mod:AddMsg("AVAP2", "P3 SOON!", 5, mod:GetSetting("SoundPortalPhase") and "Info")
            end
        end
    elseif self.L["Mobius Physics Constructor"] == sName then
        if nPourcent % 10 == 0 and nPourcent < 100 then
            mod:SendIndMessage("MOBIUS_HEALTH_UPDATE", nPourcent)
        end
    end
end

function mod:OnSpellCastStart(unitName, castName, unit)
    if unitName == self.L["Avatus"] then
        if self.L["Obliteration Beam"] == castName then
            local EndOfCannon = nHoloCannonActivationTime + HOLO_CANNONS_DURATION[nMainPhaseCount]
            local NextBeam = GetGameTime() + 37
            if EndOfCannon > NextBeam and nMainPhaseCount < 3 then
                mod:AddTimerBar("OBBEAM", "Obliteration Beam", 37, mod:GetSetting("SoundObliterationBeam"))
            else
                mod:RemoveTimerBar("OBBEAM")
            end
        end
    elseif unitName == self.L["Holo Hand"] and castName == self.L["Crushing Blow"] then
        local playerUnit = GetPlayerUnit()
        for _, hand in pairs(tHoloHandsList) do
            local distance_to_hand = self:GetDistanceBetweenUnits(playerUnit, hand["unit"])
            hand["distance"] = distance_to_hand
        end

        local closest_holo_hand = tHoloHandsList[next(tHoloHandsList)]
        for _, hand in pairs(tHoloHandsList) do
            if hand["distance"] < closest_holo_hand["distance"] then
                closest_holo_hand = hand
            end
        end
        local sSpellName = closest_holo_hand["unit"]:GetCastName():gsub(NO_BREAK_SPACE, " ")
        if sSpellName == self.L["Crushing Blow"] then
            mod:AddMsg("CRBLOW", "INTERRUPT CRUSHING BLOW!", 5, mod:GetSetting("SoundHandInterrupt") and "Inferno")
        end
    elseif unitName == self.L["Mobius Physics Constructor"] and castName == self.L["Data Flare"] then
        mod:AddTimerBar("BLIND", "Blind", 29, mod:GetSetting("SoundBlindYellowRoom"))
        mod:AddMsg("BLIND", "BLIND! TURN AWAY FROM BOSS", 5, mod:GetSetting("SoundBlindYellowRoom") and "Inferno")
    end
end

function mod:OnChatDC(message)
    local nEscalatingFound = message:match(self.L["Escalating defense matrix system"])
    if message:find(self.L["Gun Grid Activated"]) then
        mod:AddMsg("GGRIDMSG", "Gun Grid NOW!", 5, mod:GetSetting("SoundGunGrid") and "Beware")
        mod:AddTimerBar("GGRID", "~Gun Grid", 112, mod:GetSetting("SoundGunGrid"))
        if bIsHoloHand then
            mod:AddTimerBar("HOLO", "Holo Hand", 22)
            bDisplayHandsPictures = true
            RefreshHoloHandPictures()
        else
            mod:AddTimerBar("HOLO", "Holo Cannon", 22)
        end
        bIsHoloHand = not bIsHoloHand
    elseif message:find(self.L["Portals have opened!"]) then
        mod:RemoveTimerBar("GGRID")
        mod:RemoveTimerBar("OBBEAM")
        mod:RemoveTimerBar("HOLO")
    elseif nEscalatingFound then
        nEscalatingMax = tonumber(nEscalatingFound)
        mod:AddTimerBar("PURGE_INCREASE", "Next increase of number of purge", 30)
    end
end

function mod:OnShowShortcutBar(tIconFloatingSpellBar)
    if #tIconFloatingSpellBar > 0 then
        local sIcon1 = tIconFloatingSpellBar[1]
        local ePurgeType = PURGE_LIST_IN_BLUE_ROOM[sIcon1]
        if ePurgeType then
            tBlueRoomPurgeList[ePurgeType][GetPlayerUnit():GetName()] = GetGameTime()
            mod:SendIndMessage("PURGE_TYPE", ePurgeType)
        end
    end
end

function mod:ReceiveIndMessage(sFrom, sReason, data)
    if "MOBIUS_IN_COMBAT" == sReason then
        -- Drop this message for player in Yellow phase.
        if (nCurrentPhase == LABYRINTH_PHASE or nCurrentPhase == GREEN_PHASE) and nMobiusId == nil then
            nMobiusId = data
            nMobiusHealthPourcent = 100
            if mod:GetSetting("OtherMobiusHealthMessages") then
                mod:AddMsg("MOBIUS_INFO", "Yellow Room: Combat started", 3, nil, "blue")
            end
        end
    elseif "MOBIUS_HEALTH_UPDATE" == sReason then
        if nCurrentPhase == GREEN_PHASE and nMobiusHealthPourcent > data then
            nMobiusHealthPourcent = data
            if mod:GetSetting("OtherMobiusHealthMessages") then
                mod:AddMsg("MOBIUS_INFO", self.L["Mobius health: %d%%"]:format(nMobiusHealthPourcent), 2, nil, "blue")
            end
        end
    elseif "MOBIUS_DEATH" == sReason then
        if nCurrentPhase == GREEN_PHASE and nMobiusHealthPourcent ~= 0 then
            nMobiusHealthPourcent = 0
            if mod:GetSetting("OtherMobiusHealthMessages") then
                mod:AddMsg("MOBIUS_INFO", self.L["Mobius health: %d%%"]:format(0), 2, nil, "blue")
            end
        end
    elseif "PURGE_TYPE" == sReason then
        tBlueRoomPurgeList[data][sFrom] = GetGameTime()
    end
end
