local addonName = ... ---@type string "Glider"
local namespace = select(2,...) ---@class namespace

local CONFIG_VALUES = {
  updateSpeedRate = 0.02,
  updateVigorRate = 0.01,
  vigorWidgetSetID = 283,
  percentageMulti = {
    [1] = 0.1666,
    [2] = 0.3333,
    [3] = 0.4998,
    [4] = 0.6664,
    [5] = 0.8330,
    [6] = 1.0
  },
  rotations = {
    [1] = 0,
    [2] = 5.23598776,
    [3] = 4.18879021,
    [4] = 3.14159265,
    [5] = 2.0943951,
    [6] = 1.04719755,
  },
}

local VOLATILE_VALUES = {
  lastFill = 100,
  lastNumFullFrames = 0,
  elapsedSpeed = 0,
  elapsedVigor = 0,
  adjustedPercentage = 0,
  isRefreshingVigor = false,
  isThrill = false,
  justShown = false,
  noDisplayText = false,
  numFullFrames = 0,
  prevPerc = 0,
  prevSpeed = 0,
}

local defaultPosition = {
  point = 'CENTER',
  x = 0,
  y = 170,
}

local SPEEDCIRCLE = {
  Inside = "InsideSwipe",
  Outside = "OutsideSwipe",
}

local ART = {
  ["Light Blue"] = "VigorLightBlue",
  Blue = "VigorBlue",
  Bronze = "VigorBronze",
  Cerise = "VigorCerise",
  Class = "VigorColorize",
  Green = "VigorGreen",
  Lime = "VigorLime",
  Orange = "VigorOrange",
  Purple = "VigorPurple",
  Silver = "VigorSilver",
  Sunrise = "VigorSunrise",
  Turquoise = "VigorTurquoise",
}

local ART_OPTIONS = {}
for name in next, ART do
  table.insert(ART_OPTIONS, {
    text = name,
    isRadio = true,
  })
end

local TEXTPOSITION = {
  Top = "Top",
  Bottom = "Bottom",
  Left = "Left",
  Right = "Right"
}

local TEXTPOSITION_OPTIONS = {}
for name in next, TEXTPOSITION do
  table.insert(TEXTPOSITION_OPTIONS, {
    text = name,
    isRadio = true,
  })
end

table.sort(ART_OPTIONS, function(a, b) return a.text < b.text end)
-- localize maybe for that tiny extra gain in the onupdate where it's used
local FrameDeltaLerp = FrameDeltaLerp
local GetGlidingInfo = C_PlayerInfo.GetGlidingInfo

---@class Glider : Frame
local Glider = CreateFrame("Frame", "GliderAddOn", UIParent, "GliderAddOnTemplate")

---@class fixedSizeFrame : Frame
local fixedSizeFrame = CreateFrame("Frame", nil, UIParent)
fixedSizeFrame:SetSize(110, 110)
fixedSizeFrame:SetPoint(defaultPosition.point, defaultPosition.x, defaultPosition.y)
Glider:SetPoint("CENTER", fixedSizeFrame)

function Glider:ShouldUseGlobalSettings()
  if GliderAddOnDB.globalSettingsEnabled then
    return "GliderGlobalSettings"
  end
end

local function onPositionChanged(frame, layoutName, point, x, y)
  layoutName = Glider:ShouldUseGlobalSettings() or layoutName
  GliderAddOnDB.Settings[layoutName].point = point
  GliderAddOnDB.Settings[layoutName].x = x
  GliderAddOnDB.Settings[layoutName].y = y
end

function Glider:GetAddOnAtlasInfo(atlasName, returnTable)
  local data = namespace.AtlasInfo[atlasName]
  if returnTable then
    return {
      w = data[1],
      h = data[2],
      leftTexCoord = data[3],
      rightTexCoord = data[4],
      topTexCoord = data[5],
      bottomTexCoord = data[6],
    }
  else
    return data[3], data[4], data[5], data[6]
  end
end

