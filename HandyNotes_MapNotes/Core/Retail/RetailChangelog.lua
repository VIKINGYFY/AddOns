local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
ns.ChangelogPreviousVersion = "3.0.4"
ns.ChangelogCurrentVersion = "3.0.5"

ns.LOCALE_CHANGELOG_NEW = {
  deDE = [[
• In „Hauptstädte +“ - „Transport“ Reiter wurden Kampfhaustier Portalsymbole 
zu der „Portal“ Kategorie hinzugefügt.

• Im „Zonen +“ - „Instanz Symbole“ wurde Haustierkampf Dungeonsymbole hinzugefügt.

• Es wurden Kampfhaustierdungeons in den jeweiligen Zonen hinzugefügt.

• Es wurden Portalsymbole in „Dazar'Alor“, „Boralus“ und „Legion Dalaran“
zu den Kampfhaustierdungeons hinzugefügt.
Zusätzlich wurde eine Anzeige hinzugefügt, die zeigt, ob ihr den jeweiligen
Quest schon abgeschlossen habt, passend zu dem Portal.

• Wenn ihr die „Link“ Funktion im Addon-Menü aktiviert habt, könnt ihr euch den
jeweiligen Quest-Link im Chat anzeigen lassen und mit dem „Link“ dann rauskopieren,
wenn ihr auf diesen Link im Chat klickt.
Es wird immer nur der Quest mit dem Questnamen im Chat ausgegeben, 
wenn dieser auch wirklich fehlt.

• Allgemeine Tooltip-Anzeigen wurden überarbeitet.
Aktivierbar innerhalb des „Allgemein“ - „Erweiterte Optionen“ Reiters unter „Tooltip“.

• Sollte es mal vorkommen, dass bei manchen Spielern nicht alle NPC-Namen angezeigt werden, 
können diese manuell mit der Funktion „NPC-Namen aktualisieren“ im „Allgemein“ - „NPC-Datenbank“ 
Reiter aktualisiert werden.
]],

  enUS = [[
• Added pet battle portal icons to the “Portal” category under the “Capitals +” → “Transport” tab.

• Added pet battle dungeon icons to the “Zones +” → “Instance Symbols” section.

• Pet Battle Dungeons have been added in their respective zones.

• Portal icons were added for Pet Battle Dungeons in Dazar’Alor, Boralus, and Legion Dalaran.
A new indicator has also been added to show if you have already completed the corresponding
quest for the respective portal.

• If the “Link” function is enabled in the addon menu, clicking the “Link” will show the
quest link in chat, which you can then copy. Only missing quests will be shown by name.

• General tooltip displays have been overhauled.
You can toggle them under “General” → “Advanced Options” → “Tooltip.”

• If some NPC names are not displaying for certain players, they can be manually updated using
the “Update NPC Names” function under “General” → “NPC Database.”
]],

  frFR = [[
• Des icônes de portails de combats de mascottes ont été ajoutées à la catégorie « Portail »
sous l’onglet « Capitales + » → « Transport ».

• Des icônes de donjons de combats de mascottes ont été ajoutées à la section « Zones + »
→ « Symboles d’instance ».

• Des donjons de combats de mascottes ont été ajoutés dans leurs zones respectives.

• Des icônes de portails ont été ajoutées pour les donjons de combats de mascottes à
Dazar’Alor, Boralus et Legion Dalaran.
Un nouvel indicateur a également été ajouté pour afficher si vous avez déjà terminé la quête
correspondante au portail.

• Si la fonction « Lien » est activée dans le menu de l’addon, cliquer sur « Lien » affichera
le lien de quête dans le chat, que vous pourrez copier. Seules les quêtes manquantes seront
affichées par nom.

• L’affichage des info-bulles générales a été retravaillé.
Vous pouvez l’activer sous « Général » → « Options avancées » → « Info-bulle ».

• Si certains noms de PNJ n’apparaissent pas pour certains joueurs, ils peuvent être mis à jour
manuellement avec la fonction « Mettre à jour les noms des PNJ » dans « Général »
→ « Base de données PNJ ».
]],

  itIT = [[
• Aggiunte icone dei portali dei combattimenti tra mascotte nella categoria “Portale”
nella scheda “Capitali +” → “Trasporti”.

• Aggiunte icone dei dungeon dei combattimenti tra mascotte nella sezione “Zone +”
→ “Simboli Istanze”.

• Aggiunti dungeon di combattimento tra mascotte nelle relative zone.

• Aggiunte icone dei portali per i dungeon di combattimento tra mascotte a
Dazar’Alor, Boralus e Legion Dalaran.
È stato inoltre aggiunto un indicatore per mostrare se hai già completato la missione
correlata al portale.

• Se la funzione “Link” è attivata nel menu dell’addon, fare clic su “Link” mostrerà il
collegamento della missione nella chat, che potrai copiare. Verranno mostrati solo i nomi
delle missioni mancanti.

• Le visualizzazioni generali dei tooltip sono state riviste.
Puoi attivarle in “Generale” → “Opzioni avanzate” → “Tooltip”.

• Se i nomi di alcuni PNG non vengono visualizzati per alcuni giocatori, possono essere
aggiornati manualmente con la funzione “Aggiorna nomi PNG” in “Generale”
→ “Database PNG”.
]],

  esES = [[
• Se han añadido iconos de portales de combates de mascotas a la categoría “Portal”
en la pestaña “Capitales +” → “Transporte”.

• Se han añadido iconos de mazmorras de combates de mascotas en la sección “Zonas +”
→ “Símbolos de instancia”.

• Se han añadido mazmorras de combates de mascotas en sus respectivas zonas.

• Se añadieron iconos de portales para mazmorras de combates de mascotas en
Dazar’Alor, Boralus y Legión Dalaran.
También se ha añadido un indicador para mostrar si ya completaste la misión
correspondiente al portal.

• Si la función “Link” está activa en el menú del addon, al hacer clic en “Link”
se mostrará el enlace de la misión en el chat, que podrás copiar. Solo se mostrarán
las misiones que te falten.

• Se ha rehecho la visualización general de tooltips.
Puedes activarla en “General” → “Opciones avanzadas” → “Tooltip”.

• Si a algunos jugadores no se les muestran todos los nombres de PNJ, pueden
actualizarlos manualmente usando la función “Actualizar nombres de PNJ” en
“General” → “Base de datos de PNJ”.
]],

  esMX = [[
• Se agregaron íconos de portales de combates de mascotas a la categoría “Portal”
en la pestaña “Capitales +” → “Transporte”.

• Se agregaron íconos de mazmorras de combates de mascotas en la sección “Zonas +”
→ “Símbolos de instancia”.

• Se agregaron mazmorras de combates de mascotas en sus zonas respectivas.

• Se agregaron íconos de portales para mazmorras de combates de mascotas en
Dazar’Alor, Boralus y Legión Dalaran.
También se añadió un indicador que muestra si ya completaste la misión
correspondiente al portal.

• Si la función “Link” está habilitada en el menú del addon, al hacer clic en “Link”
se mostrará el enlace de la misión en el chat, que puedes copiar. Solo se mostrarán
las misiones faltantes.

• Se revisó la visualización general de tooltips.
Puedes activarla en “General” → “Opciones avanzadas” → “Tooltip”.

• Si ciertos jugadores no ven todos los nombres de PNJ, pueden actualizar
manual-mente usando la función “Actualizar nombres de PNJ” en
“General” → “Base de datos de PNJ”.
]],

  ruRU = [[
• В разделе «Столицы +» → «Транспорт» были добавлены значки порталов для
бегемот-боев (питомцев).

• В разделе «Зоны +» → «Символы подземелий» были добавлены значки питомец-боев.

• Питомец-подземелья были добавлены в соответствующих зонах.

• Были добавлены значки порталов для питомец-подземелий в Dazar’Alor, Boralus и
Legion Dalaran.
Также добавлен индикатор, который показывает, завершена ли соответствующая
задача к порталу.

• Если в меню аддона включена функция «Ссылка», при клике по «Ссылке» в чат
выводится ссылка на квест, которую можно скопировать. Отображаются только
отсутствующие квесты.

• Общие отображения всплывающих подсказок были переработаны.
Вы можете включить их в разделе «Общее» → «Расширенные параметры» → «Подсказка».

• Если у некоторых игроков не отображаются имена NPC, их можно вручную
обновить через функцию «Обновить имена NPC» в разделе «Общее»
→ «База данных NPC».
]],

  ptBR = [[
• Foram adicionados ícones de portais de batalhas de mascotes à categoria “Portal”
na aba “Capitais +” → “Transporte”.

• Foram adicionados ícones de masmorras de batalhas de mascotes na seção “Zonas +”
→ “Símbolos de Instância”.

• Masmorras de batalha de mascotes foram adicionadas em suas zonas correspondentes.

• Foram adicionados ícones de portais para masmorras de batalha de mascotes em
Dazar’Alor, Boralus e Legião Dalaran.
Também foi adicionado um indicador que mostra se você já completou a missão
correspondente ao portal.

• Se a função “Link” estiver ativada no menu do addon, ao clicar em “Link”
o link da missão será exibido no chat, e você poderá copiá-lo. Apenas missões
faltando serão mostradas.

• As exibições gerais das tooltips foram revisadas.
Você pode ativá-las em “Geral” → “Opções Avançadas” → “Tooltip”.

• Se nomes de alguns NPCs não estiverem aparecendo para certos jogadores,
eles podem ser atualizados manualmente com a função “Atualizar nomes de NPC”
em “Geral” → “Banco de Dados de NPC”.
]],

  zhCN = [[
• 在“首都 +” → “传送”标签下的“传送门”分类中，添加了战斗小宠物传送门图标。

• 在“区域 +” → “副本图标”部分，添加了战斗小宠物副本图标。

• 已在各自区域中添加了战斗小宠物副本。

• 在达萨罗、伯拉勒斯和军团达拉然的小宠物副本中添加了传送门图标。
同时新增了一个指示器，用于显示你是否已完成该传送门对应的任务。

• 如果在插件菜单中启用了“链接”功能，点击“链接”将在聊天中显示任务链接，供你复制。
只有缺少的任务才会以任务名称形式显示。

• 通用鼠标提示显示已重新设计，可在“常规” → “高级选项” → “Tooltip”中启用。

• 如果部分玩家看不到所有 NPC 名称，可以通过“常规” → “NPC 数据库”中的“更新 NPC 名称”功能手动更新。
]],

  zhTW = [[
• 在「首都 +」→「傳送」標籤下的「傳送門」分類中，新增了戰寵戰鬥的傳送門圖示。

• 在「區域 +」→「副本圖示」部分，新增了戰寵戰鬥副本圖示。

• 各區域已新增戰寵戰鬥副本。

• 在達薩羅、伯拉勒斯與軍團達拉然的戰寵戰鬥副本添加了傳送門圖示。
並新增一個指示器，顯示你是否已完成與該傳送門關聯的任務。

• 若在插件選單啟用了「連結」功能，點擊「連結」會在聊天中顯示該任務的連結，可供複製。
只有缺少的任務才會顯示任務名稱。

• 通用提示工具已重新設計，可在「一般」→「進階選項」→「Tooltip」中啟用。

• 若某些玩家無法看到所有 NPC 名稱，可透過「一般」→「NPC 資料庫」中的「更新 NPC 名稱」功能進行手動更新。
]],
}


