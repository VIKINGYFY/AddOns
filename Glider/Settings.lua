local addonName = ... ---@type string "Glider"
local namespace = select(2,...) ---@class (partial) namespace

---@class (partial) Glider
local Glider = namespace.GliderUI
---@class GliderSettings
local GliderSettings = {}
local anchorFrame = namespace.anchorFrame
local MutableData = namespace.MutableData

---@class defaultTableData
---@field point FramePoint
---@field x integer
---@field y integer
---@field scale number
---@field style VigorColor|string
---@field textPosition string
---@field insideCircle boolean
---@field hideWhenGroundedAndFull boolean
---@field noDisplayText boolean
local defaultTableData = {
  point = 'CENTER',
  x = 0,
  y = 170,
  scale = 1,
  style = "Blue",
  textPosition = "Bottom",
  insideCircle = false,
  hideWhenGroundedAndFull = false,
  noDisplayText = false,
  secondWindMode = 0,
  whirlingSurgeState = 0,
  whirlingSurgeMode = 0,
  mutedSoundsBitfield = 0,
}

local Configuration = {
  SecretAuras = 0, --Enum.RestrictedActionType.SecretAuras,
  SecretCooldowns = 1, --Enum.RestrictedActionType.SecretCooldowns,
}

local LEM = LibStub('LibEditMode')
namespace.LEM = LEM

local SPEEDCIRCLE = {
  Inside = "InsideSwipe",
  Outside = "OutsideSwipe",
}

---@class VigorColor
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

local SECOND_WIND_OPTIONS_LIST = {
  { id = 0, state = "Disabled" },
  { id = 1, state = "Integrated" },
}

local WHIRLING_SURGE_OPTIONS_LIST = {
  { id = 0, state = "Arc" },
  { id = 1, state = "Pill" },
}

local WHIRLING_SURGE_OPTIONS_SHOWNSTATE_LIST = {
  { id = 0, state = "Disabled" },
  { id = 1, state = "Show on Cooldown" },
  { id = 2, state = "Hide on Cooldown" },
}

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
    multiple = true,
  })
end

table.sort(ART_OPTIONS, function(a, b) return a.text < b.text end)
local TEXTPOSITION_OPTIONS = {}
for _, name in ipairs({"Top", "Bottom", "Left", "Right"}) do
  table.insert(TEXTPOSITION_OPTIONS, {
    text = name,
    multiple = true,
  })
end

local sounds = {
  ["groundSkimming"] = { 1695571 },
  ["fastFlying"] =     { 1841696 },
  ["chargeGained"] =   { 1489541, 1900000, 1900001 },
  ["landingStomp"] = {
    1489050, 1489051, 1489052, 1489053,
  },
  ["skywardAscent"] = {
    840091, 840093, 840095, 840097, 840099, 840101, 840103, 564163
  },
  ["surgeForward"] = { 1378204 }, -- 1378204 is also Lift Off
  ["mountedWind"] = { 2066599 },
  ["flapping"] = { 564161, 564163, 564164, 564165, 564166, 564167, 564168, 564169, 564170, 564173},

  -- mounts
  ["renewedProtoDrake"] = {
    4634942, 4634944, 4634946,
  },
  ["windborneVelocidrake"] = {
    4663454, 4663456, 4663458, 4663460, 4663462, 4663464, 4663466,
  },
  ["highlandDrake"] = {
    4633280, 4633282, 4633284, 4633286, 4633288, 4633290,
    4641087, 4641089, 4641091, 4641093, 4641095, 4641097,
    4641099, 4633316, 4634009, 4634011, 4634013, 4634015,
    4634017, 4634019, 4634021,
  },
  ["windingSlitherdrake"] = {
    5163128, 5163130, 5163132, 5163134, 5163136, 5163138, 5163140,
  },
  ["algarianStormrider"] = {
    5357752, 5357769, 5357771, 5357773, 5357775, 5356559,
    5356561, 5356563, 5356565, 5356567, 5356569, 5356571,
    5356837, 5356839, 5356841, 5356843, 5356845, 5356847,
    5356849,
  },
  ["anurelosFlamesGuidance"] = {
    4683513, 4683515, 4683517, 4683519, 4683521, 4683523,
    4683525, 4683527, 4683529, 4683531, 4683533, 4683535,
    4683537, 4683539, 4683541, 4683543, 4683545, 4683547,
    4683549, 4683551, 5482244, 5482246, 5482248, 5482250,
    5482335, 5482337, 5482339, 5482341, 5482343, 5482345,
    5482347, 5482373, 5482375, 5482377, 5482379, 5482381,
    5482383, 5482385, 5482177, 5482179, 5482181,
  },
  ["grottoNetherwingDrake"] = {
    4633370, 4633372, 4633374, 4633376, 4633378, 4633380, 4633382,
  },
}

