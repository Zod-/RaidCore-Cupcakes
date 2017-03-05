----------------------------------------------------------------------------------------------------
-- Client Lua Script for RaidCore Addon on WildStar Game.
--
-- Copyright (C) 2015 RaidCore
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- Description:
-- Unique encounter in Core-Y83 raid.
--
-- - There are 3 boss called "unit.augmentor.inactive". At any moment, one of them is
-- compromised, and his name is "unit.augmentor.active".
-- - Bosses don't move, their positions are constants so.
-- - The boss call "unit.augmentor.active" have a debuff called "Compromised Circuitry".
-- - And switch boss occur at 60% and 20% of health.
-- - The player which will be irradied is the last connected in the game (probability: 95%).
--
-- So be careful, with code based on name, as bosses are renamed many times during the combat.
--
----------------------------------------------------------------------------------------------------
local core = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("RaidCore")
local mod = core:NewEncounter("PrimeEvolutionaryOperant", 91, 0, 475)
if not mod then return end

----------------------------------------------------------------------------------------------------
-- Registering combat.
----------------------------------------------------------------------------------------------------
mod:RegisterTrigMob(core.E.TRIGGER_ANY, {
    "unit.augmentor.inactive",
    "unit.augmentor.active",
    "unit.incinerator"
  }
)
mod:RegisterEnglishLocale({
    -- Unit names.
    ["unit.augmentor.inactive"] = "Prime Evolutionary Operant",
    ["unit.augmentor.active"] = "Prime Phage Distributor",
    ["unit.add"] = "Sternum Buster",
    ["unit.incinerator"] = "Organic Incinerator",
    -- Datachron messages.
    ["chron.irradiated"] = "(.*) is being irradiated!",
    ["chron.transmission"] = "ENGAGING TECHNOPHAGE TRASMISSION",
    ["chron.corrupted"] = "A Prime Purifier has been corrupted!",
    ["chron.decontamination"] = "INITIATING DECONTAMINATION SEQUENCE",
    -- Cast
    ["cast.incinerator.disintegrate"] = "Disintegrate",
    ["cast.augmentor.digitize"] = "cast.augmentor.digitize",
    ["cast.augmentor.injection"] = "Strain Injection",
    ["cast.augmentor.spike"] = "Corruption Spike",
    -- Bars messages.
    ["msg.irradiate"] = "~Next irradiate",
    ["msg.corruption.warning"] = "%u STACKS BEFORE CORRUPTION",
  }
)
mod:RegisterFrenchLocale({
    -- Unit names.
    ["unit.augmentor.inactive"] = "Opérateur de la Primo Évolution",
    ["unit.augmentor.active"] = "Distributeur de Primo Phage",
    ["unit.incinerator"] = "Incinérateur organique",
    -- Datachron messages.
    ["chron.irradiated"] = "(.*) est irradiée.",
    ["chron.transmission"] = "ENCLENCHEMENT DE LA TRANSMISSION DU TECHNOPHAGE",
    ["cast.incinerator.disintegrate"] = "Désintégration",
    -- Bars messages.
    ["msg.irradiate"] = "~Prochaine irradiation",
    ["msg.corruption.warning"] = "%u STACKS AVANT CORRUPTION",
  }
)
mod:RegisterGermanLocale({
  }
)
-- Default settings.
mod:RegisterDefaultSetting("SoundNextIrradiateCountDown")
mod:RegisterDefaultSetting("SoundSwitch")
mod:RegisterDefaultSetting("LinesOnBosses")
mod:RegisterDefaultSetting("LineRadiation")
mod:RegisterDefaultSetting("PictureIncubation")
mod:RegisterDefaultSetting("IncubationRegroupZone")
mod:RegisterDefaultSetting("OrganicIncineratorBeam")
-- Timers default configs.
mod:RegisterDefaultTimerBarConfigs({
    ["NEXT_IRRADIATE"] = { sColor = "xkcdLightRed" },
  }
)
mod:RegisterUnitBarConfig("unit.augmentor.inactive", {
    tMidphases = {
      {percent = 60},
      {percent = 20},
    }
  }
)
mod:RegisterUnitBarConfig("unit.augmentor.active", {
    tMidphases = {
      {percent = 60},
      {percent = 20},
    }
  }
)

