
local addonName = ... ---@type string "Glider"
local namespace = select(2,...) ---@class (partial) namespace

local gameVersion = select(4, GetBuildInfo())

local Configuration = {
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
    [1] = 0.0,
    [2] = 5.23598776,
    [3] = 4.18879021,
    [4] = 3.14159265,
    [5] = 2.0943951,
    [6] = 1.04719755,
  },
  SecretAuras = 0, --Enum.RestrictedActionType.SecretAuras,
  SecretCooldowns = 1, --Enum.RestrictedActionType.SecretCooldowns,
}

local AdvFlying = {
  Enabled = false,
  Active = false,
  ForwardSpeed = 0.0,
  Charging = false,
}

local MutableData = {
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
  lastRandomColorName = "",
  previousCharges = 6,
  hideWhenGroundedAndFull = false,
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
  Void = "VigorVoid",
  Blight = "VigorBlight",
  Random = "Random",
}

local function DebugPrint(...)
  if GetCVarBool("DebugLogArc") then
    print("Glider: ",...)
  end
end

Configuration.numOptions = 0
for _ in pairs(ART) do
  Configuration.numOptions = Configuration.numOptions + 1
end

local ArtNames = {}
for colorName in pairs(ART) do
    if colorName ~= "Random" then
        table.insert(ArtNames, colorName)
    end
end

Configuration.numOptions = #ArtNames

local ART_OPTIONS = {}
for name in next, ART do
  table.insert(ART_OPTIONS, {
    text = name,
    isRadio = true,
  })
end

local TEXTPOSITION_OPTIONS = {}
for _, name in ipairs({"Top", "Bottom", "Left", "Right"}) do
  table.insert(TEXTPOSITION_OPTIONS, {
    text = name,
    isRadio = true,
  })
end

table.sort(ART_OPTIONS, function(a, b) return a.text < b.text end)
-- localize maybe for that tiny extra gain in the onupdate where it's used
local FrameDeltaLerp = FrameDeltaLerp
local GetGlidingInfo = C_PlayerInfo.GetGlidingInfo

---@class Glider : GliderUI
local Glider = namespace.GliderUI

---@class fixedSizeFrame : Frame
local anchorFrame = CreateFrame("Frame", nil, UIParent)
anchorFrame:SetSize(110, 110)
anchorFrame:SetPoint(defaultPosition.point, defaultPosition.x, defaultPosition.y)
Glider:SetPoint("CENTER", anchorFrame)

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
  self.Background:SetTexCoord(self:GetAddOnAtlasInfo("Background"))  ---@diagnostic disable-line
  self.Pulse:SetTexCoord(self:GetAddOnAtlasInfo("Pulse"))  ---@diagnostic disable-line
  self.Flash:SetTexCoord(self:GetAddOnAtlasInfo("Flash"))  ---@diagnostic disable-line
  self.TextDisplay.TextBackground:SetTexCoord(self:GetAddOnAtlasInfo("TextBackground")) ---@diagnostic disable-line
end

function Glider:SetAtlasForSwipe(frame, atlasName)
  local atlasInfo = self:GetAddOnAtlasInfo(atlasName, true)
  local lowTexCoords = { x = atlasInfo.leftTexCoord, y = atlasInfo.topTexCoord };
  local highTexCoords = { x = atlasInfo.rightTexCoord, y = atlasInfo.bottomTexCoord };
  frame:SetSwipeTexture([[Interface\AddOns\Glider\Media\Atlas.tga]]);
  frame:SetTexCoordRange(lowTexCoords, highTexCoords);
end

