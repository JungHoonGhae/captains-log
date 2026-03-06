import Foundation

// MARK: - Language

enum Language: String, CaseIterable, Codable {
    case en, ko, ja, zh, es, fr, de

    var displayName: String {
        switch self {
        case .en: return "English"
        case .ko: return "한국어"
        case .ja: return "日本語"
        case .zh: return "中文"
        case .es: return "Español"
        case .fr: return "Français"
        case .de: return "Deutsch"
        }
    }

    var flag: String {
        switch self {
        case .en: return "🇺🇸"
        case .ko: return "🇰🇷"
        case .ja: return "🇯🇵"
        case .zh: return "🇨🇳"
        case .es: return "🇪🇸"
        case .fr: return "🇫🇷"
        case .de: return "🇩🇪"
        }
    }

    static var system: Language {
        let code = Locale.current.language.languageCode?.identifier ?? "en"
        return Language(rawValue: code) ?? .en
    }
}

// MARK: - Localization Manager

enum L10n {
    static var lang: Language = .system

    // MARK: App
    static var appTitle: String { s(
        "Captain's Log",
        "캡틴스 로그",
        "キャプテンズ・ログ",
        "船长日志",
        "Diario del Capitán",
        "Journal du Capitaine",
        "Logbuch des Kapitäns"
    )}

    // MARK: Ranks
    static var rankCaptain: String { s("Captain", "캡틴", "船長", "船长", "Capitán", "Capitaine", "Kapitän") }
    static var rankFirstMate: String { s("First Mate", "항해사", "副船長", "大副", "Primer Oficial", "Second", "Erster Maat") }
    static var rankDeckhand: String { s("Deckhand", "선원", "甲板員", "水手", "Marinero", "Matelot", "Matrose") }
    static var rankCastaway: String { s("Castaway", "조난자", "漂流者", "落水者", "Náufrago", "Naufragé", "Schiffbrüchiger") }
    static var rankDavyJones: String { s("Davy Jones", "데비 존스", "亡者", "亡灵", "Alma en Pena", "Âme Perdue", "Verlorene Seele") }

    static func rankTitle(_ rank: PirateRank) -> String {
        switch rank {
        case .captain:   return rankCaptain
        case .firstMate: return rankFirstMate
        case .deckhand:  return rankDeckhand
        case .castaway:  return rankCastaway
        case .davyJones: return rankDavyJones
        }
    }

    // MARK: Rank Quotes
    static func rankQuote(_ rank: PirateRank) -> String {
        switch rank {
        case .captain:
            return s(
                "Ye be a true Captain! The sea bows to ye!",
                "캡틴이라고 불러. '캡틴'.",
                "この海の王は俺だ！",
                "这片海的主人是我！",
                "¡El mar es tuyo, Capitán!",
                "La mer t'appartient, Capitaine !",
                "Das Meer gehört dir, Kapitän!"
            )
        case .firstMate:
            return s(
                "The sea be callin', mate... better start shippin'!",
                "수평선이 흐려지고 있어... 이해했는가?",
                "波が荒れてきた… コミットしないとヤバいぞ！",
                "风浪来了… 不提交就完了！",
                "Se viene la tormenta... ¡commitea ya!",
                "La tempête approche… commite vite !",
                "Der Sturm zieht auf… schnell committen!"
            )
        case .deckhand:
            return s(
                "Ship's takin' water! Commit or walk the plank!",
                "블랙펄이 가라앉고 있어! 럼주 말고 커밋!",
                "船が沈む！今すぐコミットしろ！",
                "船在下沉！快提交！",
                "¡El barco se hunde! ¡Commitea ahora!",
                "Le navire coule ! Commite maintenant !",
                "Das Schiff sinkt! Jetzt committen!"
            )
        case .castaway:
            return s(
                "Abandon ship! Ye be drownin'!",
                "크라켄이 온다! 커밋만이 살 길이야!",
                "海に落ちた！コミットだけが命綱だ！",
                "落水了！只有提交能救你！",
                "¡Estás ahogándote! ¡Solo un commit te salva!",
                "Tu te noies ! Seul un commit peut te sauver !",
                "Du ertrinkst! Nur ein Commit rettet dich!"
            )
        case .davyJones:
            return s(
                "To Davy Jones' Locker with ye! COMMIT NOW!",
                "플라잉 더치맨에 오신 것을 환영한다. 커밋해.",
                "深海に引きずり込まれる！今すぐコミット！",
                "被拖入深渊！立刻提交！",
                "¡Te arrastra el abismo! ¡COMMITEA YA!",
                "L'abîme t'aspire ! COMMITE MAINTENANT !",
                "Der Abgrund verschlingt dich! JETZT COMMITTEN!"
            )
        }
    }

