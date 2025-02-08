--[[
                                ----o----(||)----oo----(||)----o----

                                           Lunar Festival

                                      v4.13 - 7th February 2025
                                Copyright (C) Taraezor / Chris Birch
                                         All Rights Reserved

                                ----o----(||)----oo----(||)----o----
]]

local addonName, ns = ...
ns.db = {}

-- From Data.lua
ns.points = {}
ns.textures = {}
ns.scaling = {}

-- Red/Gold theme
ns.colour = {}
ns.colour.prefix	= "\124cFFC11B17" -- Chilli Pepper
ns.colour.highlight = "\124cFFE9AB17" -- Bee Yellow
ns.colour.achieveH	= "\124cFFF70D1A" -- Ferrari Red
ns.colour.achieveI	= "\124cFFF6BE00" -- Deep Yellow
ns.colour.achieveD	= "\124cFFC3FDB8" -- Light Jade
ns.colour.seasonal	= "\124cFF5EFB6E" -- Jade Green
ns.colour.daily		= "\124cFF00BFFF" -- Deep Sky Blue
ns.colour.Guide		= "\124cFF12AD2B" -- Parrot Green
ns.colour.plaintext = "\124cFF00A36C" -- Jade
ns.colour.completeR	= "\124cFFFF0000" -- Red
ns.colour.completeG	= "\124cFF00FF00" -- Green

local defaults = { profile = { iconScale = 2.5, iconAlpha = 1, showCoords = true,
								removeOneTime = true, removeSeasonal = true, removeAchieveChar = true,
								removeAchieveAcct = false,
								iconZoneElders = 15, iconDungeonElders = 14, iconCrown = 13,
								iconFactionElders = 11, iconPreservation = 9, iconSeasonal=12,
								iconMeta = 16, iconHistory = 10, iconSpecial = 8, } }
local pluginHandler = {}

-- upvalues
local GameTooltip = _G.GameTooltip
local GetAchievementCriteriaInfo = GetAchievementCriteriaInfo
local GetAchievementInfo = GetAchievementInfo
local GetMapChildrenInfo = C_Map.GetMapChildrenInfo
local IsComplete = C_QuestLog.IsComplete
local IsOnQuest = C_QuestLog.IsOnQuest
local IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted
local UnitAura = C_UnitAuras.GetAuraDataByIndex
local LibStub = _G.LibStub
local UIParent = _G.UIParent
local format = _G.format
local gsub = string.gsub
local next = _G.next
local pairs = _G.pairs

local HandyNotes = _G.HandyNotes

_, _, _, ns.version = GetBuildInfo()
ns.faction = UnitFactionGroup( "player" )
ns.name = UnitName( "player" ) or "Character"

ns.continents = {}
if ( ns.version < 60000) then
	ns.continents[ 1414 ] = true -- Kalimdor
	ns.continents[ 1415 ] = true -- Eastern Kingdoms
	ns.continents[ 1945 ] = ( ns.version >= 20000) and true or nil -- Outland
else
	ns.continents[ 12 ] = true -- Kalimdor
	ns.continents[ 13 ] = true -- Eastern Kingdoms
	ns.continents[ 101 ] = true -- Outland
end
ns.continents[ 113 ] = ( ns.version >= 30000) and true or nil -- Northrend
ns.continents[ 203 ] = ( ns.version >= 40000) and true or nil -- Vashj'ir
ns.continents[ 948 ] = ( ns.version >= 40000) and true or nil -- Vashj'ir
ns.continents[ 424 ] = ( ns.version >= 50000) and true or nil -- Pandaria
ns.continents[ 572 ] = ( ns.version >= 60000) and true or nil -- Draenor
ns.continents[ 619 ] = ( ns.version >= 70000) and true or nil -- Broken Isles
ns.continents[ 875 ] = ( ns.version >= 80000) and true or nil -- Zandalar
ns.continents[ 876 ] = ( ns.version >= 80000) and true or nil -- Kul Tiras
ns.continents[ 1978 ] = ( ns.version >= 90000) and true or nil -- Dragon Isles
ns.continents[ 947 ] = true -- Azeroth

