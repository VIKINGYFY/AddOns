local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")
--[[
	>>>自定义添加时，要注意格式，注意逗号，注意字母大小写<<<
	ALL下面是对全职业通用的设置，其他情况请在自己职业下添加。当你添加时，要注意是否重复。
	各组别分别代表的是：
		Player Aura，是自己头像上偏小的buff组，用来监视那些不那么重要的buff；
		Special Aura，是自己头像上偏大的buff组，用来监视稍微重要的buff；
		Target Aura，是目标头像上的buff组，用来监视你循环中需要的debuff；
		Focus Aura，是焦点的buff组，用来监视焦点目标的buff及debuff；
		Spell Cooldown，是冷却时间监控组，用来监视饰品、戒指、技能CD等；
		Enchant Aura，是各种种族技能、药水、饰品触发的buff分组；
		Raid Buff，是团队重要buff的分组，用来监控如嗜血、光环、团队减伤等等；
		Raid Debuff，是团队战斗中出现的debuff组，用来监控战斗中出现的点名等等；
		Warning Aura，是目标身上需要注意的buff及debuff，可以用来监视BOSS的易伤、PVP对方的大招等等。

	数字编号含义：
		AuraID，支持BUFF和DEBUFF，在游戏中触发时，请鼠标移过去看看ID，或者自己查询数据库；
		SpellID，只是用来监视技能的CD，直接鼠标到技能上就可以看到该ID，大部分情况下与其触发后的BUFF/DEBUFF ID不一样；
		ItemID，用来监视物品的CD，例如炉石等等；
		SlotID，装备栏各部位的冷却时间，常用的有11/12戒指，6腰带，15披风，13/14饰品栏（仅主动饰品）；
		TotemID，监视图腾的持续时间，武僧的玄牛算1号图腾，萨满1-4对应4个图腾；
		UnitID，是你想监视的目标，支持宠物pet，玩家自身player，目标target和焦点focus；

	各种过滤方式：
		Caster，是法术的释放者，如果你没有标明，则任何释放该法术的都会被监视，例如猎人印记，元素诅咒等；
		Stack，是部分法术的层数，未标明则全程监视，有标明则只在达到该层数后显示，例如DK鲜血充能仅在10层后才提示；
		Value，为true时启用，用于监视一些BUFF/DEBUFF的具体数值，如牧师的盾，DK的血盾等等；
		Timeless，具体例如萨满的闪电盾，因为持续1个小时，没有必要一直监视时间，启用Timeless则只监视层数；
		Combat，启用时将仅在战斗中监视该buff，例如猎人的狙击训练，萨满的闪电护盾；
		Text，启用时将在BUFF图标下用文字提醒，优先级低于Value。比如中了某个BUFF需要出人群时，你就可以使用这个文字提醒；
		Flash，启用时在图标显示一圈高亮；

	内置CD使用说明：
		{IntID = 208052, Duration = 30, ItemID = 132452}, -- 塞弗斯的秘密
		{IntID =  98008, Duration = 30, OnSuccess = true, UnitID = "all"}, -- 灵魂链接
		IntID，计时条触发时的法术或者技能ID；
		Duration，自定义计时条的持续时间；
		ItemID，在计时条上显示的名称，如果不填写，就会直接使用触发时的Buff名称；
		OnSuccess，用于监控技能成功施放的触发器，仅当技能成功施放时开启计时条。如果不填写，则计时条由你获得该法术光环时触发；
		UnitID，用于过滤目标法术的来源，默认为player玩家自身。如果设置为all，则监控队伍/团队里的所有成员。
]]

