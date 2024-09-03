local _, ns = ...
local B, C, L, DB = unpack(ns)
local EX = B:GetModule("Extras")

local castList = {
	-- 传送门
	[ 10059] = "暴风城",
	[ 11416] = "铁炉堡",
	[ 11417] = "奥格瑞玛",
	[ 11418] = "幽暗城",
	[ 11419] = "暴风城",
	[ 11420] = "达纳苏斯",
	[ 32266] = "埃索达",
	[ 32267] = "银月城",
	[ 33691] = "沙塔斯 - 联盟",
	[ 35717] = "沙塔斯 - 部落",
	[ 49360] = "塞拉摩",
	[ 49361] = "斯通纳德",
	[ 53142] = "达拉然 - 诺森德",
	[ 88345] = "托尔巴拉德 - 联盟",
	[ 88346] = "托尔巴拉德 - 部落",
	[120146] = "达拉然 - 远古",
	[132620] = "锦绣谷 - 联盟",
	[132626] = "锦绣谷 - 部落",
	[176244] = "战争之矛",
	[176246] = "暴风之盾",
	[281400] = "伯拉勒斯",
	[281402] = "达萨罗",
	[344597] = "奥利波斯",
	[395289] = "瓦德拉肯",
	-- 英雄之路
	[131204] = "青龙寺",
	[131205] = "风暴烈酒酿造厂",
	[131206] = "影踪禅院",
	[131222] = "魔古山宫殿",
	[131225] = "残阳关",
	[131228] = "围攻砮皂寺",
	[131229] = "血色修道院",
	[131231] = "血色大厅",
	[131232] = "通灵学院",
	[159895] = "血槌炉渣矿井",
	[159896] = "钢铁码头",
	[159897] = "奥金顿",
	[159898] = "通天峰",
	[159899] = "影月墓地",
	[159900] = "恐轨车站",
	[159901] = "永茂林地",
	[159902] = "黑石塔上层",
	[354462] = "通灵战潮",
	[354463] = "凋魂之殇",
	[354464] = "塞兹仙林的迷雾",
	[354465] = "赎罪大厅",
	[354466] = "晋升高塔",
	[354467] = "伤逝剧场",
	[354468] = "彼界",
	[354469] = "赤红深渊",
	[367416] = "塔扎维什，帷纱集市",
	[373190] = "纳斯利亚堡",
	[373191] = "统御圣所",
	[373192] = "初诞者圣墓",
	[373262] = "卡拉赞",
	[373274] = "麦卡贡行动",
	[393222] = "奥达曼：提尔的遗产",
	[393256] = "红玉新生法池",
	[393262] = "诺库德阻击战",
	[393267] = "蕨皮山谷",
	[393273] = "艾杰斯亚学院",
	[393276] = "奈萨鲁斯",
	[393279] = "碧蓝魔馆",
	[393283] = "注能大厅",
	[393764] = "英灵殿",
	[393766] = "群星庭院",
	[410071] = "自由镇",
	[410074] = "地渊孢林",
	[410078] = "奈萨里奥的巢穴",
	[410080] = "旋云之巅",
	[424142] = "潮汐王座",
	[424153] = "黑鸦堡垒",
	[424163] = "黑心林地",
	[424167] = "维克雷斯庄园",
	[424187] = "阿塔达萨",
	[424197] = "永恒黎明",
}

local castUnit = {["player"] = true}
for i = 1, 4 do
	castUnit["party"..i] = true
end

function EX:CastAlert_Update(unit, castID, spellID)
	if castUnit[unit] and castList[spellID] then
		SendChatMessage(format(L["CastAlertInfo"], UnitName(unit), C_Spell.GetSpellLink(spellID) or C_Spell.GetSpellName(spellID), castList[spellID]), B.GetMSGChannel())
	end
end

function EX:CastAlert_CheckGroup()
	if IsInGroup() then
		B:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", EX.CastAlert_Update)
	else
		B:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", EX.CastAlert_Update)
	end
end

function EX:CastAlert()
	EX:CastAlert_CheckGroup()
	B:RegisterEvent("GROUP_LEFT", EX.CastAlert_CheckGroup)
	B:RegisterEvent("GROUP_JOINED", EX.CastAlert_CheckGroup)
end
