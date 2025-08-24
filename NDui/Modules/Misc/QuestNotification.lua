local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local soundKitID = SOUNDKIT.ALARM_CLOCK_WARNING_3
local LE_QUEST_TAG_TYPE_PROFESSION = Enum.QuestTagType.Profession
local LE_QUEST_FREQUENCY_DAILY = Enum.QuestFrequency.Daily

local completedQuest, initComplete = {}

local function GetQuestLinkOrName(questID)
	return GetQuestLink(questID) or C_QuestLog.GetTitleForQuestID(questID) or ""
end

local function acceptText(questID, daily)
	local title = GetQuestLinkOrName(questID)
	if daily then
		return format("%s [%s]%s", L["AcceptQuest"], DAILY, title)
	else
		return format("%s %s", L["AcceptQuest"], title)
	end
end

local function completeText(questID)
	PlaySound(soundKitID, "Master")
	return format("%s %s", GetQuestLinkOrName(questID), QUEST_COMPLETE)
end

local function sendQuestMsg(msg)
	if C.db["Misc"]["OnlyCompleteRing"] then return end

	if DB.isDeveloper then
		print(msg)
	elseif (IsPartyLFG() or C_PartyInfo.IsPartyWalkIn()) then
		C_ChatInfo.SendChatMessage(msg, "INSTANCE_CHAT")
	elseif IsInRaid() then
		C_ChatInfo.SendChatMessage(msg, "RAID")
	elseif IsInGroup() then
		C_ChatInfo.SendChatMessage(msg, "PARTY")
	end
end

local function getPattern(pattern)
	pattern = string.gsub(pattern, "%(", "%%%1")
	pattern = string.gsub(pattern, "%)", "%%%1")
	pattern = string.gsub(pattern, "%%%d?$?.", "(.+)")
	return format("^%s$", pattern)
end

local questMatches = {
	["Found"] = getPattern(ERR_QUEST_ADD_FOUND_SII),
	["Item"] = getPattern(ERR_QUEST_ADD_ITEM_SII),
	["Kill"] = getPattern(ERR_QUEST_ADD_KILL_SII),
	["PKill"] = getPattern(ERR_QUEST_ADD_PLAYER_KILL_SII),
	["ObjectiveComplete"] = getPattern(ERR_QUEST_OBJECTIVE_COMPLETE_S),
	["QuestComplete"] = getPattern(ERR_QUEST_COMPLETE_S),
	["QuestFailed"] = getPattern(ERR_QUEST_FAILED_S),
}

function M:FindQuestProgress(_, msg)
	if not C.db["Misc"]["QuestProgress"] then return end
	if C.db["Misc"]["OnlyCompleteRing"] then return end

	for _, pattern in pairs(questMatches) do
		if string.match(msg, pattern) then
			local _, _, _, cur, max = string.find(msg, "(.*)[:：]%s*([-%d]+)%s*/%s*([-%d]+)%s*$")
			cur, max = tonumber(cur), tonumber(max)
			if cur and max and max >= 10 then
				if cur % math.floor(max/5) == 0 then
					sendQuestMsg(msg)
				end
			else
				sendQuestMsg(msg)
			end
			break
		end
	end
end

local WQcache = {}
function M:FindQuestAccept(questID)
	if not questID then return end
	if C_QuestLog.IsWorldQuest(questID) and WQcache[questID] then return end
	WQcache[questID] = true

	local tagInfo = C_QuestLog.GetQuestTagInfo(questID)
	if tagInfo and tagInfo.worldQuestType == LE_QUEST_TAG_TYPE_PROFESSION then return end

	local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
	if questLogIndex then
		local info = C_QuestLog.GetInfo(questLogIndex)
		if info then
			sendQuestMsg(acceptText(questID, info.frequency == LE_QUEST_FREQUENCY_DAILY))
		end
	end
end

function M:FindQuestComplete()
	for i = 1, C_QuestLog.GetNumQuestLogEntries() do
		local questID = C_QuestLog.GetQuestIDForLogIndex(i)
		local isComplete = questID and C_QuestLog.IsComplete(questID)
		if isComplete and not completedQuest[questID] and not C_QuestLog.IsWorldQuest(questID) then
			if initComplete then
				sendQuestMsg(completeText(questID))
			end
			completedQuest[questID] = true
		end
	end
	initComplete = true
end

function M:FindWorldQuestComplete(questID)
	if C_QuestLog.IsWorldQuest(questID) then
		if questID and not completedQuest[questID] then
			sendQuestMsg(completeText(questID))
			completedQuest[questID] = true
		end
	end
end

-- Dragon glyph notification
local glyphAchievements = {
	[16575] = true, -- 觉醒海岸
	[16576] = true, -- 欧恩哈拉平原
	[16577] = true, -- 碧蓝林海
	[16578] = true, -- 索德拉苏斯
}

function M:FindDragonGlyph(achievementID, criteriaString)
	if glyphAchievements[achievementID] then
		sendQuestMsg(criteriaString.." "..COLLECTED)
	end
end

function M:QuestNotification()
	if C.db["Misc"]["QuestNotification"] then
		B:RegisterEvent("QUEST_ACCEPTED", M.FindQuestAccept)
		B:RegisterEvent("QUEST_LOG_UPDATE", M.FindQuestComplete)
		B:RegisterEvent("QUEST_TURNED_IN", M.FindWorldQuestComplete)
		B:RegisterEvent("UI_INFO_MESSAGE", M.FindQuestProgress)
		B:RegisterEvent("CRITERIA_EARNED", M.FindDragonGlyph)
	else
		table.wipe(completedQuest)
		B:UnregisterEvent("QUEST_ACCEPTED", M.FindQuestAccept)
		B:UnregisterEvent("QUEST_LOG_UPDATE", M.FindQuestComplete)
		B:UnregisterEvent("QUEST_TURNED_IN", M.FindWorldQuestComplete)
		B:UnregisterEvent("UI_INFO_MESSAGE", M.FindQuestProgress)
		B:UnregisterEvent("CRITERIA_EARNED", M.FindDragonGlyph)
	end
end
M:RegisterMisc("QuestNotification", M.QuestNotification)