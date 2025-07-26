local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

local targetTable = {}

function TT:ScanTargets(unit)
	if not (IsInGroup() and UnitExists(unit)) then return end

	table.wipe(targetTable)

	local isInRaid = IsInRaid()
	for i = 1, GetNumGroupMembers() do
		local member = B.GetGroupUnit(i, isInRaid)
		local memberTarget = member.."target"
		if not UnitIsDeadOrGhost(member) and UnitIsUnit(unit, memberTarget) then
			local name = B.HexRGB(B.UnitColor(member))..UnitName(member).."|r"
			table.insert(targetTable, name)
		end
	end

	if #targetTable > 0 then
		GameTooltip:AddLine(format("%s |cff00FFFF<%s>|r %s", L["Targeted By"], #targetTable, table.concat(targetTable, ", ")), nil,nil,nil, 1)
	end
end