    // MARK: Ship Types
    static var shipFlagship: String { s("Flagship", "기함", "旗艦", "旗舰", "Insignia", "Amiral", "Flaggschiff") }
    static var shipWarship: String { s("Warship", "전함", "軍艦", "战舰", "Acorazado", "Cuirassé", "Kriegsschiff") }
    static var shipGalleon: String { s("Galleon", "범선", "帆船", "帆船", "Galeón", "Galion", "Galeone") }
    static var shipSloop: String { s("Sloop", "소형선", "小型船", "小帆船", "Balandra", "Sloop", "Schaluppe") }
    static var shipDinghy: String { s("Dinghy", "뗏목", "筏", "木筏", "Bote", "Canot", "Beiboot") }
    static var shipShipwreck: String { s("Shipwreck", "난파선", "難破船", "沉船", "Naufragio", "Épave", "Wrack") }

    static func shipLabel(_ type: ShipType) -> String {
        switch type {
        case .flagship:  return shipFlagship
        case .warship:   return shipWarship
        case .galleon:   return shipGalleon
        case .sloop:     return shipSloop
        case .dinghy:    return shipDinghy
        case .shipwreck: return shipShipwreck
        }
    }

    static func shipDesc(_ type: ShipType) -> String {
        switch type {
        case .flagship:  return s("Leading the fleet!", "블랙펄급! 함대를 이끈다!", "艦隊の先頭！", "舰队先锋！", "¡Lidera la flota!", "En tête de flotte !", "Führt die Flotte!")
        case .warship:   return s("Battle-ready", "플라잉 더치맨처럼 강하다", "臨戦態勢", "战斗准备", "Listo", "Prêt", "Bereit")
        case .galleon:   return s("Sailing steady", "순풍에 돛 올려", "順調", "稳定航行", "Navegando", "En route", "Unterwegs")
        case .sloop:     return s("Drifting...", "바람이 멎었다...", "漂流中…", "漂流中…", "A la deriva...", "À la dérive…", "Treibend…")
        case .dinghy:    return s("Barely afloat", "크라켄 밥이 될 판", "沈みかけ", "快沉了", "Casi hundido", "Presque coulé", "Kaum über Wasser")
        case .shipwreck: return s("Sunk to the depths", "데비 존스에게 바쳤다", "沈没", "已沉", "Hundido", "Coulé", "Gesunken")
        }
    }

    // MARK: Fleet
    static var fleet: String { s("Fleet", "함대", "艦隊", "舰队", "Flota", "Flotte", "Flotte") }
    static var ships: String { s("Ships", "선박", "船", "船只", "Barcos", "Navires", "Schiffe") }
    static var noFleet: String { s("No fleet", "함대 없음", "艦隊なし", "无舰队", "Sin flota", "Pas de flotte", "Keine Flotte") }
    static func fleetStrength(_ sailing: Int, _ total: Int) -> String {
        s("\(sailing)/\(total) sailing",
          "\(sailing)/\(total) 항해 중",
          "\(sailing)/\(total) 航行中",
          "\(sailing)/\(total) 航行中",
          "\(sailing)/\(total) navegando",
          "\(sailing)/\(total) en mer",
          "\(sailing)/\(total) unterwegs")
    }

    // MARK: Weather
    static func weatherLabel(_ w: Weather) -> String {
        switch w {
        case .clear:     return s("Clear Skies", "맑은 하늘", "快晴", "晴朗", "Cielo Despejado", "Ciel Dégagé", "Klarer Himmel")
        case .cloudy:    return s("Partly Cloudy", "구름 조금", "曇り", "多云", "Parcialmente Nublado", "Partiellement Nuageux", "Teilweise Bewölkt")
        case .rainy:     return s("Rain & Wind", "비바람", "雨風", "风雨", "Lluvia y Viento", "Pluie et Vent", "Regen & Wind")
        case .stormy:    return s("Storm!", "폭풍!", "嵐！", "暴风！", "¡Tormenta!", "Tempête !", "Sturm!")
        case .hurricane: return s("Hurricane!", "태풍!", "台風！", "台风！", "¡Huracán!", "Ouragan !", "Hurrikan!")
        }
    }

