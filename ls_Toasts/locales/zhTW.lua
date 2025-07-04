﻿-- Contributors: BNS333@Curse, 彩虹の多多@Curse, RainbowUI@Curse

local _, addonTable = ...
local L = addonTable.L

-- Lua
local _G = getfenv(0)

if GetLocale() ~= "zhTW" then return end

L["ANCHOR_FRAME_#"] = "定位框架 #%d"
L["ANCHOR_FRAMES"] = "定位框架"
L["ANCHOR_RESET_DESC"] = "|cffffffffShift-左鍵點擊|r 重置位置。"
L["BORDER"] = "邊框"
L["CHANGELOG"] = "更新紀錄"
L["CHANGELOG_FULL"] = "全部"
L["COLORS"] = "顏色"
L["COORDS"] = "座標"
L["COPPER_THRESHOLD"] = "銅最小值"
L["COPPER_THRESHOLD_DESC"] = "至少要多少銅才會顯示通知面板。"
L["DEFAULT_VALUE"] = "預設值：|cffffd200%s|r"
L["DND"] = "勿擾"
L["DND_TOOLTIP"] = "通知處於勿擾模式將不會在戰鬥中顯示，但會取代成在系統佇列。一但你離開戰鬥，就會開始跳出通知。"
L["DOWNLOADS"] = "下載"
L["FADE_OUT_DELAY"] = "淡出延遲"
L["FILTERS"] = "過濾方式"
L["FLUSH_QUEUE"] = "刷新佇列"
L["FONTS"] = "字體"
L["GROWTH_DIR"] = "成長方向"
L["GROWTH_DIR_DOWN"] = "下"
L["GROWTH_DIR_LEFT"] = "左"
L["GROWTH_DIR_RIGHT"] = "右"
L["GROWTH_DIR_UP"] = "上"
L["ICON_BORDER"] = "圖示邊框"
L["INFORMATION"] = "資訊"
L["NAME"] = "名稱"
L["OPEN_CONFIG"] = "開啟設定"
L["RARITY_THRESHOLD"] = "最低物品品質"
L["SCALE"] = "縮放"
L["SIZE"] = "大小"
L["SKIN"] = "外觀風格"
L["STRATA"] = "框架層級"
L["SUPPORT"] = "支援"
L["TEST"] = "測試"
L["TEST_ALL"] = "全部測試"
L["TOAST_NUM"] = "通知數量"
L["TOAST_TYPES"] = "通知類型"
L["TOGGLE_ANCHORS"] = "切換定位點"
L["TRACK_LOSS"] = "追蹤失去"
L["TRACK_LOSS_DESC"] = "此選項忽略設置的銅幣閥值。"
L["TYPE_LOOT_GOLD"] = "拾取(金錢)"
L["X_OFFSET"] = "水平位置"
L["Y_OFFSET"] = "垂直位置"
L["YOU_LOST"] = "你失去"
L["YOU_RECEIVED"] = "你收到"

-- Retail
L["CURRENCY_THRESHOLD_DESC"] = "輸入 |cffffd200-1|r 來忽略此貨幣，|cffffd2000|r 來停用過濾，或|cffffd200任何大於 0 的數字|r來設定值臨界值，低於這個數值將不會顯示通知。"
L["HANDLE_LEFT_CLICK"] = "允許左鍵點擊"
L["NEW_CURRENCY_FILTER_DESC"] = "輸入兌換通貨 ID"
L["QUEST_ITEMS_DESC"] = "不論品質都要顯示任務物品。"
L["TAINT_WARNING"] = "啟用此選項可能會在戰鬥中打開或關閉某些UI面板時導致錯誤。"
L["THRESHOLD"] = "數量最少要"
L["TOOLTIPS"] = "工具提示"
L["TRANSMOG_ADDED"] = "外觀已加入"
L["TRANSMOG_REMOVED"] = "外觀已移除"
L["TYPE_ACHIEVEMENT"] = "成就"
L["TYPE_ARCHAEOLOGY"] = "考古"
L["TYPE_CLASS_HALL"] = "職業大廳"
L["TYPE_COLLECTION"] = "收藏"
L["TYPE_COLLECTION_DESC"] = "最新收集到的坐騎、寵物和玩具通知。"
L["TYPE_COVENANT"] = "誓盟"
L["TYPE_DUNGEON"] = "地城"
L["TYPE_GARRISON"] = "要塞"
L["TYPE_LOOT_COMMON"] = "拾取(一般)"
L["TYPE_LOOT_COMMON_DESC"] = "由聊天事件觸發的通知，例如：綠色藍色或某些史詩，一切其他不屬於特殊戰利品的處理。"
L["TYPE_LOOT_CURRENCY"] = "拾取(貨幣)"
L["TYPE_LOOT_SPECIAL"] = "拾取(特殊)"
L["TYPE_LOOT_SPECIAL_DESC"] = "由特殊戰利品觸發的通知，例如：贏得擲骰、傳說掉落、個人拾取..等等。"
L["TYPE_RUNECARVING"] = "符文雕刻"
L["TYPE_TRANSMOG"] = "塑形提醒"
L["TYPE_WAR_EFFORT"] = "陣營戰役"
L["TYPE_WORLD_QUEST"] = "世界任務"
