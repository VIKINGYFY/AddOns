local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
ns.locale = GetLocale()

local npcNameCache = {}
local retryQueue = {}
local retryTimer
local maxRetries = 10 -- try
local retryInterval = 1 -- interval in seconds
local maxPerTickBase = 20 -- max tick
local timeBudgetMs = 6 -- per tick

function ns.GetNpcInfo(npcID)
    if not npcID then return end
    if npcNameCache[npcID] then return unpack(npcNameCache[npcID]) end

    local tooltipData = C_TooltipInfo.GetHyperlink("unit:Creature-0-0-0-0-" .. npcID .. "-0000000000")
    if not tooltipData or not tooltipData.lines or not tooltipData.lines[1] then
        return nil, nil
    end

    local npcName  = tooltipData.lines[1] and tooltipData.lines[1].leftText or nil
    local npcTitle = tooltipData.lines[2] and tooltipData.lines[2].leftText or nil

    if not npcName or npcName == "" then
        return nil, nil
    end

    npcNameCache[npcID] = { npcName, npcTitle }
    return npcName, npcTitle
end

function ns.PrimeNpcNameCache()
    local seen = {}
    local successCount = 0
    local failCount = 0

    for mapID, nodes in pairs(ns.nodes or {}) do
        for coord, node in pairs(nodes) do
            local ids = {}

            if node.npcID then table.insert(ids, node.npcID) end
            for i = 1, 10 do
                local id = node["npcIDs" .. i]
                if id then table.insert(ids, id) end
            end

            for _, npcID in ipairs(ids) do
                if not seen[npcID] then
                    seen[npcID] = true
                    local name = ns.GetNpcInfo(npcID)
                    if name then
                        successCount = successCount + 1
                    else
                        failCount = failCount + 1
                        retryQueue[npcID] = {
                            attempts = 0,
                            mapID = mapID,
                            coord = coord,
                            sourceFile = node.sourceFile or ns._currentSourceFile or "?"
                        }
                        if ns.Addon.db.profile.DeveloperMode then
                            print(("%s Missing NPC: %d (mapID: %d, coord: %.2f, file: %s)"):format(ns.COLORED_ADDON_NAME, npcID, mapID, coord, retryQueue[npcID].sourceFile))
                        end
                    end
                end
            end
        end
    end

    local cachingTextDone = ns.LOCALE_CACHING_DONE[ns.locale] or ns.LOCALE_CACHING_DONE["enUS"] or "update database"
    if ns.Addon.db.profile.DeveloperMode or ns._manualScanActive then
        print(("%s %s - %d found, %d missing"):format(ns.COLORED_ADDON_NAME, cachingTextDone, successCount, failCount))
    end

    if failCount > 0 then
      local cachingText = ns.LOCALE_RETRY[ns.locale] or ns.LOCALE_RETRY["enUS"]
      print(ns.COLORED_ADDON_NAME .. " " .. cachingText .. " ...")
      ns.StartRetryQueue()
    end
end

function ns.StartRetryQueue()
  if retryTimer then return end

  retryTimer = C_Timer.NewTicker(retryInterval, function()
    local processed = 0
    local fps = GetFramerate() or 60
    local scale
    if     fps >= 120 then scale = 1.00
    elseif fps >=  90 then scale = 0.85
    elseif fps >=  60 then scale = 0.70
    elseif fps >=  45 then scale = 0.55
    elseif fps >=  30 then scale = 0.40
    else                   scale = 0.25
    end
    local maxPerTick = math.max(3, math.floor(maxPerTickBase * scale))
    local startMs = debugprofilestop()

    for npcID, data in pairs(retryQueue) do
      local name = ns.GetNpcInfo(npcID)
      if name then
        retryQueue[npcID] = nil
        if ns.Addon.db.profile.DeveloperMode then
          print(("%s Cached after retry: %d (mapID: %d, file: %s)"):format(
            ns.COLORED_ADDON_NAME, npcID, data.mapID or 0, data.sourceFile or "?"))
        end
      else
        data.attempts = (data.attempts or 0) + 1
        if data.attempts >= maxRetries then
          retryQueue[npcID] = nil
          if ns.Addon.db.profile.DeveloperMode then
            print(("%s Failed to cache: %d after %d tries (mapID: %d, coord: %.2f, file: %s)"):format(ns.COLORED_ADDON_NAME, npcID, maxRetries, data.mapID or 0, data.coord or 0, data.sourceFile or "?"))
          end
        end
      end

      processed = processed + 1
      if processed >= maxPerTick or (debugprofilestop() - startMs) >= timeBudgetMs then
        break
      end
    end

    if next(retryQueue) == nil then
      retryTimer:Cancel()
      retryTimer = nil
      local cachingText = ns.LOCALE_RETRY_DONE[ns.locale] or ns.LOCALE_RETRY_DONE["enUS"]
      print(ns.COLORED_ADDON_NAME .. " " .. cachingText)
    end
  end)
