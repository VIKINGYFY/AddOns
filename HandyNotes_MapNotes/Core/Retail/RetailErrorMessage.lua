local ADDON_NAME, ns = ...

ns._suppressBlockedUntil = ns._suppressBlockedUntil or 0

function ns.SuppressInterfaceBlockedFor(seconds)
  local dur = seconds or 0.8
  ns._suppressBlockedUntil = GetTime() + dur

  BS_ApplySilence()
  ArmWindowRestore(dur)

  ns.PurgeOurTaintsNow()
  C_Timer.After(0.05, ns.PurgeOurTaintsNow)
  C_Timer.After(dur + 0.02, ns.PurgeOurTaintsNow)

  _ScheduleMapNotesTaintWipes(dur)
end

function ns.TrySetPropagate(btn, value)
  ns.SuppressInterfaceBlockedFor(0.8)
  local ok, err = pcall(btn.SetPropagateMouseClicks, btn, value)
  return ok, err
end

local function StripWoWCodes(s)
  if type(s) ~= "string" then return "" end
  s = s:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
       :gsub("|H.-|h", ""):gsub("|h", "")
       :gsub("%s+", " ")
  return s
end

local function IsMapNotesSetPropagateTaintMsg(msg)
  if type(msg) ~= "string" then return false end
  local m = msg:lower()
  return m:find("addon_action_blocked", 1, true)
     and m:find("handynotes_mapnotes", 1, true)
     and (m:find("setpropagatemouseclicks", 1, true) 
     or m:find(":setpropagatemouseclicks", 1, true) 
     or m:find("setpassthroughbuttons", 1, true)
     or m:find(":setpassthroughbuttons", 1, true))
end

local bugSackTriggers = {
  deDE="bugsack: du hast einen fehler entdeckt", 
  enUS="bugsack: you have found an error",
  enGB="bugsack: you have found an error", 
  frFR="bugsack: vous avez trouvé une erreur",
  esES="bugsack: ¡ha ocurrido un error!", 
  esMX="bugsack: ¡ha ocurrido un error!",
  itIT="bugsack: hai trovato un bug", 
  ptBR="bugsack: você encontrou um erro",
  ruRU="bugsack: у тебя муха в супе", 
  zhCN="bugsack: 这里有一个恶心的错误",
  zhTW="bugsack: 在你的湯裡有一隻臭蟲啊！", 
  koKR="bugsack: 수프에 벌레가 있습니다",
}

local function ShouldBlockChat(raw)
  local s = StripWoWCodes(raw):lower()
  local inWindow = GetTime() <= (ns._suppressBlockedUntil or 0)

  local iab = (INTERFACE_ACTION_BLOCKED and INTERFACE_ACTION_BLOCKED:lower()) or "interface action failed because of an addon"
  local iabm = (INTERFACE_ACTION_BLOCKED_MODULAR and INTERFACE_ACTION_BLOCKED_MODULAR:lower()) or ""
  local isInterfaceBlocked = (iab ~= "" and s:find(iab,1,true)) or (iabm ~= "" and s:find(iabm,1,true))

  if isInterfaceBlocked then
    local mentions = s:find("setpropagatemouseclicks", 1, true) or s:find("setpassthroughbuttons", 1, true)
    return mentions or inWindow
  end

  if inWindow then
    local trigger = bugSackTriggers[GetLocale()]
    if trigger and s:find(trigger:lower(), 1, true) then
      return true
    end
  end
  return false
end

local function InstallChatHooks()
  for i = 1, (NUM_CHAT_WINDOWS or 10) do
    local f = _G["ChatFrame"..i]
    if f and f.AddMessage and not f.__MN_OrigAddMessage then
      f.__MN_OrigAddMessage = f.AddMessage
      f.AddMessage = function(self, msg, ...)
        if ShouldBlockChat(msg) then return end
        return self:__MN_OrigAddMessage(msg, ...)
      end
    end
  end

  if type(ChatFrame_DisplaySystemMessageInPrimary) == "function" and not _G.__MN_PrimaryHook then
    _G.__MN_PrimaryHook = true
    local orig = ChatFrame_DisplaySystemMessageInPrimary
    ChatFrame_DisplaySystemMessageInPrimary = function(msg, ...)
      if ShouldBlockChat(msg) then return end
      return orig(msg, ...)
    end
  end
end

local function PatchBugGrabber()
  if not BugGrabber then return end
  local target = BugGrabber
  local mt = getmetatable(BugGrabber)
  if mt and type(mt.__index)=="table" and type(mt.__index.StoreBug)=="function" then
    target = mt.__index
  end
  if target.__MN_StorePatched or type(target.StoreBug) ~= "function" then return end

  target.__MN_StorePatched = true
  local orig = target.StoreBug
  function target:StoreBug(bug, ...)
    local msg = (type(bug)=="table" and (bug.message or bug.error or bug.msg or bug.text)) or tostring(bug or "")
    if GetTime() <= (ns._suppressBlockedUntil or 0) and IsMapNotesSetPropagateTaintMsg(msg or "") then
      return
    end
    return orig(self, bug, ...)
  end
