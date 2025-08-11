local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

ns.DelveContinent = CreateFromMixins(CVarMapCanvasDataProviderMixin, AreaPOIDataProviderMixin)
ns.DelveContinent:Init("showContinentDelvesOnMapNotes")

function ns.BlizzardDelvesAddTT()
    if ns._BlizzDelveTT_Hooked then return end
    ns._BlizzDelveTT_Hooked = true

    hooksecurefunc(DelveEntrancePinMixin, "OnMouseEnter", function(self)
        GameTooltip:AddDoubleLine(TextIconMNL4:GetIconString() .. " " .. "|cff00ff00" .. "< " .. KEY_BUTTON3 .. " " .. L["to show delve map"] .. " > " .. TextIconMNL4:GetIconString(), nil, nil, false)
        GameTooltip:Show()
    end)
end

function ns.BlizzardDelvesAddFunction()
    if ns._BlizzDelveClick_Hooked then return end
    ns._BlizzDelveClick_Hooked = true

    hooksecurefunc(DelveEntrancePinMixin, "OnClick", function(self, button)
        ns.BlizzDelveIDs = ns.BlizzDelveAreaPoisInfoIDs[self.poiInfo.areaPoiID] or ns.BlizzBountifulDelveAreaPoisInfoIDs[self.poiInfo.areaPoiID]
        if button == "MiddleButton" then
            if ns.BlizzDelveIDs then
                WorldMapFrame:SetMapID(ns.BlizzDelveIDs)
            end
        end
    end)
end

EventUtil.ContinueOnAddOnLoaded("Blizzard_WorldMap", function()
    pcall(function() ns.BlizzardDelvesAddTT() end)
    pcall(function() ns.BlizzardDelvesAddFunction() end)
end)

function ns.DelveContinent:OnShow()
    if CVarMapCanvasDataProviderMixin.OnShow then
        CVarMapCanvasDataProviderMixin.OnShow(self)
    end
    if AreaPOIDataProviderMixin.OnShow then
        AreaPOIDataProviderMixin.OnShow(self)
    end

    self:RefreshAllData()
end

function ns.DelveContinent:OnHide()
    if CVarMapCanvasDataProviderMixin.OnHide then
        CVarMapCanvasDataProviderMixin.OnHide(self)
    end
    if AreaPOIDataProviderMixin.OnHide then
        AreaPOIDataProviderMixin.OnHide(self)
    end
end

function ns.DelveContinent:OnEvent(event, ...)
    if CVarMapCanvasDataProviderMixin.OnEvent then
        CVarMapCanvasDataProviderMixin.OnEvent(self, event, ...)
    end
    if AreaPOIDataProviderMixin.OnEvent then
        AreaPOIDataProviderMixin.OnEvent(self, event, ...)
    end
end

function ns.DelveContinent:OnMapChanged()
    self:RefreshAllData()
end

local function ConvertMapCoords(fromMapID, toMapID, x, y)
    local minX, maxX, minY, maxY = C_Map.GetMapRectOnMap(fromMapID, toMapID)
    if not minX then return end
    return Lerp(minX, maxX, x), Lerp(minY, maxY, y)
end

function ns.DelveContinent:RemoveAllData()
    local map = self:GetMap()
    if not map then return end
    map:RemoveAllPinsByTemplate("MapNotesContinentDelvePinTemplate")
end

function ns.DelveContinent:RefreshAllData()
    self:RemoveAllData()

    if not self:IsCVarSet() or InCombatLockdown() then
        return
    end

    local map = self:GetMap()
    if not map then return end

    local mapID = map:GetMapID()
    local mapInfo = C_Map.GetMapInfo(mapID)
    if not (mapInfo and mapInfo.mapType == Enum.UIMapType.Continent) then
        return
    end

    if not (ns.Addon.db.profile.showContinentDelves and ns.Addon.db.profile.showContinentKhazAlgar) then
        return
    end

    for _, child in ipairs(C_Map.GetMapChildrenInfo(mapID, nil, true) or {}) do

        if child and child.mapID then
        local minX = C_Map.GetMapRectOnMap(child.mapID, mapID)
        if minX then
            self:ProjectDelves(mapID, child.mapID)
        end
        end
    end
end

function ns.DelveContinent:IsCVarSet()
  return ns.Addon.db.profile.showContinentDelves and ns.Addon.db.profile.showContinentKhazAlgar
end

function ns.DelveContinent:ProjectDelves(parentMapID, zoneMapID)
    local delves = C_AreaPoiInfo.GetDelvesForMap(zoneMapID) or {}
    for _, delveID in ipairs(delves) do
        local info = C_AreaPoiInfo.GetAreaPOIInfo(zoneMapID, delveID)
        if info and info.position and (info.atlasName == "delves-bountiful" or not ns.Addon.db.profile.OnlyBountiful) then
            local x, y = info.position:GetXY()
            local newX, newY = ConvertMapCoords(zoneMapID, parentMapID, x, y)
            if newX and newY and newX >= 0 and newX <= 1 and newY >= 0 and newY <= 1 then
            info.position:SetXY(newX, newY)
            info.dataProvider = self
            local map = self:GetMap()
                if map then
                    map:AcquirePin("MapNotesContinentDelvePinTemplate", info)
                end
            end
        end
    end
end

EventUtil.ContinueOnAddOnLoaded("Blizzard_WorldMap", function()
    if ns._DelveProviderAdded then return end
    ns._DelveProviderAdded = true

    local provider = CreateFromMixins(ns.DelveContinent)
    WorldMapFrame:AddDataProvider(provider)

    ns._DelveProvider = provider

    if WorldMapFrame:IsShown() and provider.GetMap and provider:GetMap() then
        provider:RefreshAllData()
    end

    WorldMapFrame:HookScript("OnShow", function()
        if ns._DelveProvider and ns._DelveProvider.GetMap and ns._DelveProvider:GetMap() then
            ns._DelveProvider:RefreshAllData()
        end
    end)
end)

function ns.RefreshContinentDelvesPins(opts)
    local p = ns._DelveProvider
    if not p or not p.GetMap then return end
    local map = p:GetMap()
    if not map then return end

    if opts and opts.remove then
        p:RemoveAllData()
    else
        p:RefreshAllData()
    end
end