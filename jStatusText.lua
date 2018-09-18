local AddonName, Addon = ...

-- locals
local CreateFrame = CreateFrame
local C_NamePlate = C_NamePlate

local issecure = issecure
local hooksecurefunc = hooksecurefunc

local UnitHealth = UnitHealth
local AbbreviateLargeNumbers = AbbreviateLargeNumbers

-- main
function Addon:Load()
  self.frame = CreateFrame("Frame", nil)

  -- set OnEvent handler
  self.frame:SetScript("OnEvent", function(handler, ...)
      self:OnEvent(...)
    end)

  self.frame:RegisterEvent("PLAYER_LOGIN")
  self.frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
end

-- frame events
function Addon:OnEvent(event, ...)
  local action = self[event]

  if (action) then
    action(self, event, ...)
  end
end

function Addon:PLAYER_LOGIN()
  self.frame:UnregisterEvent("PLAYER_LOGIN")

  self:HookActionEvents()
end

function Addon:NAME_PLATE_UNIT_ADDED(event, unit)
  local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
  if (not nameplate) then
    return
  end

  local frame = nameplate.UnitFrame
  if (not frame) then
    return
  end

  local statusText = frame.statusText
  if (statusText) then
    statusText:SetPoint("LEFT", nameplate, "RIGHT", 0, -5)
    statusText:SetVertexColor(1, 1, 1)
  end
end

function Addon:UpdateStatusText(frame)
  local unit = frame.displayedUnit
  if (not unit) then
    return
  end

  local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
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

-- hooks
do
  local function Frame_UpdateStatusText(frame)
    Addon:UpdateStatusText(frame)
  end

  function Addon:HookActionEvents()
    hooksecurefunc("CompactUnitFrame_UpdateStatusText", Frame_UpdateStatusText)
  end
end

-- call
Addon:Load()
