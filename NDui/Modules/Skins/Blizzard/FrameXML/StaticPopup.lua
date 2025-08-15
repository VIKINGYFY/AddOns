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
		local popup = "StaticPopup"..i
		B.ReskinFrame(_G[popup])

		for j = 1, 4 do
			B.ReskinButton(_G[popup.."Button"..j])
		end

		local edit = _G[popup].EditBox
		B.ReskinInput(edit, 20)

		local frame = _G[popup].ItemFrame
		local item = frame.Item
		if item then
			B.StripTextures(item)
			item.bg = B.ReskinIcon(_G[popup.."IconTexture"])
			B.ReskinHLTex(item, item.bg)
			B.ReskinBorder(item.IconBorder)
			B.ReskinNameFrame(frame, item.bg)
		end

		local extra = _G[popup.."extraButton"]
		if extra then B.ReskinButton(extra) end

		local gold = _G[popup.."MoneyInputFrameGold"]
		B.ReskinInput(gold)

		local silver = _G[popup.."MoneyInputFrameSilver"]
		B.UpdatePoint(silver, "LEFT", gold, "RIGHT", 1, 0)
		B.ReskinInput(silver)

		local copper = _G[popup.."MoneyInputFrameCopper"]
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