-- ---------------------------------------------------------------------------------------------------------------------------------

local function PassClassCheck( pin )
	if ( pin.class == nil) or ( ns.class == pin.class ) then
		return true
	end
	return false
end

local function PassFactionCheck( pin )
	if ( pin.faction == nil)
			or ( ( ns.faction == "Horde" ) and ( ( pin.faction == "Neutral" ) or ( pin.faction == "Horde" ) ) )
			or ( ( ns.faction == "Alliance" ) and ( ( pin.faction == "Neutral" ) or ( pin.faction == "Alliance" ) ) )
			or ( ( ns.faction == "Neutral" ) and ( pin.faction == "Neutral" ) ) then
		return true
	end
	return false
end

local function PassVersionCheck( pin )
	if pin.version then
		if ns.version >= pin.version then return true end
		return false
	end
	if pin.versionUnder then
		if ns.version < pin.versionUnder then return true end
		return false
	end	
	return true
end

-- ---------------------------------------------------------------------------------------------------------------------------------

local function CorrectMapPhase( mapID, old )

	if ( ns.version < 60000 ) then return true end -- Safe to drop through the code but more efficient to just exit

	if ( mapID == 17 ) or -- Blasted Lands
			( mapID == 18 ) or ( mapID == 2070 ) or -- Tirisfal Glades
			( mapID == 57 ) or ( mapID == 62 ) or ( mapID == 81 ) or -- Teldrassil, Silithus, Darkshore
			( mapID == 249 ) or ( mapID == 1527 ) then -- Uldum
		for i = 1, 40 do -- 40 is rather arbitrary these days I think
			local auraData = UnitAura( "player", i, "HELPFUL" )
			if auraData == nil then break end
			if auraData.spellId then
				if ( auraData.spellId == 372329 ) or ( auraData.spellId == 276827 ) or ( auraData.spellId == 255152 ) or
						( auraData.spellId == 290246 ) or ( auraData.spellId == 317785 ) then
					-- Time Travelling buff for Blasted Lands, Tirisfal Glades, Silithus, Darkshore/Teldrassil/Darnassus, Uldum
					return old
				end
			end
		end
		return not old
	else
		return old
	end
end

local function SpacerFirstTimeHeader( firstTime, heading, colour )
	if firstTime == true then
		GameTooltip:AddLine( "\n" )
		GameTooltip:AddLine( colour ..heading )
	end
	return false
end

local function CompletionShow( completed, whatever, colour, name, completionS ) -- Last two parms are optional
	GameTooltip:AddDoubleLine( ( whatever and ( colour ..whatever) or " " ), 
		( ( completed == true ) and ( ns.colour.completeG ..ns.L[ "Completed" ] ) or ( ns.colour.completeR
		..ns.L[ "Not Completed" ] ) ) .." (" ..( ( completionS == nil ) and "" or ( ( completionS == true ) and
		ns.colour.completeG or ns.colour.completeR ) ) ..( name or "Account" )
		..( ( completed == true ) and ns.colour.completeG or ns.colour.completeR ) ..")" )
end

local function Tip( tip )
	if tip then
		GameTooltip:AddLine( ns.colour.plaintext .."\n" ..ns.L[ tip ], nil, nil, nil, true )
	end
end

local function GuideTip( pin )
	if pin.guide then
		GameTooltip:AddLine( ns.colour.highlight .."\n" ..ns.L[ "Guide" ] .."\n" ..ns.colour.Guide ..pin.guide,
				nil, nil, nil, true )
	end
	if pin.tip then
		Tip( pin.tip )
	end
end

local function GetQuestName( pin )
	-- Favour the returned name as it'll be translated but only if a name was returned from the API
	local result = QuestUtils_GetQuestName( pin.id )
	local level = pin.level and ( ns.colour.plaintext .." (" ..ns.L[ "Level" ] .." " ..pin.level ..")" ) or ""
	if result and result ~= "" then return result ..level end
	if pin.name then return ns.L[ pin.name ] ..level end
	return ns.L[ "Try again" ]
end

