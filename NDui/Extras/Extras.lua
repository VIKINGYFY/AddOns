local _, ns = ...
local B, C, L, DB = unpack(ns)
local EX = B:RegisterModule("Extras")

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
	self:FocusNotices()
	self:InstanceSomething()
	self:LFGActivityNotices()
	self:NewGetMapUIInfo()
	self:SystemNotices()
	self:RoleConfirm()

	self:ActionBarGlow()
	self:MDEnhance()
	self:MountSource()

	if C.db["Misc"]["MerchantConfirm"] then self:MerchantConfirm() end
	if DB.isDeveloper then self:AutoHideName() end
end

-- 自动隐藏名字，防止卡屏
function EX:AutoHideName()
	SetCVar("UnitNameEnemyGuardianName", 0)
	SetCVar("UnitNameEnemyMinionName", 0)
	SetCVar("UnitNameEnemyPetName", 0)
	SetCVar("UnitNameEnemyPlayerName", 0)
	SetCVar("UnitNameEnemyTotemName", 0)
	SetCVar("UnitNameFriendlyGuardianName", 0)
	SetCVar("UnitNameFriendlyMinionName", 0)
	SetCVar("UnitNameFriendlyPetName", 0)
	SetCVar("UnitNameFriendlyPlayerName", 0)
	SetCVar("UnitNameFriendlyTotemName", 0)
	SetCVar("UnitNameInteractiveNPC", 1)
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
				C_ChatInfo.SendChatMessage(text, B.GetCurrentChannel())
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
					C_ChatInfo.SendChatMessage(text, B.GetCurrentChannel())
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

function EX:InstanceSomething()
	B:RegisterEvent("PLAYER_DIFFICULTY_CHANGED", EX.UpdateInstanceTools)
	B:RegisterEvent("PLAYER_ENTERING_WORLD", EX.UpdateInstanceTools)
end

-- 自动确认出售可交易物品提示
function EX.UpdateMerchantConfirm()
	hooksecurefunc("StaticPopup_Show", function(name, ...)
		if name == "CONFIRM_MERCHANT_TRADE_TIMER_REMOVAL" then
			StaticPopup1Button1:Click() -- 自动点击“确定”按钮
		end
	end)
end

function EX:MerchantConfirm()
	B:RegisterEvent("MERCHANT_SHOW", EX.UpdateMerchantConfirm)
end

-- 自动确认职责
local RoleConfirmEnabled = true
function EX.UpdateRoleConfirm()
	if RoleConfirmEnabled then
		if LFDRoleCheckPopup:IsShown() and LFDRoleCheckPopupAcceptButton:IsEnabled() then
			LFDRoleCheckPopupAcceptButton:Click()
		end
	end
end

function EX:RoleConfirm()
	local bu = B.CreateCheckBox(LFGListFrame.SearchPanel, true)
	bu:SetPoint("LEFT", LFGListFrame.SearchPanel.CategoryName, "LEFT", 50, 0)
	bu:SetSize(26, 26)
	bu:SetChecked(RoleConfirmEnabled)
	bu.text = B.CreateFS(bu, 14, "自动确认职责", "system", "LEFT", 25, 0)

	bu:SetScript("OnClick", function(self)
		RoleConfirmEnabled = self:GetChecked()
	end)

	LFDRoleCheckPopup:HookScript("OnShow", EX.UpdateRoleConfirm)
end

-- 打印申请加入的活动
function EX.UpdateLFGActivityNotices(event, resultID, newStatus, oldStatus, groupName)
	if not resultID or newStatus ~= "inviteaccepted" then return end

	local info = C_LFGList.GetSearchResultInfo(resultID)
	if info and info.activityIDs and #info.activityIDs > 0 then
		local activityID = info.activityIDs[1]
		local fullName = C_LFGList.GetActivityFullName(activityID)
		local text = format("%s: %s %s %s %s", CLUB_FINDER_ACCEPTED, fullName or UNKNOWN, info.name or UNKNOWN, info.leaderName or UNKNOWN, info.leaderOverallDungeonScore or UNKNOWN)

		UIErrorsFrame:AddMessage(DB.InfoColor..text)
		print(DB.InfoColor..text)
	end
end

function EX:LFGActivityNotices()
	B:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED", EX.UpdateLFGActivityNotices)
end

-- 焦点打断提示
function EX.UpdateFocusNotices()
	if not (UnitExists("focus") and IsInInstance() and IsInGroup()) then return end

	local focusName = UnitName("focus")
	local focusIcon = GetRaidTargetIndex("focus")

	if not focusIcon then
		if not IsInGroup() or (IsInGroup() and not IsInRaid()) or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
			focusIcon = 7
			SetRaidTarget("focus", focusIcon)
		end
	end

	C_ChatInfo.SendChatMessage(format("我负责打断<%s%s>!", focusIcon and "{rt"..focusIcon.."}" or "", focusName), B.GetCurrentChannel())
end

function EX:FocusNotices()
	B:RegisterEvent("PLAYER_FOCUS_CHANGED", EX.UpdateFocusNotices)
end

-- 精简name
function EX:NewGetMapUIInfo()
	local Old_GetMapUIInfo = C_ChallengeMode.GetMapUIInfo

	function C_ChallengeMode.GetMapUIInfo(challengeMapID)
		local name, id, timeLimit, texture, backgroundTexture, mapID = Old_GetMapUIInfo(challengeMapID)
		if name then name = B.ReplaceText(name) end

		return name, id, timeLimit, texture, backgroundTexture, mapID
	end
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
B:LoadAddOns("Blizzard_MacroUI", EX.ExtMacroUI)

-- 自定义API
do
	function EX.isCollection(itemID, itemClassID, itemSubClassID)
		return (itemID and C_ToyBox.GetToyInfo(itemID)) or (DB.MiscellaneousIDs[itemClassID] and DB.CollectionIDs[itemSubClassID])
	end

	function EX.isEquipment(itemID, itemClassID)
		return (itemID and (C_ArtifactUI.GetRelicInfoByItemID(itemID) or C_Soulbinds.IsItemConduitByItemInfo(itemID))) or (itemClassID and DB.EquipmentIDs[itemClassID])
	end
end