-- 全职业的相关监控
local list = {
	["Enchant Aura"] = { -- 附魔及饰品组
		{AuraID =  341260, UnitID = "player", Flash = true}, -- 学识爆发，传家宝套装
		{AuraID =  354808, UnitID = "player"}, -- 棱彩之光，1万币的小宠物
		-- 种族天赋
		{AuraID =   20572, UnitID = "player"}, -- 血性狂怒 兽人
		{AuraID =   26297, UnitID = "player"}, -- 狂暴 巨魔
		{AuraID =   33697, UnitID = "player"}, -- 血性狂怒 兽人
		{AuraID =  292463, UnitID = "player"}, -- 帕库之拥 赞达拉
		{AuraID =  431932, UnitID = "player"}, -- 淬火药水
		-- 武器附魔
		{AuraID =  448730, UnitID = "player"}, -- 灿能威权
		{AuraID =  449091, UnitID = "player"}, -- 议会之诡
		{AuraID =  449100, UnitID = "player"}, -- 驭雷者之怒
		{AuraID =  449108, UnitID = "player"}, -- 石缚之艺
		{AuraID =  449115, UnitID = "player"}, -- 圣誓之韧
		-- 饰品
		{AuraID =   91374, UnitID = "player"}, -- 卡德罗斯的印记
		{AuraID =   92099, UnitID = "player"}, -- 灰鳞的优雅
		{AuraID =  268439, UnitID = "player"}, -- 艾泽洛克的共鸣之心
		{AuraID =  268769, UnitID = "player"}, -- 望远镜饰品
		{AuraID =  435493, UnitID = "player"}, -- 制剂：死亡之吻
		{AuraID =  443407, UnitID = "player"}, -- 斯卡莫拉克碎片
		{AuraID =  443531, UnitID = "player"}, -- 振奋之光
		{AuraID =  445560, UnitID = "player"}, -- 紫蛋
		{AuraID =  446887, UnitID = "player", Value = true}, -- 邪污巨兽的螯肢
		{AuraID =  449275, UnitID = "player"}, -- 阿努布伊卡基强能水晶
		{AuraID =  449947, UnitID = "player", Text =  NPE_JUMP}, -- 奸邪发射机，跳3下
		{AuraID =  449954, UnitID = "player"}, -- 奸邪发射机
		{AuraID =  451011, UnitID = "player"}, -- 暴虐演说者的喉头
		{AuraID =  451303, UnitID = "player"}, -- 收割者之诏
		{AuraID =  451568, UnitID = "player", Value = true}, -- 折转侵攻模组
		{AuraID =  452146, UnitID = "player"}, -- 艾拉-卡拉卵囊
		{AuraID =  455420, UnitID = "player"}, -- 探洞者的蜡烛残端
		{AuraID =  455444, UnitID = "player"}, -- 探洞者的蜡烛
		{AuraID =  455451, UnitID = "player"}, -- 迅芯烛台
		{AuraID =  466681, UnitID = "player"}, -- 纸牌屋
		{AuraID =  466810, UnitID = "player", Value = true}, -- 易燃铬武炸弹服
		{AuraID =  470286, UnitID = "player"}, -- 托克的大红按钮
		{AuraID = 1213433, UnitID = "player", Text = L["Crit"]}, -- 哈哈棱镜
		{AuraID = 1213434, UnitID = "player", Text = L["Haste"]}, -- 哈哈棱镜
		{AuraID = 1214806, UnitID = "player"}, -- 机械核心增幅器
		{AuraID = 1214810, UnitID = "player"}, -- 机械核心增幅器
		{AuraID = 1216650, UnitID = "player"}, -- 可疑的能量饮料
		{AuraID = 1216921, UnitID = "player", Value = true}, -- 不详污油残渣
		{AuraID = 1218713, UnitID = "player"}, -- 临时制作的爆盐起搏器
		{AuraID = 1219102, UnitID = "player", Value = true}, -- 共鸣仪式泥浆
		{AuraID = 1224918, UnitID = "player"}, -- 虚触碎片
		{AuraID = 1241806, UnitID = "player"}, -- 被诅咒的雕像
		{AuraID = 1245431, UnitID = "player", Value = true}, -- 共生以太薄纱
		{AuraID = 1247207, UnitID = "player"}, -- 虚体精华吞噬者
		{AuraID =  450962, UnitID = "player"}, -- 虚空契约石
		{AuraID = 1245643, UnitID = "player"}, -- 心智溃解之祸
		{AuraID = 1246543, UnitID = "player"}, -- 影卫的扭曲收获者

	},
	["Raid Buff"] = { -- 团队增益组
		{AuraID =   54861, UnitID = "player"}, -- 火箭靴，工程
		-- 嗜血相关
		{AuraID =    2825, UnitID = "player", Flash = true}, -- 嗜血
		{AuraID =   32182, UnitID = "player", Flash = true}, -- 英勇
		{AuraID =   80353, UnitID = "player", Flash = true}, -- 时间扭曲
		{AuraID =   90355, UnitID = "player", Flash = true}, -- 远古狂乱
		{AuraID =  102364, UnitID = "player", Flash = true}, -- 青铜龙的祝福
		{AuraID =  145534, UnitID = "player", Flash = true}, -- 时间扭曲
		{AuraID =  146555, UnitID = "player", Flash = true}, -- 暴怒之鼓
		{AuraID =  160452, UnitID = "player", Flash = true}, -- 虚空之风
		{AuraID =  178207, UnitID = "player", Flash = true}, -- 狂怒战鼓
		{AuraID =  230935, UnitID = "player", Flash = true}, -- 高山战鼓
		{AuraID =  256740, UnitID = "player", Flash = true}, -- 漩涡战鼓
		{AuraID =  263487, UnitID = "player", Flash = true}, -- 元素增效
		{AuraID =  264667, UnitID = "player", Flash = true}, -- 原始暴怒
		{AuraID =  267572, UnitID = "player", Flash = true}, -- 嗜血
		{AuraID =  267575, UnitID = "player", Flash = true}, -- 时间扭曲
		{AuraID =  272678, UnitID = "player", Flash = true}, -- 原始暴怒
		{AuraID =  290582, UnitID = "player", Flash = true}, -- 英勇
		{AuraID =  290583, UnitID = "player", Flash = true}, -- 嗜血
		{AuraID =  292686, UnitID = "player", Flash = true}, -- 制皮战鼓
		{AuraID =  309658, UnitID = "player", Flash = true}, -- 死亡凶蛮战鼓
		{AuraID =  357650, UnitID = "player", Flash = true}, -- 原始暴怒
		{AuraID =  381301, UnitID = "player", Flash = true}, -- 野性皮革战鼓
		{AuraID =  390386, UnitID = "player", Flash = true}, -- 守护巨龙之怒
		{AuraID =  397571, UnitID = "player", Flash = true}, -- 时间扭曲
		{AuraID =  397744, UnitID = "player", Flash = true}, -- 守护巨龙之怒
		{AuraID =  420083, UnitID = "player", Flash = true}, -- 玛诺洛斯之血
		{AuraID =  420321, UnitID = "player", Flash = true}, -- 嗜血
		{AuraID =  428941, UnitID = "player", Flash = true}, -- 时间扭曲
		{AuraID =  429485, UnitID = "player", Flash = true}, -- 嗜血
		{AuraID =  431286, UnitID = "player", Flash = true}, -- 守护巨龙之怒
		{AuraID =  441076, UnitID = "player", Flash = true}, -- 越时战鼓
		{AuraID =  444257, UnitID = "player", Flash = true}, -- 掣雷之鼓
		{AuraID =  466904, UnitID = "player", Flash = true}, -- 鹞鹰尖啸
		-- 团队增益或减伤
		{AuraID =    1022, UnitID = "player"}, -- 圣骑士，保护祝福
		{AuraID =    1044, UnitID = "player"}, -- 圣骑士，自由祝福
		{AuraID =    6940, UnitID = "player"}, -- 圣骑士，牺牲祝福
		{AuraID =   10060, UnitID = "player"}, -- 牧师，能量灌注
		{AuraID =   29166, UnitID = "player"}, -- 德鲁伊，激活
		{AuraID =   31821, UnitID = "player"}, -- 圣骑士，光环掌握
		{AuraID =   33206, UnitID = "player"}, -- 牧师，痛苦压制
		{AuraID =   34477, UnitID = "player"}, -- 猎人，误导
		{AuraID =   47788, UnitID = "player"}, -- 牧师，守护之魂
		{AuraID =   57934, UnitID = "player"}, -- 潜行者，嫁祸诀窍
		{AuraID =   64843, UnitID = "player"}, -- 牧师，神圣赞美诗
		{AuraID =   64901, UnitID = "player"}, -- 牧师，希望象征
		{AuraID =   77761, UnitID = "player"}, -- 德鲁伊，狂奔怒吼
		{AuraID =   77764, UnitID = "player"}, -- 德鲁伊，狂奔怒吼
		{AuraID =   81782, UnitID = "player"}, -- 牧师，真言术：障
		{AuraID =   97463, UnitID = "player"}, -- 战士，集结呐喊
		{AuraID =   98007, UnitID = "player"}, -- 灵魂链接图腾
		{AuraID =  102342, UnitID = "player"}, -- 德鲁伊，铁木树皮
		{AuraID =  106898, UnitID = "player"}, -- 德鲁伊，狂奔怒吼
		{AuraID =  115310, UnitID = "player"}, -- 五气归元
		{AuraID =  115834, UnitID = "player"}, -- 潜行者，潜伏帷幕
		{AuraID =  116841, UnitID = "player"}, -- 武僧，迅如猛虎
		{AuraID =  116849, UnitID = "player"}, -- 武僧，作茧缚命
		{AuraID =  121557, UnitID = "player"}, -- 牧师，天堂之羽
		{AuraID =  145629, UnitID = "player"}, -- 死亡骑士，反魔法领域
		{AuraID =  192082, UnitID = "player"}, -- 萨满祭司，狂风图腾
		{AuraID =  201633, UnitID = "player"}, -- 大地图腾
		{AuraID =  204018, UnitID = "player"}, -- 圣骑士，破咒祝福
		{AuraID =  207498, UnitID = "player"}, -- 先祖护佑
		{AuraID =  209426, UnitID = "player"}, -- 恶魔猎手，黑暗
		{AuraID =  223658, UnitID = "player"}, -- 捍卫
		{AuraID =  238698, UnitID = "player"}, -- 吸血光环
		{AuraID =  357170, UnitID = "player"}, -- 唤魔师，时间膨胀
		{AuraID =  363534, UnitID = "player"}, -- 唤魔师，回溯
		{AuraID =  374227, UnitID = "player"}, -- 唤魔师，微风
	},
	["Raid Debuff"] = { -- 团队减益组
		-- 大幻象
		{AuraID =  306583, UnitID = "player"}, -- 灌铅脚步，幻象
		{AuraID =  311390, UnitID = "player"}, -- 疯狂：昆虫恐惧症，幻象
		{AuraID =  313698, UnitID = "player", Flash = true}, -- 泰坦之赐，幻象
		{AuraID =  315385, UnitID = "player"}, -- 灼热跳跃，幻象

		-- 常驻词缀
		{AuraID =  209858, UnitID = "player", Flash = true}, -- 死疽溃烂
		{AuraID =  226512, UnitID = "player", Flash = true}, -- 血池
		{AuraID =  240443, UnitID = "player", Flash = true}, -- 爆裂
		{AuraID =  240447, UnitID = "player", Flash = true}, -- 践踏
		{AuraID =  240559, UnitID = "player", Flash = true}, -- 重伤
		{AuraID =  396364, UnitID = "player", Flash = true}, -- 狂风标记，DF S1
		{AuraID =  396369, UnitID = "player", Flash = true}, -- 闪电标记，DF S1
		{AuraID =  408556, UnitID = "player", Flash = true}, -- 缠绕
		{AuraID =  408805, UnitID = "player", Flash = true}, -- 失衡
		{AuraID =  409492, UnitID = "player", Flash = true}, -- 痛苦呼号
		{AuraID =  461910, UnitID = "player", Flash = true}, -- 萨拉塔斯的交易：扬升
		{AuraID =  462661, UnitID = "player", Flash = true}, -- 萨拉塔斯的交易：虚缚
		{AuraID =  465136, UnitID = "player", Flash = true}, -- 萨拉塔斯的交易：吞噬
		{AuraID = 1216943, UnitID = "player", Flash = true}, -- 萨拉塔斯的交易：脉冲
		-- DF Party
		{AuraID =   88286, UnitID = "player", Flash = true}, -- 减速风，旋云之巅
		{AuraID =  153692, UnitID = "player", Flash = true}, -- 死疽沥青，影月墓地
		{AuraID =  162652, UnitID = "player", Flash = true}, -- 纯净之月，影月墓地
		{AuraID =  197996, UnitID = "player"}, -- 烙印，英灵殿
		{AuraID =  203963, UnitID = "player"}, -- 风暴之眼，英灵殿
		{AuraID =  215898, UnitID = "player", Flash = true}, -- 晶化大地，巢穴
		{AuraID =  250585, UnitID = "player", Flash = true}, -- 剧毒之池，阿塔达萨
		{AuraID =  257407, UnitID = "player"}, -- 追踪，阿塔达萨
		{AuraID =  258723, UnitID = "player", Flash = true}, -- 怪诞之池，阿塔达萨
		{AuraID =  259718, UnitID = "player"}, -- 颠覆，孢林
		{AuraID =  268086, UnitID = "player", Text = L["Move"]}, -- 恐怖光环，庄园
		{AuraID =  269838, UnitID = "player", Flash = true}, -- 邪恶污染，孢林
		{AuraID =  273226, UnitID = "player"}, -- 腐烂孢子，孢林
		{AuraID =  274507, UnitID = "player"}, -- 湿滑肥皂，自由镇
		{AuraID =  278789, UnitID = "player", Flash = true}, -- 腐烂波，孢林
		{AuraID =  369337, UnitID = "player", Flash = true}, -- 困难地形，奥达曼
		{AuraID =  376760, UnitID = "player"}, -- 狂风之力，学院
		{AuraID =  377018, UnitID = "player", Flash = true}, -- 熔火真金，奈萨鲁斯
		{AuraID =  381862, UnitID = "player", Flash = true}, -- 地狱火之核，红玉
		{AuraID =  386181, UnitID = "player"}, -- 法力炸弹，学院
		{AuraID =  386881, UnitID = "player"}, -- 冰霜炸弹，碧蓝魔馆
		{AuraID =  388777, UnitID = "player"}, -- 压制瘴气，碧蓝魔馆
		{AuraID =  389059, UnitID = "player", Flash = true}, -- 炉渣喷发，奈萨鲁斯
		{AuraID =  389179, UnitID = "player", Flash = true}, -- 能量过载，注能大厅
		{AuraID =  391977, UnitID = "player"}, -- 涌动超载，学院
		{AuraID =  395035, UnitID = "player", Flash = true}, -- 粉碎灵魂，阻击战
		{AuraID =  397797, UnitID = "player"}, -- 腐蚀漩涡，青龙寺
		{AuraID =  397799, UnitID = "player", Flash = true}, -- 腐蚀漩涡，青龙寺
		{AuraID =  397911, UnitID = "player"}, -- 毁灭之触，青龙寺
		{AuraID =  400474, UnitID = "player"}, -- 能量湍流，阻击战
		{AuraID =  401420, UnitID = "player", Flash = true}, -- 黄沙重踏，永恒黎明
		{AuraID =  404141, UnitID = "player", Flash = true}, -- 时光凋零，永恒黎明
		{AuraID =  406543, UnitID = "player", Flash = true}, -- 窃取时间，永恒黎明
		{AuraID =  410908, UnitID = "player", Flash = true}, -- 永恒新星，永恒黎明
		{AuraID =  413142, UnitID = "player", Flash = true}, -- 万古裂片，永恒黎明
		{AuraID =  414496, UnitID = "player", Flash = true}, -- 时间线加速，永恒黎明
		{AuraID =  427513, UnitID = "player", Flash = true}, -- 剧毒释放，永茂林地
		-- DF Raids
		{AuraID =  405340, UnitID = "player", Flash = true}, -- 虚无之拥，萨卡雷斯
		{AuraID =  407406, UnitID = "player", Flash = true}, -- 腐蚀，萨卡雷斯
		{AuraID =  407496, UnitID = "player", Flash = true}, -- 无限压迫，萨卡雷斯
		{AuraID =  407576, UnitID = "player"}, -- 星界耀斑，萨卡雷斯
		{AuraID =  410642, UnitID = "player", Flash = true}, -- 虚空碎裂，萨卡雷斯
		{AuraID =  426249, UnitID = "player", Flash = true}, -- 炽焰融合，拉罗达尔
		-- TWW Party
		{AuraID =  259533, UnitID = "player", Flash = true}, -- 艾泽里特催化剂，暴富
		{AuraID =  291937, UnitID = "player", Flash = true}, -- 车间，垃圾掩体
		{AuraID =  319637, UnitID = "player"}, -- 伤逝剧场，魂魄归体
		{AuraID =  320366, UnitID = "player", Flash = true}, -- 通灵战潮，防腐剂
		{AuraID =  322681, UnitID = "player"}, -- 通灵战潮，肉钩
		{AuraID =  323471, UnitID = "player", Flash = true}, -- 通灵战潮，切肉飞刀
		{AuraID =  325027, UnitID = "player", Flash = true}, -- 仙林，荆棘爆发
		{AuraID =  327397, UnitID = "player"}, -- 通灵战潮，严酷命运
		{AuraID =  327401, UnitID = "player", Flash = true}, -- 通灵战潮，共受苦难
		{AuraID =  328181, UnitID = "player"}, -- 通灵战潮，凌冽之寒
		{AuraID =  330725, UnitID = "player", Flash = true}, -- 伤逝剧场，暗影易伤
		{AuraID =  333299, UnitID = "player"}, -- 伤逝剧场，荒芜诅咒
		{AuraID =  335161, UnitID = "player"}, -- 通灵战潮，残存心能
		{AuraID =  345323, UnitID = "player", Flash = true}, -- 通灵战潮，勇士之赐
		{AuraID =  350010, UnitID = "player", Flash = true}, -- 琳彩天街，被吞噬的心能
		{AuraID =  359019, UnitID = "player", Flash = true}, -- 琳彩天街，快拍提速！
		{AuraID =  433740, UnitID = "player"}, -- 感染，艾拉卡拉
		{AuraID =  458082, UnitID = "player", Flash = true}, -- 驭雷栖巢，驭雷者电荷
		{AuraID = 1239229, UnitID = "player", Flash = true}, -- 圆顶，卡雷什涌动
		-- TWW Raids
		{AuraID =  464748, UnitID = "player", Flash = true}, -- 束缚之网，流丝
	},
	["Warning Aura"] = { -- 目标重要光环组
		{AuraID =  268756, UnitID = "target", Caster = "player"}, -- 望远镜饰品
		{AuraID =  355596, UnitID = "target", Flash = true}, -- 橙弓，哀痛箭
		-- 大幻象
		{AuraID =  304975, UnitID = "target", Value = true}, -- 虚空哀嚎，吸收盾
		{AuraID =  319643, UnitID = "target", Value = true}, -- 虚空哀嚎，吸收盾
		-- 大秘境
		{AuraID =  226510, UnitID = "target"}, -- 血池回血
		{AuraID =  343502, UnitID = "target"}, -- 鼓舞光环
		{AuraID =  440328, UnitID = "target"}, -- 萨拉塔斯的赠礼：吞噬
		{AuraID = 1216944, UnitID = "target"}, -- 萨拉塔斯的赠礼：脉冲
		{AuraID = 1221061, UnitID = "target"}, -- 萨拉塔斯的赠礼：虚缚
		{AuraID = 1221063, UnitID = "target"}, -- 萨拉塔斯的赠礼：扬升
		-- DF Party
		{AuraID =  113309, UnitID = "target", Flash = true}, -- 至高能量，青龙寺
		{AuraID =  113315, UnitID = "target", Stack = 7, Flash = true}, -- 强烈，青龙寺
		{AuraID =  117665, UnitID = "target", Flash = true}, -- 凡尘之羁，青龙寺
		{AuraID =  200672, UnitID = "target", Value = true}, -- 水晶迸裂，巢穴
		{AuraID =  257458, UnitID = "target"}, -- 自由镇尾王易伤
		{AuraID =  369725, UnitID = "target"}, -- 震颤，奥达曼
		{AuraID =  372600, UnitID = "target"}, -- 严酷，奥达曼
		{AuraID =  372988, UnitID = "target", Value = true}, -- 寒冰壁垒，红玉
		{AuraID =  376780, UnitID = "target", Value = true}, -- 岩浆护盾，奈萨鲁斯
		{AuraID =  376781, UnitID = "target", Flash = true}, -- 火焰风暴，学院
		{AuraID =  377014, UnitID = "target", Flash = true}, -- 爆冲，奈萨鲁斯
		{AuraID =  377402, UnitID = "target", Value = true}, -- 液态屏障，注能大厅
		{AuraID =  378022, UnitID = "target", Value = true}, -- 吞噬中，蕨皮
		{AuraID =  382791, UnitID = "target", Value = true}, -- 熔火屏障，奈萨鲁斯
		{AuraID =  384686, UnitID = "target", Flash = true}, -- 能量涌动，狙击战
		{AuraID =  388084, UnitID = "target", Flash = true}, -- 冰川护盾，碧蓝
		{AuraID =  388523, UnitID = "target", Flash = true}, -- 拘禁，奈萨鲁斯
		{AuraID =  391050, UnitID = "target", Value = true}, -- 暴风骤雨之盾，红玉
		{AuraID =  396361, UnitID = "target", Value = true}, -- 晶化，碧蓝
		{AuraID =  410249, UnitID = "target", Value = true}, -- 辐光屏障，永恒黎明
		{AuraID =  413027, UnitID = "target", Flash = true}, -- 泰坦之壁，永恒黎明
		{AuraID =  419511, UnitID = "target", Value = true}, -- 时光联结，永恒黎明
		-- DF Raids
		{AuraID =  374779, UnitID = "target", Flash = true}, -- 原始屏障，恐怖图腾
		{AuraID =  382530, UnitID = "target", Value = true}, -- 涌动，莱萨杰斯
		{AuraID =  388431, UnitID = "target", Flash = true}, -- 毁灭帷幕，莱萨杰斯
		{AuraID =  388691, UnitID = "target", Value = true}, -- 风暴喷涌，莱萨杰斯
		{AuraID =  396734, UnitID = "target", Flash = true}, -- 风暴遮罩，莱萨杰斯
		{AuraID =  397383, UnitID = "target", Value = true}, -- 熔火屏障，
		{AuraID =  403284, UnitID = "target", Flash = true}, -- 虚空增效，萨卡雷斯
		{AuraID =  407036, UnitID = "target", Value = true}, -- 隐匿虚空，耐萨里奥的回响
		{AuraID =  407617, UnitID = "target", Value = true}, -- 时空畸体，里翁苏斯
		{AuraID =  410654, UnitID = "target", Flash = true}, -- 虚空增效，萨卡雷斯
		{AuraID =  421013, UnitID = "target", Flash = true}, -- 培植毁灭，瘤根
		{AuraID =  421922, UnitID = "target", Value = true}, -- 腐蚀，菲莱克
		{AuraID =  424140, UnitID = "target", Value = true}, -- 超级新星，丁达尔
		-- TWW Party
		{AuraID =  256493, UnitID = "target"}, -- 炽燃的艾泽里特，矿区1
		{AuraID =  271867, UnitID = "target"}, -- 氪金致胜，矿区1
		{AuraID =  273721, UnitID = "target", Flash = true}, -- 围攻，1号易伤
		{AuraID =  320293, UnitID = "target", Value = true}, -- 伤逝剧场，融入死亡
		{AuraID =  321754, UnitID = "target", Value = true}, -- 通灵战潮，冰缚之盾
		{AuraID =  322569, UnitID = "target"}, -- 仙林，兹洛斯之手
		{AuraID =  323059, UnitID = "target", Flash = true}, -- 仙林，宗主之怒
		{AuraID =  323149, UnitID = "target"}, -- 仙林，黑暗之拥
		{AuraID =  328351, UnitID = "target", Flash = true}, -- 通灵战潮，染血长枪
		{AuraID =  331275, UnitID = "target", Flash = true}, -- 伤逝剧场，不灭护卫
		{AuraID =  336499, UnitID = "target"}, -- 仙林，猜谜游戏
		{AuraID =  340191, UnitID = "target", Value = true}, -- 仙林，再生辐光
		{AuraID =  343470, UnitID = "target", Value = true}, -- 通灵战潮，碎骨之盾
		{AuraID =  423588, UnitID = "target", Value = true}, -- 修道院，圣光屏障
		{AuraID =  423839, UnitID = "target", Value = true}, -- 风暴复仇，驭雷栖巢
		{AuraID =  428150, UnitID = "target", Value = true}, -- 反射护盾，高阶牧师艾姆雅
		{AuraID =  445262, UnitID = "target", Value = true}, -- 虚空壳壁，驭雷栖巢
		{AuraID =  445409, UnitID = "target", Value = true}, -- 加固壳壁，斯卡莫拉克
		{AuraID =  446794, UnitID = "target", Flash = true}, -- 贪得无厌，阿瓦诺克斯
		{AuraID = 1241023, UnitID = "target", Value = true}, -- 最终警告，佐·格伦
		-- TWW Raids
		{AuraID =  440177, UnitID = "target", Flash = true}, -- 准备饕餮，噬灭者乌格拉克斯
		{AuraID =  440179, UnitID = "target", Flash = true}, -- 缠绕，阿努巴拉什
		{AuraID =  448488, UnitID = "target", Value = true}, -- 崇拜者的保护，尾王
		{AuraID =  450980, UnitID = "target", Value = true}, -- 存在瓦解，塔卡兹基
		{AuraID =  451277, UnitID = "target", Value = true}, -- 尖刺风暴，阿努巴拉什
		{AuraID =  451334, UnitID = "target", Flash = true}, -- 力勉心衰，阿努巴拉什
		{AuraID =  456245, UnitID = "target", Flash = true}, -- 刺痛谵妄，塔卡兹基
		-- PVP
		{AuraID =     498, UnitID = "target"}, -- 圣佑术
		{AuraID =     642, UnitID = "target"}, -- 圣盾术
		{AuraID =     871, UnitID = "target"}, -- 盾墙
		{AuraID =    1022, UnitID = "target"}, -- 保护祝福
		{AuraID =    1044, UnitID = "target"}, -- 自由祝福
		{AuraID =    5277, UnitID = "target"}, -- 闪避
		{AuraID =    6940, UnitID = "target"}, -- 牺牲祝福
		{AuraID =   19574, UnitID = "target"}, -- 狂野怒火
		{AuraID =   23920, UnitID = "target"}, -- 法术反射
		{AuraID =   31884, UnitID = "target"}, -- 复仇之怒
		{AuraID =   33206, UnitID = "target"}, -- 痛苦压制
		{AuraID =   45438, UnitID = "target"}, -- 寒冰屏障
		{AuraID =   47585, UnitID = "target"}, -- 消散
		{AuraID =   47788, UnitID = "target"}, -- 守护之魂
		{AuraID =   48707, UnitID = "target"}, -- 反魔法护罩
		{AuraID =   48792, UnitID = "target"}, -- 冰封之韧
		{AuraID =   61336, UnitID = "target"}, -- 生存本能
		{AuraID =  104773, UnitID = "target"}, -- 不灭决心
		{AuraID =  113862, UnitID = "target"}, -- 强化隐形术
		{AuraID =  114050, UnitID = "target"}, -- 升腾 元素
		{AuraID =  114051, UnitID = "target"}, -- 升腾 增强
		{AuraID =  114052, UnitID = "target"}, -- 升腾 恢复
		{AuraID =  118038, UnitID = "target"}, -- 剑在人在
		{AuraID =  120954, UnitID = "target"}, -- 壮胆酒
		{AuraID =  122278, UnitID = "target"}, -- 躯不坏
		{AuraID =  122783, UnitID = "target"}, -- 散魔功
		{AuraID =  125174, UnitID = "target"}, -- 业报之触
		{AuraID =  147833, UnitID = "target"}, -- 援护
		{AuraID =  162264, UnitID = "target"}, -- 恶魔变形
		{AuraID =  171607, UnitID = "target"}, -- 爱情光线
		{AuraID =  186265, UnitID = "target"}, -- 灵龟守护
		{AuraID =  187827, UnitID = "target"}, -- 恶魔变形
		{AuraID =  188499, UnitID = "target"}, -- 刃舞
		{AuraID =  199754, UnitID = "target"}, -- 还击
		{AuraID =  204018, UnitID = "target", Flash = true}, -- 破咒祝福
		{AuraID =  205191, UnitID = "target"}, -- 以眼还眼 惩戒
		{AuraID =  210152, UnitID = "target"}, -- 刃舞
		{AuraID =  212800, UnitID = "target"}, -- 疾影
		{AuraID =  228323, UnitID = "target", Value = true}, -- 克罗塔的护盾
		{AuraID =  247938, UnitID = "target"}, -- 混乱之刃
	},
	["Focus Aura"] = { -- 焦点光环组
	},
	["Spell Cooldown"] = { -- 冷却计时组
		{SlotID =  1}, -- 头部
		{SlotID =  2}, -- 颈部
		{SlotID =  3}, -- 肩部
		{SlotID =  5}, -- 胸部
		{SlotID =  6}, -- 腰部
		{SlotID =  7}, -- 腿部
		{SlotID =  8}, -- 脚部
		{SlotID =  9}, -- 腕部
		{SlotID = 10}, -- 手部
		{SlotID = 11}, -- 手指1
		{SlotID = 12}, -- 手指2
		{SlotID = 13}, -- 饰品1
		{SlotID = 14}, -- 饰品2
		{SlotID = 15}, -- 背部
		{SlotID = 16}, -- 主手
		{SlotID = 17}, -- 副手
	},
	["InternalCD"] = { -- 自定义内置冷却组
		{IntID =  114018, Duration = 15, OnSuccess = true, UnitID = "all"}, -- 帷幕
		{IntID =  353635, Duration = 30, OnSuccess = true, UnitID = "all"}, -- 坍缩之星自爆时间
		{IntID =  410232, Duration = 120}, -- 孢子披风冷却
		{IntID =  451568, Duration = 60}, -- 折转侵攻模组
		{IntID = 1237711, Duration = 30, OnSuccess = true},-- 扭曲的远征
	},
}

module:AddNewAuraWatch("ALL", list)