-- Plugin handler for HandyNotes
function pluginHandler:OnEnter(mapFile, coord)
	if self:GetCenter() > UIParent:GetCenter() then
		GameTooltip:SetOwner( self, "ANCHOR_LEFT" )
	else
		GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
	end

	local pin = ns.points[ mapFile ] and ns.points[ mapFile ][ coord ]

	local firstTime, aName, completed, completedQ, description, earnedByMe, cType, assetID;
	
	if pin.name then
		GameTooltip:SetText( ns.colour.prefix ..ns.L[ pin.name ] )
	else
		GameTooltip:SetText( ns.colour.prefix ..( ns.L[ "Lunar Festival" ] ) )
	end
	
	if pin.achievements and ( ns.version > 30002 ) then
		firstTime = true
		for _,v in ipairs( pin.achievements ) do
			if PassFactionCheck( v ) and PassVersionCheck( v ) then
				_, aName, _, completed, _, _, _, description, _, _, _, _, earnedByMe = GetAchievementInfo( v.id )
				SpacerFirstTimeHeader( firstTime, ns.L[ "Achievement" ], ns.colour.highlight )
				CompletionShow( completed, aName, ns.colour.achieveH )
				-- Strictly speaking the results are NOT correct from the API for the event's meta for earnedByMe
				CompletionShow( earnedByMe , nil, nil, ns.name )
				if v.showAllCriteria then
					GameTooltip:AddLine( ns.colour.achieveD ..description, nil, nil, nil, true )
					numCriteria = GetAchievementNumCriteria( v.id )
					for i = 1, numCriteria do
						aName, cType, completed, _, _, _, _, assetID = GetAchievementCriteriaInfo( v.id, i )
						if ( cType == 27 ) then
							-- Quest type
								if i == 1 then GameTooltip:AddLine( ns.colour.achieveH ..ns.L[ "Seasonal" ] ) end
								completedQ = IsQuestFlaggedCompleted( assetID )
								CompletionShow( completedQ, aName, ns.colour.achieveI, ns.name, completed )
						elseif ( cType == 8 ) then
							-- Achievement type. Meta. cType will show each line as an achievement
							-- Must do it this way as "completed" for the criteria becomes account wide for meta achievements
							_, aName, _, completed, _, _, _, description, _, _, _, _, earnedByMe = GetAchievementInfo( assetID )
							CompletionShow( earnedByMe, aName, ns.colour.achieveH, ns.name )
							if earnedByMe == false and description then
								GameTooltip:AddLine( ns.colour.achieveD ..description, nil, nil, nil, true )
							end
						end
					end
				else
					GameTooltip:AddLine( ns.colour.achieveD ..description, nil, nil, nil, true )
					if v.index then
						aName, _, completed = GetAchievementCriteriaInfo( v.id, v.index )
						CompletionShow( completed, aName, ns.colour.achieveI, ns.name )
					end
				end
				GuideTip( v )
			end
		end
	end

	if pin.quests then
		firstTime = true
		for _,v in ipairs( pin.quests ) do
			if PassFactionCheck( v ) and PassVersionCheck( v ) and PassClassCheck( v ) and ( v.qType == "Seasonal" ) then
				completed = IsQuestFlaggedCompleted( v.id )
				firstTime = SpacerFirstTimeHeader( firstTime, ns.L[ "Seasonal" ], ns.colour.highlight )
				CompletionShow( completed, GetQuestName( v ), ns.colour.seasonal, ns.name )
				if v.id == 56842 then -- Lunar Preservation
					if ( IsOnQuest( 56842 ) == true ) then
						completed = IsComplete( 56842 )
						if ( completed == true ) then
							GameTooltip:AddLine( ns.colour.plaintext ..ns.L[ "Ready to turn in" ] )
						else
							GameTooltip:AddLine( ns.colour.plaintext ..ns.L[ "Wells so far: " ] ..( ns.lpBuffCount or 0 ) )
						end
					elseif completed == false then
						GameTooltip:AddLine( ns.colour.plaintext ..ns.L[ "Not yet begun" ] )
					end
				end
				GuideTip( v )
			end
		end
		
		firstTime = true
		for _,v in ipairs( pin.quests ) do
			if PassFactionCheck( v ) and PassVersionCheck( v ) and PassClassCheck( v ) and ( v.qType == "Daily" ) then
				completed = IsQuestFlaggedCompleted( v.id )
				firstTime = SpacerFirstTimeHeader( firstTime, ns.L[ "Daily" ], ns.colour.highlight )
				CompletionShow( completed, GetQuestName( v ), ns.colour.daily, ns.name )
				GuideTip( v )
			end
		end
		
		firstTime = true
		for _,v in ipairs( pin.quests ) do
			if PassFactionCheck( v ) and PassVersionCheck( v ) and PassClassCheck( v ) and ( v.qType == "One Time" ) then
				completed = IsQuestFlaggedCompleted( v.id )
				firstTime = SpacerFirstTimeHeader( firstTime, ns.L[ "One Time" ], ns.colour.highlight )
				CompletionShow( completed, GetQuestName( v ), ns.colour.seasonal, ns.name )
				GuideTip( v )
			end
		end
	end
	
	if ( pin.noZidormi == nil ) and ( CorrectMapPhase( mapFile, old ) == false ) then
		Tip( ns.L[ "ZidormiWrongPhase" ] )
	end

	GuideTip( pin )

	if ( ns.db.showCoords == true ) and not pin.noCoords then
		local mX, mY = HandyNotes:getXY(coord)
		mX, mY = mX*100, mY*100
		GameTooltip:AddLine( "\n" ..ns.colour.highlight .."(" ..format( "%.02f", mX ) .."," ..format( "%.02f", mY ) ..")" )
	end

	GameTooltip:Show()
