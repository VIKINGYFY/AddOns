
---------------------------------
-- 物品信息庫 Author: M
---------------------------------

local MAJOR, MINOR = "LibUnitInfo-NDui-MOD", 1
local lib = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then return end

--獲取UNIT物品實際等級信息
function lib:GetUnitItemInfo(unit, index)
	if not UnitExists(unit) then return 0 end

	local itemID = GetInventoryItemID(unit, index)
	local itemLink = GetInventoryItemLink(unit, index)
	local itemQuality = GetInventoryItemQuality(unit, index)

	local itemLevel, mainType, subType = 0
	local data = C_TooltipInfo.GetInventoryItem(unit, index)
	if data then
		for i = 1, #data.lines do
			local lineData = data.lines[i]
			if lineData then
				if lineData.type == 28 then
					mainType = lineData.leftText
					subType = lineData.rightText
				elseif lineData.type == 41 then
					itemLevel = lineData.itemLevel
				end
			end
		end
	end

	return itemLevel, itemLink, itemQuality, mainType, subType, itemID
end

local weaponTypes = {
	[INVTYPE_2HWEAPON] = true,
	[INVTYPE_RANGED] = true,
	[INVTYPE_RANGEDRIGHT] = true,
}

--獲取UNIT的裝備等級
function lib:GetUnitItemLevel(unit)
	local total = 0

	for index = 1, 15 do
		local level = self:GetUnitItemInfo(unit, index)
		if index ~= 4 then
			total = total + level
		end
	end

	local mLevel, _, _, mType = self:GetUnitItemInfo(unit, 16)
	local oLevel, _, _, oType = self:GetUnitItemInfo(unit, 17)
	if (oType and weaponTypes[oType]) or (mType and weaponTypes[mType]) then
		total = total + math.max(mLevel, oLevel) * 2
	else
		total = total + mLevel + oLevel
	end

	return total / 16
end
