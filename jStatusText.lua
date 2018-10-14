local AddonName, Addon = ...

local _G = _G
local CreateFrame = _G.CreateFrame
local C_NamePlate = _G.C_NamePlate
local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit

local issecure = _G.issecure
local hooksecurefunc = _G.hooksecurefunc

local UnitHealth = _G.UnitHealth
local AbbreviateLargeNumbers = _G.AbbreviateLargeNumbers

function Addon:UpdateStatusText(frame)
  local unit = frame.displayedUnit
  if (not unit) then
    return
  end

  local nameplate = GetNamePlateForUnit(unit, issecure())
  if (not nameplate) then
    return
  end

  local frame = nameplate.UnitFrame
  if (not frame) then
    return
  end

  local statusText = frame.statusText
  if (not statusText:IsVisible()) then
    statusText:Show() -- force visibility
  end

  statusText:SetText(AbbreviateLargeNumbers(UnitHealth(unit)))
end

do
  local function Frame_UpdateStatusText(frame)
    Addon:UpdateStatusText(frame)
  end

  function Addon:HookActionEvents()
    hooksecurefunc("CompactUnitFrame_UpdateStatusText", Frame_UpdateStatusText)
  end
end

function Addon:PLAYER_LOGIN()
  self.frame:UnregisterEvent("PLAYER_LOGIN")

  self:HookActionEvents()
end

function Addon:NAME_PLATE_UNIT_ADDED(unit)
  local nameplate = GetNamePlateForUnit(unit, issecure())
  if (not nameplate) then
    return
  end

  local frame = nameplate.UnitFrame
  if (not frame) then
    return
  end

  local statusText = frame.statusText
  if (statusText) then
    statusText:SetPoint("LEFT", nameplate, "RIGHT")
    statusText:SetVertexColor(1, 1, 1)
  end
end

function Addon:OnEvent(event, ...)
  local action = self[event]

  if (action) then
    action(self, ...)
  end
end

do
  local function Frame_OnEvent(frame, ...)
    return Addon:OnEvent(...)
  end

  function Addon:Load()
    self.frame = CreateFrame("Frame", nil)
    self.frame:SetScript("OnEvent", Frame_OnEvent)

    self.frame:RegisterEvent("PLAYER_LOGIN")
    self.frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
  end
end

Addon:Load()
