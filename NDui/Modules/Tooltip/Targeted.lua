local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

local targetTable = {}

function TT:ScanTargets(unit)
	if not IsInGroup() or not UnitExists(unit) then return end

	table.wipe(targetTable)

	local isInRaid = IsInRaid()
	for i = 1, GetNumGroupMembers() do
		local member = (isInRaid and "raid"..i or "party"..i)
		if UnitIsUnit(unit, member.."target") and not UnitIsUnit("player", member) and not UnitIsDeadOrGhost(member) then
			local name = B.HexRGB(B.UnitColor(member))..UnitName(member).."|r"
			table.insert(targetTable, name)
		end
	end

	if #targetTable > 0 then
		GameTooltip:AddLine(format("%s |cff00FFFF<%s>|r %s", L["Targeted By"], #targetTable, table.concat(targetTable, ", ")), nil,nil,nil, 1)
	end
end