    static var seaCondition: String { s("Sea Condition", "해상 상태", "海況", "海况", "Estado del Mar", "État de la Mer", "Seezustand") }

    // MARK: UI Labels
    static var water: String { s("water", "침수", "浸水", "进水", "agua", "eau", "Wasser") }
    static var pushes: String { s("pushes", "푸시", "プッシュ", "推送", "pushes", "pushes", "Pushes") }
    static var local: String { s("local", "로컬", "ローカル", "本地", "local", "local", "lokal") }
    static var scanning: String { s("Scanning for repos...", "저장소 검색 중...", "リポジトリ検索中…", "搜索仓库中…", "Buscando repos...", "Recherche de repos…", "Suche nach Repos…") }
    static var showLess: String { s("Show Less", "접기", "閉じる", "收起", "Menos", "Moins", "Weniger") }
    static func showAll(_ count: Int) -> String {
        s("Show All (\(count))", "전체 보기 (\(count))", "すべて (\(count))", "全部 (\(count))", "Todo (\(count))", "Tout (\(count))", "Alle (\(count))")
    }
    static var quit: String { s("Quit", "종료", "終了", "退出", "Salir", "Quitter", "Beenden") }
    static var addRepo: String { s("Add Repo", "추가", "追加", "添加", "Añadir", "Ajouter", "Hinzufügen") }
    static var selectRepos: String { s(
        "Select your repos, Captain!",
        "추적할 저장소를 선택하세요!",
        "追跡するリポジトリを選択！",
        "选择要追踪的仓库！",
        "¡Selecciona tus repos!",
        "Sélectionne tes repos !",
        "Wähle deine Repos!"
    )}
    static var language: String { s("Language", "언어", "言語", "语言", "Idioma", "Langue", "Sprache") }

    // MARK: Settings
    static var settings: String { s("Settings", "설정", "設定", "设置", "Ajustes", "Paramètres", "Einstellungen") }
    static var launchAtLogin: String { s("Launch at Login", "로그인 시 시작", "ログイン時に起動", "登录时启动", "Iniciar al Login", "Lancer au Démarrage", "Beim Login starten") }
    static var captainName: String { s("Captain Name", "선장 이름", "船長名", "船长名", "Nombre", "Nom", "Name") }
    static var captainNamePlaceholder: String { s("Enter your name", "이름을 입력하세요", "名前を入力", "输入名字", "Tu nombre", "Ton nom", "Dein Name") }
    static var general: String { s("General", "일반", "一般", "通用", "General", "Général", "Allgemein") }
    static var features: String { s("Features", "기능", "機能", "功能", "Funciones", "Fonctions", "Funktionen") }
    static var github: String { s("GitHub", "GitHub", "GitHub", "GitHub", "GitHub", "GitHub", "GitHub") }

    // MARK: Ship View
    static var shipView: String { s("Ship View", "선박 보기", "船表示", "船只视图", "Vista de Barcos", "Vue des Navires", "Schiffansicht") }
    static var viewClassic: String { s("Classic", "클래식", "クラシック", "经典", "Clásico", "Classique", "Klassisch") }
    static var viewCompact: String { s("Compact", "컴팩트", "コンパクト", "紧凑", "Compacto", "Compact", "Kompakt") }
    static var viewGrid: String { s("Grid", "그리드", "グリッド", "网格", "Cuadrícula", "Grille", "Raster") }
    static var viewFleet: String { s("Fleet", "편대", "編隊", "编队", "Escuadra", "Escadre", "Geschwader") }

    // MARK: Navigator (보물 사냥)
    static var navigator: String { s("Navigator", "항해사", "ナビゲーター", "领航员", "Navegante", "Navigateur", "Navigator") }
    static var dug: String { s("dug", "발굴", "発掘", "挖掘", "excavado", "excavé", "gegraben") }
    static var stowed: String { s("stowed", "적재", "積載", "装载", "estibado", "arrimé", "verstaut") }
    static var allStashed: String { s("All stashed!", "은닉 완료!", "全て隠した！", "全部藏好了！", "¡Todo escondido!", "Tout planqué !", "Alles versteckt!") }
    static var stashed: String { s("stashed", "은닉", "格納", "藏匿", "escondido", "planqué", "versteckt") }