function Glider:SetupTextures()
  self.Background:SetTexCoord(self:GetAddOnAtlasInfo("Background"))
  self.Pulse:SetTexCoord(self:GetAddOnAtlasInfo("Pulse"))
  self.Flash:SetTexCoord(self:GetAddOnAtlasInfo("Flash"))
  self.TextDisplay.TextBackground:SetTexCoord(self:GetAddOnAtlasInfo("TextBackground"))
end

function Glider:SetAtlasForSwipe(frame, atlasName)
  local atlasInfo = self:GetAddOnAtlasInfo(atlasName, true)
  local lowTexCoords = { x = atlasInfo.leftTexCoord, y = atlasInfo.topTexCoord };
  local highTexCoords = { x = atlasInfo.rightTexCoord, y = atlasInfo.bottomTexCoord };
  frame:SetSwipeTexture([[Interface\AddOns\Glider\Media\Atlas.tga]]);
  frame:SetTexCoordRange(lowTexCoords, highTexCoords);
end

fixedSizeFrame.editModeName = "Glider"
local LEM = LibStub('LibEditMode')
LEM:AddFrame(fixedSizeFrame, onPositionChanged, defaultPosition)
LEM:AddFrameSettings(fixedSizeFrame, {
  {
    name = "Use Global Settings",
    kind = LEM.SettingType.Checkbox,
    default = false,
    get = function()
      return GliderAddOnDB.globalSettingsEnabled
    end,
    set = function(layoutName, value)
      GliderAddOnDB.globalSettingsEnabled = value
      Glider:SetupLayout(layoutName)
      LEM.internal.dialog:Update(LEM.frameSelections[fixedSizeFrame])
    end,
  },
  {
    name = 'Scale',
    kind = LEM.SettingType.Slider,
    default = 1,
    get = function(layoutName)
      layoutName = Glider:ShouldUseGlobalSettings() or layoutName
      return GliderAddOnDB.Settings[layoutName].scale or 1
    end,
    set = function(layoutName, value)
      layoutName = Glider:ShouldUseGlobalSettings() or layoutName
      GliderAddOnDB.Settings[layoutName].scale = value
      Glider:SetScale(value)
    end,
    minValue = 0.6,
    maxValue = 2,
    valueStep = 0.01,
    formatter = function(value)
      return FormatPercentage(value, true)
    end,
  },
  {
    name = "Artwork",
    kind = LEM.SettingType.Dropdown,
    default = "Blue",
    get = function(layoutName)
      layoutName = Glider:ShouldUseGlobalSettings() or layoutName
      return GliderAddOnDB.Settings[layoutName].style
    end,
    set = function(layoutName, value)
      layoutName = Glider:ShouldUseGlobalSettings() or layoutName
      GliderAddOnDB.Settings[layoutName].style = value
      Glider:SetAtlasForSwipe(Glider.VigorCharge, ART[value])
      Glider.VigorCharge:SetSwipeColor(1, 1, 1, 1)
      if value == "Class" then
        local classColor = PlayerUtil.GetClassColor() ---@diagnostic disable-line
        Glider.VigorCharge:SetSwipeColor(classColor:GetRGBA())
      end
    end,
    values = ART_OPTIONS,
  },
  {
    name = "Text Position",
    kind = LEM.SettingType.Dropdown,
    default = "Bottom",
    get = function(layoutName)
      layoutName = Glider:ShouldUseGlobalSettings() or layoutName
      return GliderAddOnDB.Settings[layoutName].textPosition
    end,
    set = function(layoutName, value)
      layoutName = Glider:ShouldUseGlobalSettings() or layoutName
      GliderAddOnDB.Settings[layoutName].textPosition = value
      Glider.TextDisplay:ClearAllPoints()
      if value == "Top" then
        Glider.TextDisplay:SetPoint("BOTTOM", Glider, "TOP", 0, -3)
      elseif value == "Right" then
        Glider.TextDisplay:SetPoint("LEFT", Glider, "RIGHT")
      elseif value == "Left" then
        Glider.TextDisplay:SetPoint("RIGHT", Glider, "LEFT")
      else
        Glider.TextDisplay:SetPoint("TOP", Glider, "BOTTOM", 0, 3)
      end
    end,
    values = TEXTPOSITION_OPTIONS,
  },
  {
    name = "Hide speed text",
    kind = LEM.SettingType.Checkbox,
    default = false,
    get = function(layoutName)
      layoutName = Glider:ShouldUseGlobalSettings() or layoutName
      return GliderAddOnDB.Settings[layoutName].noDisplayText
    end,
    set = function(layoutName, value)
      layoutName = Glider:ShouldUseGlobalSettings() or layoutName
      GliderAddOnDB.Settings[layoutName].noDisplayText = value
      VOLATILE_VALUES.noDisplayText = value
      if value then
        Glider.TextDisplay:Hide()
      end
    end,
  },
  {
    name = "Show speed circle inside",
    kind = LEM.SettingType.Checkbox,
    default = false,
    get = function(layoutName)
      layoutName = Glider:ShouldUseGlobalSettings() or layoutName
      return GliderAddOnDB.Settings[layoutName].insideCircle
    end,
    set = function(layoutName, value)
      layoutName = Glider:ShouldUseGlobalSettings() or layoutName
      GliderAddOnDB.Settings[layoutName].insideCircle = value
      if value then
        Glider:SetAtlasForSwipe(Glider.SpeedDisplay.Speed, SPEEDCIRCLE["Inside"])
      else
        Glider:SetAtlasForSwipe(Glider.SpeedDisplay.Speed, SPEEDCIRCLE["Outside"])
      end
    end,
  },
})

