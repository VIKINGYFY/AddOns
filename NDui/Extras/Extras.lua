local _, ns = ...
local B, C, L, DB = unpack(ns)
local EX = B:RegisterModule("Extras")
local S = B:GetModule("Skins")

local EX_LIST = {}

function EX:RegisterExtra(name, func)
	if not EX_LIST[name] then
		EX_LIST[name] = func
	end
end

function EX:OnLogin()
	for name, func in pairs(EX_LIST) do
		if name and type(func) == "function" then
			xpcall(func, geterrorhandler())
		end
	end

	self:DisableSomething()
	self:InstanceSomething()
	self:LFGActivityNotices()
	self:SystemNotices()

	self:ActionBarGlow()
	self:MDEnhance()
	self:MountSource()

	if C.db["Misc"]["AutoConfirm"] then self:AutoConfirm() end
	if DB.isDeveloper then self:AutoHideName() end
end

-- 自动隐藏名字，防止卡屏
function EX:AutoHideName()
	SetCVar("UnitNameEnemyMinionName", 0)
	SetCVar("UnitNameEnemyPetName", 0)
	SetCVar("UnitNameEnemyPlayerName", 0)
	SetCVar("UnitNameEnemyTotemName", 0)
	SetCVar("UnitNameFriendlyMinionName", 0)
	SetCVar("UnitNameFriendlyPetName", 0)
	SetCVar("UnitNameFriendlyPlayerName", 0)
	SetCVar("UnitNameFriendlyTotemName", 0)
end

-- 禁用奇怪的东西
function EX:DisableSomething()
	-- 公会过滤
	for i=1, 9 do
		SetGuildNewsFilter(i, 0)
	end

	-- 插件性能统计
	C_AddOnProfiler.IsEnabled = function() return false end
end

-- 系统信息通报
local lastInfo
function EX.UpdateSystemNotices(_, text)
	if string.find(text, "难度") or string.find(text, "重置") or string.find(text, "掷出") then
		if text ~= lastInfo then
			if not IsInGroup() then
				UIErrorsFrame:AddMessage(DB.InfoColor..text)
			else
				SendChatMessage(text, B.GetCurrentChannel())
			end

			lastInfo = text -- 记录新内容
		end
	end
end

function EX:SystemNotices()
	B:RegisterEvent("CHAT_MSG_SYSTEM", self.UpdateSystemNotices)
end

-- 副本工具箱：
-- 1、进本通报难度。
-- 2、进本自动标记坦克治疗（需队长权限）。
-- 3、出本自动重置副本（在队伍里需要队长权限）。
local instCache = {}
local isChallengeModeCompleted
function EX.UpdateInstanceTools()
	if IsInInstance() then
		C_Timer.After(1, function()
			local _, _, diffID, diffName, _, _, _, instID = GetInstanceInfo()
			if not instCache[instID] or instCache[instID] ~= diffID then
				local text = format("当前难度：%s", diffName)
				if diffID == 8 then
					local activeLevel = C_ChallengeMode.GetActiveKeystoneInfo()
					text = format("当前难度：%s - %s", diffName, activeLevel)
				end

				if not IsInGroup() then
					UIErrorsFrame:AddMessage(DB.InfoColor..text)
				else
					SendChatMessage(text, B.GetCurrentChannel())
				end

				instCache[instID] = diffID
			end

			if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
				for i = 1, 5 do
					local unit = (i == 5 and "player") or ("party"..i)
					local role = UnitGroupRolesAssigned(unit)
					if role == "TANK" then
						SetRaidTarget(unit, 6)
					elseif role == "HEALER" then
						SetRaidTarget(unit, 5)
					end
				end
			end
		end)
	else
		C_Timer.After(5, function()
			if isChallengeModeCompleted and (not IsInGroup() or (IsInGroup() and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")))) then
				ResetInstances()
				print(DB.InfoColor..RESET..INSTANCE)
				isChallengeModeCompleted = false
			end
		end)
	end
end

-- 大米结束以后提示洗钥匙
function EX.UpdateChallengeModeNotices()
	SendChatMessage("各位辛苦了，记得 洗钥匙 ！！", B.GetCurrentChannel())
	isChallengeModeCompleted = true
end

function EX:InstanceSomething()
	B:RegisterEvent("CHALLENGE_MODE_COMPLETED", EX.UpdateChallengeModeNotices)

	B:RegisterEvent("PLAYER_DIFFICULTY_CHANGED", EX.UpdateInstanceTools)
	B:RegisterEvent("PLAYER_ENTERING_WORLD", EX.UpdateInstanceTools)
end

-- 自动确认出售可交易物品提示
function EX.UpdateAutoConfirm()
	hooksecurefunc("StaticPopup_Show", function(name, ...)
		if name == "CONFIRM_MERCHANT_TRADE_TIMER_REMOVAL" then
			StaticPopup1Button1:Click() -- 自动点击“确定”按钮
		end
	end)
end

function EX:AutoConfirm()
	B:RegisterEvent("MERCHANT_SHOW", EX.UpdateAutoConfirm)
end

-- 打印申请加入的活动
function EX.UpdateLFGActivityNotices(event, resultID, newStatus, oldStatus, groupName)
	if not resultID or newStatus ~= "inviteaccepted" then return end

	local info = C_LFGList.GetSearchResultInfo(resultID)
	if info and info.activityIDs and #info.activityIDs > 0 then
		local activityID = info.activityIDs[1]
		local name = C_LFGList.GetActivityFullName(activityID)
		local text = format("%s: %s - %s", CLUB_FINDER_ACCEPTED, name or UNKNOWN, groupName or UNKNOWN)

		UIErrorsFrame:AddMessage(DB.InfoColor..text)
		print(DB.InfoColor..text)
	end
end

function EX:LFGActivityNotices()
	B:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED", EX.UpdateLFGActivityNotices)
end

-- 宏界面扩展
function EX.ExtMacroUI()
	_G.MacroFrame:SetHeight(624)
	_G.MacroFrameScrollFrame:SetHeight(185)
	_G.MacroFrameText:SetHeight(185)
	_G.MacroFrameTextButton:SetHeight(185)
	_G.MacroFrameTextBackground:SetHeight(195)
	_G.MacroFrame.MacroSelector:SetHeight(246)

	_G.MacroHorizontalBarLeft:SetPoint("TOPLEFT", 2, -310)
	_G.MacroFrameTextBackground:SetPoint("TOPLEFT", 6, -389)
	_G.MacroFrameSelectedMacroBackground:SetPoint("TOPLEFT", 2, -318)
end
S:LoadSkins("Blizzard_MacroUI", EX.ExtMacroUI)

-- 自定义API
do
	function EX.isCollection(itemID, itemClassID, itemSubClassID)
		return (itemID and C_ToyBox.GetToyInfo(itemID)) or (DB.MiscellaneousIDs[itemClassID] and DB.CollectionIDs[itemSubClassID])
	end

	function EX.isEquipment(itemID, itemClassID)
		return (itemID and (C_ArtifactUI.GetRelicInfoByItemID(itemID) or C_Soulbinds.IsItemConduitByItemInfo(itemID))) or (itemClassID and DB.EquipmentIDs[itemClassID])
	end
end
