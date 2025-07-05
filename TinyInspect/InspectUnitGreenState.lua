
---------------------------
-- 显示装备绿字前缀
-- Author: M
-- DepandsOn: InspectUnit.lua
---------------------------
local B, C, L, DB = unpack(NDui)

local LibEvent = LibStub:GetLibrary("LibEvent.7000")

local shownStats = {
	ITEM_MOD_CRIT_RATING_SHORT    = { r=1, g=0, b=0 },
	ITEM_MOD_HASTE_RATING_SHORT   = { r=1, g=1, b=0 },
	ITEM_MOD_MASTERY_RATING_SHORT = { r=0, g=1, b=0 },
	ITEM_MOD_VERSATILITY          = { r=0, g=1, b=1 },
}

local function strsub_utf8(s, i, j)
	local bytes = string.len(s)
	local startByte = 1
	local endByte = bytes
	local len = 0
	local pos = 1
	local byt
	while pos <= bytes do
		len = len + 1
		if (len == i) then startByte = pos end
		byt = string.byte(s, pos)
		if (byt >= 240) then
			pos = pos + 4
		elseif (byt >= 224) then
			pos = pos + 3
		elseif (byt >= 192) then
			pos = pos + 2
		else
			pos = pos + 1
		end
		if (len == j) then
			endByte = pos - 1
			break
		end
	end
	return string.sub(s, startByte, endByte)
end

LibEvent:attachTrigger("INSPECT_FRAME_CREATED", function(this, frame, parent)
	local i = 1
	local itemFrame
	while (frame["item"..i]) do
		itemFrame = frame["item"..i]
		local j = 1
		for k, v in pairs(shownStats) do
			itemFrame[k] = CreateFrame("Frame", nil, itemFrame, "BackdropTemplate")
			itemFrame[k]:SetSize(16, 16)
			itemFrame[k]:SetPoint("LEFT", (j-1)*(16+DB.margin), 0)
			itemFrame[k].text= B.CreateFS(itemFrame[k], 14, "")
			itemFrame[k].text:SetText(strsub_utf8(_G[k] or k, 1, 1))
			itemFrame[k].text:SetTextColor(v.r, v.g, v.b)
			j = j + 1
		end
		itemFrame.itemLabel:SetWidth((j-1)*(16+DB.margin))
		i = i + 1
	end
end)

LibEvent:attachTrigger("INSPECT_ITEMFRAME_UPDATED", function(this, itemFrame)
	for k in pairs(shownStats) do
		if (itemFrame[k]) then itemFrame[k]:SetAlpha(.1) end
	end
	if (itemFrame.link) then
		local stats = C_Item.GetItemStats(itemFrame.link)
		for k in pairs(stats) do
			if (shownStats[k] and itemFrame[k]) then
				itemFrame[k]:SetAlpha(1)
			end
		end
	end
end)