    // MARK: Pipeline Tooltips
    static var tooltipDug: String { s(
        "Uncommitted changes across all repos",
        "모든 저장소의 커밋되지 않은 변경사항",
        "全リポジトリの未コミット変更",
        "所有仓库的未提交更改",
        "Cambios sin commit en todos los repos",
        "Changements non commités dans tous les repos",
        "Nicht committete Änderungen in allen Repos"
    )}
    static var tooltipStowed: String { s(
        "Today's local commits across all repos",
        "오늘 모든 저장소의 로컬 커밋 수",
        "今日の全リポジトリのローカルコミット",
        "今天所有仓库的本地提交",
        "Commits locales de hoy en todos los repos",
        "Commits locaux du jour dans tous les repos",
        "Heutige lokale Commits in allen Repos"
    )}
    static var tooltipStashed: String { s(
        "Today's commits pushed to remote",
        "오늘 원격에 푸시된 커밋 수",
        "今日リモートにプッシュ済みのコミット",
        "今天已推送到远程的提交",
        "Commits pusheados hoy al remoto",
        "Commits poussés au distant aujourd'hui",
        "Heute zum Remote gepushte Commits"
    )}

    // MARK: Captain Speech Bubbles
    static func captainSpeeches(dirty: Int, unpushed: Int, waterLevel: Double) -> [String] {
        if waterLevel > 70 { return speechStorm }
        if waterLevel < 20 && dirty == 0 && unpushed == 0 { return speechCalm }
        if dirty == 0 && unpushed == 0 { return speechClean }
        if dirty > 0 && unpushed == 0 { return speechDirtyOnly }
        if dirty == 0 && unpushed > 0 { return speechUnpushedOnly }
        return speechBoth
    }

    private static var speechClean: [String] { [
        s("Hoist the sails!", "순풍에 돛을 올려라!", "帆を上げろ！", "升帆前进！", "¡Izad velas!", "Hissez les voiles !", "Segel setzen!"),
        s("The seas are ours!", "바다가 우리 편이다!", "海は我らのものだ！", "大海归我们！", "¡El mar es nuestro!", "La mer est à nous !", "Das Meer gehört uns!"),
        s("Full speed ahead!", "전속 전진!", "全速前進！", "全速前进！", "¡A toda máquina!", "En avant toute !", "Volle Kraft voraus!")
    ]}
    private static var speechDirtyOnly: [String] { [
        s("Commit those changes!", "변경사항을 커밋해라!", "変更をコミットしろ！", "提交变更！", "¡Commitea los cambios!", "Commite les changements !", "Committe die Änderungen!"),
        s("Treasure found! Stow it!", "보물 발견! 적재해라!", "宝発見！積め！", "发现宝藏！装船！", "¡Tesoro! ¡Estibad!", "Trésor ! Arrime !", "Schatz gefunden! Verstauen!"),
        s("Don't leave loot on deck!", "갑판에 전리품을 놔두지 마라!", "甲板に放置するな！", "别放在甲板上！", "¡No dejes botín en cubierta!", "Pas de butin sur le pont !", "Beute nicht an Deck lassen!")
    ]}
    private static var speechUnpushedOnly: [String] { [
        s("Send cargo to port!", "화물을 항구로 보내라!", "貨物を港へ送れ！", "把货送到港口！", "¡Envía la carga!", "Envoie la cargaison !", "Fracht zum Hafen!"),
        s("Push before the tide turns!", "밀물 전에 푸시해라!", "潮が変わる前にプッシュ！", "趁潮水未变快推！", "¡Push antes de la marea!", "Pousse avant la marée !", "Push vor der Flut!"),
        s("Harbor's waiting!", "항구가 기다린다!", "港が待っている！", "港口在等着！", "¡El puerto espera!", "Le port attend !", "Der Hafen wartet!")
    ]}
    private static var speechBoth: [String] { [
        s("Commit and push, double time!", "커밋하고 푸시! 서둘러!", "コミットしてプッシュ！急げ！", "提交并推送！快！", "¡Commit y push, rápido!", "Commit et push, vite !", "Commit und Push, schnell!"),
        s("Stow and ship the loot!", "적재하고 출항해라!", "積んで出航だ！", "装船出港！", "¡Estiba y zarpa!", "Arrime et appareille !", "Verstauen und ablegen!"),
        s("All hands on deck!", "전원 갑판으로!", "総員甲板へ！", "全员上甲板！", "¡Todos a cubierta!", "Tout l'équipage sur le pont !", "Alle Mann an Deck!")
    ]}
    private static var speechStorm: [String] { [
        s("Batten down the hatches!", "해치를 닫아라!", "ハッチを閉めろ！", "关闭舱口！", "¡Cerrad escotillas!", "Fermez les écoutilles !", "Luken dicht!"),
        s("Storm's upon us! Ship now!", "폭풍이다! 당장 출항!", "嵐だ！今すぐ出せ！", "暴风来了！快！", "¡Tormenta! ¡Ya!", "Tempête ! Vite !", "Sturm! Sofort shippen!"),
        s("We're taking on water!", "침수 중이다!", "浸水している！", "正在进水！", "¡Nos hundimos!", "On prend l'eau !", "Wir laufen voll!")
    ]}
    private static var speechCalm: [String] { [
        s("Smooth seas, Captain...", "순항이로다...", "穏やかな海だ…", "风平浪静…", "Mar en calma...", "Mer d'huile...", "Ruhige See..."),
        s("A fine day to sail...", "항해하기 좋은 날이로다...", "航海日和だ…", "好天气啊…", "Buen día para navegar...", "Belle journée en mer...", "Guter Segeltag..."),
        s("The horizon is clear...", "수평선이 맑다...", "水平線が澄んでいる…", "地平线清晰…", "Horizonte despejado...", "L'horizon est dégagé...", "Horizont ist klar...")
    ]}

