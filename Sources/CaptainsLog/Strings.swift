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
    static var appTitle: String { s("Captain's Log", "선장의 항해일지", "航海日誌", "航海日志", "Diario del Capitán", "Journal du Capitaine", "Logbuch des Kapitäns") }

    // MARK: Ranks
    static var rankCaptain: String { s("Captain", "선장", "船長", "船长", "Capitán", "Capitaine", "Kapitän") }
    static var rankFirstMate: String { s("First Mate", "일등항해사", "副長", "大副", "Primer Oficial", "Second", "Erster Maat") }
    static var rankDeckhand: String { s("Deckhand", "갑판원", "甲板員", "水手", "Marinero", "Matelot", "Matrose") }
    static var rankCastaway: String { s("Castaway", "표류자", "漂流者", "落水者", "Náufrago", "Naufragé", "Schiffbrüchiger") }
    static var rankDavyJones: String { s("Davy Jones", "데비 존스", "デイヴィ・ジョーンズ", "戴维·琼斯", "Davy Jones", "Davy Jones", "Davy Jones") }

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
            return s("Ye be a true Captain! The sea bows to ye!",
                     "진정한 선장이시다! 바다가 무릎 꿇는구나!",
                     "真の船長よ！海がひれ伏す！",
                     "真正的船长！大海向你臣服！",
                     "¡Eres un verdadero Capitán! ¡El mar se inclina ante ti!",
                     "Tu es un vrai Capitaine ! La mer s'incline devant toi !",
                     "Du bist ein wahrer Kapitän! Das Meer verneigt sich vor dir!")
        case .firstMate:
            return s("The sea be callin', mate... better start shippin'!",
                     "바다가 부르고 있다... 커밋을 시작하라!",
                     "海が呼んでいる… コミットを始めろ！",
                     "大海在呼唤… 开始提交吧！",
                     "El mar te llama... ¡empieza a commitear!",
                     "La mer t'appelle… commence à commiter !",
                     "Das Meer ruft... fang an zu committen!")
        case .deckhand:
            return s("Ship's takin' water! Commit or walk the plank!",
                     "배에 물이 찬다! 커밋하지 않으면 널빤지를 걸어라!",
                     "船に浸水中！コミットしないと海に落ちるぞ！",
                     "船在进水！不提交就走跳板！",
                     "¡El barco se hunde! ¡Commitea o camina por la plancha!",
                     "Le navire prend l'eau ! Commite ou marche sur la planche !",
                     "Das Schiff nimmt Wasser! Committe oder geh über die Planke!")
        case .castaway:
            return s("Abandon ship! Ye be drownin'!",
                     "배를 버려라! 익사 중이다!",
                     "総員退船！溺れている！",
                     "弃船！你在溺水！",
                     "¡Abandona el barco! ¡Te estás ahogando!",
                     "Abandonne le navire ! Tu te noies !",
                     "Schiff verlassen! Du ertrinkst!")
        case .davyJones:
            return s("To Davy Jones' Locker with ye! COMMIT NOW!",
                     "데비 존스의 사물함으로! 지금 당장 커밋하라!",
                     "デイヴィ・ジョーンズの海底へ！今すぐコミット！",
                     "去戴维·琼斯的储物柜吧！立即提交！",
                     "¡Al fondo del mar contigo! ¡COMMITEA AHORA!",
                     "Au fond des mers avec toi ! COMMITE MAINTENANT !",
                     "Ab in Davy Jones' Spind! JETZT COMMITTEN!")
        }
    }

    // MARK: Ship Types
    static var shipFlagship: String { s("Flagship", "기함", "旗艦", "旗舰", "Buque Insignia", "Vaisseau Amiral", "Flaggschiff") }
    static var shipWarship: String { s("Warship", "전함", "軍艦", "战舰", "Buque de Guerra", "Navire de Guerre", "Kriegsschiff") }
    static var shipGalleon: String { s("Galleon", "갤리온", "ガレオン", "大帆船", "Galeón", "Galion", "Galeone") }
    static var shipSloop: String { s("Sloop", "소형범선", "スループ", "小帆船", "Balandra", "Sloop", "Schaluppe") }
    static var shipDinghy: String { s("Dinghy", "뗏목", "小舟", "小舢板", "Bote", "Canot", "Beiboot") }
    static var shipShipwreck: String { s("Shipwreck", "난파선", "難破船", "沉船", "Naufragio", "Épave", "Schiffswrack") }

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
        case .flagship:  return s("Leading the fleet!", "함대를 이끈다!", "艦隊を率いる！", "率领舰队！", "¡Liderando la flota!", "Mène la flotte !", "Führt die Flotte an!")
        case .warship:   return s("Battle-ready", "전투 준비 완료", "戦闘準備完了", "备战就绪", "Listo para la batalla", "Prêt au combat", "Kampfbereit")
        case .galleon:   return s("Sailing steady", "순항 중", "順調に航行中", "平稳航行", "Navegando estable", "Navigation stable", "Segelt stetig")
        case .sloop:     return s("Drifting...", "표류 중...", "漂流中…", "漂流中…", "A la deriva...", "À la dérive…", "Treibend…")
        case .dinghy:    return s("Barely afloat", "간신히 떠 있음", "かろうじて浮いている", "勉强漂浮", "Apenas a flote", "À peine à flot", "Kaum über Wasser")
        case .shipwreck: return s("Sunk to the depths", "심해에 가라앉음", "深海に沈没", "沉入深海", "Hundido en las profundidades", "Coulé dans les abysses", "In die Tiefe gesunken")
        }
    }

    // MARK: Fleet
    static var fleet: String { s("Fleet", "함대", "艦隊", "舰队", "Flota", "Flotte", "Flotte") }
    static var ships: String { s("Ships", "선박", "船", "船只", "Barcos", "Navires", "Schiffe") }
    static var noFleet: String { s("No fleet", "함대 없음", "艦隊なし", "无舰队", "Sin flota", "Pas de flotte", "Keine Flotte") }
    static func fleetStrength(_ sailing: Int, _ total: Int) -> String {
        s("\(sailing)/\(total) ships sailing",
          "\(sailing)/\(total) 척 항해 중",
          "\(sailing)/\(total) 隻航行中",
          "\(sailing)/\(total) 艘航行中",
          "\(sailing)/\(total) barcos navegando",
          "\(sailing)/\(total) navires en mer",
          "\(sailing)/\(total) Schiffe unterwegs")
    }

    // MARK: UI Labels
    static var water: String { s("water", "침수", "浸水", "进水", "agua", "eau", "Wasser") }
    static var pushes: String { s("pushes", "푸시", "プッシュ", "推送", "pushes", "pushes", "Pushes") }
    static var local: String { s("local", "로컬", "ローカル", "本地", "local", "local", "lokal") }
    static var scanning: String { s("Scanning for repos...", "저장소 검색 중...", "リポジトリ検索中…", "正在搜索仓库…", "Buscando repos...", "Recherche de repos…", "Suche nach Repos…") }
    static var showLess: String { s("Show Less", "접기", "閉じる", "收起", "Mostrar Menos", "Voir Moins", "Weniger") }
    static func showAll(_ count: Int) -> String {
        s("Show All (\(count))", "모두 보기 (\(count))", "すべて表示 (\(count))", "显示全部 (\(count))", "Mostrar Todo (\(count))", "Tout Afficher (\(count))", "Alle anzeigen (\(count))")
    }
    static var quit: String { s("Quit", "종료", "終了", "退出", "Salir", "Quitter", "Beenden") }
    static var addRepo: String { s("Add Repo", "저장소 추가", "リポジトリ追加", "添加仓库", "Añadir Repo", "Ajouter un Repo", "Repo hinzufügen") }
    static var selectRepos: String { s("Select yer repos, Captain!", "저장소를 선택하라, 선장!", "リポジトリを選べ、船長！", "选择你的仓库，船长！", "¡Selecciona tus repos, Capitán!", "Sélectionne tes repos, Capitaine !", "Wähle deine Repos, Kapitän!") }
    static var language: String { s("Language", "언어", "言語", "语言", "Idioma", "Langue", "Sprache") }
    static var settings: String { s("Settings", "설정", "設定", "设置", "Ajustes", "Paramètres", "Einstellungen") }

    // MARK: Time
    static var justNow: String { s("Just now", "방금", "たった今", "刚刚", "Ahora", "À l'instant", "Gerade eben") }
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
                  "⚓ 일등항해사로 강등!",
                  "⚓ 副長に降格！",
                  "⚓ 降级为大副！",
                  "⚓ ¡Degradado a Primer Oficial!",
                  "⚓ Rétrogradé au Second !",
                  "⚓ Zum Ersten Maat degradiert!"),
                s("The sea be callin', mate... Get back to shippin'!",
                  "바다가 부른다... 다시 커밋을 시작하라!",
                  "海が呼んでいる… コミットを再開せよ！",
                  "大海在召唤… 回去提交吧！",
                  "El mar te llama... ¡Vuelve a commitear!",
                  "La mer t'appelle… Reprends les commits !",
                  "Das Meer ruft... Fang wieder an zu committen!")
            )
        case .deckhand:
            return (
                s("🪝 Demoted to Deckhand!",
                  "🪝 갑판원으로 강등!",
                  "🪝 甲板員に降格！",
                  "🪝 降级为水手！",
                  "🪝 ¡Degradado a Marinero!",
                  "🪝 Rétrogradé au Matelot !",
                  "🪝 Zum Matrosen degradiert!"),
                s("Ship's takin' water! Commit before ye walk the plank!",
                  "배에 물이 차고 있다! 널빤지를 걷기 전에 커밋하라!",
                  "船に浸水中！コミットしないと海に落ちるぞ！",
                  "船在进水！提交否则走跳板！",
                  "¡El barco se hunde! ¡Commitea antes de caminar por la plancha!",
                  "Le navire prend l'eau ! Commite avant la planche !",
                  "Das Schiff nimmt Wasser! Committe bevor du über die Planke gehst!")
            )
        case .castaway:
            return (
                s("🏊 Ye be a Castaway now!",
                  "🏊 표류자가 되었다!",
                  "🏊 漂流者になった！",
                  "🏊 你现在是落水者了！",
                  "🏊 ¡Ahora eres un Náufrago!",
                  "🏊 Tu es un Naufragé maintenant !",
                  "🏊 Du bist jetzt Schiffbrüchiger!"),
                s("ABANDON SHIP! Only a commit can save ye from Davy Jones!",
                  "배를 버려라! 커밋만이 데비 존스에서 살릴 수 있다!",
                  "総員退船！コミットだけが救いだ！",
                  "弃船！只有提交能救你！",
                  "¡ABANDONA EL BARCO! ¡Solo un commit puede salvarte!",
                  "ABANDONNE LE NAVIRE ! Seul un commit peut te sauver !",
                  "SCHIFF VERLASSEN! Nur ein Commit kann dich retten!")
            )
        case .davyJones:
            return (
                s("☠️ DAVY JONES CLAIMS YER SOUL!",
                  "☠️ 데비 존스가 영혼을 가져간다!",
                  "☠️ デイヴィ・ジョーンズが魂を奪う！",
                  "☠️ 戴维·琼斯夺取了你的灵魂！",
                  "☠️ ¡DAVY JONES RECLAMA TU ALMA!",
                  "☠️ DAVY JONES RÉCLAME TON ÂME !",
                  "☠️ DAVY JONES BEANSPRUCHT DEINE SEELE!"),
                s("Ye sleep with the fishes now. COMMIT to resurrect!",
                  "이제 물고기와 잠들었다. 커밋하여 부활하라!",
                  "魚と眠りについた。コミットして復活せよ！",
                  "你现在和鱼一起睡了。提交以复活！",
                  "Duermes con los peces. ¡COMMITEA para resucitar!",
                  "Tu dors avec les poissons. COMMITE pour ressusciter !",
                  "Du schläfst bei den Fischen. COMMITTE um aufzuerstehen!")
            )
        }
    }

    // MARK: Notifications - Rising
    static func notifRising(_ rank: PirateRank, from oldRank: PirateRank) -> (title: String, body: String) {
        if oldRank == .davyJones {
            return (
                s("🏴‍☠️ RESURRECTION!",
                  "🏴‍☠️ 부활!",
                  "🏴‍☠️ 復活！",
                  "🏴‍☠️ 复活！",
                  "🏴‍☠️ ¡RESURRECCIÓN!",
                  "🏴‍☠️ RÉSURRECTION !",
                  "🏴‍☠️ AUFERSTEHUNG!"),
                s("Ye cheated death! Back from Davy Jones' Locker! Keep shippin'!",
                  "죽음을 속였다! 데비 존스의 사물함에서 돌아왔다! 계속 커밋하라!",
                  "死を欺いた！デイヴィ・ジョーンズの海底から帰還！コミットを続けろ！",
                  "你骗过了死神！从深海归来！继续提交！",
                  "¡Engañaste a la muerte! ¡Vuelves del fondo! ¡Sigue commiteando!",
                  "Tu as trompé la mort ! Retour des abysses ! Continue à commiter !",
                  "Du hast den Tod überlistet! Zurück aus der Tiefe! Weiter committen!")
            )
        }
        switch rank {
        case .captain:
            return (
                s("🏴‍☠️ Promoted to Captain!",
                  "🏴‍☠️ 선장으로 승진!",
                  "🏴‍☠️ 船長に昇進！",
                  "🏴‍☠️ 晋升为船长！",
                  "🏴‍☠️ ¡Ascendido a Capitán!",
                  "🏴‍☠️ Promu Capitaine !",
                  "🏴‍☠️ Zum Kapitän befördert!"),
                s("The sea is yers! Keep up the legendary shipping pace!",
                  "바다가 그대의 것이다! 전설의 커밋 속도를 유지하라!",
                  "海はお前のものだ！伝説のペースを維持せよ！",
                  "大海是你的！保持传奇的提交速度！",
                  "¡El mar es tuyo! ¡Mantén el ritmo legendario!",
                  "La mer est à toi ! Maintiens le rythme légendaire !",
                  "Das Meer gehört dir! Halte das legendäre Tempo!")
            )
        case .firstMate:
            return (
                s("⚓ Promoted to First Mate!",
                  "⚓ 일등항해사로 승진!",
                  "⚓ 副長に昇進！",
                  "⚓ 晋升为大副！",
                  "⚓ ¡Ascendido a Primer Oficial!",
                  "⚓ Promu Second !",
                  "⚓ Zum Ersten Maat befördert!"),
                s("One more push and ye'll be Captain again!",
                  "한 번만 더 푸시하면 다시 선장이다!",
                  "もう一押しで船長に戻れる！",
                  "再推一把就能重回船长！",
                  "¡Un push más y serás Capitán de nuevo!",
                  "Encore un push et tu seras Capitaine !",
                  "Noch ein Push und du bist wieder Kapitän!")
            )
        case .deckhand:
            return (
                s("🪝 Promoted to Deckhand!",
                  "🪝 갑판원으로 승진!",
                  "🪝 甲板員に昇進！",
                  "🪝 晋升为水手！",
                  "🪝 ¡Ascendido a Marinero!",
                  "🪝 Promu Matelot !",
                  "🪝 Zum Matrosen befördert!"),
                s("Water's recedin'. Keep committin'!",
                  "물이 빠지고 있다. 계속 커밋하라!",
                  "水が引いている。コミットを続けろ！",
                  "水在退去。继续提交！",
                  "El agua baja. ¡Sigue commiteando!",
                  "L'eau baisse. Continue à commiter !",
                  "Das Wasser sinkt. Weiter committen!")
            )
        case .castaway:
            return (
                s("🏊 Still Castaway, but improving!",
                  "🏊 아직 표류자지만 개선 중!",
                  "🏊 まだ漂流者だが改善中！",
                  "🏊 仍是落水者，但在改善！",
                  "🏊 ¡Aún Náufrago, pero mejorando!",
                  "🏊 Encore Naufragé, mais ça s'améliore !",
                  "🏊 Noch Schiffbrüchiger, aber es wird besser!"),
                s("Ye found driftwood! Keep committin' to get back aboard!",
                  "표류목을 찾았다! 계속 커밋하여 다시 배에 타라!",
                  "流木を見つけた！コミットして船に戻れ！",
                  "你找到了浮木！继续提交回到船上！",
                  "¡Encontraste madera! ¡Sigue commiteando para volver a bordo!",
                  "Tu as trouvé du bois ! Continue à commiter pour remonter à bord !",
                  "Du hast Treibholz gefunden! Weiter committen um wieder an Bord zu kommen!")
            )
        case .davyJones:
            return ("", "")
        }
    }

    // MARK: Death Screen
    static var davyJonersLocker: String { s("DAVY JONES' LOCKER", "데비 존스의 사물함", "デイヴィ・ジョーンズの海底", "戴维·琼斯的储物柜", "EL FONDO DE DAVY JONES", "LE CASIER DE DAVY JONES", "DAVY JONES' SPIND") }
    static var commitToResurrect: String { s("Commit to Resurrect", "커밋하여 부활", "コミットして復活", "提交以复活", "Commitea para Resucitar", "Commite pour Ressusciter", "Committe zum Auferstehen") }

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
