local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadClassHallZoneLocationinfo(self)
local db = ns.Addon.db.profile
local nodes = ns.nodes
ns._currentSourceFile = "RetailClassHallZone.lua"

--#####################################################################################################
--##########################        function to hide all nodes below         ##########################
--#####################################################################################################
    if not db.activate.HideMapNote then

    --########################################################################################
    --################################         Capitals       ################################
    --########################################################################################
        if db.activate.Capitals then

        --######################
        --### Dalaran Legion ###
        --######################
            if self.db.profile.showCapitalsDalaranLegion then

            --General Dalaran Legion
                if self.db.profile.activate.CapitalsClassHall then

                    if self.db.profile.showCapitalsClassHallEntrance then
                        nodes[627][98096938] = { mnID = 720, name = "", TransportName = ORDER_HALL_DEMONHUNTER .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. SPLASH_LEGION_BOX_FEATURE1_TITLE, type = "CHDemonhunter", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[627][67054820] = { mnID = 726, name = "", TransportName = ORDER_HALL_SHAMAN .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Shaman"], type = "CHShaman", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shaman
                        nodes[627][46592575] = { mnID = 626, name = "", TransportName = ORDER_HALL_ROGUE .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Rogue"] .. "\n" .. "(" .. L["talk to"] .. ": " .. ns.Mongar .. ")", type = "CHRogue", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[627][54323277] = { mnID = 626, name = "", TransportName = ORDER_HALL_ROGUE .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Rogue"] .. "\n" .. "(" .. L["talk to"] .. ": " .. ns.LucianTrias .. ")", type = "CHRogue", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[627][52707032] = { mnID = 626, name = "", TransportName = ORDER_HALL_ROGUE .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Rogue"] .. "\n" .. "(" .. L["talk to"] .. ": " .. ns.JackFindel .. ")", type = "CHRogue", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[627][61891355] = { mnID = 24, name = "", TransportName = ORDER_HALL_PALADIN .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Paladin"], type = "CHPaladin", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Paladin
                        
                        if self.db.profile.showZoneEasternKingdom then    
                            nodes[23][75345252] = { mnID = 24, name = "", TransportName = ORDER_HALL_PALADIN .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Paladin"], type = "CHPaladin", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Paladin - Eastern Plaqelands
                        end

                        if self.db.profile.showZoneBrokenIsles then
                            nodes[641][42642587] = { mnID = 747, name = "", TransportName = ORDER_HALL_DRUID .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Druid"], type = "CHDruid", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                            nodes[650][35174553] = { mnID = 739, name = "", TransportName = ORDER_HALL_HUNTER .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Hunter"], type = "CHHunter", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                        end

                    end

                    if self.db.profile.showCapitalsClassHallPortals and self.db.profile.showCapitalsPortals then

                    end

                    if self.db.profile.showCapitalsClassHallPortals then
                        nodes[747][55542115] = { mnID = 715, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[747][56664308] = { mnID = 627, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[720][59279191] = { mnID = 627, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH - Dalaran
                        nodes[720][58361631] = { mnID = 627, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH - Dalaran
                        nodes[726][29805198] = { mnID = 627, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shaman - Dalaran
                        nodes[726][26804137] = { mnID = 325, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shaman - Vortexgipfel - Instance
                        nodes[726][31126076] = { mnID = 367, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shaman - Feuerlande - Instance
                        nodes[739][48624354] = { mnID = 627, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter - Dalaran
                        nodes[24][37606406] = { mnID = 627, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Paladin - Dalaran
                        nodes[734][57349054] = { mnID = 627, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage - Dalaran
                        nodes[734][55033957] = { mnID = 630, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage - Azsuna
                        nodes[734][54674462] = { mnID = 650, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage - Highmountans
                        nodes[734][60285195] = { mnID = 680, name = "", dnID = L["Portal"] .. "\n(" .. DUNGEON_FLOOR_GILNEAS2 .. ")", type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage - Suramar
                        nodes[734][67124161] = { mnID = 634, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage - Stormheim
                        nodes[734][66764669] = { mnID = 641, name = "", dnID = L["Portal"], type = "CHPortal", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage - Val'sharah
                    end

                    if self.db.profile.showCapitalsClassHallPaths and self.db.profile.showCapitalsPaths then
                        nodes[627][77594788] = { name = "", TransportName = L["Class Hall"] .. " " .. L["Passage"] .. "\n ==> " .. SPLASH_LEGION_BOX_FEATURE1_TITLE, type = "RedPathRU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                    end

                    if self.db.profile.showCapitalsClassHallPaths then
                        nodes[626][29572185] = { mnID = 627, name = L["Passage"], type = "RedPathRO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[626][39652153] = { mnID = 627, name = L["Passage"], type = "RedPathLO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[626][85397396] = { mnID = 627, name = L["Passage"], type = "RedPathRU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[626][32583995] = { mnID = 619, name = L["Exit"], type = "RedPathLU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[747][76219388] = { mnID = 641, name = L["Exit"], type = "RedPathRU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[721][49545406] = { mnID = 720, name = L["Passage"], type = "RedPathL", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[721][68245395] = { mnID = 720, name = L["Passage"], type = "RedPathR", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[720][69805381] = { mnID = 721, name = L["Passage"], type = "RedPathL", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[720][47675427] = { mnID = 721, name = L["Passage"], type = "RedPathR", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[24][39579315] = { mnID = 23, name = L["Exit"], type = "RedPathLU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Paladin
                        nodes[735][69407757] = { mnID = 734, name = L["Passage"], type = "RedPathRU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[735][44867427] = { mnID = 734, name = L["Passage"], type = "RedPathLU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[735][58016763] = { mnID = 734, name = L["Passage"], type = "RedPathU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[734][59795949] = { mnID = 735, name = L["Passage"], type = "RedPathO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[734][46485455] = { mnID = 735, name = L["Passage"], type = "RedPathRU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[734][73335924] = { mnID = 735, name = L["Passage"], type = "RedPathLU", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[739][46020484] = { mnID = 650, name = L["Passage"], type = "RedPathRO", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                    end

                    if self.db.profile.showCapitalsClassHallVendor and self.db.profile.showCapitalsPvEVendor then
                        nodes[627][45232906] = { npcID = 106655, name = ns.WakeningEssence .. " " .. MERCHANT, type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Vendor Dalaran
                    end

                    if self.db.profile.showCapitalsClassHallVendor then
                        nodes[747][40731865] = { npcID = 112323, name = "", dnID = ns.QuartermasterF, type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[720][58674315] = { npcIDs1 = 112407, npcIDs2 = 116621, name = ns.QuartermasterF, type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[626][26893693] = { npcID = 105986, name = "", type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[626][45542759] = { npcID = 103792, name = "", dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT .. "\n" .. TUTORIAL_TITLE1, type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[626][54354093] = { npcID = 99863, name = "", dnID = TRANSMOG_SET_PVE .. " " .. MERCHANT, type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[626][74495419] = { npcID = 106054, name = "", type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[626][64614421] = { npcID = 105982, name = "", type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[726][30306069] = { npcID = 112318, name = "", type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shaman
                        nodes[739][44574881] = { npcID = 103693, name = "", dnID = ns.QuartermasterM, type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                        nodes[24][41316114] = { npcID = 100196, name = "", type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Paladin
                        nodes[735][44705795] = { npcID = 112440, name = "", type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[734][57006695] = { npcID = 103169, name = "", dnID = TOY .. " " .. MERCHANT, type = "CHVendor", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                    end

                    if self.db.profile.showCapitalsClassHallScoutingMap then
                        nodes[626][37664439] = { npcID = 98093, name = ns.ScoutingMap, type = "CHScoutingMap", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[747][52705108] = { npcID = 98000, name = ns.ScoutingMap, type = "CHScoutingMap", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[720][58915379] = { npcID = 98613, name = ns.ScoutingMap, type = "CHScoutingMap", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[726][33495937] = { npcID = 99428, name = ns.ScoutingMap, type = "CHScoutingMap", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shaman
                        nodes[739][42484662] = { npcID = 102669, name = ns.ScoutingMap, type = "CHScoutingMap", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                        nodes[24][53447863] = { npcID = 93787, name = ns.ScoutingMap, type = "CHScoutingMap", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Paladin
                        nodes[734][81906140] = { npcID = 98695, name = ns.ScoutingMap, type = "CHScoutingMap", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                    end

                    if self.db.profile.showCapitalsClassHallArtifactForge then
                        nodes[721][58542712] = { name = L["Artifact Forge"], type = "ArtifactForge", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[626][27406178] = { name = L["Artifact Forge"], type = "ArtifactForge", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[747][30865365] = { name = L["Artifact Forge"], type = "ArtifactForge", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[726][37184574] = { name = L["Artifact Forge"], type = "ArtifactForge", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shaman
                        nodes[739][47815361] = { name = L["Artifact Forge"], type = "ArtifactForge", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                        nodes[24][72472397] = { name = L["Artifact Forge"], type = "ArtifactForge", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Paladin
                        nodes[735][59814367] = { name = L["Artifact Forge"], type = "ArtifactForge", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                    end

                    if self.db.profile.showCapitalsClassHallRecruit then
                        nodes[747][36332540] = { npcID = 108393, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[747][43276316] = { npcID = 111786, name = "", dnID = ns.RecruitM, type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[747][38623423] = { npcID = 106442, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[626][31962667] = { npcID = 105979, name = "", dnID = ns.RecruitF, type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[626][48244122] = { npcID = 106083, name = "", dnID = ns.RecruitM, type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[720][56185422] = { npcID = 103025, name = "", dnID = ns.RecruitM, type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[720][58683885] = { npcID = 103760, name = "", dnID = ns.RecruitM, type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[726][30525877] = { npcID = 106457, name = "", dnID = ns.RecruitM, type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shaman
                        nodes[726][31825148] = { npcID = 109829, name = "", dnID = ns.RecruitM, type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shaman
                        nodes[726][29274281] = { npcID = 112208, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shaman
                        nodes[739][42833769] = { npcID = 106444, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                        nodes[739][57703265] = { npcID = 106446, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                        nodes[24][53305619] = { npcID = 106447, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Paladin
                        nodes[24][58913899] = { npcID = 106448, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Paladin
                        nodes[734][47753215] = { npcID = 106433, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[734][87864745] = { npcID = 106377, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[734][82875666] = { npcID = 110427, name = "", type = "Recruit", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                    end

                    if self.db.profile.showCapitalsClassHallUpgrade then
                        nodes[721][55256271] = { npcID = 108527, name = "", type = "CHUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[626][45966916] = { npcID = 105998, name = "", dnID = ns.Upgrade, type = "CHUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[747][32862934] = { npcID = 97989, name = "", dnID = ns.Upgrade, type = "CHUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[726][33385816] = { npcID = 112199, name = "", dnID = ns.Upgrade, type = "CHUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shaman
                        nodes[739][58695119] = { npcID = 108050, name = "", type = "CHUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                        nodes[734][74942896] = { npcID = 108331, name = "", type = "CHUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                        nodes[24][39845649] = { npcID = 109901, name = "", type = "CHUpgrade", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Paladin
                    end

                    if self.db.profile.showCapitalsClassHallArchivar then
                        nodes[747][33903263] = { npcID = 111737, name = ns.Archivar, type = "Archivar", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[721][62047501] = { npcID = 111736, name = ns.Archivar, type = "Archivar", showInZone = true, showOnContinent = false, showOnMinimap = false } -- DH
                        nodes[626][37867008] = { npcID = 102641, name = "", type = "Archivar", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                        nodes[726][32594964] = { npcID = 111739, name = "", type = "Archivar", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Shaman
                        nodes[739][52505442] = { npcID = 98737, name = "", type = "Archivar", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                        nodes[24][37705720] = { npcID = 91190, name = "", type = "Archivar", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Paladin
                        nodes[735][64705027] = { npcID = 110624, name = "", type = "Archivar", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                    end

                    if self.db.profile.showCapitalsClassHallMountMerchent then
                        nodes[626][42498227] = { npcID = 121282, name = PERKS_VENDOR_CATEGORY_MOUNT .. " " .. MERCHANT, type = "CHMountMerchant", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Rogue
                    end

                    if self.db.profile.showCapitalsClassHallMailbox then
                        nodes[747][40442600] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "CHMailbox", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[734][52618324] = { dnID = MINIMAP_TRACKING_MAILBOX, name = "", type = "CHMailbox", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Mage
                    end

                    if self.db.profile.showCapitalsClassHallFP then
                        nodes[747][61733398] = { npcID = 107457, name = "", type = "CHTravel", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Druid
                        nodes[739][35812762] = { npcID = 98968, name = "", type = "CHTravel", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                        nodes[739][40072857] = { npcID = 109572, name = "", TransportName = L["Hunter"] .. " " .. L["Class Hall"] .. " " .. MINIMAP_TRACKING_FLIGHTMASTER, type = "CHTravel", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                        --nodes[627][69825114] = { mnID = 739, npcID = 96813, name = "", TransportName = ORDER_HALL_HUNTER .. "\n" .. L["Class Hall"] .. " " .. L["Hunter"], type = "CHTravel", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                    end

                    if self.db.profile.showCapitalsClassHallStablemaster then
                        nodes[739][58783181] = { npcID = 100661, name = "", type = "CHStablemasterN", showInZone = true, showOnContinent = false, showOnMinimap = false } -- Hunter
                    end

                end
            end
        end
    end
end