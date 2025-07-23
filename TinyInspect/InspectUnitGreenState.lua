
---------------------------
-- 显示装备绿字前缀
-- Author: M
-- DepandsOn: InspectUnit.lua
---------------------------
local B, C, L, DB = unpack(NDui)

local LibEvent = LibStub:GetLibrary("LibEvent-NDui-MOD")

local shownStats = {
	["ITEM_MOD_CRIT_RATING_SHORT"]    = "|cffFF0000爆|r",
	["ITEM_MOD_HASTE_RATING_SHORT"]   = "|cffFFFF00急|r",
	["ITEM_MOD_MASTERY_RATING_SHORT"] = "|cff00FF00精|r",
	["ITEM_MOD_VERSATILITY"]          = "|cff00FFFF全|r",
}

LibEvent:attachTrigger("INSPECT_FRAME_CREATED", function(this, frame, parent)
	local i = 1
	local itemFrame
	while frame["item"..i] do
		itemFrame = frame["item"..i]
		local j = 1
		for k, v in pairs(shownStats) do
			itemFrame[k] = CreateFrame("Frame", nil, itemFrame, "BackdropTemplate")
			itemFrame[k]:SetSize(16, 16)
			itemFrame[k]:SetPoint("LEFT", (j-1)*(16+DB.margin), 0)
			itemFrame[k].text= B.CreateFS(itemFrame[k], 14, v)
			j = j + 1
		end
		itemFrame.itemLabel:SetWidth((j-1)*(16+DB.margin))
		i = i + 1
	end
end)

LibEvent:attachTrigger("INSPECT_ITEMFRAME_UPDATED", function(this, itemFrame)
	for k in pairs(shownStats) do
		if itemFrame[k] then
			itemFrame[k]:SetAlpha(.1)
		end
	end

	local stats = itemFrame.link and C_Item.GetItemStats(itemFrame.link)
	if stats then
		for k in pairs(stats) do
			if itemFrame[k] then
				itemFrame[k]:SetAlpha(1)
			end
		end
	end
end)
