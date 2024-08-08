local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

local targetTable = {}

function TT:ScanTargets(unit)
	if not C.db["Tooltip"]["TargetBy"] then return end
	if not IsInGroup() then return end
	if not UnitExists(unit) then return end

	table.wipe(targetTable)

	local isInRaid = IsInRaid()
	for i = 1, GetNumGroupMembers() do
		local member = (isInRaid and "raid"..i or "party"..i)
		if UnitIsUnit(unit, member.."target") and not UnitIsUnit("player", member) and not UnitIsDeadOrGhost(member) then
			local color = B.HexRGB(B.UnitColor(member))
			local name = color..UnitName(member).."|r"
			table.insert(targetTable, name)
		end
	end

	if #targetTable > 0 then
		GameTooltip:AddLine(L["Targeted By"]..DB.InfoColor.."("..#targetTable..")|r "..table.concat(targetTable, ", "), nil, nil, nil, 1)
	end
end