ns.LOCALE_CHANGELOG_OLD = {
  enUS = [[
• Adjusted NPC names for all The War Within zones.

• Adjusted NPC names for all Dragonflight zones.

• Under "General" – "World Map", a new feature has been added.
This allows you to automatically switch the world map to the map of the new
area when you leave one zone and enter another.
]],

  deDE = [[
• Es wurden die NPC-Namen für alle The War Within Zonen angepasst.

• Es wurden die NPC-Namen für alle Dragonflight Zonen angepasst.

• Unter „Allgemein“ – „Weltkarte“ wurde eine neue Funktion hinzugefügt.
Dadurch können Sie nun die Weltkarte automatisch auf die Karte des neuen 
Gebiets umschalten lassen, wenn Sie eine Zone verlassen und eine neue betreten.
]],

  frFR = [[
• Les noms des PNJ ont été ajustés pour toutes les zones de The War Within.

• Les noms des PNJ ont été ajustés pour toutes les zones de Dragonflight.

• Dans « Général » – « Carte du monde », une nouvelle fonctionnalité a été ajoutée.
Elle vous permet désormais de basculer automatiquement la carte du monde vers
la carte de la nouvelle zone lorsque vous quittez une zone et en entrez une autre.
]],

  itIT = [[
• Aggiornati i nomi degli PNG per tutte le zone di The War Within.

• Aggiornati i nomi degli PNG per tutte le zone di Dragonflight.

• In "Generale" – "Mappa del mondo" è stata aggiunta una nuova funzione.
Ora è possibile far passare automaticamente la mappa del mondo alla mappa della
nuova area quando si lascia una zona ed entra in un’altra.
]],

  esES = [[
• Se han ajustado los nombres de los PNJ para todas las zonas de The War Within.

• Se han ajustado los nombres de los PNJ para todas las zonas de Dragonflight.

• En «General» – «Mapa del mundo» se ha añadido una nueva función.
Ahora puedes hacer que el mapa del mundo cambie automáticamente al mapa de la
nueva zona cuando salgas de una y entres en otra.
]],

  esMX = [[
• Se ajustaron los nombres de los PNJ para todas las zonas de The War Within.

• Se ajustaron los nombres de los PNJ para todas las zonas de Dragonflight.

• En «General» – «Mapa del mundo» se añadió una nueva función.
Ahora puedes hacer que el mapa del mundo cambie automáticamente al mapa de la
nueva zona cuando salgas de una y entres en otra.
]],

  ruRU = [[
• Были обновлены имена НИПов для всех зон The War Within.

• Были обновлены имена НИПов для всех зон Dragonflight.

• В разделе «Общее» – «Карта мира» была добавлена новая функция.
Теперь карта мира может автоматически переключаться на карту новой области,
когда вы покидаете одну зону и входите в другую.
]],

  ptBR = [[
• Ajustados os nomes dos PNJs para todas as zonas de The War Within.

• Ajustados os nomes dos PNJs para todas as zonas de Dragonflight.

• Em "Geral" – "Mapa-múndi", foi adicionada uma nova função.
Agora é possível fazer o mapa-múndi mudar automaticamente para o mapa da nova
área quando você sair de uma zona e entrar em outra.
]],

  zhCN = [[
• 已调整所有《地心之战》地区的 NPC 名称。

• 已调整所有《巨龙时代》地区的 NPC 名称。

• 在“常规” – “世界地图”下新增了一项功能。
现在，当你离开一个区域并进入另一个区域时，可以让世界地图自动切换到新区域的地图。
]],

  zhTW = [[
• 已調整所有《地心之戰》地區的 NPC 名稱。

• 已調整所有《巨龍崛起》地區的 NPC 名稱。

• 在「一般」–「世界地圖」中新增了一項功能。
現在，當你離開一個區域並進入另一個區域時，可以讓世界地圖自動切換到新區域的地圖。
]],
}

