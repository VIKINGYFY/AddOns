local _, ns = ...
local B, C, L, DB = unpack(ns)
if not C.Infobar.System then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar("Fps", C.Infobar.SystemPos)

local showMoreString = "%d %s (%s)"
local usageString = "%.3f ms"
local scriptProfileStatus = GetCVarBool("scriptProfile")
local entered

local function formatMemory(value)
	if value > 1024 then
		return format("%.1f mb", value / 1024)
	else
		return format("%.0f kb", value)
	end
end

local function sortByMemory(a, b)
	if a and b then
		return (a[3] == b[3] and a[2] < b[2]) or a[3] > b[3]
	end
end

local function sortByCPU(a, b)
	if a and b then
		return (a[4] == b[4] and a[2] < b[2]) or a[4] > b[4]
	end
end

local infoTable = {}
local function BuildAddonList()
	local numAddons = C_AddOns.GetNumAddOns()
	if numAddons == #infoTable then return end

	table.wipe(infoTable)
	for i = 1, numAddons do
		local _, title, _, loadable = C_AddOns.GetAddOnInfo(i)
		if loadable then
			table.insert(infoTable, {i, title, 0, 0})
		end
	end
end

local function UpdateMemory()
	UpdateAddOnMemoryUsage()

	local total = 0
	for _, data in ipairs(infoTable) do
		if C_AddOns.IsAddOnLoaded(data[1]) then
			local mem = GetAddOnMemoryUsage(data[1])
			data[3] = mem
			total = total + mem
		end
	end
	table.sort(infoTable, sortByMemory)

	return total
end

local function UpdateCPU()
	UpdateAddOnCPUUsage()

	local total = 0
	for _, data in ipairs(infoTable) do
		if C_AddOns.IsAddOnLoaded(data[1]) then
			local addonCPU = GetAddOnCPUUsage(data[1])
			data[4] = addonCPU
			total = total + addonCPU
		end
	end
	table.sort(infoTable, sortByCPU)

	return total
end

local function colorFPS(fps)
	if fps < 30 then
		return "|cffFF0000"..fps.."|r"
	elseif fps < 60 then
		return "|cffFFFF00"..fps.."|r"
	else
		return "|cff00FF00"..fps.."|r"
	end
end

local function setFrameRate(self)
	local fps = math.floor(GetFramerate())
	self.text:SetFormattedText("%s: %s", L["FPS"], colorFPS(fps))
end

info.onUpdate = function(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer > 1 then
		setFrameRate(self)
		if entered then self:onEnter() end

		self.timer = 0
	end
end

info.onEnter = function(self)
	entered = true

	if not next(infoTable) then BuildAddonList() end
	local isShiftKeyDown = IsShiftKeyDown()
	local maxAddOns = C.db["Misc"]["MaxAddOns"]
	local maxShown = isShiftKeyDown and #infoTable or math.min(maxAddOns, #infoTable)

	local _, anchor, offset = module:GetTooltipAnchor(info)
	GameTooltip:SetOwner(self, "ANCHOR_"..anchor, 0, offset)
	GameTooltip:ClearLines()

	if self.showMemory or not scriptProfileStatus then
		local totalMemory = UpdateMemory()
		GameTooltip:AddDoubleLine(L["System"], formatMemory(totalMemory), 0,1,1, 0,1,1)
		GameTooltip:AddLine(" ")

		local numEnabled = 0
		for _, data in ipairs(infoTable) do
			if C_AddOns.IsAddOnLoaded(data[1]) then
				numEnabled = numEnabled + 1
				if numEnabled <= maxShown then
					local r, g, b = B.SmoothColor(data[3], totalMemory)
					GameTooltip:AddDoubleLine(data[2], formatMemory(data[3]), 1,1,1, r,g,b)
				end
			end
		end

		if not isShiftKeyDown and (numEnabled > maxAddOns) then
			local hiddenMemory = 0
			for i = (maxAddOns + 1), numEnabled do
				hiddenMemory = hiddenMemory + infoTable[i][3]
			end
			GameTooltip:AddDoubleLine(format(showMoreString, numEnabled - maxAddOns, L["Hidden"], L["Hold Shift"]), formatMemory(hiddenMemory), 0,1,1, 0,1,1)
		end
	else
		local totalCPU = UpdateCPU()
		local passedTime = math.max(1, GetTime() - module.loginTime)
		GameTooltip:AddDoubleLine(L["System"], format(usageString, totalCPU / passedTime, 0,1,1, 0,1,1))
		GameTooltip:AddLine(" ")

		local numEnabled = 0
		for _, data in ipairs(infoTable) do
			if C_AddOns.IsAddOnLoaded(data[1]) then
				numEnabled = numEnabled + 1
				if numEnabled <= maxShown then
					local r, g, b = B.SmoothColor(data[4], totalCPU)
					GameTooltip:AddDoubleLine(data[2], format(usageString, data[4] / passedTime), 1,1,1, r,g,b)
				end
			end
		end

		if not isShiftKeyDown and (numEnabled > maxAddOns) then
			local hiddenUsage = 0
			for i = (maxAddOns + 1), numEnabled do
				hiddenUsage = hiddenUsage + infoTable[i][4]
			end
			GameTooltip:AddDoubleLine(format(showMoreString, numEnabled - maxAddOns, L["Hidden"], L["Hold Shift"]), format(usageString, hiddenUsage / passedTime), 0,1,1, 0,1,1)
		end
	end

	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", DB.LeftButton..L["Collect Memory"].." ", 1,1,1, 0,1,1)
	if scriptProfileStatus then
		GameTooltip:AddDoubleLine(" ", DB.RightButton..L["SwitchSystemInfo"].." ", 1,1,1, 0,1,1)
	end
	GameTooltip:AddDoubleLine(" ", DB.ScrollButton..L["CPU Usage"]..": "..(GetCVarBool("scriptProfile") and DB.EnableString or DB.DisableString).." ", 1,1,1, 0,1,1)
	GameTooltip:Show()
end

info.onLeave = function()
	entered = false
	GameTooltip:Hide()
end

StaticPopupDialogs["CPUUSAGE"] = {
	text = L["ReloadUI Required"],
	button1 = APPLY,
	button2 = CLASS_TRIAL_THANKS_DIALOG_CLOSE_BUTTON,
	OnAccept = function() ReloadUI() end,
	whileDead = 1,
}

info.onMouseUp = function(self, btn)
	if btn == "LeftButton" then
		if scriptProfileStatus then
			ResetCPUUsage()
			module.loginTime = GetTime()
		end
		local before = gcinfo()
		collectgarbage("collect")
		print(format("|cff66C6FF%s:|r %s", L["Collect Memory"], formatMemory(before - gcinfo())))
		self:onEnter()
	elseif btn == "RightButton" and scriptProfileStatus then
		self.showMemory = not self.showMemory
		self:onEnter()
	elseif btn == "MiddleButton" then
		if GetCVarBool("scriptProfile") then
			SetCVar("scriptProfile", 0)
		else
			SetCVar("scriptProfile", 1)
		end

		if GetCVarBool("scriptProfile") == scriptProfileStatus then
			StaticPopup_Hide("CPUUSAGE")
		else
			StaticPopup_Show("CPUUSAGE")
		end
		self:onEnter()
	end
end