end


local function PatchBugSack()
  if not BugSack then return end
  local remain = (ns._suppressBlockedUntil or 0) - GetTime()
  if remain > 0 then
    BS_ApplySilence()
    ArmWindowRestore(remain)
  end
end

ns.__BS = ns.__BS or { active=false, guard_id=0, origMute=nil, origAuto=nil, origChat=nil, origOpenSack=nil }

local function _ShouldBlockAutoOpenNow()
  if GetTime() > (ns._suppressBlockedUntil or 0) then return false end
  if type(debugstack) ~= "function" then return true end
  local st = (debugstack(3, 10, 10) or ""):lower()
  return st:find("buggrabber", 1, true) or st:find("callbackhandler", 1, true)
end

function BS_ApplySilence()
  if not BugSack or not BugSack.db then return false end

  if not ns.__BS.active then
    ns.__BS.origMute = BugSack.db.mute
    ns.__BS.origAuto = BugSack.db.auto
    ns.__BS.origChat = BugSack.db.chatframe
    ns.__BS.origOpenSack = BugSack.OpenSack
  end

  BugSack.db.chatframe = false
  BugSack.db.auto = false
  BugSack.db.mute = true

  if type(BugSack.OpenSack) == "function" then
    BugSack.OpenSack = function(self, ...)
      if _ShouldBlockAutoOpenNow() then
        return
      end
      return ns.__BS.origOpenSack and ns.__BS.origOpenSack(self, ...)
    end
  end

  ns.__BS.active = true
  return true
end

local function BS_RestoreSilence()
  if not BugSack or not BugSack.db or not ns.__BS.active then return end
  if ns.__BS.origChat ~= nil then BugSack.db.chatframe = ns.__BS.origChat end
  if ns.__BS.origAuto ~= nil then BugSack.db.auto = ns.__BS.origAuto end
  if ns.__BS.origMute ~= nil then BugSack.db.mute = ns.__BS.origMute end
  if ns.__BS.origOpenSack then BugSack.OpenSack = ns.__BS.origOpenSack end
  ns.__BS.active = false
  ns.__BS.origMute, ns.__BS.origAuto, ns.__BS.origChat, ns.__BS.origOpenSack = nil, nil, nil, nil
end



ns.__SND = ns.__SND or { active=false, guard_id=0, origPS=nil, origPSF=nil }
function SoundGate_Apply()
  if ns.__SND.active then return end
  ns.__SND.origPS  = ns.__SND.origPS  or _G.PlaySound
  ns.__SND.origPSF = ns.__SND.origPSF or _G.PlaySoundFile

  local function shouldSuppressNow() -- mute bugsack for mapnotes setpropagatemouseclicks error
    if GetTime() > (ns._suppressBlockedUntil or 0) then return false end
    if type(debugstack) ~= "function" then return false end
    local st = debugstack(2, 8, 8)
    st = st and st:lower() or ""
    return st:find("bugsack", 1, true)
  end

  if type(_G.PlaySound) == "function" then
    _G.PlaySound = function(...)
      if shouldSuppressNow() then return end
      return ns.__SND.origPS(...)
    end
  end
  if type(_G.PlaySoundFile) == "function" then
    _G.PlaySoundFile = function(...)
      if shouldSuppressNow() then return end
      return ns.__SND.origPSF(...)
    end
  end

  ns.__SND.active = true
end

function ArmWindowRestore(duration)
  local dur = duration or (ns._suppressBlockedUntil - GetTime())
  local delay = math.max(0.05, (dur or 0) + 0.01)

  ns.__BS.guard_id  = (ns.__BS.guard_id or 0) + 1
  local my_bs  = ns.__BS.guard_id

  C_Timer.After(delay, function()
    if my_bs == ns.__BS.guard_id and GetTime() >= (ns._suppressBlockedUntil or 0) then
      BS_RestoreSilence()
    end
  end)
end

local function _msgOf(e)
  return type(e)=="table" and (e.message or e.error or e.msg or e.text or "") or tostring(e or "")
end

local function _purgeList(list)
  if type(list) ~= "table" then return 0 end
  local removed = 0
  for i = #list, 1, -1 do
    if IsMapNotesSetPropagateTaintMsg(_msgOf(list[i])) then
      table.remove(list, i)
      removed = removed + 1
    end
  end
  return removed
end