    // MARK: Off Duty (비운항 시간)
    static var sleepMode: String { s("Off Duty", "비운항 시간", "停泊時間", "停泊时间", "Fuera de Servicio", "Hors Service", "Dienstfrei") }
    static var sleepDays: String { s("Active Days", "적용 요일", "適用曜日", "适用日", "Días Activos", "Jours Actifs", "Aktive Tage") }

    static func dayAbbrev(_ weekday: Int) -> String {
        switch weekday {
        case 1: return s("Sun", "일", "日", "日", "Dom", "Dim", "So")
        case 2: return s("Mon", "월", "月", "一", "Lun", "Lun", "Mo")
        case 3: return s("Tue", "화", "火", "二", "Mar", "Mar", "Di")
        case 4: return s("Wed", "수", "水", "三", "Mié", "Mer", "Mi")
        case 5: return s("Thu", "목", "木", "四", "Jue", "Jeu", "Do")
        case 6: return s("Fri", "금", "金", "五", "Vie", "Ven", "Fr")
        case 7: return s("Sat", "토", "土", "六", "Sáb", "Sam", "Sa")
        default: return ""
        }
    }
    static var sleepFrom: String { s("From", "시작", "開始", "开始", "Desde", "De", "Von") }
    static var sleepTo: String { s("To", "종료", "終了", "结束", "Hasta", "À", "Bis") }
    static func sleepHour(_ h: Int) -> String {
        let formatted = String(format: "%02d:00", h)
        return formatted
    }

    // MARK: Time
    static var justNow: String { s("Just now", "방금", "たった今", "刚刚", "Ahora", "À l'instant", "Gerade") }
    static var noCommits: String { s("No commits", "커밋 없음", "コミットなし", "无提交", "Sin commits", "Aucun commit", "Keine Commits") }
    static func minutesAgo(_ m: Int) -> String { s("\(m)m ago", "\(m)분 전", "\(m)分前", "\(m)分钟前", "hace \(m)m", "il y a \(m)m", "vor \(m)m") }
    static func hoursAgo(_ h: Int) -> String { s("\(h)h ago", "\(h)시간 전", "\(h)時間前", "\(h)小时前", "hace \(h)h", "il y a \(h)h", "vor \(h)h") }
    static func daysAgo(_ d: Int) -> String { s("\(d)d ago", "\(d)일 전", "\(d)日前", "\(d)天前", "hace \(d)d", "il y a \(d)j", "vor \(d)T") }
    static func monthsAgo(_ m: Int) -> String { s("\(m)mo ago", "\(m)개월 전", "\(m)ヶ月前", "\(m)个月前", "hace \(m)mes", "il y a \(m)mois", "vor \(m)Mon") }