local SOUND_OPTIONS = {
  -- Order matters for Dropdown.
  { id = 1, name = "Charge Gained",                key = "chargeGained" },
  { id = 2, name = "Ground Skimming",              key = "groundSkimming" },
  { id = 3, name = "Surge Forward/Lift Off",       key = "surgeForward" },
  { id = 4, name = "Skyward Ascent",               key = "skywardAscent" },
  { id = 5, name = "Ground Landing Stomp",         key = "landingStomp" },

  { id = 20, name = "Algarian Stormrider", key = "algarianStormrider", mountID = 1792},
  { id = 21, name = "Anu'relos, Flame's Guidance", key = "anurelosFlamesGuidance", mountID = 1818 },
  { id = 22, name = "Grotto Netherwing Drake", key = "grottoNetherwingDrake", mountID = 1744 },
  { id = 23, name = "Highland Drake", key = "highlandDrake", mountID = 1563 },
  { id = 24, name = "Renewed Proto-Drake", key = "renewedProtoDrake", mountID = 1589 },
  { id = 25, name = "Windborne Velocidrake", key = "windborneVelocidrake", mountID = 1590 },
  { id = 26, name = "Winding Slitherdrake", key = "windingSlitherdrake", mountID = 1588 },
}

function GliderSettings:IsSoundChecked(id)
  local mask = bit.lshift(1, id - 1)
  return bit.band(GliderAddOnDB.Settings["GliderGlobalSettings"].mutedSoundsBitfield, mask) ~= 0
end

function GliderSettings:SetSoundChecked(id)
  local mask = bit.lshift(1, id - 1)
  local settings = GliderAddOnDB.Settings["GliderGlobalSettings"]
  if self:IsSoundChecked(id) then
    settings.mutedSoundsBitfield = bit.bxor(settings.mutedSoundsBitfield, mask)
  else
    settings.mutedSoundsBitfield = bit.bor(settings.mutedSoundsBitfield, mask)
  end
  GliderSettings:ApplyMutedSoundsState()
end

function GliderSettings:ResetSounds()
  GliderAddOnDB.Settings["GliderGlobalSettings"].mutedSoundsBitfield = 0
  self:ApplyMutedSoundsState()
  GliderSettings.SoundsDropdown:GenerateMenu()
end

function GliderSettings:ApplyMutedSoundsState()
  for i, option in ipairs(SOUND_OPTIONS) do
    local soundKey = option.key
    if soundKey then
      local soundIDs = sounds[soundKey]

      if self:IsSoundChecked(option.id) then
        for _, soundID in ipairs(soundIDs) do
          MuteSoundFile(soundID)
        end
      else
        for _, soundID in ipairs(soundIDs) do
          UnmuteSoundFile(soundID)
        end
      end
    end
  end
end

function Glider:SetRandomColor()
  local randomIndex = math.random(1, Configuration.numOptions)
  local colorName = ArtNames[randomIndex] ---@type string

  if colorName == MutableData.lastRandomColorName and Configuration.numOptions > 1 then
    randomIndex = (randomIndex % Configuration.numOptions) + 1
    colorName = ArtNames[randomIndex]
  end

  MutableData.lastRandomColorName = colorName
  Glider:SetAtlasForSwipe(Glider.VigorCharge, ART[colorName])
  Glider:SetAtlasForSwipe(Glider.secondWindCharge, ART[colorName])
  Glider.VigorCharge:SetSwipeColor(1, 1, 1, 1)
  Glider.secondWindCharge:SetSwipeColor(1, 1, 1, 0.4)
  if colorName == "Class" then
    local classColor = PlayerUtil.GetClassColor() ---@diagnostic disable-line
    local r, g, b = classColor:GetRGB()
    Glider.VigorCharge:SetSwipeColor(r, g , b) ---@diagnostic disable-line
    Glider.secondWindCharge:SetSwipeColor(r, g , b, 0.4)
  end
