local _, ns = ...
local B, C, L, DB = unpack(ns)
local cr, cg, cb = DB.r, DB.g, DB.b

local function Reskin_StaticPopup(which, _, _, data)
	local info = StaticPopupDialogs[which]
	if not info then return end

	local dialog = nil
	dialog = StaticPopup_FindVisible(which, data)

	if not dialog then
		local index = 1
		if info.preferredIndex then
			index = info.preferredIndex
		end
		for i = index, STATICPOPUP_NUMDIALOGS do
			local frame = _G["StaticPopup"..i]
			if not frame:IsShown() then
				dialog = frame

				break
			end
		end

		if not dialog and info.preferredIndex then
			for i = 1, info.preferredIndex do
				local frame = _G["StaticPopup"..i]
				if not frame:IsShown() then
					dialog = frame

					break
				end
			end
		end
	end
end

local function Reskin_PlayerReport(self)
	if self.MinorCategoryButtonPool then
		for button in self.MinorCategoryButtonPool:EnumerateActive() do
			if not button.styled then
				B.ReskinButton(button)

				button.styled = true
			end
		end
	end
end

C.OnLoginThemes["StaticPopup"] = function()
	for i = 1, 4 do
		local main = "StaticPopup"..i
		B.ReskinFrame(_G[main])

		for j = 1, 4 do
			B.ReskinButton(_G[main.."Button"..j])
		end

		local edit = _G[main.."EditBox"]
		B.ReskinInput(edit, 20)

		local item = _G[main.."ItemFrame"]
		local icon = _G[main.."ItemFrameIconTexture"]
		B.StripTextures(item)
		item.bg = B.ReskinIcon(icon)
		B.ReskinHLTex(item, item.bg)
		B.ReskinBorder(item.IconBorder)

		local name = _G[main.."ItemFrameNameFrame"]
		if name then name:Hide() end

		local extra = _G[main.."extraButton"]
		if extra then B.ReskinButton(extra) end

		local gold = _G[main.."MoneyInputFrameGold"]
		B.ReskinInput(gold)

		local silver = _G[main.."MoneyInputFrameSilver"]
		B.UpdatePoint(silver, "LEFT", gold, "RIGHT", 1, 0)
		B.ReskinInput(silver)

		local copper = _G[main.."MoneyInputFrameCopper"]
		B.UpdatePoint(copper, "LEFT", silver, "RIGHT", 1, 0)
		B.ReskinInput(copper)
	end

	hooksecurefunc("StaticPopup_Show", Reskin_StaticPopup)

	-- Pet battle queue popup
	B.ReskinFrame(PetBattleQueueReadyFrame)
	B.CreateBDFrame(PetBattleQueueReadyFrame.Art)
	B.ReskinButton(PetBattleQueueReadyFrame.AcceptButton)
	B.ReskinButton(PetBattleQueueReadyFrame.DeclineButton)

	-- PlayerReportFrame
	B.ReskinFrame(ReportFrame)
	B.ReskinInput(ReportFrame.Comment)
	B.ReskinButton(ReportFrame.ReportButton)
	B.ReskinDropDown(ReportFrame.ReportingMajorCategoryDropdown)

	hooksecurefunc(ReportFrame, "AnchorMinorCategory", Reskin_PlayerReport)
end