local _, ns = ...
local B, C, L, DB = unpack(ns)
local EX = B:GetModule("Extras")

local TeleportList = {
	[  2] = 131204, -- 青龙寺
	[165] = 159899, -- 影月墓地
	[168] = 159901, -- 永茂林地
	[198] = 424163, -- 黑心林地
	[199] = 424153, -- 黑鸦堡垒
	[200] = 393764, -- 英灵殿
	[206] = 410078, -- 奈萨里奥的巢穴
	[210] = 393766, -- 群星庭院
	[244] = 424187, -- 阿塔达萨
	[245] = 410071, -- 自由镇
	[248] = 424167, -- 维克雷斯庄园
	[251] = 410074, -- 地渊孢林
	[399] = 393256, -- 红玉新生法池
	[400] = 393262, -- 诺库德阻击战
	[401] = 393279, -- 碧蓝魔馆
	[402] = 393273, -- 艾杰斯亚学院
	[403] = 393222, -- 奥达曼：提尔的遗产
	[404] = 393276, -- 奈萨鲁斯
	[405] = 393267, -- 蕨皮山谷
	[406] = 393283, -- 注能大厅
	[438] = 410080, -- 旋云之巅
	[456] = 424142, -- 潮汐王座
	[463] = 424197, -- 永恒黎明：迦拉克隆的陨落
	[464] = 424197, -- 永恒黎明：姆诺兹多的崛起
}

function EX:MDEnhance_TButtonOnEnter(parent, spellID)
	local dungeonIcon = parent:GetParent()
	if not dungeonIcon then return end

	local dungeonIcon_OnEnter = dungeonIcon:GetScript("OnEnter")
	if dungeonIcon_OnEnter then dungeonIcon_OnEnter(dungeonIcon) end

	local _, _, timeLimit = C_ChallengeMode.GetMapUIInfo(dungeonIcon.mapID)
	GameTooltip:AddLine(L["+2timeLimit"]..SecondsToClock(timeLimit*.8), 1, 1, 1)
	GameTooltip:AddLine(L["+3timeLimit"]..SecondsToClock(timeLimit*.6), 1, 1, 1)

	if IsSpellKnown(spellID) then
		local name = C_Spell.GetSpellName(spellID)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(name)

		local CDInfo = C_Spell.GetSpellCooldown(spellID)
		local start, duration = CDInfo.startTime, CDInfo.duration

		if not start or not duration then
			GameTooltip:AddLine(SPELL_FAILED_NOT_KNOWN, 1, 0, 0)
		elseif duration == 0 then
			GameTooltip:AddLine(READY, 0, 1, 0)
		else
			GameTooltip:AddLine(SecondsToTime(ceil(start + duration - GetTime())), 1, 1, 0)
		end
	else
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(SPELL_FAILED_NOT_KNOWN, 1, 0, 0)
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L["MapID"]..dungeonIcon.mapID, 1, 1, 1)

	GameTooltip:Show()
end

function EX:MDEnhance_TButtonOnLeave(parent)
	GameTooltip:Hide()
end

function EX:MDEnhance_UpdateScoreInfo(parent)
	if not parent then return end

	local affixScores, bestScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(parent.mapID)
	if not affixScores or not bestScore then return end

	parent.BScore:SetText(bestScore or "")
	parent.BScore:SetTextColor(0, 1, 0)

	parent.FScore:SetText(affixScores[1] and affixScores[1].score or "")
	parent.FScore:SetTextColor(1, 1, 0)

	parent.TScore:SetText(affixScores[2] and affixScores[2].score or "")
	parent.TScore:SetTextColor(0, 1, 1)
end

function EX:MDEnhance_CreateEnhance(parent, spellID)
	if not parent or not spellID then return end

	local TButton = CreateFrame("Button", nil, parent, "InsecureActionButtonTemplate")
	TButton:SetAllPoints(parent)
	TButton:RegisterForClicks("AnyDown", "AnyUp")
	TButton:SetAttribute("type", "spell")
	TButton:SetAttribute("spell", spellID)
	TButton:SetScript("OnEnter", function(parent) EX:MDEnhance_TButtonOnEnter(parent, spellID) end)
	TButton:SetScript("OnLeave", function(parent) EX:MDEnhance_TButtonOnLeave(parent) end)

	parent.TButton = TButton
	parent.BScore = B.CreateFS(parent, 16, "", false, "CENTER", 0, 0)
	parent.FScore = B.CreateFS(parent, 16, "", false, "BOTTOMLEFT", 0, 0)
	parent.TScore = B.CreateFS(parent, 16, "", false, "BOTTOMRIGHT", 0, 0)
end

function EX.MDEnhance_OnCreate()
	if InCombatLockdown() or not ChallengesFrame or not ChallengesFrame.DungeonIcons then return end

	for _, dungeonIcon in next, ChallengesFrame.DungeonIcons do
		if not dungeonIcon.TButton then
			EX:MDEnhance_CreateEnhance(dungeonIcon, TeleportList[dungeonIcon.mapID])
		end
		EX:MDEnhance_UpdateScoreInfo(dungeonIcon)
	end
end

function EX.MDEnhance_OnEvent(event, addon)
	if addon == "Blizzard_ChallengesUI" then
		hooksecurefunc(ChallengesFrame, "Update", EX.MDEnhance_OnCreate)
		B:UnregisterEvent(event, EX.MDEnhance_OnEvent)
	end
end

function EX:MDEnhance()
	B:RegisterEvent("ADDON_LOADED", EX.MDEnhance_OnEvent)
end