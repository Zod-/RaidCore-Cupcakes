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
local mod = core:NewEncounter("Muburu", 104, {548, 0}, {557, 548})
if not mod then return end

----------------------------------------------------------------------------------------------------
-- Registering combat.
----------------------------------------------------------------------------------------------------
mod:RegisterTrigMob(core.E.TRIGGER_ANY, { "unit.muburu", "unit.survivor" })
mod:RegisterEnglishLocale({
    -- Unit names.
    ["unit.muburu"] = "Bonedoctor Muburu",
    ["unit.abomination"] = "Stiched Abomination",
    ["unit.survivor"] = "Surgery Survivor",
    -- Cast names.
    -- Messages.
    ["msg.add.soon"] = "Add soon",
  })
----------------------------------------------------------------------------------------------------
-- Settings.
----------------------------------------------------------------------------------------------------
mod:RegisterUnitBarConfig("unit.muburu", {
    nPriority = 0,
    tMidphases = {
      {percent = 80},
      {percent = 65},
      {percent = 30},
    }
  }
)
----------------------------------------------------------------------------------------------------
-- Constants.
----------------------------------------------------------------------------------------------------
local SURVIVOR_POSITIONS = {
  {UPPER = -443, LOWER = -455},
  {UPPER = -435, LOWER = -443},
  {UPPER = -420, LOWER = -430},
  {UPPER = -405, LOWER = -420},
  {UPPER = -395, LOWER = -405},
}
----------------------------------------------------------------------------------------------------
-- Encounter description.
----------------------------------------------------------------------------------------------------
function mod:OnBossEnable()
  core:AddUnitSpacer("SURVIVOR_SPACER", nil, 1)
end

function mod:OnMuburuCreated(id, unit, name)
  mod:AddUnit(unit)
  core:WatchUnit(unit, core.E.TRACK_ALL)
end

function mod:OnMuburuHealthChanged(id, percent, name)
  if mod:IsMidphaseClose(name, percent) then
    mod:AddMsg("ADD_SOON", "msg.add.soon", 5, "Info", "xkcdWhite")
  end
end

function mod:OnSurvivorCreated(id, unit, name)
  core:WatchUnit(unit, core.E.TRACK_ALL)

  for i = 1, #SURVIVOR_POSITIONS do
    local pos = unit:GetPosition().x
    if pos >= SURVIVOR_POSITIONS[i].LOWER and pos <= SURVIVOR_POSITIONS[i].UPPER then
      mod:AddUnit(unit, nil, i+1)
      core:MarkUnit(unit, core.E.LOCATION_STATIC_NAME, i)
      break
    end
  end
end

function mod:OnSurvivorDestroyed(id, unit, name)
  core:DropMark(unit)
end

----------------------------------------------------------------------------------------------------
-- Bind event handlers.
----------------------------------------------------------------------------------------------------
mod:RegisterUnitEvents({"unit.muburu"},{
    [core.E.UNIT_CREATED] = mod.OnMuburuCreated,
    [core.E.HEALTH_CHANGED] = mod.OnMuburuHealthChanged,
  }
)

mod:RegisterUnitEvents({"unit.abomination"},{
    [core.E.UNIT_CREATED] = mod.OnAbominationCreated,
  }
)

mod:RegisterUnitEvents("unit.survivor",{
    [core.E.UNIT_CREATED] = mod.OnSurvivorCreated,
    [core.E.UNIT_DESTROYED] = mod.OnSurvivorDestroyed,
  }
)
