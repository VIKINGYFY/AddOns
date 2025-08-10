--[[
LICENSE
	cargBags: An inventory framework addon for World of Warcraft

	Copyright (C) 2010  Constantin "Cargor" Schomburg <xconstruct@gmail.com>

	cargBags is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	cargBags is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with cargBags; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

DESCRIPTION:
	Item keys which require tooltip parsing to work
]]
local _, ns = ...
local cargBags = ns.cargBags

local bindOnList = {
	[ITEM_ACCOUNTBOUND] = "account",
	[ITEM_ACCOUNTBOUND_UNTIL_EQUIP] = "accountequip",
	[ITEM_BIND_ON_EQUIP] = "equip",
	[ITEM_BIND_ON_PICKUP] = "pickup",
	[ITEM_BIND_ON_USE] = "use",
	[ITEM_BIND_QUEST] = "quest",
	[ITEM_BIND_TO_ACCOUNT] = "account",
	[ITEM_BIND_TO_ACCOUNT_UNTIL_EQUIP] = "accountequip",
	[ITEM_BIND_TO_BNETACCOUNT] = "account",
	[ITEM_BNETACCOUNTBOUND] = "account",
	[ITEM_SOULBOUND] = "soul",
}

local itemOnList = {
	[CONDUIT_TYPE_ENDURANCE] = "conduit",
	[CONDUIT_TYPE_FINESSE] = "conduit",
	[CONDUIT_TYPE_POTENCY] = "conduit",
	[ITEM_OPENABLE] = "openable",
}

local function CreateItemKeys(item, keyName, keyList)
	if not item.link then return end

	local data = C_TooltipInfo.GetBagItem(item.bagId, item.slotId)
	if not data then return end

	for j = 2, 8 do
		local lineData = data.lines[j]
		if not lineData then break end

		local lineText = lineData.leftText
		local keyName = lineText and keyList[lineText]
		if keyName then
			item.keyName = keyName
			return keyName
		end
	end
end

cargBags.itemKeys["bindOn"] = function(item)
	return CreateItemKeys(item, bindOn, bindOnList)
end
cargBags.itemKeys["itemOn"] = function(item)
	return CreateItemKeys(item, itemOn, itemOnList)
end