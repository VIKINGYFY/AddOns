local ADDON_NAME, ns = ...

ns.alchemy = IsSpellKnown(2259) or IsSpellKnown(3101) or IsSpellKnown(3464) or IsSpellKnown(11611)
ns.blacksmith = IsSpellKnown(2018) or IsSpellKnown(3100) or IsSpellKnown(3538) or IsSpellKnown(9785)
ns.enchanting = IsSpellKnown(7411) or IsSpellKnown(7412) or IsSpellKnown(7413) or IsSpellKnown(13920)
ns.engineer = IsSpellKnown(4036) or IsSpellKnown(4037) or IsSpellKnown(4038) or IsSpellKnown(12656) or IsSpellKnown(20219) or IsSpellKnown(20222)
ns.herbalism = IsSpellKnown(2366) or IsSpellKnown(2383) or IsSpellKnown(2383) or IsSpellKnown(2383)
ns.mining = IsSpellKnown(2575) or IsSpellKnown(2576) or IsSpellKnown(3564) or IsSpellKnown(10248)
ns.leatherworking = IsSpellKnown(2108) or IsSpellKnown(3104) or IsSpellKnown(3811) or IsSpellKnown(10662)
ns.skinning = IsSpellKnown(8613) or IsSpellKnown(8617) or IsSpellKnown(8618) or IsSpellKnown(10768)
ns.tailoring = IsSpellKnown(3908) or IsSpellKnown(3909) or IsSpellKnown(3910) or IsSpellKnown(12180)

ns.cooking = IsSpellKnown(2550) or IsSpellKnown(3102) or IsSpellKnown(3413) or IsSpellKnown(18260)
ns.firstAid = IsSpellKnown(3273) or IsSpellKnown(3274) or IsSpellKnown(7924) or IsSpellKnown(10846)
ns.fishing = IsSpellKnown(7620) or IsSpellKnown(7731) or IsSpellKnown(7732) or IsSpellKnown(18248)

function ns.AutomaticProfessionDetectionCapital()
    if ns.Addon.db.profile.activate.CapitalsProfessions then
        if ns.Addon.db.profile.showCapitalsProfessionDetection then
            
            if ns.alchemy then
                ns.Addon.db.profile.showCapitalsAlchemy = true
            elseif not ns.alchemy then
                ns.Addon.db.profile.showCapitalsAlchemy = false
            end

            if ns.blacksmith then
                ns.Addon.db.profile.showCapitalsBlacksmith = true
            elseif not ns.blacksmith then
                ns.Addon.db.profile.showCapitalsBlacksmith = false
            end

            if ns.enchanting then
                ns.Addon.db.profile.showCapitalsEnchanting = true
            elseif not ns.enchanting then
                ns.Addon.db.profile.showCapitalsEnchanting = false
            end

            if ns.engineer then
                ns.Addon.db.profile.showCapitalsEngineer = true
            elseif not ns.engineer then
                ns.Addon.db.profile.showCapitalsEngineer = false
            end

            if ns.herbalism then
                ns.Addon.db.profile.showCapitalsHerbalism = true
            elseif not ns.herbalism then
                ns.Addon.db.profile.showCapitalsHerbalism = false
            end

            if ns.mining then
                ns.Addon.db.profile.showCapitalsMining = true
            elseif not ns.mining then
                ns.Addon.db.profile.showCapitalsMining = false
            end

            if ns.leatherworking then
                ns.Addon.db.profile.showCapitalsLeatherworking = true
            elseif not ns.leatherworking then
                ns.Addon.db.profile.showCapitalsLeatherworking = false
            end

            if ns.skinning then
                ns.Addon.db.profile.showCapitalsSkinning = true
            elseif not ns.skinning then
                ns.Addon.db.profile.showCapitalsSkinning = false
            end

            if ns.tailoring then
                ns.Addon.db.profile.showCapitalsTailoring = true
            elseif not ns.tailoring then
                ns.Addon.db.profile.showCapitalsTailoring = false
            end

            if ns.cooking then
                ns.Addon.db.profile.showCapitalsCooking = true
            elseif not ns.cooking then
                ns.Addon.db.profile.showCapitalsCooking = false
            end

            if ns.firstAid then
                ns.Addon.db.profile.showCapitalsFirstAid = true
            elseif not ns.firstAid then
                ns.Addon.db.profile.showCapitalsFirstAid = false
            end

            if ns.fishing then
                ns.Addon.db.profile.showCapitalsFishing = true
            elseif not ns.fishing then
                ns.Addon.db.profile.showCapitalsFishing = false
            end

        end
    end
    ns.Addon:FullUpdate()
    HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
end

function ns.AutomaticProfessionDetectionCapitalMinimap()
    if ns.Addon.db.profile.activate.MinimapCapitalsProfessions then
        if ns.Addon.db.profile.showMinimapCapitalsProfessionDetection then
            
            if ns.alchemy then
                ns.Addon.db.profile.showMinimapCapitalsAlchemy = true
            elseif not ns.alchemy then
                ns.Addon.db.profile.showMinimapCapitalsAlchemy = false
            end

            if ns.blacksmith then
                ns.Addon.db.profile.showMinimapCapitalsBlacksmith = true
            elseif not ns.blacksmith then
                ns.Addon.db.profile.showMinimapCapitalsBlacksmith = false
            end

            if ns.enchanting then
                ns.Addon.db.profile.showMinimapCapitalsEnchanting = true
            elseif not ns.enchanting then
                ns.Addon.db.profile.showMinimapCapitalsEnchanting = false
            end

            if ns.engineer then
                ns.Addon.db.profile.showMinimapCapitalsEngineer = true
            elseif not ns.engineer then
                ns.Addon.db.profile.showMinimapCapitalsEngineer = false
            end

            if ns.herbalism then
                ns.Addon.db.profile.showMinimapCapitalsHerbalism = true
            elseif not ns.herbalism then
                ns.Addon.db.profile.showMinimapCapitalsHerbalism = false
            end

            if ns.mining then
                ns.Addon.db.profile.showMinimapCapitalsMining = true
            elseif not ns.mining then
                ns.Addon.db.profile.showMinimapCapitalsMining = false
            end

            if ns.leatherworking then
                ns.Addon.db.profile.showMinimapCapitalsLeatherworking = true
            elseif not ns.leatherworking then
                ns.Addon.db.profile.showMinimapCapitalsLeatherworking = false
            end

            if ns.skinning then
                ns.Addon.db.profile.showMinimapCapitalsSkinning = true
            elseif not ns.skinning then
                ns.Addon.db.profile.showMinimapCapitalsSkinning = false
            end

            if ns.tailoring then
                ns.Addon.db.profile.showMinimapCapitalsTailoring = true
            elseif not ns.tailoring then
                ns.Addon.db.profile.showMinimapCapitalsTailoring = false
            end

            if ns.cooking then
                ns.Addon.db.profile.showMinimapCapitalsCooking = true
            elseif not ns.cooking then
                ns.Addon.db.profile.showMinimapCapitalsCooking = false
            end

            if ns.firstAid then
                ns.Addon.db.profile.showMinimapCapitalsFirstAid = true
            elseif not ns.firstAid then
                ns.Addon.db.profile.showMinimapCapitalsFirstAid = false
            end

            if ns.fishing then
                ns.Addon.db.profile.showMinimapCapitalsFishing = true
            elseif not ns.fishing then
                ns.Addon.db.profile.showMinimapCapitalsFishing = false
            end

        end
    end
    ns.Addon:FullUpdate()
    HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
end