end

function pluginHandler:OnLeave()
	GameTooltip:Hide()
end

-- ---------------------------------------------------------------------------------------------------------------------------------

local function ShowAchievements( pin )
	if not pin.achievements then return false end
	if ns.version < 30002 then return false end -- Achievements began with WotLK patch 3.0.2
	if ns.db.removeAchieveChar == false then return true end

	local completed, earnedByMe;
	for _,v in ipairs( pin.achievements ) do
		if PassFactionCheck( v ) and PassVersionCheck( v ) then
			_, _, _, completed, _, _, _, _, _, _, _, _, earnedByMe = GetAchievementInfo( v.id )
			-- We now know the account and character situation
			if ( ns.db.removeAchieveAcct == true ) and ( completed == true ) then
				-- We don't wanna see this pin
			elseif earnedByMe == true then
				-- Again, we don't wanna see it ( we know that the DB options flag must be true too )
			else
				-- We must now check if it's an indexed achievement pin
				if not v.index then
					-- We definitely need to see this pin
					return true
				end
				_, _, completed = GetAchievementCriteriaInfo( v.id, v.index )
				if completed == false then return true end
			end
		end
		-- To here if we don't want to see the pin but, we may be showing > 1 achievements on the pin
	end
	return false
end

local function ShowSeasonal( pin )
	if not pin.quests then return false end

	local completed;
	for _,v in ipairs( pin.quests ) do
		if PassFactionCheck( v ) and PassVersionCheck( v ) and ( v.qType == "Seasonal" ) then
			if ns.db.removeSeasonal == false then return true end
			completed = IsQuestFlaggedCompleted( v.id )
			if completed == false then return true end
		end
	end
	return false
end

local function ShowDailies( pin )
	if not pin.quests then return false end

	local completed;
	for _,v in ipairs( pin.quests ) do
		if PassFactionCheck( v ) and PassVersionCheck( v ) and ( v.qType == "Daily" ) then
			if ns.db.removeDailies == false then return true end
			completed = IsQuestFlaggedCompleted( v.id )
			if completed == false then return true end
		end
	end
	return false
end

local function ShowOneTime( pin )
	if not pin.quests then return false end

	local completed;
	for _,v in ipairs( pin.quests ) do
		if PassFactionCheck( v ) and PassVersionCheck( v ) and ( v.qType == "One Time" ) then
			if ns.db.removeOneTime == false then return true end
			completed = IsQuestFlaggedCompleted( v.id )
			if completed == false then return true end
		end
	end
	return false
end

