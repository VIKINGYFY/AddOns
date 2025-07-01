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

-- 宏界面扩展和修复
do
	local AddSelectHeight = 100
	local AddTextHeight = 100
	local tempScrollPer = nil
	local function Init()
		hooksecurefunc(MacroFrame, "SelectMacro", function(self, index)
			if tempScrollPer then
				MacroFrame.MacroSelector.ScrollBox:SetScrollPercentage(tempScrollPer)
				tempScrollPer = nil
			end
		end)
		MacroFrame.MacroSelector:SetHeight(146 + AddSelectHeight)
		MacroHorizontalBarLeft:SetPoint("TOPLEFT", 2, -210 - AddSelectHeight)
		MacroFrameSelectedMacroBackground:SetPoint("TOPLEFT", 2, -218 - AddSelectHeight)
		MacroFrameTextBackground:SetPoint("TOPLEFT", 6, -289 - AddSelectHeight)
		local h = MacroFrame:GetHeight()
		MacroFrame:SetHeight(h + AddTextHeight + AddSelectHeight)
		MacroFrameScrollFrame:SetHeight(85 + AddTextHeight)
		MacroFrameText:SetHeight(85 + AddTextHeight)
		MacroFrameTextButton:SetHeight(85 + AddTextHeight)
		MacroFrameTextBackground:SetHeight(95 + AddTextHeight)
	end

	if MacroFrame then
		Init()
	else
		local f = CreateFrame("Frame")
		f:SetScript("OnEvent", function(self, evnet, addon)
			if evnet == "ADDON_LOADED" then
				if addon == "Blizzard_MacroUI" then
					Init()
					f:UnregisterEvent("ADDON_LOADED")
				end
			elseif MacroFrame then
				tempScrollPer = MacroFrame.MacroSelector.ScrollBox.scrollPercentage
			end
		end)
		f:RegisterEvent("ADDON_LOADED")
		f:RegisterEvent("UPDATE_MACROS")
	end
end
