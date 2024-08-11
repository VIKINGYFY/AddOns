
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
	local itemframe
	while(frame["item"..i]) do
		itemframe = frame["item"..i]
		itemframe.label:SetBackdrop({})
		itemframe.label.text:SetText("")
		itemframe.label:SetWidth(68)
		local j = 1
		for k, v in pairs(shownStats) do
			itemframe[k] = CreateFrame("Frame", nil, itemframe, "BackdropTemplate")
			itemframe[k]:SetSize(15, 15)
			itemframe[k]:SetPoint("LEFT", (j-1)*17, 0)
			itemframe[k].text= B.CreateFS(itemframe[k], 12, "")
			itemframe[k].text:SetText(strsub_utf8(_G[k] or k, 1, 1))
			itemframe[k].text:SetTextColor(v.r, v.g, v.b)
			j = j + 1
		end
		i = i + 1
	end
end)

LibEvent:attachTrigger("INSPECT_ITEMFRAME_UPDATED", function(this, itemframe)
	for k in pairs(shownStats) do
		if (itemframe[k]) then itemframe[k]:SetAlpha(.1) end
	end
	if (itemframe.link) then
		local stats = C_Item.GetItemStats(itemframe.link)
		for k in pairs(stats) do
			if (shownStats[k] and itemframe[k]) then
				itemframe[k]:SetAlpha(1)
			end
		end
	end
end)
