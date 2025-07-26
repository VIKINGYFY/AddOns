local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local previousVersion = "2.9.9"
local currentVersion = "3.0.0"

function ns.ShowChangelogWindow()
    if MapNotesChangelogFrame and MapNotesChangelogFrame:IsShown() or MapNotesChangelogFrameMenu and MapNotesChangelogFrameMenu:IsShown() then return end

    C_Timer.After(0.01, function()
        local f = CreateFrame("Frame", "MapNotesChangelogFrame", UIParent, "BasicFrameTemplateWithInset")
        f:SetSize(750, 400)
        f:SetPoint("CENTER")
        f:SetMovable(true)
        f:EnableMouse(true)
        f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart", f.StartMoving)
        f:SetScript("OnDragStop", f.StopMovingOrSizing)
        f:SetFrameStrata("DIALOG")
        f:SetToplevel(true)
        f:SetClampedToScreen(true)

        f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        f.title:SetPoint("TOP", 0, -3)
        f.title:SetText(ns.COLORED_ADDON_NAME .. "|cffffd700 " .. L["Changelog"])

        f.scrollFrame = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
        f.scrollFrame:SetPoint("TOPLEFT", 10, -40)
        f.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)

        f.editBox = CreateFrame("EditBox", nil, f.scrollFrame)
        f.editBox:SetMultiLine(true)
        f.editBox:SetFontObject(GameFontHighlight)
        f.editBox:SetWidth(700)
        local changelogText = ns.LOCALE_CHANGELOG[GetLocale()] or ns.LOCALE_CHANGELOG["enUS"]
        f.editBox:SetText(
          "|cffffd700" .. GAME_VERSION_LABEL .. ":|r " .. "|cffff0000" .. currentVersion .. "\n\n|r" ..
          "|cffffd700" .. changelogText
        )
        f.editBox:SetAutoFocus(false)
        f.scrollFrame:SetScrollChild(f.editBox)

        f.checkbox = CreateFrame("CheckButton", nil, f, "ChatConfigCheckButtonTemplate")
        f.checkbox:SetPoint("BOTTOMLEFT", 10, 10)
        f.checkbox.Text:SetText("|cffff0000" .. L["Do not show again until next version"])

        f.closeButton = CreateFrame("Button", nil, f, "GameMenuButtonTemplate")
        f.closeButton:SetPoint("BOTTOMRIGHT", -10, -10)
        f.closeButton:SetSize(100, 25)
        f.closeButton:SetText(CLOSE)
        f.closeButton:SetScript("OnClick", function()
          if f.checkbox:GetChecked() then
            HandyNotes_MapNotesRetailChangelogDB.lastSeenVersion = currentVersion
          end
          f:Hide()
        end)

        f:SetScript("OnHide", function()
          if f.checkbox:GetChecked() then
            HandyNotes_MapNotesRetailChangelogDB.lastSeenVersion = currentVersion
          end
        end)
    end)
    table.insert(UISpecialFrames, "MapNotesChangelogFrame")
end

