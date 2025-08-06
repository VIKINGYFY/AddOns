local _, ns = ...
local B, C, L, DB= unpack(ns)
local EX = B:GetModule("Extras")
local TT = B:GetModule("Tooltip")

local function GetCollectText(text, isCollected)
	if isCollected then
		return B.HexRGB(0, 1, 0, text)
	else
		return B.HexRGB(1, 0, 0, text)
	end
end

function EX:UpdateMountSource()
	if self:IsForbidden() or self ~= GameTooltip then return end
	if InCombatLockdown() then return end

	local unit = TT.GetUnit(self)
	if not UnitIsPlayer(unit) then return end

	local index = 1
	while true do
		local buffData = C_TooltipInfo.GetUnitBuff(unit, index)
		if not buffData then return end

		local mountID = C_MountJournal.GetMountFromSpell(buffData.id)
		if mountID then
			local name, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
			local _, _, source = C_MountJournal.GetMountInfoExtraByID(mountID)
			local text = format("%s(%s)", name, mountID)

			self:AddLine(" ")
			self:AddLine(MOUNTS.."："..GetCollectText(text, isCollected), nil,nil,nil)
			self:AddLine(source:gsub("|n%s*|n$", ""), 1,1,1)

			if IsShiftKeyDown() then
				print(MOUNTS.."："..text)
			end

			return
		end
		index = index + 1
	end
end

function EX:MountSource()
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, EX.UpdateMountSource)
end