do	
	local function iterator(t, prev)
		if not t then return end
		local coord, pin = next(t, prev)
		while coord do
			if pin and PassFactionCheck( pin ) and PassVersionCheck( pin ) then			
				if pin.elder or pin.elderDungeon or pin.elderFaction then
					if ShowAchievements( pin ) and ShowSeasonal( pin ) then
						if pin.elder then
							return coord, nil, ns.textures[ns.db.iconZoneElders],
								ns.db.iconScale * ns.scaling[ns.db.iconZoneElders], ns.db.iconAlpha
						elseif pin.elderDungeon then
							return coord, nil, ns.textures[ns.db.iconDungeonElders],
								ns.db.iconScale * ns.scaling[ns.db.iconDungeonElders], ns.db.iconAlpha
						elseif pin.elderFaction then
							return coord, nil, ns.textures[ns.db.iconFactionElders],
								ns.db.iconScale * ns.scaling[ns.db.iconFactionElders], ns.db.iconAlpha
						end
					end
				elseif pin.meta then
					return coord, nil, ns.textures[ns.db.iconMeta],
						ns.db.iconScale * ns.scaling[ns.db.iconMeta], ns.db.iconAlpha
				elseif pin.metaLarge then
					return coord, nil, ns.textures[ns.db.iconMeta],
						ns.db.iconScale * 2 * ns.scaling[ns.db.iconMeta], ns.db.iconAlpha
				elseif pin.history then
					return coord, nil, ns.textures[ns.db.iconHistory],
						ns.db.iconScale * 2 * ns.scaling[ns.db.iconHistory], ns.db.iconAlpha
				elseif pin.metaFaction then
					return coord, nil, ns.textures[ns.db.iconFactionElders],
						ns.db.iconScale * ns.scaling[ns.db.iconFactionElders], ns.db.iconAlpha
				elseif pin.elune then
					return coord, nil, ns.textures[ns.db.iconSeasonal],
						ns.db.iconScale * ns.scaling[ns.db.iconSeasonal], ns.db.iconAlpha
				elseif pin.coins then
					return coord, nil, ns.textures[ns.db.iconDungeonElders],
						ns.db.iconScale * ns.scaling[ns.db.iconDungeonElders], ns.db.iconAlpha
				elseif pin.pyro then
					return coord, nil, ns.textures[ns.db.iconSpecial],
						ns.db.iconScale * ns.scaling[ns.db.iconSpecial], ns.db.iconAlpha
				elseif pin.newZones then
					return coord, nil, ns.textures[ns.db.iconZoneElders],
						ns.db.iconScale * ns.scaling[ns.db.iconZoneElders], ns.db.iconAlpha
				elseif pin.showAnyway or ShowSeasonal( pin ) or ShowDailies( pin ) or ShowOneTime( pin ) then
					if pin.preservation then
						return coord, nil, ns.textures[ns.db.iconPreservation],
							ns.db.iconScale * ns.scaling[ns.db.iconPreservation], ns.db.iconAlpha
					elseif pin.seasonalQuest then
						return coord, nil, ns.textures[ns.db.iconSeasonal],
							ns.db.iconScale * ns.scaling[ns.db.iconSeasonal], ns.db.iconAlpha
					end
					if pin.crown and ( IsQuestFlaggedCompleted( 56842 ) == true ) then -- Lunar Preservation
						return coord, nil, ns.textures[ns.db.iconCrown],
							ns.db.iconScale * ns.scaling[ns.db.iconCrown] * 0.5, ns.db.iconAlpha
					end
				end
			end
			coord, pin = next(t, coord)
		end
	end
	function pluginHandler:GetNodes2(mapID)
		return iterator, ns.points[mapID]
	end
end

-- ---------------------------------------------------------------------------------------------------------------------------------

local function AddColouredText( inputText )
	local hash = gsub( ns.L[ inputText ], "%%e", ns.colour.highlight )
	return gsub( hash, "%%s", ns.colour.prefix )
end

local function SubstitutePlayerOrElseAcct( theType, character )
	return gsub( ns.L[ theType ], "%%p", ( character and ns.name or ns.L[ "Account" ] ) )
end

