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