function ns.ShowChangelogWindowMenu()
    if MapNotesChangelogFrame and MapNotesChangelogFrame:IsShown() or MapNotesChangelogFrameMenu and MapNotesChangelogFrameMenu:IsShown() then return end

        local fm = CreateFrame("Frame", "MapNotesChangelogFrameMenu", UIParent, "BasicFrameTemplateWithInset")
        fm:SetSize(750, 400)
        fm:SetPoint("CENTER")
        fm:SetMovable(true)
        fm:EnableMouse(true)
        fm:RegisterForDrag("LeftButton")
        fm:SetScript("OnDragStart", fm.StartMoving)
        fm:SetScript("OnDragStop", fm.StopMovingOrSizing)
        fm:SetFrameStrata("DIALOG")
        fm:SetToplevel(true)
        fm:SetClampedToScreen(true)

        fm.title = fm:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        fm.title:SetPoint("TOP", 0, -3)
        fm.title:SetText(ns.COLORED_ADDON_NAME .. "|cffffd700 " .. L["Changelog"])

        fm.scrollFrame = CreateFrame("ScrollFrame", nil, fm, "UIPanelScrollFrameTemplate")
        fm.scrollFrame:SetPoint("TOPLEFT", 10, -40)
        fm.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)

        fm.editBox = CreateFrame("EditBox", nil, fm.scrollFrame)
        fm.editBox:SetMultiLine(true)
        fm.editBox:SetFontObject(GameFontHighlight)
        fm.editBox:SetWidth(700)
        local changelogText = ns.LOCALE_CHANGELOG[GetLocale()] or ns.LOCALE_CHANGELOG["enUS"]
        fm.editBox:SetText(
          "|cffffd700" .. GAME_VERSION_LABEL .. ":|r " .. "|cffff0000" .. currentVersion .. "\n\n|r" ..
          "|cffffd700" .. changelogText
        )
        fm.editBox:SetAutoFocus(false)
        fm.scrollFrame:SetScrollChild(fm.editBox)

        fm.closeButton = CreateFrame("Button", nil, fm, "GameMenuButtonTemplate")
        fm.closeButton:SetPoint("BOTTOMRIGHT", -10, -10)
        fm.closeButton:SetSize(100, 25)
        fm.closeButton:SetText(CLOSE)
        fm.closeButton:SetScript("OnClick", function()
          fm:Hide()
          LibStub("AceConfigDialog-3.0"):Open("MapNotes")
        end)

        fm:SetScript("OnHide", function()
          LibStub("AceConfigDialog-3.0"):Open("MapNotes")
        end)

    table.insert(UISpecialFrames, "MapNotesChangelogFrameMenu")
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, event, addonName)
    if addonName == "HandyNotes_MapNotes" then
        if not HandyNotes_MapNotesRetailChangelogDB then
            HandyNotes_MapNotesRetailChangelogDB = {}
        end
        if not HandyNotes_MapNotesRetailChangelogDB.lastSeenVersion then
            HandyNotes_MapNotesRetailChangelogDB.lastSeenVersion = previousVersion
        end

        if HandyNotes_MapNotesRetailChangelogDB.lastSeenVersion ~= currentVersion then
            ns.ShowChangelogWindow()
        end
    end
end)