LEM:RegisterCallback('enter', function()
  CooldownFrame_SetDisplayAsPercentage(Glider.VigorCharge, 1);
  Glider:SetAlpha(1)
  Glider:Show()
end)

LEM:RegisterCallback('exit', function()
  if not Glider:IsSkyriding() then
    Glider:SetAlpha(0)
    Glider:Hide()
  end
end)

function Glider:SetupLayout(layoutName)
  GliderAddOnDB = GliderAddOnDB or {}
  GliderAddOnDB.Settings = GliderAddOnDB.Settings or {}
  layoutName = Glider:ShouldUseGlobalSettings() or layoutName
  if not GliderAddOnDB.Settings[layoutName] then
    GliderAddOnDB.Settings[layoutName] = CopyTable(defaultPosition)
  end

  local layout = GliderAddOnDB.Settings[layoutName]
  fixedSizeFrame:ClearAllPoints()
--[[   local function CalculateOffset(offset)
    return Round(768.0 / (select(2, GetPhysicalScreenSize()) * Glider:GetEffectiveScale()) * offset)
  end
  fixedSizeFrame:SetPoint(layout.point, CalculateOffset(layout.x), CalculateOffset(layout.y)) ]]
  fixedSizeFrame:SetPoint(layout.point, Round(layout.x), Round(layout.y))
  if layout.scale then
    Glider:SetScale(layout.scale)
    Glider.VigorCharge:SetEdgeTexture(layout.scale > 1 and [[Interface\AddOns\Glider\Media\VigorEdge2x.tga]] or
      [[Interface\AddOns\Glider\Media\VigorEdge.tga]])
  end

  Glider.VigorCharge:SetSwipeColor(1, 1, 1, 1)
  if not ART[layout.style] then
    Glider:SetAtlasForSwipe(Glider.VigorCharge, ART["Blue"])
  else
    Glider:SetAtlasForSwipe(Glider.VigorCharge, ART[layout.style])
    if layout.style == "Class" then
      local classColor = PlayerUtil.GetClassColor() ---@diagnostic disable-line
      Glider.VigorCharge:SetSwipeColor(classColor:GetRGB())
    end
  end
  layout.textPosition = layout.textPosition or "Bottom"
  Glider.TextDisplay:ClearAllPoints()
  if layout.textPosition == "Top" then
    Glider.TextDisplay:SetPoint("BOTTOM", Glider, "TOP", 0, -3)
  elseif layout.textPosition == "Right" then
    Glider.TextDisplay:SetPoint("LEFT", Glider, "RIGHT")
  elseif layout.textPosition == "Left" then
    Glider.TextDisplay:SetPoint("RIGHT", Glider, "LEFT")
  else
    Glider.TextDisplay:SetPoint("TOP", Glider, "BOTTOM", 0, 3)
  end

  if layout.insideCircle then
    Glider:SetAtlasForSwipe(Glider.SpeedDisplay.Speed, SPEEDCIRCLE["Inside"])
  else
    Glider:SetAtlasForSwipe(Glider.SpeedDisplay.Speed, SPEEDCIRCLE["Outside"])
  end
  if layout.loadDefaultVigor then
    layout.loadDefaultVigor = nil
  end
  VOLATILE_VALUES.noDisplayText = layout.noDisplayText
