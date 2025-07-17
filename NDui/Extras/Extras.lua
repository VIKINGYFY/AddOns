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
	self:SystemSomething()

	self:ActionBarGlow()
	self:MDEnhance()

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
function EX.UpdateSystemSomething(_, text)
	if string.find(text, "难度") or string.find(text, "重置") or string.find(text, "掷出") then
		if text ~= lastInfo then
			if not IsInGroup() then
				UIErrorsFrame:AddMessage(DB.InfoColor..text)
			else
				SendChatMessage(text, B.GetMSGChannel())
			end

			lastInfo = text -- 记录新内容
		end
	end
end

function EX:SystemSomething()
	B:RegisterEvent("CHAT_MSG_SYSTEM", self.UpdateSystemSomething)
end

-- 副本自动标记坦克和治疗
function EX.UpdateInstanceMarke()
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

function EX:InstanceSomething()
	B:RegisterEvent("PLAYER_ENTERING_WORLD", EX.UpdateInstanceMarke)
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