ns.iconStandard = "1 = " ..ns.L["White"] .."\n2 = " ..ns.L["Purple"] .."\n3 = " ..ns.L["Red"] .."\n4 = " ..ns.L["Yellow"]
				.."\n5 = " ..ns.L["Green"] .."\n6 = " ..ns.L["Grey"] .."\n7 = " .. ns.L["Blue Coin"]
				.."\n8 = " ..ns.L["Deep Green Coin"] .."\n9 = " ..ns.L["Deep Pink Coin"] .."\n10 = " ..ns.L["Deep Red Coin"]
				.."\n11 = " ..ns.L["Green Coin"] .."\n12 = " ..ns.L["Light Blue Coin"] .."\n13 = " ..ns.L["Pink Coin"]
				.."\n14 = " ..ns.L["Purple Coin"] .."\n15 = " ..ns.L["Teal Coin"] .."\n16 = " ..ns.L["Original Coin"]

-- Interface -> Addons -> Handy Notes -> Plugins -> Lunar Festival options
ns.options = {
	type = "group",
	name = ns.L["Lunar Festival"],
	desc = AddColouredText( "AddOn Description" ),
	get = function(info) return ns.db[info[#info]] end,
	set = function(info, v)
		ns.db[info[#info]] = v
		pluginHandler:Refresh()
	end,
	args = {
		options = {
			type = "group",
			-- Add a " " to force this to be before the first group. HN arranges alphabetically on local language
			name = " " ..ns.L["Options"],
			inline = true,
			args = {
				iconScale = {
					type = "range",
					name = ns.L["Map Pin Size"],
					desc = ns.L["The Map Pin Size"],
					min = 1, max = 4, step = 0.1,
					arg = "iconScale",
					order = 1,
				},
				iconAlpha = {
					type = "range",
					name = ns.L["Map Pin Alpha"],
					desc = ns.L["The alpha transparency of the map pins"],
					min = 0, max = 1, step = 0.01,
					arg = "iconAlpha",
					order = 2,
				},
				showCoords = {
					name = ns.L["Show Coordinates"],
					desc = ns.L["Show Coordinates Description"] ..ns.colour.highlight .."\n(xx.xx,yy.yy)",
					type = "toggle",
					width = "full",
					arg = "showCoords",
					order = 3,
				},
				removeOneTime = {
					name = SubstitutePlayerOrElseAcct( "RWCQuestOneTime", true ),
					desc = SubstitutePlayerOrElseAcct( "RWCQuestOneTimeDesc", true ),
					type = "toggle",
					width = "full",
					arg = "removeOneTime",
					order = 4,
				},
				removeSeasonal = {
					name = SubstitutePlayerOrElseAcct( "RWCQuestSeasonal", true ),
					desc = SubstitutePlayerOrElseAcct( "RWCQuestSeasonalDesc", true ),
					type = "toggle",
					width = "full",
					arg = "removeSeasonal",
					order = 5,
				},
				removeAchieveChar = {
					name = SubstitutePlayerOrElseAcct( "RWCAchievements", true ),
					desc = SubstitutePlayerOrElseAcct( "RWCAchievementsDesc", true ),
					type = "toggle",
					width = "full",
					arg = "removeAchieveChar",
					order = 6,
				},
				removeAchieveAcct = {
					name = SubstitutePlayerOrElseAcct( "RWCAchievements" ),
					desc = SubstitutePlayerOrElseAcct( "RWCAchievementsDescAcct" ),
					type = "toggle",
					width = "full",
					arg = "removeAchieveAcct",
					order = 7,
				},
			},
		},
		icon = {
			type = "group",
			name = ns.L["Map Pin Selections"],
			inline = true,
			args = {
				iconZoneElders = {
					type = "range",
					name = ns.L["Zones"],
					desc = ns.iconStandard, 
					min = 1, max = 16, step = 1,
					arg = "iconZoneElders",
					order = 10,
				},
				iconDungeonElders = {
					type = "range",
					name = ns.L["Dungeons"],
					desc = ns.iconStandard, 
					min = 1, max = 16, step = 1,
					arg = "iconDungeonElders",
					order = 11,
				},
				iconFactionElders = {
					type = "range",
					name = ns.L["Factions"],
					desc = ns.iconStandard, 
					min = 1, max = 16, step = 1,
					arg = "iconFactionElders",
					order = 12,
				},
				iconPreservation = {
					type = "range",
					name = ns.L["Lunar Preservation"],
					desc = ns.iconStandard, 
					min = 1, max = 16, step = 1,
					arg = "iconPreservation",
					order = 13,
				},
				iconCrown = {
					type = "range",
					name = ns.L["Crown of... Quests"],
					desc = ns.iconStandard, 
					min = 1, max = 16, step = 1,
					arg = "iconCrown",
					order = 14,
				},
				iconSeasonal = {
					type = "range",
					name = ns.L["Seasonal"] .." " ..ns.L["Quests"],
					desc = ns.iconStandard, 
					min = 1, max = 16, step = 1,
					arg = "iconSeasonal",
					order = 15,
				},
				iconMeta = {
					type = "range",
					name = ns.L["HonorElders"],
					desc = ns.iconStandard, 
					min = 1, max = 16, step = 1,
					arg = "iconMeta",
					order = 16,
				},
				iconHistory = {
					type = "range",
					name = ns.L["History"],
					desc = ns.iconStandard, 
					min = 1, max = 16, step = 1,
					arg = "iconHistory",
					order = 17,
				},
				iconSpecial = {
					type = "range",
					name = ns.L["Special"],
					desc = ns.iconStandard, 
					min = 1, max = 16, step = 1,
					arg = "iconSpecial",
					order = 18,
				},
			},
		},
		notes = {
			type = "group",
			name = ns.L["Notes"],
			inline = true,
			args = {
				noteMenu = { type = "description", name = ns.L[ "MinimapMenu" ], order = 20, },
				separator1 = { type = "header", name = "", order = 21, },
				noteChat = { type = "description", name = ns.L[ "ChatCommands" ]
					..NORMAL_FONT_COLOR_CODE .."/lf" ..HIGHLIGHT_FONT_COLOR_CODE ..", "
					..NORMAL_FONT_COLOR_CODE .."/lunar" ..HIGHLIGHT_FONT_COLOR_CODE ..ns.L[ "ShowPanel" ],
					order = 22, },
			},
		},
	},
}

-- ---------------------------------------------------------------------------------------------------------------------------------

function HandyNotes_LunarFestival_OnAddonCompartmentClick( addonName, buttonName )
	Settings.OpenToCategory( "HandyNotes" )
	LibStub( "AceConfigDialog-3.0" ):SelectGroup( "HandyNotes", "plugins", "LunarFestival" )
 end

function HandyNotes_LunarFestival_OnAddonCompartmentEnter( ... )
	GameTooltip:SetOwner( MinimapCluster or AddonCompartmentFrame, "ANCHOR_LEFT" )	
	GameTooltip:AddLine( ns.colour.prefix ..ns.L[ "Lunar Festival" ] )
	GameTooltip:AddLine( ns.colour.highlight .." " )
	GameTooltip:AddDoubleLine( ns.colour.highlight ..ns.L[ "Left" ] .."/" ..ns.L[ "Right" ], ns.colour.plaintext
			..ns.L[ "Options" ] )
	GameTooltip:Show()
end

function HandyNotes_LunarFestival_OnAddonCompartmentLeave( ... )
	GameTooltip:Hide()
end

-- ---------------------------------------------------------------------------------------------------------------------------------

function pluginHandler:OnEnable()
	local HereBeDragons = LibStub( "HereBeDragons-2.0", true )
	if not HereBeDragons then return end
	
	for continentMapID in next, ns.continents do
		local children = C_Map.GetMapChildrenInfo(continentMapID, nil, true)
		for _, map in next, children do
			if ns.points[map.mapID] then
				-- Maps here will not propagate upwards
				if ( map.mapID == 33 ) or -- Blackrock Mountain - Blackrock Spire
					( map.mapID == 34 ) or -- Blackrock Mountain - Blackrock Caverns
					( map.mapID == 35 ) or -- Blackrock Mountain - Blackrock Depths					
					-- HandyNotes pins are incorrectly scaled for Khaz Algar and therefore Azeroth too
					-- So I had to do them manually
					( map.mapID == 2255 ) or -- Azj-Kahet
					( map.mapID == 2216 ) or -- City of Threads / Azj-Kahet - Lower
					( map.mapID == 2213 ) or -- City of Threads / Azj-Kahet
					( map.mapID == 2215 ) or -- Hallowfall
					( map.mapID == 2248 ) or -- Isle of Dorn
					( map.mapID == 2339 ) or -- City of Dornogal
					( map.mapID == 2214 ) or -- The Ringing Deeps
					( map.mapID == 2274 ) then -- Khaz Algar
				else
					for coord, v in next, ns.points[map.mapID] do
						if v.noContinent == nil then
							local mx, my = HandyNotes:getXY(coord)
							local cx, cy = HereBeDragons:TranslateZoneCoordinates(mx, my, map.mapID, continentMapID)
							if cx and cy then
								ns.points[continentMapID] = ns.points[continentMapID] or {}
								ns.points[continentMapID][HandyNotes:getCoord(cx, cy)] = v
							end
						end
					end
				end
			end
		end
	end
	HandyNotes:RegisterPluginDB( "LunarFestival", pluginHandler, ns.options )
	ns.db = LibStub( "AceDB-3.0" ):New( "HandyNotes_LunarFestivalDB", defaults, "Default" ).profile
	pluginHandler:Refresh()
end

function pluginHandler:Refresh()
	if GetTime() > ( ns.delay or 0 ) then
		ns.delay = nil
		self:SendMessage( "HandyNotes_NotifyUpdate", "LunarFestival" )
	end
end

LibStub( "AceAddon-3.0" ):NewAddon( pluginHandler, "HandyNotes_LunarFestivalDB", "AceEvent-3.0" )

-- ---------------------------------------------------------------------------------------------------------------------------------

ns.eventFrame = CreateFrame( "Frame" )

local function OnUpdate()
	if GetTime() > ( ns.timeSinceLastBuffCheck or 0 ) then
		ns.timeSinceLastBuffCheck = GetTime() + 1
		if ( IsOnQuest( 56842 ) == true ) then -- Lunar Preservation
			for i = 1, 40 do
				local aura = UnitAura( "player", i, "HELPFUL" )
				if not aura then break end
				if aura.spellId == 303601 then
					ns.lpBuffCount = aura.applications
					break
				end
			end
		else
			ns.lpBuffCount = 0
		end
	end
	
	if GetTime() > ( ns.saveTime or 0 ) then
		ns.saveTime = GetTime() + 5
		pluginHandler:Refresh()
	end
end

ns.eventFrame:SetScript( "OnUpdate", OnUpdate )

local function OnEventHandler( self, event, ... )
	if ( event == "PLAYER_ENTERING_WORLD" ) or ( event == "PLAYER_LEAVING_WORLD" ) then
		ns.delay = GetTime() + 60 -- Some arbitrary large amount
	elseif ( event == "SPELLS_CHANGED" ) then
		ns.delay = GetTime() + 5 -- Allow a 5 second safety buffer before we resume refreshes
	end
end

ns.eventFrame:RegisterEvent( "PLAYER_ENTERING_WORLD" )
ns.eventFrame:RegisterEvent( "PLAYER_LEAVING_WORLD" )
ns.eventFrame:RegisterEvent( "SPELLS_CHANGED" )
ns.eventFrame:SetScript( "OnEvent", OnEventHandler )

-- ---------------------------------------------------------------------------------------------------------------------------------

SLASH_LunarFestival1, SLASH_LunarFestival2 = "/lf", "/lunar"

local function Slash( options )

	Settings.OpenToCategory( "HandyNotes" )
	LibStub( "AceConfigDialog-3.0" ):SelectGroup( "HandyNotes", "plugins", "LunarFestival" )
	if ( ns.version >= 100000 ) then
		print( ns.colour.prefix ..ns.L[ "Lunar Festival" ] ..": " ..ns.colour.highlight ..ns.L[ "TryMinimapMenu" ] )
	end
end

SlashCmdList[ "LunarFestival" ] = function( options ) Slash( options ) end