end

LEM:RegisterCallback('layout', function(layoutName)
  Glider:SetupLayout(layoutName)
end)

--EventRegistry:RegisterFrameEventAndCallback('EDIT_MODE_LAYOUTS_UPDATED', onEditModeChanged)

function Glider:OnEvent(e, ...)
  if e == "UPDATE_UI_WIDGET" then
    self:Update(...)
  elseif e == "UPDATE_ALL_UI_WIDGETS" then
    -- ugly fix: Flying from Khaz Algar to Ringing Deeps and similar world transitions can flash the vigor bar
    -- so just hide the entire container for a short duration, permamently hiding it messes with content that uses the same bar
    if self:IsShown() then
      UIWidgetPowerBarContainerFrame:Hide()
      C_Timer.After(5, function() UIWidgetPowerBarContainerFrame:Show() end)
    end
  end
end

function Glider:SetRandomColor()
  local timestamp = GetServerTime()
  local combinedValue = timestamp + 19204
  local result = (combinedValue % 6) + 1
  local count = 1
  for _, value in pairs(ART) do
    if count == result then
      Glider:SetAtlasForSwipe(Glider.VigorCharge, value)
      break
    end
    count = count + 1
  end
end

function Glider:RefreshVigor(elapsed)
  VOLATILE_VALUES.elapsedVigor = VOLATILE_VALUES.elapsedVigor + elapsed

  if not (VOLATILE_VALUES.elapsedVigor > CONFIG_VALUES.updateVigorRate) then return end
  VOLATILE_VALUES.elapsedVigor = 0
  local prevPerc = VOLATILE_VALUES.prevPerc or VOLATILE_VALUES.adjustedPercentage
  local newPerc = FrameDeltaLerp(prevPerc, VOLATILE_VALUES.adjustedPercentage, 0.2)
  --if Volatile.numFullFrames ~= 6 then
  CooldownFrame_SetDisplayAsPercentage(self.VigorCharge, newPerc);
  -- end
  VOLATILE_VALUES.prevPerc = newPerc
  if newPerc > 0.99 then
    CooldownFrame_SetDisplayAsPercentage(self.VigorCharge, 1);
    VOLATILE_VALUES.isRefreshingVigor = false
  end
end

local textDisplayWidthHalf = Glider.TextDisplay:GetWidth() / 2
function Glider:UpdateSpeedText(forwardSpeed)
  if not VOLATILE_VALUES.noDisplayText then
    local TextDisplay = self.TextDisplay
    if forwardSpeed <= 0 then
      if TextDisplay:IsShown() and not TextDisplay.textDisplayAnimHide:IsPlaying() then
        TextDisplay.textDisplayAnimHide:Play()
      end
    else
      if not TextDisplay:IsShown() and not TextDisplay.textDisplayAnimShow:IsPlaying() then
        TextDisplay.textDisplayAnimShow:Play()
      end
    end

    forwardSpeed = forwardSpeed > 0 and forwardSpeed or 0
    TextDisplay.Text:SetFormattedText(" %d ", forwardSpeed)
    local stringWidth = floor(TextDisplay.Text:GetUnboundedStringWidth())
    TextDisplay.Text:SetPoint("LEFT", textDisplayWidthHalf - (stringWidth / 2), 0)
  end
end