end


function Glider:SetAtlasForSwipe(frame, atlasName)
  local atlasInfo = Glider:GetAddOnAtlasInfo(atlasName, true)
  local lowTexCoords = { x = atlasInfo.leftTexCoord, y = atlasInfo.topTexCoord };
  local highTexCoords = { x = atlasInfo.rightTexCoord, y = atlasInfo.bottomTexCoord };
  frame:SetSwipeTexture([[Interface\AddOns\Glider\Media\Atlas.tga]]);
  frame:SetTexCoordRange(lowTexCoords, highTexCoords);
end

---@param layoutName string
---@return string
function GliderSettings:GetCurrentLayoutName(layoutName, forceGlobal)
  if GliderAddOnDB.globalSettingsEnabled or forceGlobal then
    return "GliderGlobalSettings"
  end
  return layoutName
end

function GliderSettings:SetupLayout(layoutName)
  GliderAddOnDB = GliderAddOnDB or {} ---@diagnostic disable-line
  GliderAddOnDB.Settings = GliderAddOnDB.Settings or {} ---@diagnostic disable-line
  layoutName = self:GetCurrentLayoutName(layoutName)
  if not GliderAddOnDB.Settings[layoutName] then
    GliderAddOnDB.Settings[layoutName] = CopyTable(defaultTableData)
  end
  GliderAddOnDB.Settings["GliderGlobalSettings"] = GliderAddOnDB.Settings["GliderGlobalSettings"] or CopyTable(defaultTableData)
  local layout = GliderAddOnDB.Settings[layoutName] ---@type defaultTableData
  anchorFrame:ClearAllPoints()
  anchorFrame:SetPoint(layout.point, Round(layout.x), Round(layout.y))
  Glider:SetScale(layout.scale)
  Glider.VigorCharge:SetEdgeTexture(layout.scale > 1 and [[Interface\AddOns\Glider\Media\VigorEdge2x.tga]] or
    [[Interface\AddOns\Glider\Media\VigorEdge.tga]]) ---@diagnostic disable-line

  Glider.VigorCharge:SetSwipeColor(1, 1, 1, 1)
  Glider.secondWindCharge:SetSwipeColor(1, 1, 1, 0.4)
  if not ART[layout.style] then
    Glider:SetAtlasForSwipe(Glider.VigorCharge, ART["Blue"])
    Glider:SetAtlasForSwipe(Glider.secondWindCharge, ART["Blue"])
  elseif ART[layout.style] == "Random" then
    MutableData.isRandomColor = true
    Glider:SetRandomColor()
  else
    Glider:SetAtlasForSwipe(Glider.VigorCharge, ART[layout.style])
    Glider:SetAtlasForSwipe(Glider.secondWindCharge, ART[layout.style])
    if layout.style == "Class" then
      local classColor = PlayerUtil.GetClassColor()
      local r, g, b = classColor:GetRGB()
      Glider.VigorCharge:SetSwipeColor(r, g, b)
      Glider.secondWindCharge:SetSwipeColor(r, g, b, 0.4)
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

  if layout.hideWhenGroundedAndFull then
    MutableData.hideWhenGroundedAndFull = layout.hideWhenGroundedAndFull
  end

  MutableData.noDisplayText = layout.noDisplayText
  GliderSettings:ApplyMutedSoundsState()
end

local function OnPositionChanged(frame, layoutName, point, x, y)
  layoutName = GliderSettings:GetCurrentLayoutName(layoutName)
  GliderAddOnDB.Settings[layoutName].point = point
  GliderAddOnDB.Settings[layoutName].x = x
  GliderAddOnDB.Settings[layoutName].y = y
end

function GliderSettings:GenerateMenu(owner)
  owner:GenerateMenu()
end