function ns.ShowChangelogWindow()
  if MapNotesChangelogFrame and MapNotesChangelogFrame:IsShown() or MapNotesChangelogFrameMenu and MapNotesChangelogFrameMenu:IsShown() then return end

  C_Timer.After(0.01, function()
    local LoginChangeLogFrame = CreateFrame("Frame", "MapNotesChangelogFrame", UIParent, "BasicFrameTemplateWithInset")
    LoginChangeLogFrame:SetSize(750, 400)
    LoginChangeLogFrame:SetPoint("CENTER")
    LoginChangeLogFrame:SetMovable(true)
    LoginChangeLogFrame:EnableMouse(true)
    LoginChangeLogFrame:RegisterForDrag("LeftButton")
    LoginChangeLogFrame:SetScript("OnDragStart", LoginChangeLogFrame.StartMoving)
    LoginChangeLogFrame:SetScript("OnDragStop", LoginChangeLogFrame.StopMovingOrSizing)
    LoginChangeLogFrame:SetFrameStrata("DIALOG")
    LoginChangeLogFrame:SetToplevel(true)
    LoginChangeLogFrame:SetClampedToScreen(true)

    LoginChangeLogFrame.title = LoginChangeLogFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    LoginChangeLogFrame.title:SetPoint("TOP", 0, -3)
    LoginChangeLogFrame.title:SetText(ns.COLORED_ADDON_NAME .. "|cffffd700 " .. L["Changelog"])

    LoginChangeLogFrame.fixedVersionText = LoginChangeLogFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    LoginChangeLogFrame.fixedVersionText:SetPoint("TOPLEFT", 10, -5)
    LoginChangeLogFrame.fixedVersionText:SetText("|cffffd700" .. GAME_VERSION_LABEL .. ":|r " .. "|cffff0000" .. ns.ChangelogCurrentVersion)
        
    LoginChangeLogFrame.scrollFrame = CreateFrame("ScrollFrame", nil, LoginChangeLogFrame, "UIPanelScrollFrameTemplate")
    LoginChangeLogFrame.scrollFrame:SetPoint("TOPLEFT", 10, -40)
    LoginChangeLogFrame.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)

    local content = CreateFrame("Frame", nil, LoginChangeLogFrame.scrollFrame) -- EditBox with padding inside frame
    content:SetSize(700, 1)

    LoginChangeLogFrame.editBox = CreateFrame("EditBox", nil, content)
    LoginChangeLogFrame.editBox:SetMultiLine(true)
    LoginChangeLogFrame.editBox:SetFontObject(GameFontHighlight)

    local padding = 38 -- = 1cm left and right
    LoginChangeLogFrame.editBox:SetWidth(700 - (padding * 2))
    LoginChangeLogFrame.editBox:SetPoint("TOPLEFT", padding, 0)
    LoginChangeLogFrame.editBox:SetPoint("RIGHT", content, "RIGHT", -padding, 0)
    LoginChangeLogFrame.editBox:SetAutoFocus(false)

    local changelogText = ns.LOCALE_CHANGELOG_NEW[GetLocale()] or ns.LOCALE_CHANGELOG_NEW["enUS"]
    LoginChangeLogFrame.editBox:SetText("|cffffd700" .. changelogText)
    LoginChangeLogFrame.scrollFrame:SetScrollChild(content)
    LoginChangeLogFrame.checkbox = CreateFrame("CheckButton", nil, LoginChangeLogFrame, "ChatConfigCheckButtonTemplate")
    LoginChangeLogFrame.checkbox:SetPoint("BOTTOMLEFT", 10, 10)
    LoginChangeLogFrame.checkbox.Text:SetText("|cffff0000" .. L["Do not show again until next version"])
    LoginChangeLogFrame.closeButton = CreateFrame("Button", nil, LoginChangeLogFrame, "GameMenuButtonTemplate")
    LoginChangeLogFrame.closeButton:SetPoint("BOTTOMRIGHT", -10, -10)
    LoginChangeLogFrame.closeButton:SetSize(100, 25)
    LoginChangeLogFrame.closeButton:SetText(CLOSE)

    LoginChangeLogFrame.closeButton:SetScript("OnClick", function()
      if LoginChangeLogFrame.checkbox:GetChecked() then
        HandyNotes_MapNotesRetailChangelogDB.lastChangelogVersion = ns.ChangelogCurrentVersion
      end
      LoginChangeLogFrame:Hide()
    end)

    LoginChangeLogFrame:SetScript("OnHide", function()
      if LoginChangeLogFrame.checkbox:GetChecked() then
        HandyNotes_MapNotesRetailChangelogDB.lastChangelogVersion = ns.ChangelogCurrentVersion
      end
    end)

  end)

  table.insert(UISpecialFrames, "MapNotesChangelogFrame")