function Glider:RefreshSpeedDisplay(elapsed)
  VOLATILE_VALUES.elapsedSpeed = VOLATILE_VALUES.elapsedSpeed + elapsed
  if not (VOLATILE_VALUES.elapsedSpeed > CONFIG_VALUES.updateSpeedRate) then return end
  VOLATILE_VALUES.elapsedSpeed = 0

  local _, _, forwardSpeed = GetGlidingInfo()
  Glider:UpdateSpeedText(forwardSpeed * 14.286)

  local speed = forwardSpeed and VOLATILE_VALUES.getRidingAbroadPercent and forwardSpeed / VOLATILE_VALUES.getRidingAbroadPercent or
      forwardSpeed / 100 --((base/100 * 240) / 360)
  local prevSpeed = VOLATILE_VALUES.prevSpeed or speed
  local newSpeed = FrameDeltaLerp(prevSpeed, speed, 0.2)
  CooldownFrame_SetDisplayAsPercentage(self.Speed, newSpeed)
  if VOLATILE_VALUES.isThrill then
    self.Speed:SetSwipeColor(0.47, 0.97, 0.514, 1)   -- 0.47,0.97,0.514,1
  else
    self.Speed:SetSwipeColor(0.894, 0.227, 0.278, 1) -- 0.902,0.376,0.388,1
  end
  VOLATILE_VALUES.prevSpeed = newSpeed
  if newSpeed < 0.01 then
    VOLATILE_VALUES.prevSpeed = 0
    CooldownFrame_SetDisplayAsPercentage(self.Speed, 0)
    self:SetScript("OnUpdate", nil)
  end
end

function Glider:HideAnim()
  if not LEM:IsInEditMode() and self:IsShown() and not self.animHide:IsPlaying() then
    self.animShow:Stop()
    self.animHide:Play()
    self:SetScript("OnUpdate", nil)
    VOLATILE_VALUES.isRefreshingVigor = false
  end
end

function Glider:ShowAnim()
  if not (self:IsShown() or self.animShow:IsPlaying()) then
    VOLATILE_VALUES.justShown = true
    C_Timer.After(0.2, function() VOLATILE_VALUES.justShown = false end)
    self.animShow:Play()
  end
end

local instances = {
  -- Nokhud Offensive
  [2093] = true,
  -- Valdrakken
  [2112] = true,
  -- Amirdrassil (Raid)
  [2234] = true,
}

function Glider:GetRidingAbroadPercent()
  -- Dragonriding Races, but do not apply to Derby Racing
  if C_UnitAuras.GetPlayerAuraBySpellID(369968) and not HasOverrideActionBar() then
    return 100
  end

  local mapID = C_Map.GetBestMapForUnit('player')
  if not mapID then return 85 end
  local mapInfo = C_Map.GetMapInfo(mapID)
  if mapInfo and (instances[mapID] or mapInfo.parentMapID == 1978) then -- 1978 is Dragon Isles
    return 100
  else
    return 85
  end
end

function Glider:RemoveWidgets()
  for _, widget in pairs(UIWidgetPowerBarContainerFrame.widgetFrames) do
    if widget then
      if widget.widgetType == 24 and widget.widgetSetID == 283 then
      widget:Hide()
      widget = nil
      end
    end
  end
end

function Glider:IsSkyriding()
  -- 650 is Derby racing
  local powerBarID = UnitPowerBarID("player") -- Sadly also bugs out, but we use it in this case cause GetGlidingInfo is laggy, bad for responsive UI
  local hasSkyridingBar = (GetBonusBarIndex() == 11 and GetBonusBarOffset() == 5)
  local canGlide = select(2, GetGlidingInfo())
  return ( hasSkyridingBar or
          --powerBarID == 631 or
          --powerBarID == 650 or
          (canGlide and powerBarID ~= 0)
        ) and true or false;
end

