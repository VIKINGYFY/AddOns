local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)

local style = {
	name = "NDui",
	border = {
		color = {0, 0, 0},
		offset = 0,
		size = 1,
		texture = {1, 1, 1, 1},
	},
	title = {
		flags = DB.Font[3],
		shadow = false,
	},
	text = {
		flags = DB.Font[3],
		shadow = false,
	},
	icon = {
		tex_coords = DB.TexCoord,
	},
	icon_border = {
		color = {0, 0, 0},
		offset = 0,
		size = 1,
		texture = {1, 1, 1, 1},
	},
	icon_text_1 = {
		flags = DB.Font[3],
	},
	icon_text_2 = {
		flags = DB.Font[3],
	},
	slot = {
		tex_coords = DB.TexCoord,
	},
	slot_border = {
		color = {0, 0, 0},
		offset = 0,
		size = 1,
		texture = {1, 1, 1, 1},
	},
	glow = {
		texture = {1, 1, 1, 1},
		size = {226, 50},
	},
	shine = {
		tex_coords = {403 / 512, 465 / 512, 15 / 256, 61 / 256},
		size = {67, 50},
		point = {
			y = -1,
		},
	},
	text_bg = {
		hidden = true,
	},
	leaves = {
		hidden = true,
	},
	dragon = {
		hidden = true,
	},
	icon_highlight = {
		hidden = true,
	},
	bg = {
		default = {
			texture = "",
		},
	},
}

local function SkinToast(event, toast)
	if not toast.bg then
		toast.bg = B.SetBD(toast)
		toast.bg:SetOutside()
		toast.bg:SetFrameLevel(toast:GetFrameLevel() - 1)
	end
end

function S:ls_Toasts()
	if not S.db["ls_Toasts"] then return end

	style.border.size = C.mult
	style.icon_border.size = C.mult
	style.slot_border.size = C.mult
	style.shine.point.y = -C.mult

	if C.db["Skins"]["CustomBD"] then
		local colors = C.db["Skins"]["CustomBDColor"]
		style.border.color = {colors.r, colors.g, colors.b}
		style.icon_border.color = {colors.r, colors.g, colors.b}
		style.slot_border.color = {colors.r, colors.g, colors.b}
	end

	local LE, LC = unpack(_G.ls_Toasts)
	LE:RegisterSkin("ndui", style)
	LE:RegisterCallback("ToastCreated", SkinToast)
	LC.db.profile.skin = "ndui"
end

function S:LSPreviewBoxCurrency(widget)
	S:Ace3_EditBox(widget)
	P.ReskinTooltip(widget.preview)
end

S:RegisterSkin("ls_Toasts", S.ls_Toasts)
S:RegisterAceGUIWidget("LSPreviewBoxCurrency")