end

function ns.NpcTooltips(tooltip, nodeData )
  if not nodeData then return end

  local npcName, npcTitle = ns.GetNpcInfo(nodeData.npcID)
  if nodeData.type ~= "LFR" then -- hide on "LFR" types
    if npcName then -- single npcID
      tooltip:AddLine("|cffffffff" .. npcName)
    end
    if npcTitle and not npcTitle:match("%?%?+") then -- if no title is present, blizzard replaces it with a dummy with "Level ??"", this suppresses the title instead of creating a dummy ad
      tooltip:AddLine(npcTitle)
    end
  end

  for i = 1, 10 do
    local id   = nodeData["npcIDs" .. i]
    local icon = nodeData["icon"   .. i]
    if id then
      local npcName, npcTitle = ns.GetNpcInfo(id)
      if icon then
        if npcName then
          tooltip:AddLine(npcName or "???")
        end
        if npcTitle and not npcTitle:match("%?%?+") then
          tooltip:AddLine(icon .. " " .. npcTitle)
        end
      else
        if npcName then
          tooltip:AddLine("|cffffffff" .. npcName)
        end
        if npcTitle and not npcTitle:match("%?%?+") then
          tooltip:AddLine(npcTitle)
        end
      end

      if i < 10 and (nodeData["npcIDs" .. (i + 1)] or nodeData.dnID) then -- add a blank line if further IDs follow (except for 10)
        tooltip:AddLine(" ")
      end
    end
  end

  -- old example npcIDs1-9
  --if nodeData.npcIDs1 then -- additional npcIDs
  --  local npcName, npcTitle = ns.GetNpcInfo(nodeData.npcIDs1)
  --  if nodeData.icon1 then
  --    if npcName then 
  --    tooltip:AddLine( (npcName or "???"))
  --    end
  --    if npcTitle and not npcTitle:match("%?%?+") then 
  --      tooltip:AddLine(nodeData.icon1 .. " " .. npcTitle)
  --    end
  --  else
  --    if npcName then 
  --      tooltip:AddLine("|cffffffff" .. npcName)
  --    end
  --    if npcTitle and not npcTitle:match("%?%?+") then 
  --      tooltip:AddLine(npcTitle) 
  --    end
  --  end
  --  if nodeData.npcIDs2 or nodeData.dnID then
  --    tooltip:AddLine(" ")
  --  end
  --end

  -- old example npcIDs10 last NPC name without spacing
  -- if nodeData.npcIDs10 then -- 
  --  local npcName, npcTitle = ns.GetNpcInfo(nodeData.npcIDs10)
  --  if nodeData.icon10 then
  --    if npcName then 
  --      tooltip:AddLine((npcName or "???"))
  --    end
  --    if npcTitle and not npcTitle:match("%?%?+") then 
  --      tooltip:AddLine(nodeData.icon10 .. " " .. npcTitle)
  --    end
  --  else
  --    if npcName then
  --      tooltip:AddLine("|cffffffff" .. npcName) 
  --    end
  --    if npcTitle and not npcTitle:match("%?%?+") then 
  --      tooltip:AddLine(npcTitle)
  --    end
  --  end
  --end

end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, event, addonName)
    if addonName == "HandyNotes_MapNotes" then
      
        if not HandyNotes_MapNotesRetailNpcCacheDB then
            HandyNotes_MapNotesRetailNpcCacheDB = {}
        end

        if HandyNotes_MapNotesRetailNpcCacheDB.lastNpcCacheVersion ~= ns.currentVersion then 
          HandyNotes_MapNotesRetailNpcCacheDB.lastNpcCacheVersion = ns.currentVersion
        
          if ns.PrimeNpcNameCache then
          local cachingText = ns.LOCALE_CACHING[ns.locale] or ns.LOCALE_CACHING["enUS"]
              C_Timer.After(2, function()
                if ns.Addon.db.profile.DeveloperMode then
                  print(ns.COLORED_ADDON_NAME .. " " .. cachingText .. " ...")
                end
                ns.PrimeNpcNameCache()
              end)
          end
        end

    end
end)