function Glider:Update(widget)
  if not widget or (widget.widgetSetID ~= CONFIG_VALUES.vigorWidgetSetID) then
    return
  end

  self:RemoveWidgets()

  if not self:IsSkyriding() then
    self:HideAnim()
    return
  end

  if widget.widgetID ~= 4460 then
    return
  end

  local info = C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo(4460)
  if not info then
    self:HideAnim()
    return
  end

  if not (self:IsShown() or self.animShow:IsPlaying()) and info.numTotalFrames > 0 then
    VOLATILE_VALUES.lastNumFullFrames = info.numFullFrames
    self:ShowAnim()
  end

  -- Widget initially returns numFullFrames with old fillValue of previous numFullFrames
  local fillValue = (info.numFullFrames + info.fillValue == 1 + VOLATILE_VALUES.lastFill) and 0 or info.fillValue
  VOLATILE_VALUES.lastFill = info.numFullFrames + info.fillValue

  VOLATILE_VALUES.lastNumFullFrames = VOLATILE_VALUES.lastNumFullFrames or info.numFullFrames
  VOLATILE_VALUES.numFullFrames = info.numFullFrames

  local originalPercentage = info.numTotalFrames == 0 and 0 or
      (info.numFullFrames + fillValue / (info.fillMax + 0.0000001)) / info.numTotalFrames

  VOLATILE_VALUES.adjustedPercentage = (CONFIG_VALUES.percentageMulti[info.numTotalFrames] or 0) * originalPercentage
  self.VigorCharge:SetDrawEdge(VOLATILE_VALUES.adjustedPercentage ~= 1 and VOLATILE_VALUES.adjustedPercentage ~= 0)

  if not VOLATILE_VALUES.isRefreshingVigor then
    VOLATILE_VALUES.isRefreshingVigor = true
    self:SetScript("OnUpdate", self.RefreshVigor)
  end

  self.SpeedDisplay:SetScript("OnUpdate", self.RefreshSpeedDisplay)

  VOLATILE_VALUES.getRidingAbroadPercent = self:GetRidingAbroadPercent()
  VOLATILE_VALUES.isThrill = C_UnitAuras.GetPlayerAuraBySpellID(377234) and true or false
  if info.pulseFillingFrame then
    self.pulseAnim:Play()
  else
    -- Let the animation finish
    self.pulseAnim:SetLooping("NONE")
  end

  -- Widget API is returning garbage data when you first mount up after login for the first few updates
  -- so it would cause some frame to flash up
  if VOLATILE_VALUES.justShown then
    VOLATILE_VALUES.lastNumFullFrames = info.numFullFrames
    return
  end

  if info.numFullFrames > VOLATILE_VALUES.lastNumFullFrames then
    self.Flash:SetRotation(CONFIG_VALUES.rotations[info.numFullFrames])
    self.flashAnim:Restart()
  end

  VOLATILE_VALUES.lastNumFullFrames = info.numFullFrames
end

function Glider:OnLoad()
  self:SetupTextures()
  self:SetScript("OnEvent", function(_, ...) self:OnEvent(...) end)
  self:RegisterEvent("UPDATE_UI_WIDGET")
  self:RegisterEvent("UPDATE_ALL_UI_WIDGETS")
  self.SpeedDisplay.Speed:SetRotation(-117 * (math.pi/180))
  self.VigorCharge.noCooldownCount = true
  self.SpeedDisplay.Speed.noCooldownCount = true

  -- VSCode compatible version for color preview ^^ entirely pointless!
  -- Initialize Alpha to 0
  local function CreateRGBAFromHexString(hexColor)
    assert(#hexColor == 8, "Use #AARRGGBB Format")
    return tonumber(hexColor:sub(3, 4), 16) / 255,
        tonumber(hexColor:sub(5, 6), 16) / 255,
        tonumber(hexColor:sub(7, 8), 16) / 255,
        0 --tonumber(hexColor:sub(1, 2), 16) / 255
  end
  self.Pulse:SetVertexColor(CreateRGBAFromHexString("FFFFD900"))
end
Glider:OnLoad()

local function AddMessage(...) _G.DEFAULT_CHAT_FRAME:AddMessage(strjoin(" ", tostringall(...))) end;
function Glider:Help(msg)
  local fName = "|cff58C6FAGlider:|r ";
  local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)");
  if not cmd or cmd == "" or cmd == "help" then
    AddMessage("|cff58C6FAGlider: /glider   /vigor|r");
    AddMessage("Settings for Glider can be found in Game Menu > Edit Mode and clicking on the Glider window");
  end
end

SLASH_GLIDER1, SLASH_GLIDER2 = "/glider", "/vigor";
function SlashCmdList.GLIDER(...)
  Glider:Help(...);
end