LEM:AddFrame(anchorFrame, OnPositionChanged, defaultTableData)
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
      GliderSettings:SetupLayout(layoutName)
      LEM.internal.dialog:Update(LEM.frameSelections[anchorFrame])
    end,
  },
  {
    name = 'Scale',
    kind = LEM.SettingType.Slider,
    default = 1,
    get = function(layoutName)
      layoutName = GliderSettings:GetCurrentLayoutName(layoutName)
      return GliderAddOnDB.Settings[layoutName].scale or 1
    end,
    set = function(layoutName, value)
      layoutName = GliderSettings:GetCurrentLayoutName(layoutName)
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
      layoutName = GliderSettings:GetCurrentLayoutName(layoutName)
      return GliderAddOnDB.Settings[layoutName].style
    end,
    set = function(layoutName, value)
      layoutName = GliderSettings:GetCurrentLayoutName(layoutName)
      GliderAddOnDB.Settings[layoutName].style = value
      Glider.VigorCharge:SetSwipeColor(1, 1, 1, 1)
      Glider.secondWindCharge:SetSwipeColor(1, 1, 1, 0.4)
      MutableData.isRandomColor = false

      if value == "Random" then
        MutableData.isRandomColor = true
        Glider:SetRandomColor()
      elseif value == "Class" then
        local classColor = PlayerUtil.GetClassColor() ---@diagnostic disable-line
        local r, g, b = classColor:GetRGB()
        Glider.VigorCharge:SetSwipeColor(r, g, b)
        Glider.secondWindCharge:SetSwipeColor(r, g, b, 0.4)
        Glider:SetAtlasForSwipe(Glider.VigorCharge, ART[value])
        Glider:SetAtlasForSwipe(Glider.secondWindCharge, ART[value])
      else
        Glider:SetAtlasForSwipe(Glider.VigorCharge, ART[value])
        Glider:SetAtlasForSwipe(Glider.secondWindCharge, ART[value])
      end
    end,
    values = ART_OPTIONS,
  },
  {
    name = "Text Position",
    kind = LEM.SettingType.Dropdown,
    default = "Bottom",
    get = function(layoutName)
      layoutName = GliderSettings:GetCurrentLayoutName(layoutName)
      return GliderAddOnDB.Settings[layoutName].textPosition
    end,
    set = function(layoutName, value)
      layoutName = GliderSettings:GetCurrentLayoutName(layoutName)
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
    name = "Mute Sounds",
    kind = LEM.SettingType.Dropdown,
    default = 0,
    set = function()
      GliderSettings:ResetSounds()
    end,
    generator = function(owner, rootDescription)
      GliderSettings.SoundsDropdown = owner
      owner.ShouldShowTooltip = nop
      local getFunc = function(value)
        return GliderSettings:IsSoundChecked(value)
      end
      local setFunc = function(value)
        GliderSettings:SetSoundChecked(value)
      end

      rootDescription:CreateTitle("Skyriding Sounds");
      for i, option in ipairs(SOUND_OPTIONS) do
        if option.key and not option.mountID then
          rootDescription:CreateCheckbox(option.name, getFunc, setFunc, option.id)
        end
      end
      local dividerAndTitleCreated = false
      local function CreateDividerAndTitle()
        if not dividerAndTitleCreated then
          rootDescription:CreateSpacer();
          rootDescription:CreateTitle("Mount Sounds");
          dividerAndTitleCreated = true
        end
      end
        for i, option in ipairs(SOUND_OPTIONS) do
          if option.key and option.mountID then
            local isCollected = select(11,C_MountJournal.GetMountInfoByID(option.mountID))
            if isCollected then
              CreateDividerAndTitle()
              rootDescription:CreateCheckbox(option.name, getFunc, setFunc, option.id)
            end
          end
        end
    end,
  },
  {
    name = "Second Wind",
    kind = LEM.SettingType.Dropdown,
    default = 0,
    set = function(layoutName, value)
      GliderAddOnDB.Settings["GliderGlobalSettings"].secondWindMode = 0
      CooldownFrame_SetDisplayAsPercentage(Glider.secondWindCharge, 0)
      GliderSettings.SecondWindDropdown:GenerateMenu()
    end,
    generator = function(owner, rootDescription)
      GliderSettings.SecondWindDropdown = owner
      owner.ShouldShowTooltip = nop
      local getFunc = function(value)
          return GliderAddOnDB.Settings["GliderGlobalSettings"].secondWindMode == value
      end
      local setFunc = function(value)
        GliderAddOnDB.Settings["GliderGlobalSettings"].secondWindMode = value
        if value ~= 1 then
          CooldownFrame_SetDisplayAsPercentage(Glider.secondWindCharge, 0)
        end
      end

      for _, option in ipairs(SECOND_WIND_OPTIONS_LIST) do
        if option.state then
          rootDescription:CreateRadio(option.state, getFunc, setFunc, option.id)
        end
      end
    end,
  },
  {
    name = "Whirling Surge",
    kind = LEM.SettingType.Dropdown,
    default = 0,
    set = function(layoutName, value)
      GliderAddOnDB.Settings["GliderGlobalSettings"].whirlingSurgeMode = 0
      GliderAddOnDB.Settings["GliderGlobalSettings"].whirlingSurgeState = 0
      GliderSettings.SecondWindDropdown:GenerateMenu()
    end,
    generator = function(owner, rootDescription)
      GliderSettings.WhirlingSurgeDropdown = owner
      owner.ShouldShowTooltip = nop
      local getFunc = function(value)
          return GliderAddOnDB.Settings["GliderGlobalSettings"].whirlingSurgeMode == value
      end
      local setFunc = function(value)
        GliderAddOnDB.Settings["GliderGlobalSettings"].whirlingSurgeMode = value
      end

      local getFuncState = function(value)
          return GliderAddOnDB.Settings["GliderGlobalSettings"].whirlingSurgeState == value
      end

      local setFuncState = function(value)
        GliderAddOnDB.Settings["GliderGlobalSettings"].whirlingSurgeState = value
      end

      for _, option in ipairs(WHIRLING_SURGE_OPTIONS_SHOWNSTATE_LIST) do
        if option.state then
          rootDescription:CreateRadio(option.state, getFuncState, setFuncState, option.id)
        end
      end
      rootDescription:CreateDivider()
      for _, option in ipairs(WHIRLING_SURGE_OPTIONS_LIST) do
        if option.state then
          rootDescription:CreateRadio(option.state, getFunc, setFunc, option.id)
        end
      end
    end,
  },
  {
    name = "Hide speed text",
    kind = LEM.SettingType.Checkbox,
    default = false,
    get = function(layoutName)
      layoutName = GliderSettings:GetCurrentLayoutName(layoutName)
      return GliderAddOnDB.Settings[layoutName].noDisplayText
    end,
    set = function(layoutName, value)
      layoutName = GliderSettings:GetCurrentLayoutName(layoutName)
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
      layoutName = GliderSettings:GetCurrentLayoutName(layoutName)
      return GliderAddOnDB.Settings[layoutName].insideCircle
    end,
    set = function(layoutName, value)
      layoutName = GliderSettings:GetCurrentLayoutName(layoutName)
      GliderAddOnDB.Settings[layoutName].insideCircle = value
      if value then
        Glider:SetAtlasForSwipe(Glider.SpeedDisplay.Speed, SPEEDCIRCLE["Inside"])
      else
        Glider:SetAtlasForSwipe(Glider.SpeedDisplay.Speed, SPEEDCIRCLE["Outside"])
      end
    end,
  },
  {
    name = "Hide when grounded and fully charged",
    kind = LEM.SettingType.Checkbox,
    default = false,
    get = function(layoutName)
      layoutName = GliderSettings:GetCurrentLayoutName(layoutName)
      return GliderAddOnDB.Settings[layoutName].hideWhenGroundedAndFull
    end,
    set = function(layoutName, value)
      layoutName = GliderSettings:GetCurrentLayoutName(layoutName)
      GliderAddOnDB.Settings[layoutName].hideWhenGroundedAndFull = value
      MutableData.hideWhenGroundedAndFull = value
    end,
  },
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

LEM:RegisterCallback('layout', function(layoutName)
  GliderSettings:SetupLayout(layoutName)
end)

LEM:RegisterCallback('rename', function(layoutName, newLayoutName)
  GliderAddOnDB.Settings[newLayoutName] = CopyTable(GliderAddOnDB.Settings[layoutName])
  GliderAddOnDB.Settings[layoutName] = nil
  GliderSettings:SetupLayout(newLayoutName)
end)

LEM:RegisterCallback('delete', function(layoutName)
  GliderAddOnDB.Settings[layoutName] = nil
end)