function ns.CreateTargetButton(npcName, title)
  if not npcName then return end

  local x, y = GetCursorPosition()
  local scale = UIParent:GetEffectiveScale()
  x, y = x/scale, y/scale

  if not ns.TargetButton then
    local btn = CreateFrame("Button", "MapNotesTargetButton", UIParent,"SecureActionButtonTemplate,UIPanelButtonTemplate")
    btn:SetSize(80, 30)
    btn:SetFrameStrata("FULLSCREEN_DIALOG")
    btn:SetToplevel(true)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    btn:SetScript("OnMouseUp", function(self, button)
      if button == "RightButton" then
        self:Hide()
      end
    end)

    btn:SetScript("PostClick", function(self)
      C_Timer.After(0.2, function()
        if not UnitExists("target") or UnitName("target") ~= npcName then
          local fullName = title and (npcName.." – "..title) or npcName
          local colored  = "|cffffd700"..fullName.."|r"
          if ns.Addon.db.profile.NpcNameTargetingChatText then
            print( ("%s %s (%s)"):format(ns.COLORED_ADDON_NAME, SPELL_FAILED_CUSTOM_ERROR_216, colored))
          end
        end
      end)
      C_Timer.After(0.05, function() self:Hide() end)
    end)

    btn:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_TOP")
      GameTooltip:SetText(ns.COLORED_ADDON_NAME, 1, 1, 1)
      local actionText = ns.LOCALE_TARGETING[ns.locale] or ns.LOCALE_TARGETING["enUS"]
      GameTooltip:AddLine(KEY_BUTTON1 .. " => " .. actionText, 1, 1, 1)
      GameTooltip:AddLine(KEY_BUTTON2 .. " => " .. CANCEL, 1, 1, 1)
      GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", GameTooltip_Hide)

    btn:SetScript("OnHide", function(self)
      self:ClearAllPoints()
      self:SetAttribute("macrotext", nil)
    end)

    ns.TargetButton = btn
  end

  local btn = ns.TargetButton
  btn:ClearAllPoints()
  btn:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
  btn:SetText(npcName)
  local w = btn:GetFontString():GetStringWidth() + 20
  btn:SetWidth(math.max(80, w))

  local macro = string.format( "/target %s\n" .. "/run if UnitExists('target') and (GetRaidTargetIndex('target') or 0) ~= 7 then SetRaidTarget('target', 7) end", npcName )
  btn:SetAttribute("type",      "macro")
  btn:SetAttribute("macrotext", macro)
  btn:Show()
end

function ns.TryCreateTarget(uiMapId, coord, button)
  if ns.Addon.db.profile.NpcNameTargeting then 
    if button ~= "MiddleButton" or not IsShiftKeyDown() then return false end
    
    local cd    = ns.nodes[uiMapId] and ns.nodes[uiMapId][coord]
    local npcID = cd and (cd.npcID or cd.npcIDs1)
    if not npcID then return false end
    
    local npcName, npcTitle = ns.GetNpcInfo(npcID)
    if not npcName then return false end
    local fullName = npcTitle and (npcName.." – "..npcTitle) or npcName
    local colored  = "|cffffd700"..fullName.."|r"
    
    local desiredYards = 102
    
    local nx, ny = HandyNotes:getXY(coord)
    if not (nx and ny) then return false end
    
    -- distanz from GetWorldPosFromMapPos
    local pX, pY, pZ = UnitPosition("player")
    local _, wp = C_Map.GetWorldPosFromMapPos(uiMapId, { x = nx, y = ny })
    if wp then
      local wX, wY, wZ = wp.x, wp.y, wp.z or 0
      local dx, dy     = pX - wX, pY - wY
      local distYards  = math.sqrt(dx*dx + dy*dy)
      
      --local distMeters = distYards * 0.9144
      --print( ("%s Entfernung: %.1f Y / %.1f m"):format( ns.COLORED_ADDON_NAME, distYards, distMeters ))
    
      if distYards <= desiredYards then
        ns.CreateTargetButton(npcName, npcTitle)
      else
        if ns.Addon.db.profile.NpcNameTargetingChatText then
          print( ("%s %s (%s)"):format(ns.COLORED_ADDON_NAME, SPELL_FAILED_CUSTOM_ERROR_216, colored))
        end
      end
    end
  
    return true
  end
end

hooksecurefunc(WorldMapFrame, "Hide", function()
  if ns.TargetButton and ns.TargetButton:IsShown() then
    ns.TargetButton:Hide()
  end
end)

