---@class AddonPrivate
local Private = select(2, ...)

local locales = Private.Locales or {}
Private.Locales = locales
local L = {
    -- UI/Components/Dropdown.lua
    ["Components.Dropdown.SelectOption"] = "Selecione uma opção",

    -- UI/Tabs/ArtifactTraitsTabUI.lua
    ["Tabs.ArtifactTraitsTabUI.AutoActivateForSpec"] = "Auto-Activate for Spec",
    ["Tabs.ArtifactTraitsTabUI.NoArtifactEquipped"] = "Nenhum Artefato Equipado",

    -- UI/Tabs/CollectionTabUI.lua
    ["Tabs.CollectionTabUI.CtrlClickPreview"] = "Ctrl-Click para pré visualização",
    ["Tabs.CollectionTabUI.ShiftClickToLink"] = "Shift-Click para link",
    ["Tabs.CollectionTabUI.NoName"] = "Sem Nome",
    ["Tabs.CollectionTabUI.AltClickVendor"] = "Alt-Click para marcar um Ponto de Referência até o vendedor",
    ["Tabs.CollectionTabUI.AltClickAchievement"] = "Alt-Click para visualizar uma Conquista",
    ["Tabs.CollectionTabUI.FilterCollected"] = "Coletado",
    ["Tabs.CollectionTabUI.FilterNotCollected"] = "Não Coletado",
    ["Tabs.CollectionTabUI.FilterSources"] = "Fontes",
    ["Tabs.CollectionTabUI.FilterCheckAll"] = "Marcar Todos",
    ["Tabs.CollectionTabUI.FilterUncheckAll"] = "Desmarcar Todos",
    ["Tabs.CollectionTabUI.FilterRaidVariants"] = "Show Raid Variants",
    ["Tabs.CollectionTabUI.FilterUnique"] = "Only Remix-Specific Items",
    ["Tabs.CollectionTabUI.Type"] = "Tipo",
    ["Tabs.CollectionTabUI.Source"] = "Fonte",
    ["Tabs.CollectionTabUI.SearchInstructions"] = "Busca",
    ["Tabs.CollectionTabUI.Progress"] = "%d / %d (%.2f%%)",
    ["Tabs.CollectionTabUI.ProgressTooltip"] = "Sua coleção vale %s de %s Bronze.\nVocê precisa gastar mais %s para coletar tudo!",

    -- UI/CollectionsTabUI.lua
    ["CollectionsTabUI.TabTitle"] = "Legion Remix",
    ["CollectionsTabUI.ResearchProgress"] = "Pesquisa: %s/%s",
    ["CollectionsTabUI.TraitsTabTitle"] = "Traços do Artefato",
    ["CollectionsTabUI.CollectionTabTitle"] = "Coleção",

    -- UI/QuickActionBarUI.lua
    ["QuickActionBarUI.QuickBarTitle"] = "Barra-Rápida",
    ["QuickActionBarUI.SettingTitlePreview"] = "Título da Ação aqui",
    ["QuickActionBarUI.SettingsEditorTitle"] = "Edição da Ação",
    ["QuickActionBarUI.SettingsTitleLabel"] = "Título da Ação:",
    ["QuickActionBarUI.SettingsTitleInput"] = "Nome da Ação",
    ["QuickActionBarUI.SettingsIconLabel"] = "Ícone:",
    ["QuickActionBarUI.SettingsIconInput"] = "ID da Textura ou Caminho",
    ["QuickActionBarUI.SettingsIDLabel"] = "ID da Ação:",
    ["QuickActionBarUI.SettingsIDInput"] = "Item/Nome da magia ou ID",
    ["QuickActionBarUI.SettingsTypeLabel"] = "Tipo da Ação:",
    ["QuickActionBarUI.SettingsTypeInputSpell"] = "Magia",
    ["QuickActionBarUI.SettingsTypeInputItem"] = "Item",
    ["QuickActionBarUI.SettingsCheckUsableLabel"] = "Apenas quando usável:",
    ["QuickActionBarUI.SettingsEditorSave"] = "Salvar Ação",
    ["QuickActionBarUI.SettingsEditorNew"] = "Nova Ação",
    ["QuickActionBarUI.SettingsEditorDelete"] = "Deletar Ação",
    ["QuickActionBarUI.SettingsNoActionSaveError"] = "Nenhuma ação para salvar.",
    ["QuickActionBarUI.SettingsEditorAction"] = "Ação %s",
    ["QuickActionBarUI.SettingsGeneralActionSaveError"] = "Houve um erro durante o salvamento da ação: %s",
    ["QuickActionBarUI.CombatToggleError"] = "The Quick Action Bar cannot be opened or closed in combat.",

    -- UI/ScrappingUI.lua
    ["ScrappingUI.MaxScrappingQuality"] = "Qualidade Máxima do Sucateamento",
    ["ScrappingUI.MinItemLevelDifference"] = "Nível de Item Mínimo de Diferença",
    ["ScrappingUI.MinItemLevelDifferenceInstructions"] = "x níveis abaixo do equipado",
    ["ScrappingUI.AutoScrap"] = "Auto Sucateamento",

    -- Utils/ArtifactTraitUtils.lua
    ["ArtifactTraitUtils.NoItemEquipped"] = "Nenhum Item Equipado.",
    ["ArtifactTraitUtils.UnknownTrait"] = "Traço Desconhecido",
    ["ArtifactTraitUtils.ColumnNature"] = "Natureza",
    ["ArtifactTraitUtils.ColumnFel"] = "Caos",
    ["ArtifactTraitUtils.ColumnArcane"] = "Arcano",
    ["ArtifactTraitUtils.ColumnStorm"] = "Tempestade",
    ["ArtifactTraitUtils.ColumnHoly"] = "Sagrado",
    ["ArtifactTraitUtils.JewelryFormat"] = "|T%s:16|t %s (+%d)",
    ["ArtifactTraitUtils.MaxTriesReached"] = "Máximo de tentativas alcançadas ao comprar nós.",
    ["ArtifactTraitUtils.SettingsCategoryPrefix"] = "Traços do Artefato",
    ["ArtifactTraitUtils.SettingsCategoryTooltip"] = "Configurações para recursos de Traços de Artefato",
    ["ArtifactTraitUtils.AutoBuy"] = "Comprar Nós Automaticamente",
    ["ArtifactTraitUtils.AutoBuyTooltip"] = "Compra automaticamente os talentos predefinidos quando você tem Poder de Artefato suficiente.",

    -- Utils/CollectionUtils.lua
    ["CollectionUtils.Sources"] = "Fontes:",
    ["CollectionUtils.Achievement"] = "Conquista: ",
    ["CollectionUtils.UnknownAchievement"] = "Conquista Desconhecida",
    ["CollectionUtils.UnknownVendor"] = "Vendedor Desconhecido",
    ["CollectionUtils.Vendor"] = "Vendedor, ",

    -- Utils/CommandUtils.lua
    ["CommandUtils.UnknownCommand"] =
[[Unknown Command!
Usage: /LRH or /LegionRH <subCommand>
Subcommands:
    collections (c) - Open the Collections tab.
    settings (s) - Open the settings menu.
Example: /LRH s]],
    ["CommandUtils.CollectionsCommand"] = "collections",
    ["CommandUtils.CollectionsCommandShort"] = "c",
    ["CommandUtils.SettingsCommand"] = "settings",
    ["CommandUtils.SettingsCommandShort"] = "s",

    -- Utils/EditModeUtils.lua
    ["EditModeUtils.ShowAddonSystems"] = "Legion-Remix-Helper-Systems",
    ["EditModeUtils.SystemLabel.ToastUI"] = "Toasts",
    ["EditModeUtils.SystemTooltip.ToastUI"] = "Move the position of the toasts.",

    -- Utils/ItemOpenerUtils.lua
    ["ItemOpenerUtils.SettingsCategoryPrefix"] = "Abridor Automático de itens",
    ["ItemOpenerUtils.SettingsCategoryTooltip"] = "Configurações do recurso Abridor Automático de itens",
    ["ItemOpenerUtils.AutoItemOpen"] = "Abre Itens Automaticamente",
    ["ItemOpenerUtils.AutoItemOpenTooltip"] = "Abre automaticamente determinados itens no seu inventário quando encontrados. (Este recurso ainda está em desenvolvimento)",
    ["ItemOpenerUtils.AutoOpenItemEntryTooltip"] = "Abre automaticamente %s quando encontrado no seu inventário.",

    -- Utils/MerchantUtils.lua
    ["MerchantUtils.SettingsCategoryPrefix"] = "Merchant Settings",
    ["MerchantUtils.SettingsCategoryTooltip"] = "Settings for the Merchant feature",
    ["MerchantUtils.HideCollectedMerchantItems"] = "Hide Collected Merchant Items",
    ["MerchantUtils.HideCollectedMerchantItemsTooltip"] = "Hides items in the merchant window that you already have in your collection.",

    -- Utils/QuestUtils.lua
    ["QuestUtils.SettingsCategoryPrefix"] = "Missões-Automáticas",
    ["QuestUtils.SettingsCategoryTooltip"] = "Configurações do recurso Missões-Automáticas",
    ["QuestUtils.AutoTurnIn"] = "Entrega Automática",
    ["QuestUtils.AutoTurnInTooltip"] = "Automaticamente entrega as missões ao interagir com os PNJs.",
    ["QuestUtils.AutoAccept"] = "Aceitação automática",
    ["QuestUtils.AutoAcceptTooltip"] = "Automaticamente aceita as missões ao interagir com os PNJs.",
    ["QuestUtils.IgnoreEternus"] = "Ignore Eternus",
    ["QuestUtils.IgnoreEternusTooltip"] = "Ignore quests that come from Eternus.",
    ["QuestUtils.SuppressShift"] = "Suppress with Shift",
    ["QuestUtils.SuppressShiftTooltip"] = "Hold Shift to suppress automatic quest acceptance/turn-in.",

    -- Utils/QuickActionBarUtils.lua
    ["QuickActionBarUtils.SettingsCategoryPrefix"] = "Barra de Ações Rápidas",
    ["QuickActionBarUtils.SettingsCategoryTooltip"] = "Configurações do recurso Barra-Rápida",
    ["QuickActionBarUtils.ActionNotFound"] = "Ação não encontrada",
    ["QuickActionBarUtils.Action"] = "Ação %s",

    -- Utils/ToastUtils.lua
    ["ToastUtils.SettingsCategoryPrefix"] = "Pop-up",
    ["ToastUtils.SettingsCategoryTooltip"] = "Configurações para o recurso Pop-up",
    ["ToastUtils.TypeBronze"] = "Marco de Bronze",
    ["ToastUtils.TypeBronzeTooltip"] = "Mostrar um Pop-up quando você alcançar um novo marco de Bronze.",
    ["ToastUtils.TypeArtifact"] = "Aprimoramentos de Artefato",
    ["ToastUtils.TypeArtifactTooltip"] = "Mostrar Pop-up quando você encontra um aprimoramento do artefato em suas bolsas.",
    ["ToastUtils.TypeUpgrade"] = "Aprimoramentos de Items",
    ["ToastUtils.TypeUpgradeTooltip"] = "Mostrar Pop-up quando você encontra um aprimoramento de item em suas bolsas.",
    ["ToastUtils.TypeTrait"] = "Novos Traços",
    ["ToastUtils.TypeTraitTooltip"] = "Mostrar Pop-up quando você desbloqueia um novo traço de artefato.",
    ["ToastUtils.TypeSound"] = "Tocar Sons",
    ["ToastUtils.TypeSoundTooltip"] = "Tocar um som quando apresentar qualquer Pop-up.",
    ["ToastUtils.TypeGeneral"] = "Habilitar Pop-ups",
    ["ToastUtils.TypeGeneralTooltip"] = "Habilitar ou Desabilitar todas as notificações em Pop-up.",
    ["ToastUtils.TestToast"] = "Testar Pop-up",
    ["ToastUtils.TestToastButtonTitle"] = "Teste de Notificação Pop-up",
    ["ToastUtils.TestToastTooltip"] = "Mostra um teste de notificação pop-up.",
    ["ToastUtils.TestToastTitle"] = "Teste de Notificação Pop-up",
    ["ToastUtils.TestToastDescription"] = "Isto é um teste de notificação pop-up.",
    ["ToastUtils.TypeBronzeTitle"] = "Novo Marco de Bronze!",
    ["ToastUtils.TypeBronzeDescription"] = "Você alcançou %d bronze! (%.2f%% até o limite)",
    ["ToastUtils.TypeArtifactTitle"] = "Novo Aprimoramento de Artefato!",
    ["ToastUtils.TypeArtifactDescription"] = "Você possui uma nova melhoria de artefato! Confira seu inventário ou a barra de ação rápida.",
    ["ToastUtils.TypeUpgradeTitle"] = "Novo Aprimoramento de Item!",
    ["ToastUtils.TypeUpgradeFallback"] = "Item Desconhecido",
    ["ToastUtils.TypeTraitTitle"] = "Novo Traço Desbloqueado!",
    ["ToastUtils.TypeTraitDescription"] = "Novo Traço: %s",
    ["ToastUtils.TypeTraitFallback"] = "Traço Desconhecido",

    -- Utils/TooltipUtils.lua
    ["TooltipUtils.Threads"] = "Tópicos",
    ["TooltipUtils.InfinitePower"] = "Poder Infinito",
    ["TooltipUtils.Estimate"] = " (Estimativa)",
    ["TooltipUtils.SettingsCategoryPrefix"] = "Caixa de Informação do Poder",
    ["TooltipUtils.SettingsCategoryTooltip"] = "Configurações do recurso Caixa de Informação do Poder",
    ["TooltipUtils.Activate"] = "Ativar",
    ["TooltipUtils.ActivateTooltip"] = "Exibir Caixa de Informação do Poder",
    ["TooltipUtils.ThreadsInfo"] = "Informações de Tópicos",
    ["TooltipUtils.ThreadsInfoTooltip"] = "Exibir Caixa de Informação do Poder com informações do Tópico",
    ["TooltipUtils.PowerInfo"] = "Informações do Poder",
    ["TooltipUtils.PowerInfoTooltip"] = "Exibir Caixa de Informação do Poder com informações do Poder Infinito",

    -- Utils/UpdateUtils.lua
    ["UpdateUtils.PatchNotesMessage"] = "Seu addon foi atualizado da versão %s para a versão %s. Confira as notas do patch no Discord do Addon!",
    ["UpdateUtils.NilVersion"] = "N/D",

    -- Utils/UXUtils.lua
    ["UXUtils.SettingsCategoryPrefix"] = "Configurações Gerais",
    ["UXUtils.SettingsCategoryTooltip"] = "Configurações Gerais do Addon",
}
locales["ptBR"] = L