end

function ns.ShowChangelogWindowMenuNew()
  if (MapNotesChangelogFrame and MapNotesChangelogFrame:IsShown()) or (MapNotesChangelogFrameMenu and MapNotesChangelogFrameMenu:IsShown()) then return end

  local ChangeLogFrameMenu = CreateFrame("Frame", "MapNotesChangelogFrameMenu", UIParent, "BasicFrameTemplateWithInset")
  ChangeLogFrameMenu:SetSize(750, 400)
  ChangeLogFrameMenu:SetPoint("CENTER")
  ChangeLogFrameMenu:SetMovable(true)
  ChangeLogFrameMenu:EnableMouse(true)
  ChangeLogFrameMenu:RegisterForDrag("LeftButton")
  ChangeLogFrameMenu:SetScript("OnDragStart", ChangeLogFrameMenu.StartMoving)
  ChangeLogFrameMenu:SetScript("OnDragStop", ChangeLogFrameMenu.StopMovingOrSizing)
  ChangeLogFrameMenu:SetFrameStrata("DIALOG")
  ChangeLogFrameMenu:SetToplevel(true)
  ChangeLogFrameMenu:SetClampedToScreen(true)

  ChangeLogFrameMenu.title = ChangeLogFrameMenu:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
  ChangeLogFrameMenu.title:SetPoint("TOP", 0, -3)
  ChangeLogFrameMenu.title:SetText(ns.COLORED_ADDON_NAME .. "|cffffd700 " .. L["Changelog"])

  ChangeLogFrameMenu.fixedVersionText = ChangeLogFrameMenu:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  ChangeLogFrameMenu.fixedVersionText:SetPoint("TOPLEFT", 10, -5)
  ChangeLogFrameMenu.fixedVersionText:SetText("|cffffd700" .. GAME_VERSION_LABEL .. ":|r " .. "|cffff0000" .. ns.ChangelogCurrentVersion)

  ChangeLogFrameMenu.scrollFrame = CreateFrame("ScrollFrame", nil, ChangeLogFrameMenu, "UIPanelScrollFrameTemplate")
  ChangeLogFrameMenu.scrollFrame:SetPoint("TOPLEFT", 10, -40)
  ChangeLogFrameMenu.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)

  local content = CreateFrame("Frame", nil, ChangeLogFrameMenu.scrollFrame) -- EditBox with padding inside frame
  content:SetSize(700, 1)
  ChangeLogFrameMenu.editBox = CreateFrame("EditBox", nil, content)
  ChangeLogFrameMenu.editBox:SetMultiLine(true)
  ChangeLogFrameMenu.editBox:SetFontObject(GameFontHighlight)

  local padding = 38 -- = 1cm left and right
  ChangeLogFrameMenu.editBox:SetWidth(700 - padding * 2)
  ChangeLogFrameMenu.editBox:SetPoint("TOPLEFT", padding, 0)
  ChangeLogFrameMenu.editBox:SetPoint("RIGHT", content, "RIGHT", -padding, 0)
  ChangeLogFrameMenu.editBox:SetAutoFocus(false)

  local changelogText = ns.LOCALE_CHANGELOG_NEW[GetLocale()] or ns.LOCALE_CHANGELOG_NEW["enUS"]
  ChangeLogFrameMenu.editBox:SetText("|cffffd700" .. changelogText)
  ChangeLogFrameMenu.scrollFrame:SetScrollChild(content)

  ChangeLogFrameMenu.closeButton = CreateFrame("Button", nil, ChangeLogFrameMenu, "GameMenuButtonTemplate")
  ChangeLogFrameMenu.closeButton:SetPoint("BOTTOMRIGHT", -10, -10)
  ChangeLogFrameMenu.closeButton:SetSize(100, 25)
  ChangeLogFrameMenu.closeButton:SetText(CLOSE)

  ChangeLogFrameMenu.closeButton:SetScript("OnClick", function()
    ChangeLogFrameMenu:Hide()
    LibStub("AceConfigDialog-3.0"):Open("MapNotes")
  end)

  ChangeLogFrameMenu:SetScript("OnHide", function()
    LibStub("AceConfigDialog-3.0"):Open("MapNotes")
  end)

  table.insert(UISpecialFrames, "MapNotesChangelogFrameMenu")