function ns.PurgeOurTaintsNow()
  local removed = 0

  if BugGrabber then
    if type(BugGrabber.GetSessionErrors)=="function" then
      local sess = BugGrabber:GetSessionErrors()
      removed = removed + _purgeList(sess)
    end
    removed = removed + _purgeList(BugGrabber.errors)
    if BugGrabber.db then removed = removed + _purgeList(BugGrabber.db.errors) end
  end

  removed = removed + _purgeList(_G.BugGrabberDB and _G.BugGrabberDB.errors)

  if BugSack then
    if type(BugSack.UpdateDisplay)=="function" then pcall(BugSack.UpdateDisplay, BugSack) end
    local any = false
    if BugGrabber and type(BugGrabber.GetSessionErrors)=="function" then
      local sess = BugGrabber:GetSessionErrors()
      any = type(sess)=="table" and #sess > 0
    end
    if not any and _G.BugGrabberDB and type(_G.BugGrabberDB.errors)=="table" then
      any = #_G.BugGrabberDB.errors > 0
    end
    local frame = _G.BugSackFrame or BugSack.frame
    if frame and frame:IsShown() and not any then
      if type(BugSack.CloseSack)=="function" then
        pcall(BugSack.CloseSack, BugSack)
      else
        frame:Hide()
      end
    end
  end
  return removed
end

function ns.WipeStoredMapNotesTaints()
  local db = _G.BugGrabberDB
  if not db or type(db.errors) ~= "table" then return 0 end

  local t = db.errors
  local removed = 0
  for i = #t, 1, -1 do
    local e = t[i]
    local msg = (type(e)=="table" and (e.message or e.error or e.msg or e.text)) or tostring(e or "")
    if IsMapNotesSetPropagateTaintMsg((msg or "")) then
      local cnt = tonumber(type(e)=="table" and e.counter) or 1
      table.remove(t, i)
      removed = removed + cnt
    end
  end

  if BugSack and type(BugSack.UpdateDisplay)=="function" then
    pcall(BugSack.UpdateDisplay, BugSack)
  end
  return removed
end

function _ScheduleMapNotesTaintWipes(duration)
  local d = duration or 0.8
  local deadline = GetTime() + d + 0.05
  ns.WipeStoredMapNotesTaints()
  C_Timer.After(0.05, ns.WipeStoredMapNotesTaints)
  C_Timer.After(d + 0.02, ns.WipeStoredMapNotesTaints)

  if not _G.BugGrabberDB then
    if ns.__MN_WipeOnceFrame then
      ns.__MN_WipeOnceFrame:UnregisterAllEvents()
      ns.__MN_WipeOnceFrame:SetScript("OnEvent", nil)
      ns.__MN_WipeOnceFrame = nil
    end
    ns.__MN_WipeOnceFrame = CreateFrame("Frame")
    ns.__MN_WipeOnceFrame:RegisterEvent("ADDON_LOADED")
    ns.__MN_WipeOnceFrame:SetScript("OnEvent", function(self, _, name)
      if name == "!BugGrabber" and GetTime() <= deadline then
        ns.WipeStoredMapNotesTaints()
      end
      self:UnregisterAllEvents()
      self:SetScript("OnEvent", nil)
      ns.__MN_WipeOnceFrame = nil
    end)
  end
end

local function EnsurePatches()
  InstallChatHooks()
  PatchBugGrabber()
  PatchBugSack()
end

function ns.ErrorMessages()
  if ns.__ErrorMessagesInstalled then return end
  ns.__ErrorMessagesInstalled = true

  EnsurePatches()

  if not ns.__ErrorMessagesEventFrame then
    local f = CreateFrame("Frame")
    ns.__ErrorMessagesEventFrame = f
    f:RegisterEvent("PLAYER_LOGIN")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function(_, event, arg1)
      if event == "PLAYER_LOGIN" then
        EnsurePatches()
        if (ns._suppressBlockedUntil or 0) > GetTime() then
          BS_ApplySilence(); ArmWindowRestore(ns._suppressBlockedUntil - GetTime())
        end
      elseif event == "ADDON_LOADED" then
        if arg1 == "!BugGrabber" or arg1 == "BugSack" then
          EnsurePatches()
          if arg1 == "BugSack" and (ns._suppressBlockedUntil or 0) > GetTime() then
            BS_ApplySilence(); ArmWindowRestore(ns._suppressBlockedUntil - GetTime())
          end
        end
      end
    end)
  end
end

SLASH_MNSUPTEST1 = "/mnsuptrig"
SlashCmdList["MNSUPTEST"] = function()
  ns.SuppressInterfaceBlockedFor(0.8)
  local f = DEFAULT_CHAT_FRAME
  f:AddMessage("|cffffff00Interface-Aktion auf Grund eines Addons fehlgeschlagen|r")
  f:AddMessage("|cff00ff00BugSack: Du hast einen Fehler entdeckt!|r")
  f:AddMessage("|cffffffff[neutral sofort] Diese Zeile sollte sichtbar sein.|r")
  C_Timer.After(1.0, function()
    f:AddMessage("|cffffff00Interface-Aktion auf Grund eines Addons fehlgeschlagen (nach 1s)|r")
    f:AddMessage("|cff00ff00BugSack: Du hast einen Fehler entdeckt! (nach 1s)|r")
    f:AddMessage("|cffffffff[neutral 1s] Diese Zeile sollte sichtbar sein.|r")
  end)
end