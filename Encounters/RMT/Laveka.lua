----------------------------------------------------------------------------------------------------
-- Client Lua Script for RaidCore Addon on WildStar Game.
--
-- Copyright (C) 2015 RaidCore
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Description:
-- TODO
----------------------------------------------------------------------------------------------------
local core = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("RaidCore")
local mod = core:NewEncounter("Laveka", 104, 548, 559)
if not mod then return end

----------------------------------------------------------------------------------------------------
-- Registering combat.
----------------------------------------------------------------------------------------------------
mod:RegisterTrigMob(core.E.TRIGGER_ALL, { "unit.laveka" })
mod:RegisterEnglishLocale({
    -- Unit names.
    ["unit.laveka"] = "Laveka the Dark-Hearted",
    ["unit.phantom"] = "Phantom",
    ["unit.essence"] = "Essence Void",
    ["unit.tortued_apparition"] = "Tortured Apparition",
    ["unit.orb"] = "Soul Eater",
    ["unit.boneclaw"] = "Risen Boneclaw",
    ["unit.titan"] = "Risen Titan",
    -- Cast names.
    -- Messages.
    ["msg.laveka.soulfire.you"] = "SOULFIRE ON YOU",
    ["msg.laveka.spirit_of_soulfire"] = "Spirit of Soulfire timer",
    ["msg.laveka.expulsion"] = "STACK!",
  }
)
----------------------------------------------------------------------------------------------------
-- Constants.
----------------------------------------------------------------------------------------------------
local DEBUFFS = {
  EXPULSION_OF_SOULS = 87901, -- Runic circle debuff
  NECROTIC_EXPLOSION = 75610,
  SOUL_EATER = 87069,
  REALM_OF_THE_DEAD = 75528, -- When in dead world
  ECHOES_OF_THE_AFTERLIFE = 75525, -- stacking debuff
  SOULFIRE = 75574, -- Debuff to be cleansed
}

local BUFFS = {
  SPIRIT_OF_SOULFIRE = 75576,
}

local TIMERS = {
  SPIRIT_OF_SOULFIRE = 6,
  ECHOES_OF_THE_AFTERLIFE = 10,
}
----------------------------------------------------------------------------------------------------
-- Locals.
----------------------------------------------------------------------------------------------------
local player
----------------------------------------------------------------------------------------------------
-- Settings.
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Encounter description.
----------------------------------------------------------------------------------------------------
function mod:OnBossEnable()
  player = {}
  player.unit = GameLib.GetPlayerUnit()
  player.id = player.unit:GetId()
end

function mod:OnAnyUnitDestroyed(id, unit, name)
  mod:RemoveSoulfireLine(name)
end

function mod:OnWatchedUnitCreated(id, unit, name)
  core:AddUnit(unit)
  core:WatchUnit(unit, core.E.TRACK_ALL)
end

function mod:OnSoulfireAdd(id, spellId, stack, timeRemaining, targetName)
  if id ~= player.id then
    mod:AddSoulfireLine(id, targetName)
  else
    mod:AddMsg("SOULFIRE_MSG_YOU", "msg.laveka.soulfire.you", 5, "Burn", "xkcdGreen")
  end
end

function mod:OnSoulfireRemove(id, spellId, targetName)
  core:RemoveLineBetweenUnits("SOULFIRE_LINE_"..targetName)
end

function mod:AddSoulfireLine(id, name)
  core:AddLineBetweenUnits("SOULFIRE_LINE_"..name, player.unit, id, 4, "xkcdBarneyPurple")
end

function mod:RemoveSoulfireLine(name)
  core:RemoveLineBetweenUnits("SOULFIRE_LINE_"..name)
end

function mod:OnSpiritOfSoulfireAdd(id, spellId, stack, timeRemaining, targetName)
  mod:AddTimerBar("SPIRIT_OF_SOULFIRE_TIMER", "msg.laveka.spirit_of_soulfire", TIMERS.SPIRIT_OF_SOULFIRE)
end

function mod:OnSpiritOfSoulfireRemove(id, spellId, targetName)
  mod:RemoveTimerBar("SPIRIT_OF_SOULFIRE_TIMER")
end

function mod:OnExpulsionAdd(id, spellId, stack, timeRemaining, targetName)
  mod:AddMsg("EXPULSION", "msg.laveka.expulsion", 5, "Beware", "xkcdBabyPink")
end

function mod:OnEchoesAdd(id, spellId, stack, timeRemaining, targetName)
  mod:StartEchoesTimer(id)
end

function mod:OnEchoesUpdate(id, spellId, stack, timeRemaining)
  mod:StartEchoesTimer(id)
end

function mod:StartEchoesTimer(id)
  if id == player.id then
    mod:AddTimerBar("ECHOES_OF_THE_AFTERLIFE_TIMER", "msg.laveka.echoes_of_the_afterlife.timer", TIMERS.ECHOES_OF_THE_AFTERLIFE)
  end
end

function mod:OnEchoesRemove(id, spellId, targetName)
  if id == player.id then
    mod:RemoveTimerBar("ECHOES_OF_THE_AFTERLIFE_TIMER")
  end
end

function mod:OnRealmOfTheDeadAdd(id, spellId, stack, timeRemaining, targetName)
  mod:StartEchoesTimer(id)
end

----------------------------------------------------------------------------------------------------
-- Bind event handlers.
----------------------------------------------------------------------------------------------------
mod:RegisterUnitEvents({
    "unit.laveka",
    "unit.titan",
    "unit.orb",
    },{
    [core.E.UNIT_CREATED] = mod.OnWatchedUnitCreated,
  }
)

mod:RegisterUnitEvents("unit.laveka",{
    [BUFFS.SPIRIT_OF_SOULFIRE] = {
      [core.E.BUFF_ADD] = mod.OnSpiritOfSoulfireAdd,
      [core.E.BUFF_REMOVE] = mod.OnSpiritOfSoulfireRemove,
    }
  }
)

mod:RegisterUnitEvents(core.E.ALL_UNITS,{
    [core.E.UNIT_DESTROYED] = mod.OnAnyUnitDestroyed,
    [DEBUFFS.SOULFIRE] = {
      [core.E.DEBUFF_ADD] = mod.OnSoulfireAdd,
      [core.E.DEBUFF_REMOVE] = mod.OnSoulfireRemove,
    },
    [DEBUFFS.EXPULSION_OF_SOULS] = {
      [core.E.DEBUFF_ADD] = mod.OnExpulsionAdd,
    },
    [DEBUFFS.ECHOES_OF_THE_AFTERLIFE] = {
      [core.E.DEBUFF_ADD] = mod.OnEchoesAdd,
      [core.E.DEBUFF_UPDATE] = mod.OnEchoesUpdate,
      [core.E.DEBUFF_REMOVE] = mod.OnEchoesRemove,
    },
    [DEBUFFS.REALM_OF_THE_DEAD] = {
      [core.E.DEBUFF_ADD] = mod.OnRealmOfTheDeadAdd,
    },
  }
)