----------------------------------------------------------------------------------------------------
-- Copy of few objects to reduce the cpu load.
-- Because all local objects are faster.
----------------------------------------------------------------------------------------------------
local GetGameTime = GameLib.GetGameTime
local GetPlayerUnitByName = GameLib.GetPlayerUnitByName
local NewVector3 = Vector3.New

----------------------------------------------------------------------------------------------------
-- Constants.
----------------------------------------------------------------------------------------------------
-- Center of the room, where is the unit.incinerator button.
local ORGANIC_INCINERATOR = { x = 1268, y = -800, z = 876 }

local DEBUFFS = {
  RADIATION_BATH = 71188, -- Cleansing debuff in bath
  STRAIN_INCUBATION = 49303, -- DOT from active boss, cleanse with bath/phase push
  DEGENERATION = 79892, -- HM debuff
  PAIN_SUPPRESSORS = 81783, -- HM debuff, Laser interrupt
}
local BUFFS = {
  NANOSTRAIN_INFUSION = 50075, -- Wall buff on boss
  COMPROMISED_CIRCUITRY = 48735, -- Active boss
}

local NANOSTRAIN_2_CORRUPTION_THRESHOLD = 15
-- On the axe Y, where is the ground.
local GROUND_Y = -800.51
-- Lines on bosses.
local STATIC_LINES = {
  -- West boss (or left):
  { NewVector3(1220.19, GROUND_Y, 874.18), NewVector3(1246.70, GROUND_Y, 920.07) },
  { NewVector3(1216.12, GROUND_Y, 893.83), NewVector3(1208.58, GROUND_Y, 880.88) },
  { NewVector3(1216.12, GROUND_Y, 893.83), NewVector3(1201.14, GROUND_Y, 893.83) },
  { NewVector3(1216.12, GROUND_Y, 907.16), NewVector3(1201.14, GROUND_Y, 907.16) },
  { NewVector3(1216.12, GROUND_Y, 907.16), NewVector3(1208.64, GROUND_Y, 920.10) },
  { NewVector3(1227.65, GROUND_Y, 913.78), NewVector3(1220.25, GROUND_Y, 926.77) },
  { NewVector3(1227.65, GROUND_Y, 913.78), NewVector3(1235.09, GROUND_Y, 926.77) },
  -- Est boss (or right):
  { NewVector3(1289.25, GROUND_Y, 920.17), NewVector3(1315.75, GROUND_Y, 874.27) },
  { NewVector3(1308.30, GROUND_Y, 913.88), NewVector3(1300.85, GROUND_Y, 926.87) },
  { NewVector3(1308.30, GROUND_Y, 913.88), NewVector3(1315.75, GROUND_Y, 926.87) },
  { NewVector3(1319.82, GROUND_Y, 907.23), NewVector3(1327.35, GROUND_Y, 920.17) },
  { NewVector3(1319.82, GROUND_Y, 907.23), NewVector3(1334.80, GROUND_Y, 907.27) },
  { NewVector3(1319.82, GROUND_Y, 893.92), NewVector3(1334.80, GROUND_Y, 893.92) },
  { NewVector3(1319.82, GROUND_Y, 893.92), NewVector3(1327.35, GROUND_Y, 880.97) },
  -- North boss (or middle/ahead):
  { NewVector3(1294.67, GROUND_Y, 837.02), NewVector3(1241.67, GROUND_Y, 837.02) },
  { NewVector3(1279.70, GROUND_Y, 823.67), NewVector3(1294.67, GROUND_Y, 823.62) },
  { NewVector3(1279.70, GROUND_Y, 823.67), NewVector3(1287.22, GROUND_Y, 810.72) },
  { NewVector3(1268.17, GROUND_Y, 817.01), NewVector3(1275.62, GROUND_Y, 804.02) },
  { NewVector3(1268.17, GROUND_Y, 817.01), NewVector3(1260.72, GROUND_Y, 804.02) },
  { NewVector3(1256.64, GROUND_Y, 823.67), NewVector3(1249.12, GROUND_Y, 810.72) },
  { NewVector3(1256.64, GROUND_Y, 823.67), NewVector3(1241.67, GROUND_Y, 823.62) },
}
local INCUBATION_ZONE_WEST = 1
local INCUBATION_ZONE_NORTH = 2
local INCUBATION_ZONE_EST = 3
local INCUBATION_REGROUP_ZONE = {
  -- West boss (or left):
  [INCUBATION_ZONE_WEST] = NewVector3(1238.03, GROUND_Y, 894.45),
  -- North boss (or middle/ahead):
  [INCUBATION_ZONE_NORTH] = NewVector3(1268.17, GROUND_Y, 842.32),
  -- Est boss (or right):
  [INCUBATION_ZONE_EST] = NewVector3(1298.20, GROUND_Y, 894.57),
}

