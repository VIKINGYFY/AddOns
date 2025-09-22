local ADDON_NAME, ns = ...

ns.PreviousAddonVersion = "3.0.7"
ns.CurrentAddonVersion = "3.0.8"

ns.LOCALE_CHANGELOG_NEW = {
  deDE = [[
• Im Kampf ist es nicht mehr möglich, die Weltkarte über Addons zu wechseln, ohne Blizzard-Fehler zu erzeugen.
  • Da dies eine Kernfunktion von MapNotes ist, wurden nun drei Optionen hinzugefügt, die dieses Problem auf verschiedenen Wegen lösen.

• Möglichkeit 1: „Im Kampf trotzdem verwenden“ aktivieren
  • Unter „Allgemein -> Karten + -> Im Kampf trotzdem verwenden“ können Spieler die Weltkartenwechsel-Funktion wie bisher auch im Kampf nutzen.
  • Diese Option versucht, alle Fehler zu unterdrücken und auszublenden, die durch das Wechseln der Weltkarte über MapNotes entstehen können, sodass nur sehr seltene und spezielle Fehler durchkommen.
  • In diesen Fällen erstellt MapNotes ein eigenes Fenster mit einem Knopf, um die Benutzeroberfläche mit einem Klick kurz neu zu laden, sodass der Fehler bereinigt wird.

• Möglichkeit 2: „Karten umschalten“ aktivieren (standardmäßig ausgewählt)
  • Die Funktion, die Weltkarte per Klick auf bestimmte MapNotes-Symbole „außerhalb des Kampfes“ zu wechseln, wurde hinzugefügt.
  • Sie kann unter „Allgemein -> Karten + -> Karten umschalten“ deaktiviert werden.
  • Für diese Funktion gibt es zusätzlich „Nach Kampf wechseln“: Dabei wird der letzte Klick auf das Symbol gespeichert und die Weltkarte nach dem Kampf auf die Zielkarte gewechselt.
  • Ebenfalls unter „Allgemein -> Karten + -> Info: Im Kampf blockiert“ befindet sich eine Option, die im Kampf eine Meldung am Bildschirm einblendet, dass dies nicht möglich ist.

• Möglichkeit 3: „Karten umschalten“ deaktivieren
  • Es wurde die Möglichkeit hinzugefügt, das Wechseln der Weltkarte per Klick auf bestimmte MapNotes-Symbole komplett zu deaktivieren.
  • Unter „Allgemein -> Karten + -> Karten umschalten“ muss dafür nur diese Funktion deaktiviert werden.
  • Bei Deaktivierung funktionieren Kartenwechsel über MapNotes nicht mehr.
  • Unter „Allgemein -> Karten + -> Karten umschalten Tooltip“ erhalten diese Symbole zusätzlich den Tooltip: „Die Funktion ‚Karten umschalten‘ ist deaktiviert“.

• Zusätzlich wurde dem Minikarten-Knopf eine neue Funktion hinzugefügt: „Umschalt-Taste + Mittlere Maustaste“ lädt die Benutzeroberfläche neu (/reload).

• Unter „Allgemein -> Karten +“ befinden sich nun auch die Optionen für die „Standort-Chatnachrichten“ und „Standort-Details-Chatnachrichten“ (zuvor im Reiter „Allgemein -> Chat-Optionen“).
]],

  enUS = [[
• It is no longer possible to switch the world map via addons during combat without triggering Blizzard errors.
  • Because this is a core MapNotes feature, three options were added to address the problem in different ways.

• Option 1: Enable “Use in combat anyway”
  • Under “General -> Maps + -> Use in combat anyway”, players can keep using the world-map switching feature even during combat as before.
  • This option attempts to suppress and hide all errors that may arise from switching the world map via MapNotes, so that only very rare and specific errors get through.
  • In such cases, MapNotes opens its own small window with a button to quickly reload the UI so the error is cleared.

• Option 2: Enable “Toggle Maps” (enabled by default)
  • Adds the ability to switch the world map by clicking certain MapNotes icons **outside of combat**.
  • It can be disabled under “General -> Maps + -> Toggle Maps”.
  • Additionally, “Switch after battle” stores the last click and switches the world map to the target map after combat.
  • Also under “General -> Maps + -> Info: Blocked in combat” you’ll find an option that shows an on-screen message in combat that this isn’t possible.

• Option 3: Disable “Toggle Maps”
  • Adds the possibility to completely disable switching the world map by clicking certain MapNotes icons.
  • Simply disable this option under “General -> Maps + -> Toggle Maps”.
  • When disabled, switching maps via MapNotes no longer works.
  • Under “General -> Maps + -> Toggle Maps Tooltip” these icons additionally show the tooltip: “The ‘Toggle Maps’ function is disabled”.

• Additionally, a new function was added to the minimap button: “Shift + Middle Mouse Button” reloads the user interface (/reload).

• Under “General -> Maps +” you will now also find the options for “Location chat messages” and “Location details chat messages” (previously under “General -> Chat Options”).
]],

  frFR = [[
• Il n’est plus possible de changer la carte du monde via des addons pendant le combat sans provoquer des erreurs Blizzard.
  • Comme il s’agit d’une fonctionnalité essentielle de MapNotes, trois options ont été ajoutées pour traiter ce problème de différentes manières.

• Option 1 : Activer « Utiliser en combat quand même »
  • Dans « Général -> Cartes + -> Utiliser en combat quand même », vous pouvez continuer à utiliser le changement de carte du monde même en combat, comme auparavant.
  • Cette option tente de supprimer et de masquer toutes les erreurs susceptibles de survenir lors du changement de carte via MapNotes, afin que seules des erreurs très rares et spécifiques passent.
  • Dans ces cas, MapNotes ouvre une petite fenêtre dédiée avec un bouton pour recharger rapidement l’interface afin de corriger l’erreur.

• Option 2 : Activer « Basculer les cartes » (activé par défaut)
  • Ajoute la possibilité de changer la carte du monde en cliquant sur certaines icônes MapNotes **hors combat**.
  • Peut être désactivé dans « Général -> Cartes + -> Basculer les cartes ».
  • En complément, « Changer après le combat » mémorise le dernier clic et bascule la carte du monde vers la carte cible après le combat.
  • Également dans « Général -> Cartes + -> Info : Bloqué en combat », une option affiche un message à l’écran en combat indiquant que l’action est impossible.

• Option 3 : Désactiver « Basculer les cartes »
  • Permet de désactiver complètement le changement de carte du monde en cliquant sur certaines icônes MapNotes.
  • Il suffit de désactiver l’option dans « Général -> Cartes + -> Basculer les cartes ».
  • Une fois désactivé, le changement de carte via MapNotes ne fonctionne plus.
  • Dans « Général -> Cartes + -> Info-bulle Basculer les cartes », ces icônes affichent en outre : « La fonction “Basculer les cartes” est désactivée ».

• Par ailleurs, un nouveau raccourci a été ajouté au bouton de la minicarte : « Maj + Bouton central de la souris » recharge l’interface (/reload).

• Dans « Général -> Cartes + » se trouvent désormais aussi les options « Messages de localisation dans le chat » et « Détails de localisation dans le chat » (auparavant dans « Général -> Options du chat »).
]],

  itIT = [[
• Non è più possibile cambiare la mappa del mondo tramite addon durante il combattimento senza causare errori Blizzard.
  • Poiché questa è una funzione fondamentale di MapNotes, sono state aggiunte tre opzioni per affrontare il problema in modi diversi.

• Opzione 1: Attivare « Usare comunque in combattimento »
  • In « Generale -> Mappe + -> Usare comunque in combattimento » i giocatori possono continuare a usare il cambio mappa anche in combattimento, come in passato.
  • Questa opzione cerca di sopprimere e nascondere tutti gli errori che possono insorgere cambiando la mappa tramite MapNotes, così che passino solo errori molto rari e specifici.
  • In tali casi, MapNotes apre una piccola finestra dedicata con un pulsante per ricaricare rapidamente l’interfaccia e risolvere l’errore.

• Opzione 2: Attivare « Cambia mappe » (attiva per impostazione predefinita)
  • Aggiunge la possibilità di cambiare la mappa del mondo facendo clic su alcune icone di MapNotes **fuori dal combattimento**.
  • Può essere disattivata in « Generale -> Mappe + -> Cambia mappe ».
  • Inoltre, « Cambia dopo il combattimento » salva l’ultimo clic e cambia la mappa del mondo alla mappa di destinazione dopo il combattimento.
  • In « Generale -> Mappe + -> Info: Bloccato in combattimento » è presente un’opzione che mostra in combattimento un messaggio a schermo che indica l’impossibilità dell’azione.

• Opzione 3: Disattivare « Cambia mappe »
  • Consente di disattivare completamente il cambio della mappa del mondo facendo clic su alcune icone di MapNotes.
  • È sufficiente disattivare l’opzione in « Generale -> Mappe + -> Cambia mappe ».
  • Una volta disattivata, il cambio mappa tramite MapNotes non funziona più.
  • In « Generale -> Mappe + -> Tooltip Cambia mappe » tali icone mostrano inoltre: « La funzione “Cambia mappe” è disattivata ».

• Inoltre, al pulsante della minimappa è stata aggiunta una nuova funzione: « Maiusc + tasto centrale del mouse » ricarica l’interfaccia (/reload).

• In « Generale -> Mappe + » sono ora presenti anche le opzioni « Messaggi di posizione in chat » e « Dettagli posizione in chat » (in precedenza in « Generale -> Opzioni chat »).
]],

  esES = [[
• Ya no es posible cambiar el mapa del mundo mediante addons durante el combate sin provocar errores de Blizzard.
  • Como se trata de una función principal de MapNotes, se han añadido tres opciones para abordar el problema de diferentes maneras.

• Opción 1: Activar « Usar en combate de todos modos »
  • En « General -> Mapas + -> Usar en combate de todos modos », los jugadores pueden seguir usando el cambio de mapa incluso en combate, como antes.
  • Esta opción intenta suprimir y ocultar todos los errores que puedan surgir al cambiar el mapa mediante MapNotes, de modo que solo aparezcan errores muy raros y específicos.
  • En estos casos, MapNotes abre una pequeña ventana con un botón para recargar rápidamente la interfaz y así resolver el error.

• Opción 2: Activar « Alternar mapas » (activado por defecto)
  • Añade la posibilidad de cambiar el mapa del mundo haciendo clic en ciertos iconos de MapNotes **fuera de combate**.
  • Puede desactivarse en « General -> Mapas + -> Alternar mapas ».
  • Además, « Cambiar después del combate » guarda el último clic y cambia el mapa del mundo al mapa de destino después del combate.
  • También en « General -> Mapas + -> Info: Bloqueado en combate » hay una opción que muestra un mensaje en pantalla durante el combate indicando que no es posible.

• Opción 3: Desactivar « Alternar mapas »
  • Permite desactivar por completo el cambio del mapa del mundo al hacer clic en ciertos iconos de MapNotes.
  • Basta con desactivar la opción en « General -> Mapas + -> Alternar mapas ».
  • Al desactivarla, el cambio de mapas mediante MapNotes deja de funcionar.
  • En « General -> Mapas + -> Tooltip Alternar mapas » estos iconos muestran además: « La función “Alternar mapas” está desactivada ».

• Además, se ha añadido una función nueva al botón del minimapa: « Mayús + Botón central del ratón » recarga la interfaz (/reload).

• En « General -> Mapas + » también encontrarás ahora las opciones « Mensajes de ubicación en el chat » y « Detalles de ubicación en el chat » (antes en « General -> Opciones de chat »).
]],

  esMX = [[
• Ya no es posible cambiar el mapa del mundo mediante addons durante el combate sin causar errores de Blizzard.
  • Debido a que esta es una función central de MapNotes, se agregaron tres opciones para abordar el problema de distintas maneras.

• Opción 1: Activar « Usar en combate de todos modos »
  • En « General -> Mapas + -> Usar en combate de todos modos », los jugadores pueden seguir usando el cambio de mapa también en combate, como antes.
  • Esta opción intenta suprimir y ocultar todos los errores que puedan surgir al cambiar el mapa mediante MapNotes, de modo que solo aparezcan errores muy raros y específicos.
  • En estos casos, MapNotes abre una pequeña ventana dedicada con un botón para recargar rápidamente la interfaz y resolver el error.

• Opción 2: Activar « Alternar mapas » (activado de forma predeterminada)
  • Agrega la posibilidad de cambiar el mapa del mundo al hacer clic en ciertos íconos de MapNotes **fuera de combate**.
  • Se puede desactivar en « General -> Mapas + -> Alternar mapas ».
  • Además, « Cambiar después del combate » guarda el último clic y cambia el mapa del mundo al mapa de destino después del combate.
  • También en « General -> Mapas + -> Info: Bloqueado en combate » encontrarás una opción que muestra en combate un mensaje en pantalla indicando que no es posible.

• Opción 3: Desactivar « Alternar mapas »
  • Permite deshabilitar por completo el cambio del mapa del mundo al hacer clic en ciertos íconos de MapNotes.
  • Solo desactiva la opción en « General -> Mapas + -> Alternar mapas ».
  • Al deshabilitarla, el cambio de mapas mediante MapNotes deja de funcionar.
  • En « General -> Mapas + -> Tooltip Alternar mapas » estos íconos también mostrarán: « La función “Alternar mapas” está deshabilitada ».

• Además, se añadió una nueva función al botón del minimapa: « Mayús + Botón central del mouse » recarga la interfaz (/reload).

• En « General -> Mapas + » ahora también encontrarás las opciones « Mensajes de ubicación en el chat » y « Detalles de ubicación en el chat » (antes en « General -> Opciones de chat »).
]],

  ptBR = [[
• Não é mais possível trocar o mapa-múndi por addons durante o combate sem causar erros da Blizzard.
  • Como isso é um recurso central do MapNotes, foram adicionadas três opções para lidar com o problema de maneiras diferentes.

• Opção 1: Ativar « Usar em combate mesmo assim »
  • Em « Geral -> Mapas + -> Usar em combate mesmo assim », os jogadores podem continuar usando a troca de mapa também em combate, como antes.
  • Esta opção tenta suprimir e ocultar todos os erros que podem surgir ao trocar o mapa via MapNotes, permitindo que apenas erros muito raros e específicos passem.
  • Nesses casos, o MapNotes abre uma pequena janela com um botão para recarregar rapidamente a interface e corrigir o erro.

• Opção 2: Ativar « Alternar mapas » (ativada por padrão)
  • Adiciona a possibilidade de trocar o mapa do mundo clicando em certos ícones do MapNotes **fora de combate**.
  • Pode ser desativada em « Geral -> Mapas + -> Alternar mapas ».
  • Além disso, « Alternar após o combate » armazena o último clique e muda o mapa do mundo para o destino após o combate.
  • Em « Geral -> Mapas + -> Info: Bloqueado em combate » há uma opção que exibe, durante o combate, uma mensagem na tela informando que não é possível.

• Opção 3: Desativar « Alternar mapas »
  • Permite desativar completamente a troca do mapa do mundo ao clicar em certos ícones do MapNotes.
  • Basta desativar a opção em « Geral -> Mapas + -> Alternar mapas ».
  • Desativando, a troca de mapas via MapNotes deixa de funcionar.
  • Em « Geral -> Mapas + -> Dica de ferramenta Alternar mapas » esses ícones também exibem: « A função “Alternar mapas” está desativada ».

• Além disso, foi adicionada uma nova função ao botão do minimapa: « Shift + Botão do meio do mouse » recarrega a interface (/reload).

• Em « Geral -> Mapas + » agora você também encontra as opções « Mensagens de localização no chat » e « Detalhes de localização no chat » (antes em « Geral -> Opções de chat »).
]],

  ruRU = [[
• Во время боя больше нельзя переключать карту мира через аддоны без вызова ошибок Blizzard.
  • Так как это ключевая функция MapNotes, были добавлены три варианта, решающие проблему разными способами.

• Вариант 1: Включить « Использовать в бою всё равно »
  • В « Общие -> Карты + -> Использовать в бою всё равно » игроки могут, как и раньше, пользоваться переключением карты мира даже во время боя.
  • Этот вариант пытается подавлять и скрывать все ошибки, которые могут возникать при переключении карты через MapNotes, так что проходят только очень редкие и специфические ошибки.
  • В таких случаях MapNotes открывает небольшое отдельное окно с кнопкой для быстрой перезагрузки интерфейса, чтобы устранить ошибку.

• Вариант 2: Включить « Переключение карт » (включено по умолчанию)
  • Добавляет возможность переключать карту мира, нажимая на некоторые значки MapNotes **вне боя**.
  • Можно отключить в « Общие -> Карты + -> Переключение карт ».
  • Дополнительно « Переключать после боя » запоминает последний щелчок и переключает карту мира на целевую после боя.
  • В « Общие -> Карты + -> Инфо: Заблокировано в бою » есть опция, показывающая во время боя на экране сообщение о невозможности действия.

• Вариант 3: Отключить « Переключение карт »
  • Позволяет полностью запретить переключение карты мира по нажатию на определённые значки MapNotes.
  • Для этого достаточно отключить опцию в « Общие -> Карты + -> Переключение карт ».
  • После отключения переключение карт через MapNotes работать не будет.
  • В « Общие -> Карты + -> Подсказка Переключение карт » такие значки дополнительно получают подсказку: « Функция “Переключение карт” отключена ».

• Кроме того, для кнопки на миникарте добавлена новая функция: « Shift + Средняя кнопка мыши » перезагружает интерфейс (/reload).

• В « Общие -> Карты + » теперь также находятся опции « Сообщения о локации в чат » и « Подробные сообщения о локации в чат » (раньше — в « Общие -> Настройки чата »).
]],

  zhCN = [[
• 战斗中已无法通过插件切换世界地图而不触发暴雪错误。
  • 由于这是 MapNotes 的核心功能，我们新增了三种方式来应对这一问题。

• 方案一：启用“战斗中仍然使用”
  • 在“通用 -> 地图 + -> 战斗中仍然使用”下，玩家可以像以往一样在战斗中继续使用世界地图切换功能。
  • 该选项会尽量抑制并隐藏通过 MapNotes 切换世界地图时可能产生的所有错误，使只有极少数特定错误会显示。
  • 遇到这种情况时，MapNotes 会弹出一个小窗口，提供一键快速重载界面的按钮，以清除错误。

• 方案二：启用“切换地图”（默认启用）
  • 新增可在**非战斗**状态下，通过点击部分 MapNotes 图标来切换世界地图。
  • 可在“通用 -> 地图 + -> 切换地图”中关闭。
  • 另外，“战后切换”会记录你对图标的最后一次点击，并在战斗结束后切换到目标地图。
  • 在“通用 -> 地图 + -> 信息：战斗中已阻止”中，还提供在战斗中提示“此操作不可用”的选项。

• 方案三：关闭“切换地图”
  • 可完全关闭通过点击 MapNotes 图标切换世界地图的功能。
  • 只需在“通用 -> 地图 + -> 切换地图”中关闭该选项。
  • 关闭后，MapNotes 将不再执行任何地图切换。
  • 在“通用 -> 地图 + -> ‘切换地图’提示”中，这些图标还会额外显示：“‘切换地图’功能已禁用”。

• 另外，小地图按钮新增功能：“Shift + 鼠标中键”可重新载入界面（/reload）。

• “通用 -> 地图 +”下现在也能找到“位置聊天消息”和“位置详细聊天消息”的选项（之前位于“通用 -> 聊天选项”）。
]],

  zhTW = [[
• 戰鬥中已無法透過外掛切換世界地圖而不產生暴雪錯誤。
  • 由於這是 MapNotes 的核心功能，因此新增三種方式來處理這個問題。

• 方案一：啟用「戰鬥中仍然使用」
  • 於「一般 -> 地圖 + -> 戰鬥中仍然使用」中，玩家可如以往一樣在戰鬥中繼續使用世界地圖切換功能。
  • 此選項會盡量抑制並隱藏透過 MapNotes 切換世界地圖時可能產生的所有錯誤，使僅有極少數特定錯誤會顯示。
  • 發生此情況時，MapNotes 會彈出一個小視窗，提供一鍵快速重新載入介面的按鈕，以清除錯誤。

• 方案二：啟用「切換地圖」（預設啟用）
  • 新增可在**非戰鬥**狀態下，透過點擊部分 MapNotes 圖示來切換世界地圖。
  • 可在「一般 -> 地圖 + -> 切換地圖」中停用。
  • 另外，「戰後切換」會記錄你對圖示的最後一次點擊，並在戰鬥結束後切換到目標地圖。
  • 在「一般 -> 地圖 + -> 資訊：戰鬥中已封鎖」中，也提供在戰鬥中提示「此操作不可用」的選項。

• 方案三：停用「切換地圖」
  • 可完全停用透過點擊 MapNotes 圖示切換世界地圖的功能。
  • 只需在「一般 -> 地圖 + -> 切換地圖」中停用該選項。
  • 停用後，MapNotes 將不再執行任何地圖切換。
  • 在「一般 -> 地圖 + -> 切換地圖滑鼠提示」中，這些圖示也會額外顯示：「『切換地圖』功能已停用」。

• 另外，小地圖按鈕新增功能：「Shift + 滑鼠中鍵」可重新載入介面（/reload）。

• 「一般 -> 地圖 +」下現在也能找到「位置聊天訊息」與「位置詳細聊天訊息」選項（先前位於「一般 -> 聊天選項」）。
]],

  koKR = [[
• 전투 중에는 애드온으로 세계 지도를 전환하면 블리자드 오류가 발생하므로 더 이상 수행할 수 없습니다.
  • 이는 MapNotes의 핵심 기능이기 때문에, 문제를 다양한 방식으로 해결할 수 있도록 세 가지 옵션이 추가되었습니다.

• 옵션 1: ‘전투 중에도 강제로 사용’ 활성화
  • ‘일반 -> 지도 + -> 전투 중에도 강제로 사용’에서, 예전처럼 전투 중에도 세계 지도 전환 기능을 계속 사용할 수 있습니다.
  • 이 옵션은 MapNotes로 세계 지도를 전환할 때 발생할 수 있는 모든 오류를 최대한 억제하고 숨겨, 매우 드물고 특정한 오류만 표시되도록 시도합니다.
  • 이러한 경우에는, MapNotes가 전용 작은 창을 띄워 버튼 한 번으로 UI를 빠르게 다시 불러와 오류를 정리할 수 있게 합니다.

• 옵션 2: ‘지도 전환’ 활성화 (기본값)
  • **비전투** 상태에서 일부 MapNotes 아이콘을 클릭해 세계 지도를 전환할 수 있는 기능을 추가합니다.
  • ‘일반 -> 지도 + -> 지도 전환’에서 비활성화할 수 있습니다.
  • 또한 ‘전투 후 전환’은 마지막 클릭을 저장했다가 전투가 끝난 뒤 대상 지도로 전환합니다.
  • ‘일반 -> 지도 + -> 정보: 전투 중 차단됨’에는 전투 중 해당 작업이 불가함을 화면에 표시하는 옵션이 있습니다.

• 옵션 3: ‘지도 전환’ 비활성화
  • 특정 MapNotes 아이콘을 클릭해 세계 지도를 전환하는 기능을 완전히 비활성화할 수 있습니다.
  • ‘일반 -> 지도 + -> 지도 전환’에서 이 옵션을 끄면 됩니다.
  • 비활성화 시, MapNotes를 통한 지도 전환은 더 이상 동작하지 않습니다.
  • ‘일반 -> 지도 + -> 지도 전환 툴팁’에서 해당 아이콘에 “‘지도 전환’ 기능이 비활성화되어 있습니다”라는 툴팁을 추가로 표시합니다.

• 추가로 미니맵 버튼에 ‘Shift + 마우스 가운데 버튼’으로 UI를 다시 불러오는 (/reload) 기능이 추가되었습니다.

• ‘일반 -> 지도 +’에는 이제 ‘위치 채팅 메시지’ 및 ‘위치 상세 채팅 메시지’ 옵션도 있습니다(기존에는 ‘일반 -> 채팅 옵션’에 위치).
]],
}