    // MARK: Notifications - Sinking
    static func notifSinking(_ rank: PirateRank) -> (title: String, body: String) {
        switch rank {
        case .captain:
            return ("", "")
        case .firstMate:
            return (
                s("⚓ Demoted to First Mate!",
                  "⚓ 항해사로 강등!",
                  "⚓ 副船長に降格！",
                  "⚓ 降为大副！",
                  "⚓ ¡Degradado a Primer Oficial!",
                  "⚓ Rétrogradé au Second !",
                  "⚓ Zum Ersten Maat degradiert!"),
                s("Your ship is slowing down... get back to coding!",
                  "블랙펄이 속도를 잃고 있어... 이해했는가?",
                  "船が減速している… コードに戻れ！",
                  "船在减速… 回去写代码！",
                  "Tu barco frena... ¡vuelve a programar!",
                  "Ton navire ralentit… retourne coder !",
                  "Dein Schiff wird langsamer… zurück zum Coden!")
            )
        case .deckhand:
            return (
                s("🪝 Demoted to Deckhand!",
                  "🪝 선원으로 강등!",
                  "🪝 甲板員に降格！",
                  "🪝 降为水手！",
                  "🪝 ¡Degradado a Marinero!",
                  "🪝 Rétrogradé au Matelot !",
                  "🪝 Zum Matrosen degradiert!"),
                s("Your ship is sinking! Commit now!",
                  "블랙펄에 물이 차오른다! 럼주 말고 커밋!",
                  "船が沈んでいる！今すぐコミットしろ！",
                  "船在下沉！赶快提交！",
                  "¡Tu barco se hunde! ¡Commitea ya!",
                  "Ton navire coule ! Commite vite !",
                  "Dein Schiff sinkt! Sofort committen!")
            )
        case .castaway:
            return (
                s("🏊 You're a Castaway now!",
                  "🏊 크라켄에게 당했다!",
                  "🏊 漂流中！",
                  "🏊 你落水了！",
                  "🏊 ¡Estás naufragando!",
                  "🏊 Tu es naufragé !",
                  "🏊 Du bist schiffbrüchig!"),
                s("You're drowning! Only a commit can save you!",
                  "크라켄이 끌어당기고 있어! 커밋만이 살 길이야!",
                  "溺れている！コミットだけが救いだ！",
                  "你在溺水！只有提交能救你！",
                  "¡Te ahogas! ¡Solo un commit te salva!",
                  "Tu te noies ! Seul un commit peut te sauver !",
                  "Du ertrinkst! Nur ein Commit rettet dich!")
            )
        case .davyJones:
            return (
                s("☠️ YOU ARE DEAD!",
                  "☠️ 플라잉 더치맨 탑승!",
                  "☠️ 死亡！",
                  "☠️ 你死了！",
                  "☠️ ¡ESTÁS MUERTO!",
                  "☠️ TU ES MORT !",
                  "☠️ DU BIST TOT!"),
                s("Game over. Commit to come back to life!",
                  "데비 존스와 100년 계약 체결. 커밋하면 파기.",
                  "ゲームオーバー。コミットで復活！",
                  "游戏结束。提交即可复活！",
                  "Fin del juego. ¡Commitea para revivir!",
                  "Game over. Commite pour revivre !",
                  "Game Over. Committe zum Wiederbeleben!")
            )
        }
    }