ns.LOCALE_CHANGELOG = {
    enUS = [[
    • A changelog window has been added that displays the most important changes.
      It will reappear at every login unless the option
      “Do not show again until next version” at the bottom left is selected.

    • A new subtab in the General menu named “Information” was added,
      allowing you to reopen the changelog window.

    • The general Shift function in the “General” tab under “Additional Options” was removed.

    • New features called “Waypoint Shift” were added under “Advanced Options”.
      This allows waypoints to be created with or without pressing the Shift key.

    • New features called “Mouse Key Mapping” were added under “Advanced Options”.
      This allows you to change the mouse interaction with MapNotes icons,
      including swapping the left and right mouse button functions.

    • A new subtab named “Minimap +” was added.
      The function for displaying the minimap player arrow above addon icons
      was moved here (previously under “Symbol Options”).
    ]],

    deDE = [[
    • Ein Änderungsprotokollfenster wurde hinzugefügt, das die wichtigsten Änderungen anzeigt.
      Es wird bei jedem Login erneut angezeigt, solange unten links nicht die Option
      „Nicht erneut anzeigen bis zur nächsten Version“ ausgewählt wurde.

    • Ein neuer Unterreiter im Allgemein-Menü namens „Information“ wurde hinzugefügt
      und ermöglicht das erneute Anzeigen des Änderungsfensters.

    • Die allgemeine Shift-Funktion im Reiter „Allgemein“ innerhalb des Reiters „Zusätzliche Optionen“ wurde entfernt.

    • Eine neue Funktion mit dem Name „Wegpunkt-Shift“ wurde unter „Erweiterte Optionen“ hinzugefügt.
      Damit kann das Erzeugen von Wegpunkten mit oder ohne zusätzliches Drücken der Shift-Taste erfolgen.

    • Eine neue Funktion mit dem Namen „Maus-Tastenbelegung“ wurde unter „Erweiterte Optionen“ hinzugefügt.
      Hiermit kann die Mausfunktion für die Interaktion mit den MapNotes-Symbolen geändert werden,
      also die Funktion der linken und rechten Maustaste vertauscht werden.

    • Ein neuer Unterreiter mit dem Namen „Minimap +“ wurde hinzugefügt.
      Die Funktion zur Anzeige des Minikarten-Spielerpfeils über den Symbolen von Addons
      wurde in diesen neuen Reiter verschoben (zuvor unter „Symbol-Optionen“).
    ]],

    frFR = [[
    • Une fenêtre de journal des modifications a été ajoutée pour afficher les changements importants.
      Elle apparaîtra à chaque connexion sauf si l’option
      « Ne plus afficher avant la prochaine version » en bas à gauche est sélectionnée.

    • Un nouvel onglet dans le menu Général nommé « Informations » permet de rouvrir cette fenêtre.

    • La fonction Maj générale dans l’onglet « Général » sous « Options supplémentaires » a été supprimée.

    • De nouvelles fonctions appelées « Déplacement de point via Maj » ont été ajoutées sous « Options avancées ».
      Elles permettent de créer des points avec ou sans appuyer sur la touche Maj.

    • De nouvelles fonctions appelées « Mappage des touches de la souris » ont été ajoutées sous « Options avancées ».
      Elles permettent de modifier l’interaction de la souris avec les icônes MapNotes,
      notamment d’inverser les clics gauche et droit.

    • Un nouvel onglet nommé « Minicarte + » a été ajouté.
      La fonction d’affichage de la flèche du joueur sur la minicarte a été déplacée ici
      (auparavant dans « Options des symboles »).
    ]],

    itIT = [[
    • È stata aggiunta una finestra del registro delle modifiche che mostra le modifiche più importanti.
      Apparirà a ogni accesso, a meno che non sia selezionata l’opzione
      “Non mostrare di nuovo fino alla prossima versione” in basso a sinistra.

    • È stata aggiunta una nuova sottoscheda nel menu Generale chiamata “Informazioni” per riaprire il changelog.

    • La funzione Shift generale nella scheda “Generale” sotto “Opzioni aggiuntive” è stata rimossa.

    • Nuove funzionalità chiamate “Waypoint Shift” sono state aggiunte sotto “Opzioni avanzate”.
      Permettono di creare punti anche senza premere Shift.

    • Aggiunta anche la funzione “Mappatura tasti del mouse” sotto “Opzioni avanzate”,
      per invertire i pulsanti sinistro e destro del mouse per le icone MapNotes.

    • È stata aggiunta una nuova sottoscheda chiamata “Minimappa +”.
      La funzione di visualizzazione della freccia del giocatore è stata spostata qui
      (precedentemente in “Opzioni simboli”).
    ]],

    esES = [[
    • Se ha añadido una ventana de registro de cambios que muestra las actualizaciones más importantes.
      Aparecerá en cada inicio de sesión, a menos que se seleccione la opción
      “No mostrar de nuevo hasta la próxima versión” en la parte inferior izquierda.

    • Se ha añadido una nueva subpestaña llamada “Información” en el menú General para volver a abrir la ventana de cambios.

    • Se eliminó la función general de Shift en la pestaña “General” dentro de “Opciones adicionales”.

    • Nuevas funciones llamadas “Waypoint Shift” se han añadido en “Opciones avanzadas”,
      lo que permite crear puntos con o sin pulsar la tecla Shift.

    • También se han añadido funciones para “Asignación de teclas del ratón”,
      lo que permite intercambiar el clic izquierdo y derecho para las interacciones con iconos MapNotes.

    • Se ha añadido una nueva subpestaña llamada “Minimapa +”.
      La función de mostrar la flecha del jugador se ha movido aquí
      (anteriormente en “Opciones de símbolos”).
    ]],

    esMX = [[
    • Se ha añadido una ventana de registro de cambios que muestra las actualizaciones más importantes.
      Aparecerá en cada inicio de sesión, a menos que se seleccione la opción
      “No mostrar de nuevo hasta la próxima versión” en la parte inferior izquierda.

    • Se ha añadido una nueva subpestaña llamada “Información” en el menú General para volver a abrir la ventana de cambios.

    • Se eliminó la función general de Shift en la pestaña “General” dentro de “Opciones adicionales”.

    • Nuevas funciones llamadas “Waypoint Shift” se han añadido en “Opciones avanzadas”,
      lo que permite crear puntos con o sin pulsar la tecla Shift.

    • También se han añadido funciones para “Asignación de teclas del ratón”,
      lo que permite intercambiar el clic izquierdo y derecho para las interacciones con iconos MapNotes.

    • Se ha añadido una nueva subpestaña llamada “Minimapa +”.
      La función de mostrar la flecha del jugador se ha movido aquí
      (anteriormente en “Opciones de símbolos”).
    ]],

    ruRU = [[
    • Добавлено окно журнала изменений, отображающее важные обновления.
      Оно будет появляться при каждом входе, если не выбрана опция
      «Больше не показывать до следующей версии» в нижнем левом углу.

    • В меню «Общие» добавлена новая вкладка «Информация» для повторного открытия журнала изменений.

    • Общая функция Shift в разделе «Общие» → «Дополнительные настройки» была удалена.

    • Добавлена новая функция «Waypoint Shift» в разделе «Расширенные параметры»,
      позволяющая создавать точки с помощью или без нажатия Shift.

    • Также добавлена функция «Настройка кнопок мыши»,
      позволяющая изменить действия левой и правой кнопок мыши для иконок MapNotes.

    • Добавлена новая вкладка «Миникарта +».
      Функция отображения стрелки игрока на миникарте теперь находится здесь
      (ранее в «Параметры значков»).
    ]],

    ptBR = [[
    • Uma janela de registro de alterações foi adicionada para exibir as mudanças mais importantes.
      Ela aparecerá em todo login, a menos que a opção
      “Não mostrar novamente até a próxima versão” no canto inferior esquerdo seja selecionada.

    • Uma nova subguia no menu Geral chamada “Informações” foi adicionada,
      permitindo abrir novamente o registro de alterações.

    • A função Shift geral na aba “Geral” em “Opções adicionais” foi removida.

    • Novas funções chamadas “Waypoint Shift” foram adicionadas em “Opções avançadas”.
      Isso permite criar pontos com ou sem pressionar a tecla Shift.

    • Novas funções chamadas “Mapeamento das Teclas do Mouse” também foram adicionadas.
      Agora é possível alternar as funções de clique esquerdo e direito nos ícones do MapNotes.

    • Uma nova subguia chamada “Minimapa +” foi adicionada.
      A função de seta do jogador no minimapa foi movida para cá
      (anteriormente estava em “Opções de Símbolo”).
    ]],

    zhCN = [[
    • 添加了一个变更日志窗口，用于显示重要更新内容。
      每次登录时都会显示，除非在左下角勾选“不再显示直到下个版本”。

    • 在“常规”菜单中添加了一个名为“信息”的新子选项卡，
      可用于重新打开变更日志。

    • “常规”选项卡下的 Shift 功能已被移除（位于“附加选项”中）。

    • 在“高级选项”中添加了新的“Waypoint Shift”功能，
      可选择是否需要按住 Shift 键来创建路径点。

    • 新增“鼠标按键映射”功能，可在高级选项中切换左/右键的交互方式。

    • 新增“迷你地图+”子选项卡，
      显示玩家箭头的功能已移至此处（之前在“图标选项”中）。
    ]],

    zhTW = [[
    • 已新增一個變更記錄視窗，顯示重要更新內容。
      除非在左下角勾選「下個版本前不再顯示」，否則每次登入時都會顯示。

    • 在「一般」選單中新增了「資訊」子選項卡，可再次開啟變更記錄。

    • 「一般」頁面中的 Shift 功能（位於「其他選項」中）已被移除。

    • 在「進階選項」中新增了「Waypoint Shift」功能，
      可選擇是否需按 Shift 鍵來設定路徑點。

    • 新增「滑鼠按鍵對應」功能，可調整滑鼠左右鍵在 MapNotes 圖示上的操作方式。

    • 新增「小地圖 +」子選項卡，顯示玩家箭頭的功能已移至此處（原於「圖示選項」）。
    ]],

}