ns.LOCALE_CHANGELOG_OLD = {
  deDE = [[
• Es wurden Instanzsymbole auf den Flugkarten von TWW, Dragonflight und Schattenlande hinzugefügt; weitere Gebiete folgen.
Zusätzlich wurde ein Knopf oben rechts auf der Flugkarte erstellt, mit dem ihr die Symbole ein- bzw. ausblenden könnt.
Die Option zum Aktivieren bzw. Deaktivieren des Knopfes sowie der Symbole befindet sich zusätzlich im MapNotes-Menü im allgemeinen Reiter unter „Flugkarte“.

• Für die restlichen Klassen wurden Ordenshallensymbole hinzugefügt.

• Es ist nun möglich, den Spielerpfeil auf der Weltkarte zu vergrößern oder zu verkleinern.
Die dazugehörige Option befindet sich im Allgemeinen Reiter unter Weltkarte (Weltkarten-Spielerpfeil).

• Die Koordinatenanzeige für Spieler- und Mausposition wurde angepasst.
Das Koordinatenfenster für die Spielerposition besitzt nun einen Tooltip und kann nur noch mit „Umschalttaste + Linksklick“ verschoben werden (statt mit einfachem Linksklick).
Das Koordinatenfenster für die Spielerposition lässt sich vom Spieler frei positionieren.
Das Koordinatenfenster für die Mausposition besitzt nun einen Tooltip und kann nur noch mit „Umschalttaste + Linksklick“ verschoben werden (statt mit einfachem Linksklick).
Das Koordinatenfenster für die Mausposition gibt es 2x. 1x gibt es eines auf der verkleinerten Weltkarte und 1x gibt es eines auf der vergrößerten Weltkarte.
Die Koordinatenfenster der Mausposition lassen sich vom Spieler auf der verkleinerten und vergrößerten Weltkarte jeweils unabhängig frei positionieren.
Im Addon Menü teilen sich die zwei Koordinatenfenster der Mausposition jeweils die Größe und Transparenz.
Das Fenster der Mausposition wird automatisch ausgeblendet, wenn die Weltkarte geschlossen wird, und wieder angezeigt, wenn sie geöffnet wird.
Auch die Standardeinstellungen (position/größe/transparenz) wurden angepasst.

• Außerdem wurden noch ein paar kleinere Änderungen vorgenommen.
]],

  enUS = [[
• Instance icons have been added to the flight maps of TWW, Dragonflight, and Shadowlands; more zones will follow.
In addition, a button has been added at the top right of the flight map to toggle the icons on or off.
The option to enable or disable the button as well as the icons can also be found in the MapNotes menu in the General tab under "Flight Map".

• Class Order Hall icons have been added for the remaining classes.

• It is now possible to increase or decrease the size of the player arrow on the world map.
The corresponding option can be found in the General tab under World Map (World Map Player Arrow).

• The coordinate display for player and mouse position has been adjusted.
The coordinate window for the player position now has a tooltip and can only be moved with "Shift + Left Click" (instead of just Left Click).
The coordinate window for the player position can be freely positioned by the player.
The coordinate window for the mouse position now has a tooltip and can only be moved with "Shift + Left Click" (instead of just Left Click).
There are two coordinate windows for the mouse position: one on the minimized world map and one on the maximized world map.
The mouse-position windows can be freely and independently positioned by the player on both the minimized and maximized world maps.
In the addon menu, the two mouse-position windows share the size and transparency settings.
The mouse-position window is automatically hidden when the world map is closed and shown again when it is opened.
The default settings (position/size/transparency) have also been adjusted.

• A few other minor changes have also been made.
]],

  frFR = [[
• Des icônes d’instance ont été ajoutées aux cartes de vol de TWW, Dragonflight et Ombreterre ; d’autres zones suivront.
Un bouton a également été ajouté en haut à droite de la carte de vol pour afficher ou masquer les icônes.
L’option permettant d’activer ou de désactiver le bouton ainsi que les icônes se trouve également dans le menu MapNotes, onglet Général, sous « Carte de vol ».

• Des icônes du domaine de classe ont été ajoutées pour les classes restantes.

• Il est désormais possible d’augmenter ou de diminuer la taille de la flèche du joueur sur la carte du monde.
L’option correspondante se trouve dans l’onglet Général, sous Carte du monde (Flèche du joueur sur la carte du monde).

• L’affichage des coordonnées pour la position du joueur et de la souris a été ajusté.
La fenêtre des coordonnées pour la position du joueur dispose désormais d’une info-bulle et ne peut plus être déplacée qu’avec « Maj + clic gauche » (au lieu d’un simple clic gauche).
La fenêtre des coordonnées de la position du joueur peut être librement positionnée par le joueur.
La fenêtre des coordonnées pour la position de la souris dispose désormais aussi d’une info-bulle et ne peut plus être déplacée qu’avec « Maj + clic gauche ».
Il existe deux fenêtres de coordonnées pour la position de la souris : l’une sur la carte du monde réduite et l’autre sur la carte du monde agrandie.
Ces deux fenêtres peuvent être positionnées librement et indépendamment sur les versions réduite et agrandie de la carte du monde.
Dans le menu de l’addon, ces deux fenêtres partagent les paramètres de taille et de transparence.
La fenêtre de la position de la souris est automatiquement masquée lorsque la carte du monde est fermée, puis réaffichée lorsqu’elle est ouverte.
Les paramètres par défaut (position/taille/transparence) ont également été ajustés.

• Quelques autres petites modifications ont également été apportées.
]],

  itIT = [[
• Sono state aggiunte icone delle istanze alle mappe di volo di TWW, Dragonflight e Shadowlands; altre zone seguiranno.
Inoltre, è stato aggiunto un pulsante in alto a destra della mappa di volo per mostrare o nascondere le icone.
L’opzione per abilitare o disabilitare sia il pulsante sia le icone si trova anche nel menu di MapNotes nella scheda Generale, in "Mappa di volo".

• Aggiunte le icone della Sala d’Ordine per le classi rimanenti.

• Ora è possibile aumentare o ridurre la dimensione della freccia del giocatore sulla mappa del mondo.
L’opzione corrispondente si trova nella scheda Generale, sotto Mappa del mondo (Freccia del giocatore sulla mappa del mondo).

• È stata modificata la visualizzazione delle coordinate per la posizione del giocatore e del mouse.
La finestra delle coordinate della posizione del giocatore ora ha un tooltip e può essere spostata solo con "Maiusc + Clic sinistro" (invece del solo clic sinistro).
La finestra delle coordinate della posizione del giocatore può essere posizionata liberamente.
Anche la finestra della posizione del mouse ora ha un tooltip e può essere spostata solo con "Maiusc + Clic sinistro".
Esistono due finestre di coordinate per la posizione del mouse: una sulla mappa del mondo ridotta e una su quella ingrandita.
Queste due finestre possono essere posizionate liberamente e in modo indipendente sulla mappa ridotta e su quella ingrandita.
Nel menu dell’addon, le due finestre della posizione del mouse condividono impostazioni di dimensione e trasparenza.
La finestra della posizione del mouse viene nascosta automaticamente quando la mappa del mondo è chiusa e riappare quando viene aperta.
Sono stati inoltre aggiornati i valori predefiniti (posizione/dimensione/trasparenza).

• Sono state apportate anche alcune altre piccole modifiche.
]],

  esES = [[
• Se han añadido iconos de instancias a los mapas de vuelo de TWW, Dragonflight y Tierras Sombrías; se añadirán más zonas próximamente.
Además, se ha añadido un botón en la parte superior derecha del mapa de vuelo para mostrar u ocultar los iconos.
La opción para activar o desactivar tanto el botón como los iconos también se encuentra en el menú MapNotes, en la pestaña General, en «Mapa de vuelo».

• Se han añadido iconos de la Sede de la Orden para las clases restantes.

• Ahora es posible aumentar o reducir el tamaño de la flecha del jugador en el mapa del mundo.
La opción correspondiente se encuentra en la pestaña General, en Mapa del mundo (Flecha del jugador en el mapa del mundo).

• Se ha ajustado la visualización de coordenadas para la posición del jugador y del ratón.
La ventana de coordenadas de la posición del jugador ahora tiene un tooltip y solo se puede mover con «Mayús + Clic izquierdo» (en lugar de solo Clic izquierdo).
La ventana de la posición del jugador se puede colocar libremente.
La ventana de coordenadas de la posición del ratón también tiene ahora un tooltip y solo se puede mover con «Mayús + Clic izquierdo».
Hay dos ventanas de coordenadas para la posición del ratón: una en el mapa del mundo reducido y otra en el mapa del mundo ampliado.
Estas dos ventanas pueden colocarse de forma libre e independiente tanto en el mapa reducido como en el ampliado.
En el menú del addon, ambas ventanas de la posición del ratón comparten el tamaño y la transparencia.
La ventana de la posición del ratón se ocultará automáticamente cuando se cierre el mapa del mundo y se volverá a mostrar al abrirlo.
También se han ajustado los valores predeterminados (posición/tamaño/transparencia).

• También se han realizado algunos otros cambios menores.
]],

  esMX = [[
• Se han agregado íconos de instancias a los mapas de vuelo de TWW, Dragonflight y Tierras Sombrías; más zonas se añadirán próximamente.
Además, se agregó un botón en la parte superior derecha del mapa de vuelo para mostrar u ocultar los íconos.
La opción para habilitar o deshabilitar tanto el botón como los íconos también está disponible en el menú de MapNotes, en la pestaña General, en «Mapa de vuelo».

• Se añadieron íconos de la Sede de la Orden para las clases restantes.

• Ahora es posible aumentar o reducir el tamaño de la flecha del jugador en el mapa del mundo.
La opción correspondiente se encuentra en la pestaña General, en Mapa del mundo (Flecha del jugador en el mapa del mundo).

• Se ajustó la visualización de coordenadas para la posición del jugador y del mouse.
La ventana de coordenadas de la posición del jugador ahora tiene un tooltip y solo se puede mover con «Shift + Clic izquierdo» (en lugar de solo Clic izquierdo).
La ventana de la posición del jugador puede posicionarse libremente.
La ventana de coordenadas de la posición del mouse también tiene ahora un tooltip y solo se puede mover con «Shift + Clic izquierdo».
Existen dos ventanas de coordenadas para la posición del mouse: una en el mapa del mundo minimizado y otra en el maximizado.
Estas dos ventanas pueden colocarse de forma libre e independiente tanto en el mapa minimizado como en el maximizado.
En el menú del addon, ambas ventanas de la posición del mouse comparten el tamaño y la transparencia.
La ventana de la posición del mouse se ocultará automáticamente cuando se cierre el mapa del mundo y se volverá a mostrar al abrirlo.
También se ajustaron los valores predeterminados (posición/tamaño/transparencia).

• También se realizaron algunos otros cambios menores.
]],

  ruRU = [[
• На карты полётов TWW, Dragonflight и Shadowlands добавлены значки подземелий; другие зоны будут добавлены позже.
Также в правом верхнем углу карты полётов добавлена кнопка для включения и отключения значков.
Опция включения или отключения как кнопки, так и значков находится в меню MapNotes, во вкладке «Общие», раздел «Карта полётов».

• Добавлены значки Оплота класса для оставшихся классов.

• Теперь можно увеличить или уменьшить размер стрелки игрока на карте мира.
Соответствующая опция находится во вкладке «Общие», раздел «Карта мира» (стрелка игрока на карте мира).

• Отображение координат для позиции игрока и курсора было изменено.
Окно координат позиции игрока теперь имеет подсказку и может перемещаться только с помощью «Shift + ЛКМ» (вместо простого ЛКМ).
Окно координат позиции игрока можно свободно располагать.
Окно координат позиции курсора также получило подсказку и перемещается только с помощью «Shift + ЛКМ».
Существует два окна координат позиции курсора: одно на уменьшенной карте мира и одно на увеличенной.
Эти два окна можно свободно и независимо располагать на уменьшенной и увеличенной версиях карты мира.
В меню аддона оба окна для позиции курсора используют общие настройки размера и прозрачности.
Окно позиции курсора автоматически скрывается при закрытии карты мира и снова отображается при её открытии.
Также были изменены значения по умолчанию (позиция/размер/прозрачность).

• Были внесены и некоторые другие небольшие изменения.
]],

  ptBR = [[
• Ícones de instância foram adicionados aos mapas de voo de TWW, Dragonflight e Shadowlands; mais zonas serão adicionadas futuramente.
Além disso, foi adicionado um botão no canto superior direito do mapa de voo para mostrar ou ocultar os ícones.
A opção para ativar ou desativar tanto o botão quanto os ícones também pode ser encontrada no menu do MapNotes, na aba Geral, em "Mapa de voo".

• Foram adicionados ícones do Salão da Ordem para as classes restantes.

• Agora é possível aumentar ou diminuir o tamanho da seta do jogador no mapa-múndi.
A opção correspondente pode ser encontrada na aba Geral, em Mapa-múndi (Seta do jogador no mapa-múndi).

• A exibição de coordenadas para a posição do jogador e do mouse foi ajustada.
A janela de coordenadas da posição do jogador agora possui uma dica de ferramenta e só pode ser movida com "Shift + Clique esquerdo" (em vez de apenas Clique esquerdo).
A janela da posição do jogador pode ser posicionada livremente.
A janela de coordenadas da posição do mouse também passou a ter uma dica de ferramenta e só pode ser movida com "Shift + Clique esquerdo".
Há duas janelas de coordenadas para a posição do mouse: uma no mapa do mundo reduzido e outra no mapa do mundo ampliado.
Essas duas janelas podem ser posicionadas livremente e de forma independente tanto no mapa reduzido quanto no ampliado.
No menu do addon, as duas janelas da posição do mouse compartilham as configurações de tamanho e transparência.
A janela da posição do mouse é ocultada automaticamente quando o mapa-múndi é fechado e reaparece quando é aberto.
Os valores padrão (posição/tamanho/transparência) também foram ajustados.

• Algumas outras pequenas alterações também foram feitas.
]],

  zhCN = [[
• 已在 TWW、巨龙时代和暗影国度的飞行地图上添加了副本图标，更多区域将陆续加入。
此外，在飞行地图的右上角新增了一个按钮，可切换这些图标的显示与隐藏。
启用或禁用按钮及图标的选项也可在 MapNotes 菜单的常规选项卡下的“飞行地图”中找到。

• 已为其余职业添加了职业大厅图标。

• 现在可以增大或减小世界地图上玩家箭头的大小。
相关选项位于常规选项卡的世界地图（世界地图玩家箭头）中。

• 已调整玩家与鼠标位置的坐标显示。
玩家位置的坐标窗口现在带有提示，并且只能通过“Shift + 左键点击”移动（而不是仅左键）。
该窗口可由玩家自由放置。
鼠标位置的坐标窗口同样带有提示，并且也只能通过“Shift + 左键点击”移动。
鼠标位置的坐标窗口有两个：一个在缩小的世界地图上，另一个在放大的世界地图上。
这两个鼠标坐标窗口在缩小和放大的世界地图上都可由玩家自由且相互独立地定位。
在插件菜单中，这两个鼠标坐标窗口共享大小和透明度设置。
当世界地图关闭时，鼠标位置窗口会自动隐藏；打开时会再次显示。
默认设置（位置/大小/透明度）也已调整。

• 还进行了其他一些小的改动。
]],

  zhTW = [[
• 已在 TWW、巨龍崛起與暗影之境的飛行地圖上新增副本圖示，更多區域將陸續加入。
此外，在飛行地圖的右上角新增了一個按鈕，可切換圖示的顯示與隱藏。
啟用或停用按鈕及圖示的選項，也可在 MapNotes 功能表的一般分頁中的「飛行地圖」找到。

• 已為其餘職業新增了職業大廳圖示。

• 現在可以放大或縮小世界地圖上玩家箭頭的大小。
相關選項位於一般分頁的世界地圖（世界地圖玩家箭頭）中。

• 已調整玩家與滑鼠位置的座標顯示。
玩家位置的座標視窗現在具有工具提示，且只能透過「Shift + 左鍵點擊」移動（而非僅左鍵點擊）。
該視窗可由玩家自由放置。
滑鼠位置的座標視窗同樣具有工具提示，且也只能透過「Shift + 左鍵點擊」移動。
滑鼠位置的座標視窗有兩個：一個在縮小的世界地圖上，另一個在放大的世界地圖上。
這兩個滑鼠座標視窗可在縮小與放大的世界地圖上分別獨立地由玩家自由定位。
在外掛選單中，這兩個滑鼠座標視窗共用大小與透明度設定。
當世界地圖關閉時，滑鼠位置視窗會自動隱藏；打開時會再次顯示。
預設值（位置/大小/透明度）也已調整。

• 另外還進行了一些其他小幅更動。
]],
}