    // MARK: Notifications - Rising
    static func notifRising(_ rank: PirateRank, from oldRank: PirateRank) -> (title: String, body: String) {
        if oldRank == .davyJones {
            return (
                s("🏴‍☠️ RESURRECTION!",
                  "🏴‍☠️ 플라잉 더치맨 탈출!",
                  "🏴‍☠️ 復活！",
                  "🏴‍☠️ 复活！",
                  "🏴‍☠️ ¡RESURRECCIÓN!",
                  "🏴‍☠️ RÉSURRECTION !",
                  "🏴‍☠️ AUFERSTEHUNG!"),
                s("You cheated death! Keep shipping!",
                  "데비 존스와의 계약을 파기했다! 항해를 계속하라!",
                  "死から蘇った！コミットを続けろ！",
                  "你复活了！继续提交！",
                  "¡Volviste de la muerte! ¡Sigue commiteando!",
                  "Tu es revenu ! Continue à commiter !",
                  "Du bist zurück! Weiter committen!")
            )
        }
        switch rank {
        case .captain:
            return (
                s("🏴‍☠️ Promoted to Captain!",
                  "🏴‍☠️ 캡틴 승진!",
                  "🏴‍☠️ 船長に昇進！",
                  "🏴‍☠️ 晋升为船长！",
                  "🏴‍☠️ ¡Ascendido a Capitán!",
                  "🏴‍☠️ Promu Capitaine !",
                  "🏴‍☠️ Zum Kapitän befördert!"),
                s("You own the seas! Keep this pace!",
                  "블랙펄의 캡틴이다! 캡틴 잭 스패로우!",
                  "海の王だ！このペースを維持しろ！",
                  "你是海上之王！保持这个速度！",
                  "¡El mar es tuyo! ¡Mantén el ritmo!",
                  "La mer est à toi ! Garde ce rythme !",
                  "Das Meer gehört dir! Halte dieses Tempo!")
            )
        case .firstMate:
            return (
                s("⚓ Promoted to First Mate!",
                  "⚓ 항해사 승진!",
                  "⚓ 副船長に昇進！",
                  "⚓ 晋升为大副！",
                  "⚓ ¡Ascendido a Primer Oficial!",
                  "⚓ Promu Second !",
                  "⚓ Zum Ersten Maat befördert!"),
                s("Almost there! One more push to Captain!",
                  "블랙펄의 키가 보인다! 조금만 더 하면 캡틴이다!",
                  "もう少しで船長だ！あと一押し！",
                  "快了！再加把劲就是船长！",
                  "¡Casi llegas! ¡Un push más y eres Capitán!",
                  "Presque ! Encore un push et tu es Capitaine !",
                  "Fast da! Noch ein Push zum Kapitän!")
            )
        case .deckhand:
            return (
                s("🪝 Promoted to Deckhand!",
                  "🪝 선원 승진!",
                  "🪝 甲板員に昇進！",
                  "🪝 晋升为水手！",
                  "🪝 ¡Ascendido a Marinero!",
                  "🪝 Promu Matelot !",
                  "🪝 Zum Matrosen befördert!"),
                s("Water's going down. Keep it up!",
                  "크라켄의 촉수에서 벗어났다! 계속 가자!",
                  "水が引いている。その調子だ！",
                  "水在退去。继续加油！",
                  "El agua baja. ¡Sigue así!",
                  "L'eau baisse. Continue !",
                  "Das Wasser sinkt. Weiter so!")
            )
        case .castaway:
            return (
                s("🏊 Still struggling, but improving!",
                  "🏊 아직 심해지만 수면이 보인다!",
                  "🏊 まだ危険だが改善中！",
                  "🏊 还在挣扎，但在好转！",
                  "🏊 ¡Aún luchas, pero mejoras!",
                  "🏊 Tu luttes encore, mais ça s'améliore !",
                  "🏊 Noch im Kampf, aber es wird besser!"),
                s("Keep committing to get back on deck!",
                  "블랙펄의 갑판이 보인다! 커밋으로 올라가자!",
                  "コミットを続けて船に戻れ！",
                  "继续提交回到甲板上！",
                  "¡Sigue commiteando para volver a bordo!",
                  "Continue à commiter pour remonter !",
                  "Weiter committen um zurück an Bord zu kommen!")
            )
        case .davyJones:
            return ("", "")
        }
    }

    // MARK: Navigator v2 — Hull & Voyage
    static func hullStatus(_ rank: PirateRank) -> String {
        switch rank {
        case .captain:   return s("Perfect sailing!", "최고의 항해!", "最高の航海！", "完美航行！", "¡Navegación perfecta!", "Navigation parfaite !", "Perfekte Fahrt!")
        case .firstMate: return s("Fair winds", "순풍", "順風", "顺风", "Buen viento", "Bon vent", "Guter Wind")
        case .deckhand:  return s("Getting rough!", "거칠어진다!", "荒れてきた！", "变得粗暴！", "¡Se pone difícil!", "Ça se complique !", "Wird rau!")
        case .castaway:  return s("Mayday!", "조난 신호!", "メーデー！", "求救信号！", "¡Mayday!", "Mayday !", "Mayday!")
        case .davyJones: return s("Commit to resurrect!", "커밋으로 부활!", "コミットで復活！", "提交即复活！", "¡Commitea para revivir!", "Commite pour revivre !", "Committe zum Wiederbeleben!")
        }
    }

    static func dSailing(_ days: Int) -> String {
        s("\(days)d sailing",
          "\(days)일 항해",
          "\(days)日航海",
          "\(days)天航海",
          "\(days)d navegando",
          "\(days)j en mer",
          "\(days)T Fahrt")
    }

    static var hullIntegrity: String { s("Hull Integrity", "선체 건강도", "船体耐久度", "船体耐久", "Integridad", "Intégrité", "Hüllenstärke") }