----------------------------------------------------------------------------------------------------
-- Locals.
----------------------------------------------------------------------------------------------------
local nRadiationEndTime
local painSuppressorsFadeTime
local tPrimeOperant2ZoneIndex
local nPrimeDistributorId
local bIsPhaseUnder20Poucent

----------------------------------------------------------------------------------------------------
-- Encounter description.
----------------------------------------------------------------------------------------------------
function mod:OnBossEnable()
  nRadiationEndTime = 0
  painSuppressorsFadeTime = 0
  tPrimeOperant2ZoneIndex = {}
  nPrimeDistributorId = nil
  bIsPhaseUnder20Poucent = false
  mod:AddTimerBar("NEXT_IRRADIATE", "msg.irradiate", 27, mod:GetSetting("SoundNextIrradiateCountDown"))
  if mod:GetSetting("LinesOnBosses") then
    for i, Vectors in next, STATIC_LINES do
      core:AddLineBetweenUnits("StaticLine" .. i, Vectors[1], Vectors[2], 3, "xkcdAmber")
    end
  end
  if mod:GetSetting("IncubationRegroupZone") then
    local Vector = INCUBATION_REGROUP_ZONE[INCUBATION_ZONE_NORTH]
    core:AddPicture("IZ" .. INCUBATION_ZONE_NORTH, Vector, "ClientSprites:LootCloseBox_Holo", 30)
  end
end

function mod:OnOperantCreated(id, unit, name)
  local priority
  core:WatchUnit(unit, core.E.TRACK_BUFFS + core.E.TRACK_HEALTH)
  core:AddSimpleLine("CLEAVE_"..id, id, 0, 15, 0, 5, "green")
  local tPosition = unit:GetPosition()
  if tPosition.x < ORGANIC_INCINERATOR.x then
    priority = 1
    core:MarkUnit(unit, 51, "L")
    tPrimeOperant2ZoneIndex[id] = INCUBATION_ZONE_WEST
  else
    priority = 3
    core:MarkUnit(unit, 51, "R")
    tPrimeOperant2ZoneIndex[id] = INCUBATION_ZONE_EST
  end
  mod:AddUnit(unit, nil, priority)
end

function mod:OnAugmentorDestroyed(id, unit, name)
  core:RemoveSimpleLine("CLEAVE_"..id)
end

function mod:OnDistributorCreated(id, unit, name)
  mod:AddUnit(unit, nil, 2)
  core:WatchUnit(unit, core.E.TRACK_BUFFS + core.E.TRACK_HEALTH)
  core:MarkUnit(unit, 51, "M")
  core:AddSimpleLine("CLEAVE_"..id, id, 0, 15, 0, 5, "green")
  tPrimeOperant2ZoneIndex[id] = INCUBATION_ZONE_NORTH
  nPrimeDistributorId = id
end

function mod:OnIncineratorCreated(id, unit, name)
  core:WatchUnit(unit, core.E.TRACK_CASTS)
end

function mod:OnIncineratorDestroyed(id, unit, name)
  core:RemoveSimpleLine("INCINERATOR_BEAM")