ns.pluginHandler = ns.pluginHandler or {}
ns.pluginHandler.OnEnter = function(self, uiMapId, coord)
  local nodeData = (ns.minimap[uiMapId] and ns.minimap[uiMapId][coord]) or (ns.nodes[uiMapId] and ns.nodes[uiMapId][coord])
  if not nodeData then return end

  local tooltip = (self:GetParent()==WorldMapButton and WorldMapTooltip) or GameTooltip
  if self:GetCenter() > UIParent:GetCenter() then
    tooltip:SetOwner(self, "ANCHOR_LEFT")
  else
    tooltip:SetOwner(self, "ANCHOR_RIGHT")
  end

  ns.NpcTooltips(tooltip, nodeData)
  tooltip:Show()
end

ns.LOCALE_TARGETING = {
  enUS = [[target]],
  deDE = [[anvisieren]],
  frFR = [[cibler]],
  esES = [[apuntar]],
  esMX = [[apuntar]],
  itIT = [[mirare]],
  ptBR = [[mirar]],
  ruRU = [[нацелить]],
  koKR = [[대상 지정]],
  zhCN = [[选定目标]],
  zhTW = [[選定目標]],
}

ns.LOCALE_CACHING = {
  enUS = [[update npc name database]],
  deDE = [[Aktualisiere NPC-Namen Datenbank]],
  frFR = [[Mise à jour de la base de données des noms de PNJ]],
  esES = [[Actualizando base de datos de nombres de PNJ]],
  esMX = [[Actualizando base de datos de nombres de PNJ]],
  itIT = [[Aggiornamento del database dei nomi degli NPC]],
  ptBR = [[Atualizando banco de dados de nomes de NPC]],
  ruRU = [[Обновление базы данных имён NPC]],
  koKR = [[NPC 이름 데이터베이스 업데이트 중]],
  zhCN = [[正在更新NPC名称数据库]],
  zhTW = [[正在更新NPC名稱資料庫]],
}

ns.LOCALE_RETRY = {
  enUS = [[Database is being updated, please wait]],
  deDE = [[Datenbank wird aktualisiert, bitte warten]],
  frFR = [[Mise à jour de la base de données, veuillez patienter]],
  esES = [[La base de datos se está actualizando, por favor espere]],
  esMX = [[La base de datos se está actualizando, por favor espere]],
  itIT = [[Il database è in fase di aggiornamento, attendere prego]],
  ptBR = [[O banco de dados está sendo atualizado, por favor aguarde]],
  ruRU = [[База данных обновляется, пожалуйста, подождите]],
  koKR = [[데이터베이스를 업데이트하는 중입니다. 잠시만 기다려주세요]],
  zhCN = [[数据库正在更新，请稍候]],
  zhTW = [[資料庫正在更新，請稍候]],
}

ns.LOCALE_RETRY_DONE = {
  enUS = [[Database update completed]],
  deDE = [[Datenbankaktualisierung abgeschlossen]],
  frFR = [[Mise à jour de la base de données terminée]],
  esES = [[Actualización de la base de datos completada]],
  esMX = [[Actualización de la base de datos completada]],
  itIT = [[Aggiornamento del database completato]],
  ptBR = [[Atualização do banco de dados concluída]],
  ruRU = [[Обновление базы данных завершено]],
  koKR = [[데이터베이스 업데이트 완료]],
  zhCN = [[数据库更新完成]],
  zhTW = [[資料庫更新完成]],
}

ns.LOCALE_CACHING_DONE = {
  enUS = [[Database check completed]],
  deDE = [[Datenbanküberprüfung abgeschlossen]],
  frFR = [[Vérification de la base de données terminée]],
  esES = [[Comprobación de la base de datos completada]],
  esMX = [[Comprobación de la base de datos completada]],
  itIT = [[Verifica del database completata]],
  ptBR = [[Verificação do banco de dados concluída]],
  ruRU = [[Проверка базы данных завершена]],
  koKR = [[데이터베이스 확인 완료]],
  zhCN = [[数据库检查完成]],
  zhTW = [[資料庫檢查完成]],
}

ns.LOCALE_CACHINGFOUND = {
  enUS = [[new npcID(s) found]],
  deDE = [[neue npcID(s) gefunden]],
  frFR = [[nouveaux ID(s) PNJ trouvés]],
  esES = [[nuevas ID(s) de PNJ encontradas]],
  esMX = [[nuevas ID(s) de PNJ encontradas]],
  itIT = [[nuovi ID NPC trovati]],
  ptBR = [[novas ID(s) de NPC encontradas]],
  ruRU = [[найдены новые ID NPC]],
  koKR = [[새로운 NPC ID 발견됨]],
  zhCN = [[发现新的NPC ID]],
  zhTW = [[發現新的NPC ID]],
}