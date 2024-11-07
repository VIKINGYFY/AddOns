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
	self:InstanceAutoMarke()
	self:InstanceDifficulty()
	self:InstanceReset()
	self:MDEnhance()
end

-- 副本重置自动喊话
function EX.UpdateInstanceReset(_, msg)
	if not IsInInstance() then
		if string.find(msg, "难度") or string.find(msg, "重置") then
			if not IsInGroup() then
				UIErrorsFrame:AddMessage(DB.InfoColor..msg)
			else
				SendChatMessage(msg, B.GetMSGChannel())
			end
		end
	end
end

function EX:InstanceReset()
	B:RegisterEvent("CHAT_MSG_SYSTEM", self.UpdateInstanceReset)
end

-- 副本难度自动喊话
function EX.UpdateInstanceDifficulty()
	C_Timer.After(1, function()
		if IsInInstance() then
			local _, instanceType, difficultyID, difficultyName = GetInstanceInfo()
			if instanceType == "party" then
				if difficultyID == 8 then
					difficultyName = difficultyName..":"..C_ChallengeMode.GetActiveKeystoneInfo()
				end
				if not IsInGroup() then
					UIErrorsFrame:AddMessage(format(DB.InfoColor..L["Instance Difficulty"], difficultyName))
				else
					SendChatMessage(format(L["Instance Difficulty"], difficultyName), B.GetMSGChannel())
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
