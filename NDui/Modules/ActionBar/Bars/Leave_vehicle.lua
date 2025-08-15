local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

function Bar:UpdateVehicleButton()
	local frame = _G["NDui_ActionBarExit"]
	if not frame then return end

	local size = C.db["Actionbar"]["VehButtonSize"]
	frame.buttons[1]:SetSize(size, size)
	frame:SetSize(size, size)
	frame.mover:SetSize(size, size)
end

function Bar:CreateLeaveVehicle()
	local buttonList = {}

	local frame = CreateFrame("Frame", "NDui_ActionBarExit", UIParent, "SecureHandlerStateTemplate")
	frame.mover = B.Mover(frame, L["LeaveVehicle"], "LeaveVehicle", {"LEFT", _G.NDui_ActionBarExtra, "RIGHT", DB.margin, 0})

	local button = CreateFrame("CheckButton", "NDui_LeaveVehicleButton", frame, "ActionButtonTemplate, SecureHandlerClickTemplate")
	table.insert(buttonList, button)
	button:ClearAllPoints()
	button:SetPoint("CENTER", frame)
	button:RegisterForClicks("AnyDown", "AnyUp")
	button.icon:SetTexture("INTERFACE\\ICONS\\UI-Vehicles-Button-Exit-Down-Icon")
	if button.Arrow then button.Arrow:SetAlpha(0) end

	button:SetScript("OnEnter", MainMenuBarVehicleLeaveButton.OnEnter)
	button:SetScript("OnLeave", B.HideTooltip)
	button:SetScript("OnClick", function(self)
		if UnitOnTaxi("player") then
			TaxiRequestEarlyLanding()
		else
			VehicleExit()
		end
		self:SetChecked(true)
	end)
	button:SetScript("OnShow", function(self)
		self:SetChecked(false)
	end)

	frame.buttons = buttonList

	frame.frameVisibility = "[canexitvehicle]c;[mounted]m;n"
	RegisterStateDriver(frame, "exit", frame.frameVisibility)

	frame:SetAttribute("_onstate-exit", [[ if CanExitVehicle() then self:Show() else self:Hide() end ]])
	if not CanExitVehicle() then frame:Hide() end
end