anchorFrame.editModeName = "Glider"
local LEM = LibStub('LibEditMode')
LEM:AddFrame(anchorFrame, onPositionChanged, defaultPosition)
LEM:AddFrameSettings(anchorFrame, {
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
      LEM.internal.dialog:Update(LEM.frameSelections[anchorFrame])
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
      Glider.VigorCharge:SetSwipeColor(1, 1, 1, 1)
      MutableData.isRandomColor = false

      if value == "Random" then
        MutableData.isRandomColor = true
        Glider:SetRandomColor()
      elseif value == "Class" then
        local classColor = PlayerUtil.GetClassColor() ---@diagnostic disable-line
        Glider.VigorCharge:SetSwipeColor(classColor:GetRGBA())
        Glider:SetAtlasForSwipe(Glider.VigorCharge, ART[value])
      else
        Glider:SetAtlasForSwipe(Glider.VigorCharge, ART[value])
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
      MutableData.noDisplayText = value
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
  -- {
  --   name = "Hide when grounded and fully charged",
  --   kind = LEM.SettingType.Checkbox,
  --   default = false,
  --   get = function(layoutName)
  --     layoutName = Glider:ShouldUseGlobalSettings() or layoutName
  --     return GliderAddOnDB.Settings[layoutName].hideWhenGroundedAndFull
  --   end,
  --   set = function(layoutName, value)
  --     layoutName = Glider:ShouldUseGlobalSettings() or layoutName
  --     GliderAddOnDB.Settings[layoutName].hideWhenGroundedAndFull = value
  --     MutableData.hideWhenGroundedAndFull = value
  --   end,
  -- },
  {
    name = "Disable Skyriding game effects",
    kind = LEM.SettingType.Checkbox,
    default = false,
    get = function(layoutName)
      return not C_CVar.GetCVarBool("AdvFlyingDynamicFOVEnabled") and not C_CVar.GetCVarBool("DriveDynamicFOVEnabled")
    end,
    set = function(layoutName, value)
      SetCVar("AdvFlyingDynamicFOVEnabled", not value)
      SetCVar("DriveDynamicFOVEnabled", not value)

      local settingEffects = Settings.GetSetting("DisableAdvancedFlyingFullScreenEffects")
      if settingEffects then
        settingEffects:ApplyValue(not value)
      end

      local settingVFX = Settings.GetSetting("DisableAdvancedFlyingVelocityVFX")
      if settingVFX then
        settingVFX:ApplyValue(not value)
      end
    end,
  },
})

LEM:RegisterCallback('enter', function()
  CooldownFrame_SetDisplayAsPercentage(Glider.VigorCharge, 1);
  Glider.VigorCharge:SetAlpha(1)
  Glider:SetAlpha(1)
  Glider:Show()
end)

