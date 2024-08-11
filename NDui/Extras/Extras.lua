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
			func()
		end
	end

	self:ActionBarGlow()
	self:AutoHideName()
	self:CastAlert()
	self:InstanceAutoMarke()
	self:InstanceDifficulty()
	self:InstanceReset()
	self:MDEnhance()
end

-- 频道选择
function EX:GetMSGChannel()
	return (IsPartyLFG() and "INSTANCE_CHAT") or (IsInRaid() and "RAID") or "PARTY"
end

-- 副本重置自动喊话
function EX.UpdateInstanceReset(_, msg)
	if string.find(msg, "难度") or string.find(msg, "重置") then
		if not IsInGroup() then
			UIErrorsFrame:AddMessage(DB.InfoColor..msg)
		else
			SendChatMessage(msg, EX:GetMSGChannel())
		end
	end
end

function EX:InstanceReset()
	B:RegisterEvent("CHAT_MSG_SYSTEM", self.UpdateInstanceReset)
end

-- 副本难度自动喊话
function EX.UpdateInstanceDifficulty()
	C_Timer.After(.5, function()
		if IsInInstance() then
			local _, instanceType, difficultyID, difficultyName = GetInstanceInfo()
			if instanceType == "party" then
				if difficultyID == 8 then
					difficultyName = difficultyName..":"..C_ChallengeMode.GetActiveKeystoneInfo()
				end
				if not IsInGroup() then
					UIErrorsFrame:AddMessage(format(DB.InfoColor..L["Instance Difficulty"], difficultyName))
				else
					SendChatMessage(format(L["Instance Difficulty"], difficultyName), EX:GetMSGChannel())
				end
			end
		end
	end)
end

function EX:InstanceDifficulty()
	B:RegisterEvent("PLAYER_ENTERING_WORLD", EX.UpdateInstanceDifficulty)
end

-- 进本自动标记坦克和治疗
function EX.UpdateInstanceAutoMarke()
	if IsInInstance() and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
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
end

function EX:InstanceAutoMarke()
	B:RegisterEvent("UPDATE_INSTANCE_INFO", self.UpdateInstanceAutoMarke)
end

-- 自动隐藏名字，防止卡屏
function EX.UpdateAutoHideName()
	SetCVar("UnitNameEnemyMinionName", 0)
	SetCVar("UnitNameEnemyPetName", 0)
	SetCVar("UnitNameEnemyPlayerName", 0)
	SetCVar("UnitNameEnemyTotemName", 0)
	SetCVar("UnitNameFriendlyMinionName", 0)
	SetCVar("UnitNameFriendlyPetName", 0)
	SetCVar("UnitNameFriendlyPlayerName", 0)
	SetCVar("UnitNameFriendlyTotemName", 0)
end

function EX:AutoHideName()
	B:RegisterEvent("PLAYER_ENTERING_WORLD", self.UpdateAutoHideName)
end

-- 自动选择节日BOSS
do
	local function autoSelect()
		for i = 1, GetNumRandomDungeons() do
			local id, name = GetLFGRandomDungeonInfo(i)
			local isHoliday = select(15, GetLFGDungeonInfo(id))
			if isHoliday and not GetLFGDungeonRewards(id) then
				LFDQueueFrame_SetType(id)
			end
		end
	end

	LFDParentFrame:HookScript("OnShow", autoSelect)
end

-- 修复金币文本显示问题
do
	local function resizeMoneyText(frameName, money, forceShow)
		local frame
		if type(frameName) == "table" then
			frame = frameName
			frameName = frame:GetDebugName()
		else
			frame = _G[frameName]
		end
		if not frame.info then return end

		local iconWidth = MONEY_ICON_WIDTH
		if frame.small then
			iconWidth = MONEY_ICON_WIDTH_SMALL
		end

		if ENABLE_COLORBLIND_MODE ~= "1" then
			if (not frame.colorblind) or (not frame.vadjust) or (frame.vadjust ~= MONEY_TEXT_VADJUST) then
				_G[frameName.."GoldButtonText"]:SetPoint("RIGHT", -iconWidth, 0)
				_G[frameName.."SilverButtonText"]:SetPoint("RIGHT", -iconWidth, 0)
				_G[frameName.."CopperButtonText"]:SetPoint("RIGHT", -iconWidth, 0)
			end
		end
	end

	hooksecurefunc("MoneyFrame_Update", resizeMoneyText)
end

-- 格式化死亡摘要
do
	local function formatDeathRecap(_, addon)
		if addon == "Blizzard_DeathRecap" then
			hooksecurefunc("DeathRecapFrame_OpenRecap", function(recapID)
				local self = DeathRecapFrame
				local events = DeathRecap_GetEvents(recapID)
				local maxHp = UnitHealthMax("player")

				for i = 1, #events do
					local entry = self.DeathRecapEntry[i]
					local dmgInfo = entry.DamageInfo
					local evtData = events[i]

					if evtData.amount then
						local amountStr = "-"..B.Numb(evtData.amount)
						dmgInfo.Amount:SetText(amountStr)
						dmgInfo.AmountLarge:SetText(amountStr)
						dmgInfo.amount = B.Numb(evtData.amount)

						dmgInfo.dmgExtraStr = ""
						if evtData.overkill and evtData.overkill > 0 then
							dmgInfo.dmgExtraStr = format(TEXT_MODE_A_STRING_RESULT_OVERKILLING, B.Numb(evtData.overkill))
							dmgInfo.amount = B.Numb(evtData.amount - evtData.overkill)
						end
						if evtData.absorbed and evtData.absorbed > 0 then
							dmgInfo.dmgExtraStr = dmgInfo.dmgExtraStr..format(TEXT_MODE_A_STRING_RESULT_ABSORB, B.Numb(evtData.absorbed))
							dmgInfo.amount = B.Numb(evtData.amount - evtData.absorbed)
						end
						if evtData.resisted and evtData.resisted > 0 then
							dmgInfo.dmgExtraStr = dmgInfo.dmgExtraStr..format(TEXT_MODE_A_STRING_RESULT_RESIST, B.Numb(evtData.resisted))
							dmgInfo.amount = B.Numb(evtData.amount - evtData.resisted)
						end
						if evtData.blocked and evtData.blocked > 0 then
							dmgInfo.dmgExtraStr = dmgInfo.dmgExtraStr..format(TEXT_MODE_A_STRING_RESULT_BLOCK, B.Numb(evtData.blocked))
							dmgInfo.amount = B.Numb(evtData.amount - evtData.blocked)
						end
					end

					dmgInfo.hpPercent = format("%.1f", evtData.currentHP / maxHp * 100)
				end
			end)
		end
	end

	B:RegisterEvent("ADDON_LOADED", formatDeathRecap)
end