end

function ns.ShowChangelogWindowMenuOld()
  if (MapNotesChangelogFrame and MapNotesChangelogFrame:IsShown()) or (MapNotesChangelogFrameMenu and MapNotesChangelogFrameMenu:IsShown()) then return end

  local ChangeLogFrameMenu = CreateFrame("Frame", "MapNotesChangelogFrameMenu", UIParent, "BasicFrameTemplateWithInset")
  ChangeLogFrameMenu:SetSize(750, 400)
  ChangeLogFrameMenu:SetPoint("CENTER")
  ChangeLogFrameMenu:SetMovable(true)
  ChangeLogFrameMenu:EnableMouse(true)
  ChangeLogFrameMenu:RegisterForDrag("LeftButton")
  ChangeLogFrameMenu:SetScript("OnDragStart", ChangeLogFrameMenu.StartMoving)
  ChangeLogFrameMenu:SetScript("OnDragStop", ChangeLogFrameMenu.StopMovingOrSizing)
  ChangeLogFrameMenu:SetFrameStrata("DIALOG")
  ChangeLogFrameMenu:SetToplevel(true)
  ChangeLogFrameMenu:SetClampedToScreen(true)

  ChangeLogFrameMenu.title = ChangeLogFrameMenu:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
  ChangeLogFrameMenu.title:SetPoint("TOP", 0, -3)
  ChangeLogFrameMenu.title:SetText(ns.COLORED_ADDON_NAME .. "|cffffd700 " .. L["Changelog"])

  ChangeLogFrameMenu.fixedVersionText = ChangeLogFrameMenu:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  ChangeLogFrameMenu.fixedVersionText:SetPoint("TOPLEFT", 10, -5)
  ChangeLogFrameMenu.fixedVersionText:SetText("|cffffd700" .. GAME_VERSION_LABEL .. ":|r " .. "|cffff0000" .. ns.ChangelogPreviousVersion)

  ChangeLogFrameMenu.scrollFrame = CreateFrame("ScrollFrame", nil, ChangeLogFrameMenu, "UIPanelScrollFrameTemplate")
  ChangeLogFrameMenu.scrollFrame:SetPoint("TOPLEFT", 10, -40)
  ChangeLogFrameMenu.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)

  local content = CreateFrame("Frame", nil, ChangeLogFrameMenu.scrollFrame) -- EditBox with padding inside frame
  content:SetSize(700, 1)
  ChangeLogFrameMenu.editBox = CreateFrame("EditBox", nil, content)
  ChangeLogFrameMenu.editBox:SetMultiLine(true)
  ChangeLogFrameMenu.editBox:SetFontObject(GameFontHighlight)

  local padding = 38 -- = 1cm left and right
  ChangeLogFrameMenu.editBox:SetWidth(700 - padding * 2)
  ChangeLogFrameMenu.editBox:SetPoint("TOPLEFT", padding, 0)
  ChangeLogFrameMenu.editBox:SetPoint("RIGHT", content, "RIGHT", -padding, 0)
  ChangeLogFrameMenu.editBox:SetAutoFocus(false)

  local changelogText = ns.LOCALE_CHANGELOG_OLD[GetLocale()] or ns.LOCALE_CHANGELOG_OLD["enUS"]
  ChangeLogFrameMenu.editBox:SetText("|cffffd700" .. changelogText)
  ChangeLogFrameMenu.scrollFrame:SetScrollChild(content)
  ChangeLogFrameMenu.closeButton = CreateFrame("Button", nil, ChangeLogFrameMenu, "GameMenuButtonTemplate")
  ChangeLogFrameMenu.closeButton:SetPoint("BOTTOMRIGHT", -10, -10)
  ChangeLogFrameMenu.closeButton:SetSize(100, 25)
  ChangeLogFrameMenu.closeButton:SetText(CLOSE)

  ChangeLogFrameMenu.closeButton:SetScript("OnClick", function()
    ChangeLogFrameMenu:Hide()
    LibStub("AceConfigDialog-3.0"):Open("MapNotes")
  end)

  ChangeLogFrameMenu:SetScript("OnHide", function()
    LibStub("AceConfigDialog-3.0"):Open("MapNotes")
  end)

  table.insert(UISpecialFrames, "MapNotesChangelogFrameMenu")
end

local DBFrame = CreateFrame("Frame")
DBFrame:RegisterEvent("ADDON_LOADED")
DBFrame:SetScript("OnEvent", function(_, event, addonName)
  if addonName == "HandyNotes_MapNotes" then
    if not HandyNotes_MapNotesRetailChangelogDB then
      HandyNotes_MapNotesRetailChangelogDB = {}
    end

    if not HandyNotes_MapNotesRetailChangelogDB.lastChangelogVersion then
      HandyNotes_MapNotesRetailChangelogDB.lastChangelogVersion = ns.ChangelogPreviousVersion
    end

    if HandyNotes_MapNotesRetailChangelogDB.lastChangelogVersion ~= ns.ChangelogCurrentVersion then
      ns.ShowChangelogWindow()
    end
  end
end)