end

function mod:OnDatachron(sMessage)
  local sPlayerNameIrradiate = sMessage:match(self.L["chron.irradiated"])
  if sPlayerNameIrradiate then
    -- Sometime it's 26s, sometime 27s or 28s.
    mod:AddTimerBar("NEXT_IRRADIATE", "msg.irradiate", 26, mod:GetSetting("SoundNextIrradiateCountDown"))
    if mod:GetSetting("LineRadiation") then
      local tMemberUnit = GetPlayerUnitByName(sPlayerNameIrradiate)
      if tMemberUnit then
        local memberId = tMemberUnit:GetId()
        if not tMemberUnit:IsThePlayer() then
          local o = core:AddLineBetweenUnits("RADIATION", mod.player.id, memberId, 3, "cyan")
          o:SetMinLengthVisible(10)
        end
      end
    end
  elseif sMessage == self.L["chron.transmission"] then
    mod:AddTimerBar("NEXT_IRRADIATE", "msg.irradiate", 40, mod:GetSetting("SoundNextIrradiateCountDown"))
  elseif sMessage == self.L["chron.corrupted"] then
    bIsPhaseUnder20Poucent = true
  end
end

function mod:OnAugmentorHealthChanged(id, percent, name)
  if mod:IsMidphaseClose(name, percent) then
    mod:AddMsg("SWITCH", "SWITCH SOON", 5, mod:GetSetting("SoundSwitch") and "Long")
  elseif percent == 20 then
    tPrimeOperant2ZoneIndex[id] = nil
  end
end

function mod:OnStrainIncubationAdd(id, spellId, stack, timeRemaining, name, unitCaster, unitTarget)
  if mod:GetSetting("PictureIncubation") then
    core:AddPicture("INCUBATION_"..id, id, "Crosshair", 20)
  end
  if mod:GetSetting("IncubationRegroupZone") and nPrimeDistributorId then
    local nIndex = tPrimeOperant2ZoneIndex[nPrimeDistributorId]
    if nIndex then
      local sColor = unitTarget:IsThePlayer() and "ffff00ff" or "60ff00ff"
      local Vector = INCUBATION_REGROUP_ZONE[nIndex]
      local o = core:AddLineBetweenUnits("SAFE_ZONE_GO_"..id, id, Vector, 5, sColor, 10)
      o:SetSprite("CRB_MegamapSprites:sprMap_PlayerArrowNoRing", 20)
      o:SetMinLengthVisible(5)
      o:SetMaxLengthVisible(50)
    end
  end
end

function mod:OnRadiationBathAdd(id, spellId, stack, timeRemaining, name, unitCaster, unitTarget)
  local currentTime = GetGameTime()
  if nRadiationEndTime < currentTime then
    nRadiationEndTime = currentTime + 12
    if mod:GetSetting("LineRadiation") then
      local o = core:AddLineBetweenUnits("RADIATION", mod.player.id, unitTarget:GetPosition(), 3, "cyan")
      o:SetMinLengthVisible(10)
      mod:ScheduleTimer(function()
          core:RemoveLineBetweenUnits("RADIATION")
        end,
        10)
    end
  end
end

function mod:OnPainSuppressorsAdd(id, spellId, stack, timeRemaining, name, unitCaster, unitTarget)
  local currentTime = GetGameTime()
  if painSuppressorsFadeTime < currentTime then
    painSuppressorsFadeTime = currentTime + timeRemaining
    local line = core:GetSimpleLine("INCINERATOR_BEAM")
    if line then
      line:SetColor("6000ff00")
      self:ScheduleTimer(function(l) l:SetColor("A0ff8000") end, 4, line)
      self:ScheduleTimer(function(l) l:SetColor("red") end, 5, line)
    end
  end
end

function mod:OnStrainIncubationRemove(id)
  core:RemovePicture("INCUBATION_"..id)
  core:RemoveLineBetweenUnits("SAFE_ZONE_GO_"..id)
end

