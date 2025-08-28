local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

local levelPrefix = STAT_AVERAGE_ITEM_LEVEL..":|r |cffFFFFFF"
local isPending = LFG_LIST_LOADING
local resetTime, frequency = 900, .5
local cache, weapon, currentUNIT, currentGUID = {}, {}

TT.TierSets = {
	-- WARRIOR
	[237608] = true, [237609] = true, [237610] = true, [237611] = true, [237613] = true,
	-- PALADIN
	[237617] = true, [237618] = true, [237619] = true, [237620] = true, [237622] = true,
	-- HUNTER
	[237644] = true, [237645] = true, [237646] = true, [237647] = true, [237649] = true,
	-- ROGUE
	[237662] = true, [237663] = true, [237664] = true, [237665] = true, [237667] = true,
	-- PRIEST
	[237707] = true, [237712] = true, [237708] = true, [237709] = true, [237710] = true,
	-- DEATHKNIGHT
	[237626] = true, [237627] = true, [237628] = true, [237629] = true, [237631] = true,
	-- SHAMAN
	[237635] = true, [237636] = true, [237637] = true, [237638] = true, [237640] = true,
	-- MAGE
	[237718] = true, [237716] = true, [237721] = true, [237719] = true, [237717] = true,
	-- WARLOCK
	[237698] = true, [237703] = true, [237699] = true, [237700] = true, [237701] = true,
	-- MONK
	[237671] = true, [237672] = true, [237673] = true, [237674] = true, [237676] = true,
	-- DRUID
	[237682] = true, [237680] = true, [237685] = true, [237683] = true, [237681] = true,
	-- DEMONHUNTER
	[237689] = true, [237690] = true, [237691] = true, [237692] = true, [237694] = true,
	-- EVOKER
	[237653] = true, [237654] = true, [237655] = true, [237656] = true, [237658] = true,
}

local formatSets = {
	[1] = " |cffFFFFFF(1 / 4)|r", -- Common
	[2] = " |cff1EFF00(2 / 4)|r", -- Uncommon
	[3] = " |cff0070DD(3 / 4)|r", -- Rare
	[4] = " |cffA335EE(4 / 4)|r", -- Epic
	[5] = " |cffFF8000(5 / 5)|r", -- Legendary
}

function TT:InspectOnUpdate(elapsed)
	self.elapsed = (self.elapsed or frequency) + elapsed
	if self.elapsed > frequency then
		self.elapsed = 0
		self:Hide()
		ClearInspectPlayer()

		if currentUNIT and UnitGUID(currentUNIT) == currentGUID then
			B:RegisterEvent("INSPECT_READY", TT.GetInspectInfo)
			NotifyInspect(currentUNIT)
		end
	end
end

local updater = CreateFrame("Frame")
updater:SetScript("OnUpdate", TT.InspectOnUpdate)
updater:Hide()

local lastTime = 0
function TT:GetInspectInfo(...)
	if self == "UNIT_INVENTORY_CHANGED" then
		local thisTime = GetTime()
		if thisTime - lastTime > .1 then
			lastTime = thisTime

			local unit = ...
			if UnitGUID(unit) == currentGUID then
				TT:InspectUnit(unit, true)
			end
		end
	elseif self == "INSPECT_READY" then
		local guid = ...
		if guid == currentGUID then
			local level = TT:GetUnitItemLevel(currentUNIT)
			cache[guid].level = level
			cache[guid].getTime = GetTime()

			if level then
				TT:SetupItemLevel(level)
			else
				TT:InspectUnit(currentUNIT, true)
			end
		end
		B:UnregisterEvent(self, TT.GetInspectInfo)
	end
end
B:RegisterEvent("UNIT_INVENTORY_CHANGED", TT.GetInspectInfo)

function TT:SetupItemLevel(level)
	local _, unit = GameTooltip:GetUnit()
	if not unit or UnitGUID(unit) ~= currentGUID then return end

	local levelLine
	for i = 2, GameTooltip:NumLines() do
		local line = _G["GameTooltipTextLeft"..i]
		local text = line:GetText()
		if text and string.find(text, levelPrefix) then
			levelLine = line
		end
	end

	level = levelPrefix..(level or isPending)
	if levelLine then
		levelLine:SetText(level)
	else
		GameTooltip:AddLine(level)
	end
end

local weaponTypes = {
	["INVTYPE_2HWEAPON"] = true,
	["INVTYPE_RANGED"] = true,
	["INVTYPE_RANGEDRIGHT"] = true,
}

function TT:GetUnitItemLevel(unit)
	if not unit or UnitGUID(unit) ~= currentGUID then return end

	local ilvl, mlvl, olvl, total, boa, sets, delay, mtype, otype = 0, 0, 0, 0, 0, 0

	for i = 1, 17 do
		if i ~= 4 then
			local itemTexture = GetInventoryItemTexture(unit, i)

			if itemTexture then
				local itemLink = GetInventoryItemLink(unit, i)

				if not itemLink then
					delay = true
				else
					local itemID = C_Item.GetItemIDForItemInfo(itemLink)
					local _, _, itemQuality, itemLevel, _, _, _, _, itemEquipLoc = C_Item.GetItemInfo(itemLink)
					if (not itemQuality) or (not itemLevel) then
						delay = true
					else
						if itemQuality == Enum.ItemQuality.Heirloom then
							boa = boa + 1
						end

						if TT.TierSets[itemID] then
							sets = sets + 1
						end

						if unit ~= "player" then
							itemLevel = B.GetItemLevel(itemLink) or 0
							if i < 16 then
								total = total + itemLevel
							elseif i == 16 then
								mlvl = itemLevel
								mtype = itemEquipLoc
							elseif i == 17 then
								olvl = itemLevel
								otype = itemEquipLoc
							end
						end
					end
				end
			end
		end
	end

	if not delay then
		if unit == "player" then
			ilvl = select(2, GetAverageItemLevel())
		else
			if (otype and weaponTypes[otype]) or (mtype and weaponTypes[mtype]) then
				total = total + math.max(mlvl, olvl) * 2
			else
				total = total + mlvl + olvl
			end

			ilvl = total / 16
		end

		if ilvl > 0 then ilvl = format("%.1f", ilvl) end
		if boa > 0 then ilvl = ilvl..format(" |cff00FFFF(%s x %s)|r", HEIRLOOMS, boa) end
		if sets > 0 then ilvl = ilvl..formatSets[sets] end
	else
		ilvl = nil
	end

	return ilvl
end

function TT:InspectUnit(unit)
	local level

	if UnitIsUnit(unit, "player") then
		level = self:GetUnitItemLevel("player")
		self:SetupItemLevel(level)
	else
		if not unit or UnitGUID(unit) ~= currentGUID then return end
		if not UnitIsPlayer(unit) then return end

		local currentDB = cache[currentGUID]
		level = currentDB.level
		self:SetupItemLevel(level)

		local currentTime = GetTime()
		if level and (currentTime - currentDB.getTime < resetTime) then updater.elapsed = frequency return end
		if not UnitIsVisible(unit) or UnitIsDeadOrGhost("player") or UnitOnTaxi("player") then return end
		if InspectFrame and InspectFrame:IsShown() then return end

		self:SetupItemLevel()
		updater:Show()
	end
end

function TT:InspectUnitItemLevel(unit)
	if not unit or not CanInspect(unit) then return end
	currentUNIT, currentGUID = unit, UnitGUID(unit)
	if not cache[currentGUID] then cache[currentGUID] = {} end

	TT:InspectUnit(unit)
end