LEM:RegisterCallback('exit', function()
  if not Glider:IsSkyriding() or (GetRestrictedActionStatus and GetRestrictedActionStatus(Configuration.SecretCooldowns)) then
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
  anchorFrame:ClearAllPoints()
--[[   local function CalculateOffset(offset)
    return Round(768.0 / (select(2, GetPhysicalScreenSize()) * Glider:GetEffectiveScale()) * offset)
  end
  fixedSizeFrame:SetPoint(layout.point, CalculateOffset(layout.x), CalculateOffset(layout.y)) ]]
  anchorFrame:SetPoint(layout.point, Round(layout.x), Round(layout.y))
  layout.scale = layout.scale or 1
  Glider:SetScale(layout.scale)
  Glider.VigorCharge:SetEdgeTexture(layout.scale > 1 and [[Interface\AddOns\Glider\Media\VigorEdge2x.tga]] or
      [[Interface\AddOns\Glider\Media\VigorEdge.tga]]) ---@diagnostic disable-line

  Glider.VigorCharge:SetSwipeColor(1, 1, 1, 1)
  if not ART[layout.style] then
    Glider:SetAtlasForSwipe(Glider.VigorCharge, ART["Blue"])
  elseif ART[layout.style] == "Random" then
    MutableData.isRandomColor = true
    Glider:SetRandomColor()
  else
    Glider:SetAtlasForSwipe(Glider.VigorCharge, ART[layout.style])
    if layout.style == "Class" then
      local classColor = PlayerUtil.GetClassColor() ---@diagnostic disable-line
      Glider.VigorCharge:SetSwipeColor(classColor:GetRGB()) ---@diagnostic disable-line
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

  if layout.hideWhenGroundedAndFull then
    MutableData.hideWhenGroundedAndFull = layout.hideWhenGroundedAndFull or false
  end
  MutableData.noDisplayText = layout.noDisplayText
end

LEM:RegisterCallback('layout', function(layoutName)
  Glider:SetupLayout(layoutName)
end)

function Glider:SetRandomColor()
    local randomIndex = math.random(1, Configuration.numOptions)
    local colorName = ArtNames[randomIndex]

    if colorName == MutableData.lastRandomColorName and Configuration.numOptions > 1 then
        randomIndex = (randomIndex % Configuration.numOptions) + 1
        colorName = ArtNames[randomIndex]
    end

    MutableData.lastRandomColorName = colorName
    Glider:SetAtlasForSwipe(Glider.VigorCharge, ART[colorName])
    Glider.VigorCharge:SetSwipeColor(1, 1, 1, 1)

    if colorName == "Class" then
        local classColor = PlayerUtil.GetClassColor() ---@diagnostic disable-line
        Glider.VigorCharge:SetSwipeColor(classColor:GetRGBA()) ---@diagnostic disable-line
    end
end

function Glider:RefreshVigor(elapsed)
  MutableData.elapsedVigor = MutableData.elapsedVigor + elapsed

  if (MutableData.elapsedVigor < Configuration.updateVigorRate) then return end
  MutableData.elapsedVigor = 0
  local prevPerc = MutableData.prevPerc or MutableData.adjustedPercentage
  local newPerc = FrameDeltaLerp(prevPerc, MutableData.adjustedPercentage, 0.2)
  --if Volatile.numFullFrames ~= 6 then
  self:SetCooldownPercentage(self.VigorCharge, newPerc);
  self.VigorCharge:SetDrawEdge(newPerc ~= 1 and newPerc ~= 0)
  -- end
  MutableData.prevPerc = newPerc
  if newPerc > 0.99 then
    self.VigorCharge:SetDrawEdge(false)
    self:SetCooldownPercentage(self.VigorCharge, 1);
    self:SetScript("OnUpdate", nil)
    MutableData.isRefreshingVigor = false
  end
end

local textDisplayWidthHalf = Glider.TextDisplay:GetWidth() / 2
function Glider:UpdateSpeedText(forwardSpeed)
  if not MutableData.noDisplayText then
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
  MutableData.elapsedSpeed = MutableData.elapsedSpeed + elapsed
  if not (MutableData.elapsedSpeed > Configuration.updateSpeedRate) then return end
  MutableData.elapsedSpeed = 0
  Glider:RefreshGlidingInfo()
  Glider:UpdateSpeedText(AdvFlying.ForwardSpeed * 14.286)

  local speed = AdvFlying.ForwardSpeed and MutableData.getRidingAbroadPercent and AdvFlying.ForwardSpeed / MutableData.getRidingAbroadPercent or
      AdvFlying.ForwardSpeed / 100 --((base/100 * 240) / 360)
  local prevSpeed = MutableData.prevSpeed or speed
  local newSpeed = FrameDeltaLerp(prevSpeed, speed, 0.2)
  CooldownFrame_SetDisplayAsPercentage(self.SpeedDisplay.Speed, newSpeed)
  if MutableData.isThrill then
    self.SpeedDisplay.Speed:SetSwipeColor(0.47, 0.97, 0.514, 1)   -- 0.47,0.97,0.514,1
  else
    self.SpeedDisplay.Speed:SetSwipeColor(0.894, 0.227, 0.278, 1) -- 0.902,0.376,0.388,1
  end
  MutableData.prevSpeed = newSpeed
  if newSpeed < 0.01 then
    MutableData.prevSpeed = 0
    CooldownFrame_SetDisplayAsPercentage(self.SpeedDisplay.Speed, 0)
    self.SpeedDisplay:SetScript("OnUpdate", nil)
  end
end

function Glider:HideAnim()
  if not LEM:IsInEditMode() and self:IsShown() and not self.animHide:IsPlaying() then
    self.animShow:Stop()
    self.animHide:Play()
    self:SetScript("OnUpdate", nil)
    MutableData.isRefreshingVigor = false
    MutableData.isThrill = false
  end
end

function Glider:ShowAnim()
  if not (self:IsShown() or self.animShow:IsPlaying()) then
    MutableData.justShown = true
    if MutableData.isRandomColor then
      self:SetRandomColor()
    end
    C_Timer.After(0.2, function() MutableData.justShown = false end)
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
    if not (GetRestrictedActionStatus and GetRestrictedActionStatus(Configuration.SecretAuras)) then
      if C_UnitAuras.GetPlayerAuraBySpellID(369968) and not HasOverrideActionBar() then
        return 100
      end
    end

    local mapID = C_Map.GetBestMapForUnit('player')
    if not mapID then return 85 end

    if instances[mapID] then
      return 100
    end

    local mapInfo = C_Map.GetMapInfo(mapID)
    if mapInfo and mapInfo.parentMapID == 1978 then
      return 100
    end

    return 85
end

function Glider:ProcessWidgets()
  local isShown = 0
  for _, widget in pairs(UIWidgetPowerBarContainerFrame.widgetFrames) do
    if widget then
      if widget.widgetType == 24 and widget.widgetSetID == 283 then
      local info = C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo(widget.widgetID)
      if info then
        -- here we just assume if we still run into bugged widgets, numTotalFrames is 0 but i can't tell if this bug is still around
        isShown = bit.bor(isShown, (info.shownState == 1 and info.numTotalFrames > 0) and 1 or 0)
        MutableData.widgetID = (info.shownState == 1 and info.numTotalFrames > 0) and widget.widgetID or 4460
      end
      widget:Hide()
      end
    end
  end
  MutableData.isWidgetShown = isShown
end

function Glider:SetCooldownPercentage(frame, perc)
  if LEM:IsInEditMode() then return end
  CooldownFrame_SetDisplayAsPercentage(frame, perc);
end

function Glider:IsDerbyRacing()
  return UnitPowerBarID("player") == 650
end

function Glider:IsSkyriding()
  -- Works for everything that uses the bar, but not 'special' integrations that do not use this bar like Derby racing.
  local hasSkyridingBar = (GetBonusBarIndex() == 11 and GetBonusBarOffset() == 5)
  if hasSkyridingBar then
    return true
  else
    -- 650 is Derby racing
    local powerBarID = UnitPowerBarID("player")
    return hasSkyridingBar or (AdvFlying.Enabled and powerBarID ~= 0);
  end
end

function Glider:SetFlashAndPlay(chargeValue)
  self.Flash:SetRotation(Configuration.rotations[chargeValue])
  self.flashAnim:Restart()
end

function Glider:PlayPulseAnimation(shouldPulse)
  if shouldPulse and not self.pulseAnim:IsPlaying() then
    self.pulseAnim:Play()
  else
    -- Let the animation finish
    self.pulseAnim:SetLooping("NONE")
  end
end

local spellChargeInfoDefaults = {
  currentCharges = 0,
  maxCharges = 0,
  cooldownStartTime = 0,
  cooldownDuration = 0,
  chargeModRate = 0,
}

local spellChargeInfo = {}

function Glider:UpdateUI()
  if self:IsDerbyRacing() then return end

  local isNotSkyriding = not self:IsSkyriding()
  local isRestricted = GetRestrictedActionStatus and GetRestrictedActionStatus(Configuration.SecretCooldowns)
  if isNotSkyriding or isRestricted then
    -- Always initialize back to 6 on hide, so there is no flashing on showing UI later
    MutableData.previousCharges = 6
    self:HideAnim()
    return
  end

  spellChargeInfo = C_Spell.GetSpellCharges(372608) or spellChargeInfoDefaults
  local charges = spellChargeInfo.currentCharges
  local maxCharges = spellChargeInfo.maxCharges
  local chargeStart = spellChargeInfo.cooldownStartTime
  local chargeDuration = spellChargeInfo.cooldownDuration
  local newStartTime = GetTime()
  local newDuration = 0.0
  local isCharging = false
  if maxCharges > 0 and chargeDuration > 0 then
    local shouldPulse = chargeDuration < 10
    self:PlayPulseAnimation(shouldPulse)

    if MutableData.previousCharges < charges then
      -- Add option for this
      PlaySound(201528, "SFX")
      self:SetFlashAndPlay(charges)
    end

    local now = GetTime()
    local cooldownElapsed = now - chargeStart
    local cooldownProgress = cooldownElapsed / chargeDuration
    newDuration = chargeDuration * maxCharges
    local totalElapsedChargeTime = (charges + cooldownProgress) * chargeDuration
    newStartTime = now - totalElapsedChargeTime
    isCharging = charges < maxCharges
    MutableData.previousCharges = charges
  else
    isCharging = false
  end
  MutableData.getRidingAbroadPercent = self:GetRidingAbroadPercent()

  if isCharging then
    if self.VigorCharge:IsPaused() then
      self.VigorCharge:Resume()
    end
    self.VigorCharge:SetCooldown(newStartTime, newDuration, spellChargeInfo.chargeModRate);
    self.VigorCharge:SetDrawEdge(true);
  else
    CooldownFrame_SetDisplayAsPercentage(self.VigorCharge, 1);
    self.VigorCharge:SetDrawEdge(false);
  end
  self.SpeedDisplay:SetScript("OnUpdate", function(_, elapsed) self:RefreshSpeedDisplay(elapsed) end)
  local shouldHideFullAndGrounded = (not AdvFlying.Active) and (not isCharging) and MutableData.hideWhenGroundedAndFull
  if shouldHideFullAndGrounded then
    self:HideAnim()
    return
  end
  self:ShowAnim()
end

function Glider:Update(widget)
  if gameVersion >= 110207 then
    if not self:IsDerbyRacing() then return end
  end

  if not widget or (widget.widgetSetID ~= Configuration.vigorWidgetSetID) then
    return
  end

  self:ProcessWidgets()

  if widget.widgetID ~= MutableData.widgetID then
    return
  end

  if not self:IsSkyriding() or not MutableData.isWidgetShown then
    MutableData.lastNumFullFrames = 6
    self:HideAnim()
    return
  end

  local info = C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo(MutableData.widgetID)
  if not info then
    self:HideAnim()
    return
  end

  if not (self:IsShown() or self.animShow:IsPlaying()) and info.numTotalFrames > 0 then
    --MutableData.lastNumFullFrames = info.numFullFrames
    self:ShowAnim()
  end

  -- Widget initially returns numFullFrames with old fillValue of previous numFullFrames
  local fillValue = (info.numFullFrames + info.fillValue == 1 + MutableData.lastFill) and 0 or info.fillValue
  MutableData.lastFill = info.numFullFrames + info.fillValue

  MutableData.lastNumFullFrames = MutableData.lastNumFullFrames or info.numFullFrames
  MutableData.numFullFrames = info.numFullFrames

  local originalPercentage = info.numTotalFrames == 0 and 0 or
      (info.numFullFrames + fillValue / (info.fillMax + 0.0000001)) / info.numTotalFrames

  MutableData.adjustedPercentage = (Configuration.percentageMulti[info.numTotalFrames] or 0) * originalPercentage
  self.VigorCharge:SetDrawEdge(MutableData.adjustedPercentage ~= 1 and MutableData.adjustedPercentage ~= 0)

  if not MutableData.isRefreshingVigor then
    MutableData.isRefreshingVigor = true
    self:SetScript("OnUpdate", self.RefreshVigor)
  end

  self.SpeedDisplay:SetScript("OnUpdate", function(_, elapsed) self:RefreshSpeedDisplay(elapsed) end)

  MutableData.getRidingAbroadPercent = self:GetRidingAbroadPercent()
  self:PlayPulseAnimation(info.pulseFillingFrame)
  -- Widget API is returning garbage data when you first mount up after login for the first few updates
  -- so it would cause some frame to flash up
  if MutableData.justShown then
    MutableData.lastNumFullFrames = info.numFullFrames
    return
  end

  if info.numFullFrames > MutableData.lastNumFullFrames then
    self:SetFlashAndPlay(info.numFullFrames)
  end

  MutableData.lastNumFullFrames = info.numFullFrames
end

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
  elseif e == "UNIT_AURA" and self:IsShown() then
    if not (GetRestrictedActionStatus and GetRestrictedActionStatus(Configuration.SecretAuras)) then
      MutableData.isThrill = not not C_UnitAuras.GetPlayerAuraBySpellID(377234)
    end
  else
      self:RefreshGlidingInfo()
      self:UpdateUI()
  end
end

function Glider:RefreshGlidingInfo()
  local isGliding, canGlide, forwardSpeed = GetGlidingInfo()
  AdvFlying.Enabled = canGlide
  AdvFlying.Active = isGliding
  AdvFlying.ForwardSpeed = forwardSpeed
end

function Glider:OnLoad()
  self:SetupTextures()
  self:SetScript("OnEvent", function(_, ...) self:OnEvent(...) end)
  if gameVersion >= 110207 then
    self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    self:RegisterEvent("ACTIONBAR_UPDATE_STATE")
    self:RegisterEvent("PLAYER_IN_COMBAT_CHANGED")
    self:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
    self:RegisterEvent("PLAYER_CAN_GLIDE_CHANGED")
    self:RegisterEvent("PLAYER_IS_GLIDING_CHANGED")
    self:RegisterEvent("UPDATE_UI_WIDGET")
    self:RegisterEvent("UPDATE_ALL_UI_WIDGETS")
    self:RegisterEvent("UNIT_AURA")
  else
    self:RegisterEvent("UPDATE_UI_WIDGET")
    self:RegisterEvent("UPDATE_ALL_UI_WIDGETS")
    self:RegisterEvent("UNIT_AURA")
  end
  self.SpeedDisplay.Speed:SetRotation(-117 * (math.pi/180))
  self.VigorCharge.noCooldownCount = true
  self.SpeedDisplay.Speed.noCooldownCount = true
  self.Pulse:SetVertexColor(1, 0.85, 0, 0)
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