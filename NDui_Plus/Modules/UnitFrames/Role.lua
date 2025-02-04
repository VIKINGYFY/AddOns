local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local oUF = ns.oUF
local G = P:GetModule("GUI")
local UF = P:GetModule("UnitFrames")
local NUF = B:GetModule("UnitFrames")

function UF:Configure_RoleIcon(frame)
	local role = frame.GroupRoleIndicator
	local mystyle = frame.mystyle
	if role and mystyle == "raid" then
		role:ClearAllPoints()
		role:SetPoint(G.Points[UF.db["RolePoint"]], frame, UF.db["RoleXOffset"], UF.db["RoleYOffset"])
		role:SetSize(UF.db["RoleSize"], UF.db["RoleSize"])
	end
end

function UF:UpdateRoleIcons()
	for _, frame in pairs(oUF.objects) do
		UF:Configure_RoleIcon(frame)
	end
end

function UF:SetupRoleIcons()
	if not UF.db["RolePos"] then return end

	UF:UpdateRoleIcons()
	hooksecurefunc(NUF, "CreateIcons", function(_, frame)
		UF:Configure_RoleIcon(frame)
	end)
end