function mod:OnAnyUnitDestroyed(id, unit, name)
  mod:OnStrainIncubationRemove(id)
end

function mod:OnCompromisedCircuitryAdd(id, spellId, stack, timeRemaining, name, unitCaster, unitTarget)
  for i, Vector in next, INCUBATION_REGROUP_ZONE do
    core:RemovePicture("IZ" .. i)
  end
  if not bIsPhaseUnder20Poucent then
    nPrimeDistributorId = id
    if mod:GetSetting("IncubationRegroupZone") then
      local nIndex = tPrimeOperant2ZoneIndex[id]
      if nIndex then
        local Vector = INCUBATION_REGROUP_ZONE[nIndex]
        core:AddPicture("IZ" .. nIndex, Vector, "ClientSprites:LootCloseBox_Holo", 30)
      end
    end
  end
end

--TODO: Filter out dropping stacks
function mod:OnNanostrainInfusionUpdate(id, spellId, stack, timeRemaining, name, unitCaster, unitTarget)
  local nRemain = NANOSTRAIN_2_CORRUPTION_THRESHOLD - stack
  if nRemain == 2 or nRemain == 1 then
    local sColor = nRemain == 2 and "blue" or "red"
    core:AddMsg("WARNING", self.L["msg.corruption.warning"]:format(nRemain), 4, nil, sColor)
  end
end

function mod:OnDisintegrateStart(id, castName, endTime, name)
  local line = core:GetSimpleLine("INCINERATOR_BEAM")
  if not line and mod:GetSetting("OrganicIncineratorBeam") then
    core:AddSimpleLine("INCINERATOR_BEAM", id, 0, 65, 0, 10, "red")
  end
end
----------------------------------------------------------------------------------------------------
-- Bind event handlers.
----------------------------------------------------------------------------------------------------
mod:RegisterUnitEvents(core.E.ALL_UNITS, {
    [core.E.UNIT_DESTROYED] = mod.OnAnyUnitDestroyed,
    [DEBUFFS.STRAIN_INCUBATION] = {
      [core.E.DEBUFF_ADD] = mod.OnStrainIncubationAdd,
      [core.E.DEBUFF_REMOVE] = mod.OnStrainIncubationRemove,
    },
    [DEBUFFS.PAIN_SUPPRESSORS] = {
      [core.E.DEBUFF_ADD] = mod.OnPainSuppressorsAdd,
    },
    [DEBUFFS.RADIATION_BATH] = {
      [core.E.DEBUFF_ADD] = mod.OnRadiationBathAdd,
    },
  }
)
mod:RegisterUnitEvents({
    "unit.augmentor.inactive",
    "unit.augmentor.active",
    }, {
    [core.E.UNIT_DESTROYED] = mod.OnAugmentorDestroyed,
    [core.E.HEALTH_CHANGED] = mod.OnAugmentorHealthChanged,
    [BUFFS.COMPROMISED_CIRCUITRY] = {
      [core.E.BUFF_ADD] = mod.OnCompromisedCircuitryAdd,
    },
    [BUFFS.NANOSTRAIN_INFUSION] = {
      [core.E.BUFF_UPDATE] = mod.OnNanostrainInfusionUpdate,
    },
  }
)
mod:RegisterUnitEvents("unit.augmentor.inactive", {
    [core.E.UNIT_CREATED] = mod.OnOperantCreated,
    [core.E.UNIT_DESTROYED] = mod.OnAugmentorDestroyed,
  }
)
mod:RegisterUnitEvents("unit.augmentor.active", {
    [core.E.UNIT_CREATED] = mod.OnDistributorCreated,
    [core.E.UNIT_DESTROYED] = mod.OnAugmentorDestroyed,
  }
)
mod:RegisterUnitEvents("unit.incinerator", {
    [core.E.UNIT_CREATED] = mod.OnIncineratorCreated,
    [core.E.UNIT_DESTROYED] = mod.OnIncineratorDestroyed,
    ["cast.incinerator.disintegrate"] = {
      [core.E.CAST_START] = mod.OnDisintegrateStart,
    }
  }
)