    static func anchoredTime(_ time: String) -> String {
        s("\u{2693} \(time) calm", "\u{2693} \(time) 잔잔", "\u{2693} \(time) 穏やか", "\u{2693} \(time) 平静", "\u{2693} \(time) calma", "\u{2693} \(time) calme", "\u{2693} \(time) ruhig")
    }
    static func driftingTime(_ time: String) -> String {
        s("\u{1F327}\u{FE0F} \(time) rain", "\u{1F327}\u{FE0F} \(time) 비바람", "\u{1F327}\u{FE0F} \(time) 雨", "\u{1F327}\u{FE0F} \(time) 雨", "\u{1F327}\u{FE0F} \(time) lluvia", "\u{1F327}\u{FE0F} \(time) pluie", "\u{1F327}\u{FE0F} \(time) Regen")
    }
    static func floodingTime(_ time: String) -> String {
        s("\u{26C8}\u{FE0F} \(time) storm", "\u{26C8}\u{FE0F} \(time) 폭풍", "\u{26C8}\u{FE0F} \(time) 嵐", "\u{26C8}\u{FE0F} \(time) 暴风", "\u{26C8}\u{FE0F} \(time) tormenta", "\u{26C8}\u{FE0F} \(time) tempête", "\u{26C8}\u{FE0F} \(time) Sturm")
    }
    static func sunkTime(_ time: String) -> String {
        s("\u{1F300} \(time)+ hurricane", "\u{1F300} \(time)+ 태풍", "\u{1F300} \(time)+ 台風", "\u{1F300} \(time)+ 台风", "\u{1F300} \(time)+ huracán", "\u{1F300} \(time)+ ouragan", "\u{1F300} \(time)+ Hurrikan")
    }
    static var todayVoyage: String { s("Today's Voyage", "오늘 항해", "今日の航海", "今日航行", "Viaje de Hoy", "Voyage du Jour", "Heutige Fahrt") }
    static var flagship: String { s("Flagship!", "기함 달성!", "旗艦達成！", "旗舰达成！", "¡Insignia!", "Amiral !", "Flaggschiff!") }
    static var treasure: String { s("Treasure", "보물", "宝物", "宝藏", "Tesoro", "Trésor", "Schatz") }
    static var speechBubble: String { s("Speech Bubble", "말풍선", "吹き出し", "对话框", "Bocadillo", "Bulle", "Sprechblase") }
    static var dailyGoal: String { s("Daily Goal", "일일 목표", "日課目標", "每日目标", "Meta Diaria", "Objectif Quotidien", "Tagesziel") }
    static var commits: String { s("commits", "커밋", "コミット", "提交", "commits", "commits", "Commits") }

    // MARK: Death Screen
    static var davyJonersLocker: String { s(
        "DAVY JONES' LOCKER",
        "데비 존스의 해저 감옥",
        "海の墓場",
        "深海坟墓",
        "TUMBA MARINA",
        "TOMBEAU MARIN",
        "GRAB DER TIEFE"
    )}
    static var commitToResurrect: String { s(
        "Commit to Resurrect",
        "커밋하면 블랙펄이 돌아온다",
        "コミットで復活",
        "提交即复活",
        "Commitea para Revivir",
        "Commite pour Revivre",
        "Committe zum Wiederbeleben"
    )}

    // MARK: Voyage Log
    static var voyageLog: String { s("Voyage Log", "항해 일지", "航海日誌", "航海日志", "Diario de Viaje", "Journal de Voyage", "Fahrtenbuch") }
    static func sailing(_ days: Int) -> String {
        s("⚓ \(days)d sailing",
          "⚓ \(days)일 연속 항해",
          "⚓ \(days)日連続航海",
          "⚓ 连续航行\(days)天",
          "⚓ \(days)d navegando",
          "⚓ \(days)j en mer",
          "⚓ \(days)T unterwegs")
    }
    static var noVoyage: String { s("No voyages yet", "아직 항해 기록 없음", "航海記録なし", "暂无航海记录", "Sin viajes aún", "Pas encore de voyages", "Noch keine Fahrten") }
    static var range1d: String { s("1D", "1일", "1日", "1天", "1D", "1J", "1T") }
    static var range3d: String { s("3D", "3일", "3日", "3天", "3D", "3J", "3T") }
    static var range7d: String { s("7D", "7일", "7日", "7天", "7D", "7J", "7T") }
    static var range30d: String { s("30D", "30일", "30日", "30天", "30D", "30J", "30T") }
    static var range1y: String { s("1Y", "1년", "1年", "1年", "1A", "1A", "1J") }

    // MARK: - Helper

    private static func s(_ en: String, _ ko: String, _ ja: String, _ zh: String, _ es: String, _ fr: String, _ de: String) -> String {
        switch lang {
        case .en: return en
        case .ko: return ko
        case .ja: return ja
        case .zh: return zh
        case .es: return es
        case .fr: return fr
        case .de: return de
        }
    }
}
