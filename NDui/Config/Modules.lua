-- Configure 配置页面
local _, ns = ...
local _, C = unpack(ns)

-- 光环相关
C.Auras = {
	BuffPos        = {"TOPRIGHT", Minimap, "TOPLEFT", -15, 0}, -- BUFF默认位置
	TotemsPos      = {"TOPRIGHT", UIParent, "CENTER", -480, -175}, -- 图腾助手默认位置

	RaidBuffPos    = {"BOTTOMRIGHT", UIParent, "CENTER", -200, 200}, -- 团队增益分组
	EnchantAuraPos = {"TOPRIGHT", UIParent, "CENTER", -200, -55}, -- 附魔及饰品分组
	SpecialAuraPos = {"TOPRIGHT", UIParent, "CENTER", -200, -100}, -- 玩家重要光环分组
	PlayerAuraPos  = {"TOPRIGHT", UIParent, "CENTER", -200, -137}, -- 玩家光环分组

	RaidDebuffPos  = {"BOTTOMLEFT", UIParent, "CENTER", 200, 200}, -- 团队减益分组
	WarningAuraPos = {"TOPLEFT", UIParent, "CENTER", 200, -87}, -- 目标重要光环分组
	TargetAuraPos  = {"TOPLEFT", UIParent, "CENTER", 200, -132}, -- 目标光环分组

	FocusAuraPos   = {"TOPLEFT", UIParent, "LEFT", 5, -60}, -- 焦点光环分组

	SpellCDPos     = {"BOTTOMLEFT", UIParent, "BOTTOM", -420, 30}, -- 冷却计时分组
	InternalCDPos  = {"BOTTOMLEFT", UIParent, "BOTTOM", 280, 30}, -- 法术内置冷却分组
}

-- 头像相关
C.UFs = {
	PlayerCB    = {"TOP", UIParent, "CENTER", 0, -250}, -- 玩家施法条默认位置
	TargetCB    = {"TOP", UIParent, "CENTER", 0, -150}, -- 目标施法条默认位置
	FocusCB     = {"BOTTOM", UIParent, "CENTER", 0, 200}, -- 焦点施法条默认位置

	PlayerPos   = {"TOPRIGHT", UIParent, "CENTER", -200, -175}, -- 玩家框体默认位置
	TargetPos   = {"TOPLEFT", UIParent, "CENTER", 200, -175}, -- 目标框体默认位置
	FocusPos    = {"TOPLEFT", UIParent, "LEFT", 5, -95}, -- 焦点框体默认位置

	PlayerPlate = {"TOP", UIParent, "CENTER", 0, -200}, -- 玩家姓名板默认位置
}

-- 小地图
C.Minimap = {
	Pos = {"TOPRIGHT", UIParent, "TOPRIGHT", -7, -7}, -- 小地图默认位置
}

-- 美化及皮肤
C.Skins = {
	MMPos = {"BOTTOM", UIParent, "BOTTOM", 0, 3}, -- 微型菜单默认坐标
	RMPos = {"TOP", UIParent, "TOP", 0, -3}, -- 团队工具默认坐标
}

-- 鼠标提示框
C.Tooltips = {
	Pos = {"BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -55, 230}, -- 鼠标提示框默认位置
}

-- 信息条
C.Infobar = {
	CustomAnchor  = false, -- 自定义位置

	Guild         = true, -- 公会信息
	GuildPos      = {"TOPLEFT", UIParent, 15, -6}, -- 公会信息位置
	Friends       = true, -- 好友模块
	FriendsPos    = {"TOPLEFT", UIParent, 105, -6}, -- 好友模块位置
	Latency       = true, -- 延迟
	LatencyPos    = {"TOPLEFT", UIParent, 195, -6}, -- 延迟信息位置
	System        = true, -- 帧数
	SystemPos     = {"TOPLEFT", UIParent, 285, -6}, -- 帧数信息位置
	Location      = true, -- 区域信息
	LocationPos   = {"TOPLEFT", UIParent, 380, -6}, -- 区域信息位置
	Combat        = true, -- 战斗时长
	CombatPos     = {"TOPLEFT", UIParent, -390, 6}, -- 战斗时长位置
	Spec          = true, -- 天赋专精
	SpecPos       = {"BOTTOMRIGHT", UIParent, -310, 6}, -- 天赋专精位置
	Durability    = true, -- 耐久度
	DurabilityPos = {"BOTTOM", UIParent, "BOTTOMRIGHT", -230, 6}, -- 耐久度位置
	Gold          = true, -- 金币信息
	GoldPos       = {"BOTTOM", UIParent, "BOTTOMRIGHT", -125, 6}, -- 金币信息位置
	Time          = true, -- 时间信息
	TimePos       = {"BOTTOMRIGHT", UIParent, -15, 6}, -- 时间信息位置
}