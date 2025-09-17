local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.ChangingMapToPlayerZone()
  if ns._MapChangeInit then return end
  ns._MapChangeInit = true

  local lastSet
  local function SetToPlayerMap()
    if not (ns.Addon and ns.Addon.db and ns.Addon.db.profile.MapChanging) then return end
    if not (WorldMapFrame and WorldMapFrame:IsShown()) then return end

    local target = C_Map.GetBestMapForUnit("player")
    if not target then return end

    if target ~= lastSet and WorldMapFrame:GetMapID() ~= target then
      ns.SafeSetMapID(target)
      lastSet = target
      if ns.Addon.db.profile.DeveloperMode then
        print("Switched map to:", target, C_Map.GetMapInfo(target) and C_Map.GetMapInfo(target).name)
      end
    end
  end

  local Worldmap = CreateFrame("Frame")
  Worldmap:RegisterEvent("ZONE_CHANGED_NEW_AREA")
  Worldmap:RegisterEvent("ZONE_CHANGED")
  Worldmap:RegisterEvent("ZONE_CHANGED_INDOORS")
  Worldmap:RegisterEvent("NEW_WMO_CHUNK") -- micro maps
  Worldmap:SetScript("OnEvent", SetToPlayerMap)
end

function ns.ShowPlayersMap(targetType) -- Find the right maps for the activation options for the mapnotes menu (zone/continent/dungeon (RetailOptions.lua))
  local PlayerMapID = C_Map.GetBestMapForUnit("player")
  if not PlayerMapID then return end

  local info = C_Map.GetMapInfo(PlayerMapID)
  while info and info.mapType and info.mapType > targetType and info.parentMapID do
    info = C_Map.GetMapInfo(info.parentMapID)
  end

  if info and info.mapType == targetType then
    ns.SafeSetMapID(info.mapID)
  end
end

do
  local GroupMembersPin
  local ArrowSizesTable
  local function EnsureArrowData()
    if GroupMembersPin and ArrowSizesTable then return true end
    if not (WorldMapFrame and WorldMapFrame.EnumeratePinsByTemplate) then return false end
    for pin in WorldMapFrame:EnumeratePinsByTemplate("GroupMembersPinTemplate") do
      if pin.dataProvider and pin.dataProvider.GetUnitPinSizesTable then
        GroupMembersPin = pin
        ArrowSizesTable = pin.dataProvider:GetUnitPinSizesTable()
        return true
      end
    end
    return false
  end

  function ns.ApplyWorldMapArrowSize()
    if not EnsureArrowData() then return end

    if ns.Addon.db.profile.activate.HideMapNote then
      ArrowSizesTable.player = 27
      GroupMembersPin:SynchronizePinSizes()
      return
    end

    if ns.Addon.db.profile.activate.WorldMapArrow then
      ArrowSizesTable.player = 27 * (ns.Addon.db.profile.activate.WorldMapArrowScale or 1)
    else
      ArrowSizesTable.player = 27
    end
    GroupMembersPin:SynchronizePinSizes()
  end
end

local f = CreateFrame("Frame")
local function HookWorldMap()
  if f._hooked then return end
  if not WorldMapFrame then return end
  WorldMapFrame:HookScript("OnShow", ns.ApplyWorldMapArrowSize)
  f._hooked = true
end

HookWorldMap()

f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, _, addon)
  if addon == "Blizzard_WorldMap" then
    HookWorldMap()
  end
end)