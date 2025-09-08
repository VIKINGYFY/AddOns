local ADDON_NAME, ns = ...

function ns.RemoveBlizzPOIs()
    if ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate.HideMapNote then return end
    if not (WorldMapFrame and WorldMapFrame.pinPools) then return end

    ns.BlizzAreaPoisLookup = ns.BlizzAreaPoisLookup or {}
    if next(ns.BlizzAreaPoisLookup) == nil then
        for _, poiID in pairs(ns.BlizzAreaPoisInfo or {}) do
            if poiID then ns.BlizzAreaPoisLookup[poiID] = true end
        end
    end

    ns.BlizzAreaPoisLookupZidormi = ns.BlizzAreaPoisLookupZidormi or {}
    if next(ns.BlizzAreaPoisLookupZidormi) == nil then
        for _, poiID in pairs(ns.BlizzAreaPoisInfoZidormi or {}) do
            if poiID then ns.BlizzAreaPoisLookupZidormi[poiID] = true end
        end
    end

    for _, pinPool in pairs(WorldMapFrame.pinPools) do
        for pin in pinPool:EnumerateActive() do

            local info = pin.poiInfo
            local areaPoiID = pin.areaPoiID or (info and info.areaPoiID)
            local BlizzAreaPoiID = areaPoiID and ns.BlizzAreaPoisLookup[areaPoiID]
            local ZidormiAreaPoiID = areaPoiID and ns.BlizzAreaPoisLookupZidormi[areaPoiID]
            local ZidormiGUID = false
            if pin.objectGUID and not ZidormiAreaPoiID then
                for _, id in ipairs(ns.BlizzAreaPoisInfoZidormi or {}) do
                    if id and string.find(pin.objectGUID, tostring(id), 1, true) then
                        ZidormiGUID = true
                        break
                    end
                end
            end

            local ZidormiAreaPoiGUID = ZidormiAreaPoiID or ZidormiGUID
            local shouldHide = (ns.Addon.db.profile.activate.RemoveBlizzPOIs and BlizzAreaPoiID) or (ns.Addon.db.profile.activate.RemoveBlizzPOIsZidormi and ZidormiAreaPoiGUID)
            if shouldHide then
                pin:Hide()
            else
                if BlizzAreaPoiID or ZidormiAreaPoiGUID then
                    pin:Show()
                end
            end
        end
    end
end


for dp in pairs(WorldMapFrame.dataProviders or {}) do
    if (not dp.GetPinTemplates and type(dp.GetPinTemplate) == "function") then
        if (dp:GetPinTemplate() == "AreaPOIPinTemplate") then
            hooksecurefunc(dp, "RefreshAllData", ns.RemoveBlizzPOIs)
        end
    end
end