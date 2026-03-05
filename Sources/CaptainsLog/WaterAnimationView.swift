import SwiftUI

// MARK: - Helpers

private func wavePath(
    in size: CGSize, time: Double,
    speed: Double, amplitude: CGFloat, frequency: CGFloat, level: CGFloat
) -> Path {
    let waterY = size.height * (1 - level)
    var path = Path()
    path.move(to: CGPoint(x: 0, y: waterY))
    let offset = CGFloat(time * speed)
    for x in stride(from: CGFloat(0), through: size.width, by: 2) {
        let relX = x / size.width
        let w1 = sin((relX * frequency + offset) * .pi * 2) * amplitude
        let w2 = sin((relX * frequency * 1.8 + offset * 1.4) * .pi * 2) * amplitude * 0.35
        let w3 = sin((relX * frequency * 3.2 + offset * 0.6) * .pi * 2) * amplitude * 0.12
        path.addLine(to: CGPoint(x: x, y: waterY + w1 + w2 + w3))
    }
    path.addLine(to: CGPoint(x: size.width, y: size.height))
    path.addLine(to: CGPoint(x: 0, y: size.height))
    path.closeSubpath()
    return path
}

private func hash(_ seed: Double) -> Double {
    let x = sin(seed * 127.1 + 311.7) * 43758.5453
    return x - x.rounded(.down)
}

// Ship wood colors
private let woodDark = Color(red: 0.38, green: 0.22, blue: 0.10)
private let woodMid = Color(red: 0.52, green: 0.34, blue: 0.18)
private let woodLight = Color(red: 0.65, green: 0.45, blue: 0.25)
private let woodHighlight = Color(red: 0.75, green: 0.55, blue: 0.30)
private let goldTrim = Color(red: 0.85, green: 0.68, blue: 0.25)
private let sailCream = Color(red: 0.95, green: 0.91, blue: 0.82)
private let sailWorn = Color(red: 0.78, green: 0.72, blue: 0.60)
private let coatRed = Color(red: 0.60, green: 0.12, blue: 0.10)
private let coatDarkRed = Color(red: 0.42, green: 0.08, blue: 0.06)
private let skinTone = Color(red: 0.88, green: 0.72, blue: 0.56)

// MARK: - Main Animation View

struct WaterAnimationView: View {
    let waterLevel: Double
    let rank: PirateRank
    var navigatorEnabled: Bool = false
    var totalDirtyFiles: Int = 0
    var totalUnpushedCommits: Int = 0

    private var level: CGFloat { 0.12 + min(CGFloat(waterLevel) / 100.0, 1.0) * 0.78 }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                sceneCanvas(time: t)

                if waterLevel >= 100 {
                    Color.black.opacity(0.55)
                        .allowsHitTesting(false)
                    VStack(spacing: 4) {
                        Text(L10n.davyJonersLocker)
                            .font(.system(size: 10, weight: .heavy))
                            .tracking(3)
                        Text(L10n.commitToResurrect)
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(1)
                    }
                    .foregroundColor(.white.opacity(0.8))
                }

                if waterLevel > 85 {
                    let flash = sin(t * 4.3) * sin(t * 7.1)
                    Color.white
                        .opacity(flash > 0.92 ? 0.3 : 0)
                        .allowsHitTesting(false)
                }

                if navigatorEnabled {
                    navigatorOverlay
                }
            }
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var navigatorOverlay: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                if totalDirtyFiles == 0 && totalUnpushedCommits == 0 {
                    Text("\u{1F3DD}\u{FE0F} \(L10n.allStashed)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.green)
                } else {
                    if totalDirtyFiles > 0 {
                        Text("\u{1F48E} \(totalDirtyFiles) \(L10n.dug)")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.orange)
                    }
                    if totalUnpushedCommits > 0 {
                        Text("\u{1F4E6} \(totalUnpushedCommits) \(L10n.stowed)")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.cyan)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [.black.opacity(0.45), .clear],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }
        .allowsHitTesting(false)
    }

    // MARK: - Scene Canvas

    private func sceneCanvas(time: Double) -> some View {
        Canvas { ctx, size in
            drawSky(ctx: &ctx, size: size)
            drawCelestial(ctx: &ctx, size: size, time: time)
            drawClouds(ctx: &ctx, size: size, time: time)
            if waterLevel > 55 { drawStars(ctx: &ctx, size: size, time: time) }
            if waterLevel < 30 { drawSeagulls(ctx: &ctx, size: size, time: time) }

            drawWave(ctx: &ctx, size: size, time: time,
                     speed: 0.12, amp: 4, freq: 1.3, levelMod: 0.86, colors: deepWaterColors)
            if level > 0.3 { drawCaustics(ctx: &ctx, size: size, time: time) }

            drawGalleon(ctx: &ctx, size: size, time: time)

            drawWave(ctx: &ctx, size: size, time: time,
                     speed: 0.2, amp: 5, freq: 2.0, levelMod: 0.95, colors: midWaterColors)
            drawReflection(ctx: &ctx, size: size, time: time)
            if waterLevel > 65 { drawSharkFin(ctx: &ctx, size: size, time: time) }

            drawWave(ctx: &ctx, size: size, time: time,
                     speed: 0.32, amp: 3.5, freq: 2.8, levelMod: 1.0, colors: frontWaterColors)
            drawFoam(ctx: &ctx, size: size, time: time)
            if waterLevel > 55 { drawDebris(ctx: &ctx, size: size, time: time) }
            if waterLevel > 45 { drawBubbles(ctx: &ctx, size: size, time: time) }
            if waterLevel > 40 { drawRain(ctx: &ctx, size: size, time: time) }
            if waterLevel > 82 { drawDrowningHand(ctx: &ctx, size: size, time: time) }
        }
    }

    // MARK: - Galleon Ship

    private func drawGalleon(ctx: inout GraphicsContext, size: CGSize, time: Double) {
        let waterY = size.height * (1 - level * 0.93)
        let cx = size.width * 0.42

        let sinkAmount = max(0, waterLevel - 8) / 92.0 * 55
        let shipY = waterY + CGFloat(sinkAmount)

        let tiltAmp = 2.0 + min(waterLevel, 80) / 80.0 * 18.0
        let tiltSpeed = 0.7 + min(waterLevel, 80) / 80.0 * 1.0
        let tilt = sin(time * tiltSpeed) * tiltAmp
        let bobAmp: CGFloat = waterLevel > 60 ? 5 : 2.5
        let bob = CGFloat(sin(time * (waterLevel > 60 ? 2.2 : 1.0))) * bobAmp

        ctx.drawLayer { lctx in
            let t = CGAffineTransform.identity
                .translatedBy(x: cx, y: shipY + bob)
                .rotated(by: tilt * .pi / 180)
                .translatedBy(x: -cx, y: -(shipY + bob))
            lctx.concatenate(t)

            let sy = shipY + bob

            // === HULL ===
            if waterLevel < 75 {
                drawHull(ctx: &lctx, cx: cx, sy: sy, time: time)
            }

            // === MASTS & SAILS ===
            if waterLevel < 88 {
                drawMastsAndSails(ctx: &lctx, cx: cx, sy: sy, time: time)
            }

            // === PIRATE CAPTAIN ===
            drawCaptain(ctx: &lctx, cx: cx, sy: sy, time: time)
        }
    }

    // MARK: - Hull

    private func drawHull(ctx: inout GraphicsContext, cx: CGFloat, sy: CGFloat, time: Double) {
        let hw: CGFloat = 42   // half-width
        let hullH: CGFloat = 14
        let sternRise: CGFloat = 8
        let bowRise: CGFloat = 3

        // Main hull body (curved)
        var hull = Path()
        hull.move(to: CGPoint(x: cx - hw, y: sy - sternRise))          // stern top
        hull.addLine(to: CGPoint(x: cx - hw + 6, y: sy + hullH))       // stern bottom
        hull.addQuadCurve(
            to: CGPoint(x: cx + hw - 3, y: sy + hullH - 2),            // bow bottom
            control: CGPoint(x: cx, y: sy + hullH + 4))                // keel curve
        hull.addLine(to: CGPoint(x: cx + hw + 4, y: sy - bowRise))     // bow tip
        hull.addLine(to: CGPoint(x: cx + hw, y: sy))                   // bow deck
        hull.addLine(to: CGPoint(x: cx - hw + 2, y: sy))               // deck line
        hull.addLine(to: CGPoint(x: cx - hw, y: sy - sternRise))       // back to stern
        hull.closeSubpath()
        ctx.fill(hull, with: .color(woodMid))

        // Hull planking stripes
        for i in 1..<4 {
            let py = sy + CGFloat(i) * 3.5
            var plank = Path()
            plank.move(to: CGPoint(x: cx - hw + 5 + CGFloat(i), y: py))
            plank.addLine(to: CGPoint(x: cx + hw - CGFloat(i), y: py - 1))
            ctx.stroke(plank, with: .color(woodDark.opacity(0.4)), lineWidth: 0.5)
        }

        // Hull bottom (darker keel area)
        var keel = Path()
        keel.move(to: CGPoint(x: cx - hw + 6, y: sy + hullH))
        keel.addQuadCurve(
            to: CGPoint(x: cx + hw - 3, y: sy + hullH - 2),
            control: CGPoint(x: cx, y: sy + hullH + 4))
        keel.addLine(to: CGPoint(x: cx + hw - 5, y: sy + hullH - 5))
        keel.addQuadCurve(
            to: CGPoint(x: cx - hw + 8, y: sy + hullH - 3),
            control: CGPoint(x: cx, y: sy + hullH + 1))
        keel.closeSubpath()
        ctx.fill(keel, with: .color(woodDark.opacity(0.6)))

        // Deck
        var deck = Path()
        deck.move(to: CGPoint(x: cx - hw + 2, y: sy))
        deck.addLine(to: CGPoint(x: cx + hw, y: sy))
        ctx.stroke(deck, with: .color(woodHighlight), lineWidth: 1.5)

        // Stern castle (raised back)
        var stern = Path()
        stern.move(to: CGPoint(x: cx - hw, y: sy - sternRise))
        stern.addLine(to: CGPoint(x: cx - hw + 2, y: sy))
        stern.addLine(to: CGPoint(x: cx - hw + 18, y: sy))
        stern.addLine(to: CGPoint(x: cx - hw + 16, y: sy - sternRise + 2))
        stern.closeSubpath()
        ctx.fill(stern, with: .color(woodLight))
        ctx.stroke(stern, with: .color(woodDark.opacity(0.4)), lineWidth: 0.5)

        // Stern windows (captain's quarters)
        for i in 0..<2 {
            let wx = cx - hw + 5 + CGFloat(i) * 7
            let wy = sy - sternRise + 4
            let window = Path(CGRect(x: wx, y: wy, width: 4, height: 3))
            ctx.fill(window, with: .color(Color(red: 0.9, green: 0.8, blue: 0.4).opacity(0.5)))
            ctx.stroke(window, with: .color(goldTrim.opacity(0.6)), lineWidth: 0.5)
        }

        // Bowsprit (diagonal pole at front)
        var bowsprit = Path()
        bowsprit.move(to: CGPoint(x: cx + hw, y: sy - 1))
        bowsprit.addLine(to: CGPoint(x: cx + hw + 18, y: sy - 10))
        ctx.stroke(bowsprit, with: .color(woodLight), lineWidth: 2)

        // Bow ornament (golden figurehead)
        let fhX = cx + hw + 16
        let fhY = sy - 9
        var figurehead = Path()
        figurehead.addEllipse(in: CGRect(x: fhX - 2, y: fhY - 2, width: 4, height: 4))
        ctx.fill(figurehead, with: .color(goldTrim.opacity(0.8)))

        // Gold trim along hull top
        var trim = Path()
        trim.move(to: CGPoint(x: cx - hw + 16, y: sy - sternRise + 2))
        trim.addLine(to: CGPoint(x: cx + hw + 4, y: sy - bowRise))
        ctx.stroke(trim, with: .color(goldTrim.opacity(0.4)), lineWidth: 0.8)

        // Cannon ports
        for i in 0..<4 {
            let px = cx - 15 + CGFloat(i) * 12
            let port = Path(CGRect(x: px - 2, y: sy + 5, width: 4, height: 3))
            ctx.fill(port, with: .color(woodDark))
            // Cannon barrel
            var barrel = Path()
            barrel.move(to: CGPoint(x: px, y: sy + 6.5))
            barrel.addLine(to: CGPoint(x: px + 3, y: sy + 6.5))
            ctx.stroke(barrel, with: .color(Color(white: 0.25)), lineWidth: 1)
        }

        // Railing posts
        for i in 0..<6 {
            let rx = cx - 30 + CGFloat(i) * 12
            var post = Path()
            post.move(to: CGPoint(x: rx, y: sy))
            post.addLine(to: CGPoint(x: rx, y: sy - 3))
            ctx.stroke(post, with: .color(woodLight.opacity(0.6)), lineWidth: 0.8)
        }
    }

    // MARK: - Masts & Sails

    private func drawMastsAndSails(ctx: inout GraphicsContext, cx: CGFloat, sy: CGFloat, time: Double) {
        let mainMastX = cx - 2
        let foreMastX = cx + 20
        let mainMastH: CGFloat = waterLevel < 55 ? 60 : max(25, 60 - CGFloat(waterLevel - 55) * 0.8)
        let foreMastH: CGFloat = waterLevel < 55 ? 45 : max(18, 45 - CGFloat(waterLevel - 55) * 0.6)
        let sailWind = CGFloat(sin(time * 0.5)) * 4

        // Main mast
        let mainTop = sy - mainMastH
        var mainMast = Path()
        mainMast.move(to: CGPoint(x: mainMastX, y: sy - 2))
        mainMast.addLine(to: CGPoint(x: mainMastX, y: mainTop))
        ctx.stroke(mainMast, with: .color(woodMid), lineWidth: 2.5)

        // Fore mast
        let foreTop = sy - foreMastH
        var foreMast = Path()
        foreMast.move(to: CGPoint(x: foreMastX, y: sy - 2))
        foreMast.addLine(to: CGPoint(x: foreMastX, y: foreTop))
        ctx.stroke(foreMast, with: .color(woodMid), lineWidth: 2)

        // Crow's nest on main mast
        if waterLevel < 60 {
            let nestY = mainTop + 6
            var nest = Path()
            nest.move(to: CGPoint(x: mainMastX - 6, y: nestY))
            nest.addLine(to: CGPoint(x: mainMastX - 5, y: nestY + 5))
            nest.addLine(to: CGPoint(x: mainMastX + 5, y: nestY + 5))
            nest.addLine(to: CGPoint(x: mainMastX + 6, y: nestY))
            nest.closeSubpath()
            ctx.fill(nest, with: .color(woodLight.opacity(0.8)))
            ctx.stroke(nest, with: .color(woodDark.opacity(0.5)), lineWidth: 0.5)
        }

        // === SAILS ===
        if waterLevel < 60 {
            // Main sail (large square)
            let ms1Top = mainTop + 10
            let ms1Bot = sy - 12
            drawSquareSail(ctx: &ctx, mastX: mainMastX, top: ms1Top, bottom: ms1Bot,
                          width: 30, wind: sailWind, worn: waterLevel > 35)

            // Fore sail
            let fs1Top = foreTop + 6
            let fs1Bot = sy - 14
            drawSquareSail(ctx: &ctx, mastX: foreMastX, top: fs1Top, bottom: fs1Bot,
                          width: 22, wind: sailWind * 0.8, worn: waterLevel > 35)

            // Jib sail (triangle from bowsprit to fore mast)
            if waterLevel < 40 {
                let bowTipX = cx + 42 + 18
                let bowTipY = sy - 10
                var jib = Path()
                jib.move(to: CGPoint(x: bowTipX - 2, y: bowTipY + 1))
                jib.addQuadCurve(
                    to: CGPoint(x: foreMastX + 1, y: sy - 6),
                    control: CGPoint(x: (bowTipX + foreMastX) / 2 + sailWind * 0.5, y: bowTipY + 15 + sailWind))
                jib.addLine(to: CGPoint(x: foreMastX + 1, y: foreTop + 4))
                jib.closeSubpath()
                ctx.fill(jib, with: .color(sailCream.opacity(0.7)))
            }

            // Rigging lines
            drawRigging(ctx: &ctx, cx: cx, sy: sy, mainTop: mainTop, foreTop: foreTop,
                       mainMastX: mainMastX, foreMastX: foreMastX)
        }

        // === JOLLY ROGER ===
        drawJollyRoger(ctx: &ctx, mastX: mainMastX, mastTop: mainTop, time: time)
    }

    private func drawSquareSail(
        ctx: inout GraphicsContext, mastX: CGFloat,
        top: CGFloat, bottom: CGFloat, width: CGFloat,
        wind: CGFloat, worn: Bool
    ) {
        let halfW = width / 2

        // Yard arms (horizontal poles)
        var topYard = Path()
        topYard.move(to: CGPoint(x: mastX - halfW - 2, y: top))
        topYard.addLine(to: CGPoint(x: mastX + halfW + 2, y: top))
        ctx.stroke(topYard, with: .color(woodMid), lineWidth: 1.5)

        var botYard = Path()
        botYard.move(to: CGPoint(x: mastX - halfW, y: bottom))
        botYard.addLine(to: CGPoint(x: mastX + halfW, y: bottom))
        ctx.stroke(botYard, with: .color(woodMid.opacity(0.8)), lineWidth: 1)

        // Sail cloth
        let billow = wind * 0.8
        var sail = Path()
        sail.move(to: CGPoint(x: mastX - halfW, y: top + 1))
        sail.addLine(to: CGPoint(x: mastX + halfW, y: top + 1))
        sail.addQuadCurve(
            to: CGPoint(x: mastX + halfW - 1, y: bottom - 1),
            control: CGPoint(x: mastX + halfW + billow, y: (top + bottom) / 2))
        sail.addLine(to: CGPoint(x: mastX - halfW + 1, y: bottom - 1))
        sail.addQuadCurve(
            to: CGPoint(x: mastX - halfW, y: top + 1),
            control: CGPoint(x: mastX - halfW + billow * 0.3, y: (top + bottom) / 2))
        sail.closeSubpath()

        let color = worn ? sailWorn : sailCream
        ctx.fill(sail, with: .color(color.opacity(0.85)))

        // Sail folds (horizontal lines)
        let sections = 3
        for i in 1..<sections {
            let t = CGFloat(i) / CGFloat(sections)
            let lineY = top + t * (bottom - top)
            let bulgeFactor = sin(t * .pi) * billow * 0.5
            var fold = Path()
            fold.move(to: CGPoint(x: mastX - halfW + 2, y: lineY))
            fold.addLine(to: CGPoint(x: mastX + halfW - 2 + bulgeFactor, y: lineY))
            ctx.stroke(fold, with: .color(color.opacity(0.25)), lineWidth: 0.5)
        }

        // Skull & crossbones on main sail
        if width > 25 && !worn {
            let skullX = mastX + billow * 0.3
            let skullY = (top + bottom) / 2 - 2
            // Skull
            let skull = Path(ellipseIn: CGRect(x: skullX - 4, y: skullY - 4, width: 8, height: 7))
            ctx.fill(skull, with: .color(.black.opacity(0.18)))
            // Eyes
            let eye1 = Path(ellipseIn: CGRect(x: skullX - 3, y: skullY - 2, width: 2, height: 2))
            let eye2 = Path(ellipseIn: CGRect(x: skullX + 1, y: skullY - 2, width: 2, height: 2))
            ctx.fill(eye1, with: .color(color.opacity(0.4)))
            ctx.fill(eye2, with: .color(color.opacity(0.4)))
            // Crossbones
            var bones = Path()
            bones.move(to: CGPoint(x: skullX - 5, y: skullY + 4))
            bones.addLine(to: CGPoint(x: skullX + 5, y: skullY + 10))
            bones.move(to: CGPoint(x: skullX + 5, y: skullY + 4))
            bones.addLine(to: CGPoint(x: skullX - 5, y: skullY + 10))
            ctx.stroke(bones, with: .color(.black.opacity(0.12)), lineWidth: 1.5)
        }
    }

    private func drawRigging(
        ctx: inout GraphicsContext, cx: CGFloat, sy: CGFloat,
        mainTop: CGFloat, foreTop: CGFloat,
        mainMastX: CGFloat, foreMastX: CGFloat
    ) {
        let hw: CGFloat = 42
        let rigColor = Color(white: 0.2).opacity(0.25)

        // Shrouds (angled lines from mast tops to hull sides)
        let rigLines: [(from: CGPoint, to: CGPoint)] = [
            (CGPoint(x: mainMastX, y: mainTop + 8), CGPoint(x: cx - hw + 5, y: sy)),
            (CGPoint(x: mainMastX, y: mainTop + 8), CGPoint(x: cx + 10, y: sy)),
            (CGPoint(x: foreMastX, y: foreTop + 5), CGPoint(x: cx + 10, y: sy)),
            (CGPoint(x: foreMastX, y: foreTop + 5), CGPoint(x: cx + hw - 2, y: sy)),
            // Stay between masts
            (CGPoint(x: mainMastX, y: mainTop + 12), CGPoint(x: foreMastX, y: foreTop + 8)),
        ]

        for line in rigLines {
            var rig = Path()
            rig.move(to: line.from)
            rig.addLine(to: line.to)
            ctx.stroke(rig, with: .color(rigColor), lineWidth: 0.5)
        }
    }

    // MARK: - Jolly Roger Flag

    private func drawJollyRoger(ctx: inout GraphicsContext, mastX: CGFloat, mastTop: CGFloat, time: Double) {
        let wave1 = CGFloat(sin(time * 3.5)) * 2.5
        let wave2 = CGFloat(sin(time * 4.2 + 1)) * 1.5
        let flagW: CGFloat = 18
        let flagH: CGFloat = 12
        let fx = mastX
        let fy = mastTop - 1

        // Flag cloth (waving shape)
        var flag = Path()
        flag.move(to: CGPoint(x: fx, y: fy))
        flag.addQuadCurve(
            to: CGPoint(x: fx + flagW, y: fy + 1 + wave1),
            control: CGPoint(x: fx + flagW * 0.5, y: fy - 2 + wave2))
        flag.addQuadCurve(
            to: CGPoint(x: fx, y: fy + flagH),
            control: CGPoint(x: fx + flagW * 0.5, y: fy + flagH + 2 + wave1))
        flag.closeSubpath()
        ctx.fill(flag, with: .color(.black.opacity(0.9)))

        // Skull on flag
        let skX = fx + 7 + wave1 * 0.2
        let skY = fy + 3 + wave2 * 0.2
        let skull = Path(ellipseIn: CGRect(x: skX - 2.5, y: skY - 1.5, width: 5, height: 4))
        ctx.fill(skull, with: .color(.white.opacity(0.85)))
        // Eye sockets
        let e1 = Path(ellipseIn: CGRect(x: skX - 1.5, y: skY - 0.5, width: 1.2, height: 1.2))
        let e2 = Path(ellipseIn: CGRect(x: skX + 0.5, y: skY - 0.5, width: 1.2, height: 1.2))
        ctx.fill(e1, with: .color(.black.opacity(0.8)))
        ctx.fill(e2, with: .color(.black.opacity(0.8)))
        // Crossed bones under skull
        var xbones = Path()
        xbones.move(to: CGPoint(x: skX - 3, y: skY + 2.5))
        xbones.addLine(to: CGPoint(x: skX + 3, y: skY + 5.5))
        xbones.move(to: CGPoint(x: skX + 3, y: skY + 2.5))
        xbones.addLine(to: CGPoint(x: skX - 3, y: skY + 5.5))
        ctx.stroke(xbones, with: .color(.white.opacity(0.75)), lineWidth: 1)
    }

    // MARK: - Pirate Captain

    private func drawCaptain(ctx: inout GraphicsContext, cx: CGFloat, sy: CGFloat, time: Double) {
        let pirateX = cx - 14

        if waterLevel < 75 {
            let baseY = sy - 2

            // === BODY (long coat) ===
            var coat = Path()
            coat.move(to: CGPoint(x: pirateX - 4, y: baseY - 14))   // shoulders
            coat.addLine(to: CGPoint(x: pirateX - 5.5, y: baseY + 1)) // coat bottom left
            coat.addLine(to: CGPoint(x: pirateX + 5.5, y: baseY + 1)) // coat bottom right
            coat.addLine(to: CGPoint(x: pirateX + 4, y: baseY - 14))  // shoulders
            coat.closeSubpath()
            ctx.fill(coat, with: .color(coatRed))

            // Coat details - buttons/trim
            var trim = Path()
            trim.move(to: CGPoint(x: pirateX, y: baseY - 12))
            trim.addLine(to: CGPoint(x: pirateX, y: baseY))
            ctx.stroke(trim, with: .color(goldTrim.opacity(0.5)), lineWidth: 0.8)

            // Belt
            var belt = Path()
            belt.move(to: CGPoint(x: pirateX - 5, y: baseY - 5))
            belt.addLine(to: CGPoint(x: pirateX + 5, y: baseY - 5))
            ctx.stroke(belt, with: .color(woodDark), lineWidth: 1.5)
            // Belt buckle
            let buckle = Path(CGRect(x: pirateX - 1.5, y: baseY - 6.5, width: 3, height: 3))
            ctx.fill(buckle, with: .color(goldTrim.opacity(0.7)))

            // === LEGS (boots) ===
            var leg1 = Path()
            leg1.move(to: CGPoint(x: pirateX - 2.5, y: baseY + 1))
            leg1.addLine(to: CGPoint(x: pirateX - 3, y: baseY + 5))
            leg1.addLine(to: CGPoint(x: pirateX - 5, y: baseY + 5))  // boot toe
            var leg2 = Path()
            leg2.move(to: CGPoint(x: pirateX + 2.5, y: baseY + 1))
            leg2.addLine(to: CGPoint(x: pirateX + 3, y: baseY + 5))
            leg2.addLine(to: CGPoint(x: pirateX + 5, y: baseY + 5))
            ctx.stroke(leg1, with: .color(woodDark), lineWidth: 2)
            ctx.stroke(leg2, with: .color(woodDark), lineWidth: 2)

            // === HEAD ===
            let head = Path(ellipseIn: CGRect(x: pirateX - 4, y: baseY - 22, width: 8, height: 8))
            ctx.fill(head, with: .color(skinTone))

            // Beard
            var beard = Path()
            beard.move(to: CGPoint(x: pirateX - 3, y: baseY - 16))
            beard.addQuadCurve(
                to: CGPoint(x: pirateX + 3, y: baseY - 16),
                control: CGPoint(x: pirateX, y: baseY - 12))
            ctx.fill(beard, with: .color(woodDark.opacity(0.6)))

            // Eye patch or eyes
            let eye = Path(ellipseIn: CGRect(x: pirateX + 0.5, y: baseY - 19.5, width: 2, height: 1.5))
            ctx.fill(eye, with: .color(.black.opacity(0.8)))
            // Eyepatch
            var patch = Path()
            patch.addEllipse(in: CGRect(x: pirateX - 3, y: baseY - 20, width: 3, height: 2.5))
            ctx.fill(patch, with: .color(.black.opacity(0.7)))
            var patchStrap = Path()
            patchStrap.move(to: CGPoint(x: pirateX - 1.5, y: baseY - 20))
            patchStrap.addLine(to: CGPoint(x: pirateX + 3, y: baseY - 22))
            ctx.stroke(patchStrap, with: .color(.black.opacity(0.4)), lineWidth: 0.5)

            // === TRICORN HAT ===
            // Hat body
            var hat = Path()
            hat.move(to: CGPoint(x: pirateX - 7, y: baseY - 21))
            hat.addLine(to: CGPoint(x: pirateX - 2, y: baseY - 29))
            hat.addLine(to: CGPoint(x: pirateX + 3, y: baseY - 28))
            hat.addLine(to: CGPoint(x: pirateX + 7, y: baseY - 21))
            hat.closeSubpath()
            ctx.fill(hat, with: .color(Color(red: 0.10, green: 0.08, blue: 0.06)))

            // Hat brim (wide)
            var brim = Path()
            brim.move(to: CGPoint(x: pirateX - 8, y: baseY - 21))
            brim.addQuadCurve(
                to: CGPoint(x: pirateX + 8, y: baseY - 21),
                control: CGPoint(x: pirateX, y: baseY - 19.5))
            ctx.stroke(brim, with: .color(Color(red: 0.10, green: 0.08, blue: 0.06)), lineWidth: 2)

            // Hat skull emblem
            let emblem = Path(ellipseIn: CGRect(x: pirateX - 1.5, y: baseY - 26, width: 3, height: 2.5))
            ctx.fill(emblem, with: .color(goldTrim.opacity(0.6)))

            // === ARMS & WEAPONS ===
            if waterLevel < 20 {
                // Captain: sword raised triumphantly
                let sway = CGFloat(sin(time * 2)) * 3
                // Right arm with cutlass
                var arm = Path()
                arm.move(to: CGPoint(x: pirateX + 4, y: baseY - 12))
                arm.addLine(to: CGPoint(x: pirateX + 12, y: baseY - 20 + sway))
                ctx.stroke(arm, with: .color(coatDarkRed), lineWidth: 2)
                // Cutlass blade
                var blade = Path()
                blade.move(to: CGPoint(x: pirateX + 12, y: baseY - 20 + sway))
                blade.addQuadCurve(
                    to: CGPoint(x: pirateX + 18, y: baseY - 28 + sway),
                    control: CGPoint(x: pirateX + 16, y: baseY - 22 + sway))
                ctx.stroke(blade, with: .color(Color(white: 0.85)), lineWidth: 1.2)
                // Guard
                var guard_ = Path()
                guard_.move(to: CGPoint(x: pirateX + 10, y: baseY - 19 + sway))
                guard_.addLine(to: CGPoint(x: pirateX + 14, y: baseY - 21 + sway))
                ctx.stroke(guard_, with: .color(goldTrim), lineWidth: 1)

                // Left arm on hip
                var larm = Path()
                larm.move(to: CGPoint(x: pirateX - 4, y: baseY - 12))
                larm.addLine(to: CGPoint(x: pirateX - 8, y: baseY - 7))
                ctx.stroke(larm, with: .color(coatDarkRed), lineWidth: 2)

            } else if waterLevel < 50 {
                // First mate: sword at ready
                var arm = Path()
                arm.move(to: CGPoint(x: pirateX + 4, y: baseY - 12))
                arm.addLine(to: CGPoint(x: pirateX + 12, y: baseY - 14))
                ctx.stroke(arm, with: .color(coatDarkRed), lineWidth: 2)
                var blade = Path()
                blade.move(to: CGPoint(x: pirateX + 12, y: baseY - 14))
                blade.addLine(to: CGPoint(x: pirateX + 20, y: baseY - 16))
                ctx.stroke(blade, with: .color(Color(white: 0.8)), lineWidth: 1)

                var larm = Path()
                larm.move(to: CGPoint(x: pirateX - 4, y: baseY - 12))
                larm.addLine(to: CGPoint(x: pirateX - 9, y: baseY - 8))
                ctx.stroke(larm, with: .color(coatDarkRed), lineWidth: 2)

            } else {
                // Deckhand+: desperately gripping rigging
                let grip = CGFloat(sin(time * 4)) * 2
                var arm1 = Path()
                arm1.move(to: CGPoint(x: pirateX + 4, y: baseY - 12))
                arm1.addLine(to: CGPoint(x: cx - 2 + grip, y: baseY - 20))
                var arm2 = Path()
                arm2.move(to: CGPoint(x: pirateX - 4, y: baseY - 12))
                arm2.addLine(to: CGPoint(x: cx - 2 - grip, y: baseY - 18))
                ctx.stroke(arm1, with: .color(coatDarkRed), lineWidth: 2)
                ctx.stroke(arm2, with: .color(coatDarkRed), lineWidth: 2)
            }

        } else if waterLevel < 92 {
            // In the water — struggling
            let bobble = CGFloat(sin(time * 3)) * 4
            let baseY = sy + bobble

            // Head above water
            let head = Path(ellipseIn: CGRect(x: pirateX - 4, y: baseY - 10, width: 8, height: 8))
            ctx.fill(head, with: .color(skinTone))

            // Soaked hat (droopy)
            var hat = Path()
            hat.move(to: CGPoint(x: pirateX - 6, y: baseY - 9))
            hat.addLine(to: CGPoint(x: pirateX - 1, y: baseY - 16))
            hat.addLine(to: CGPoint(x: pirateX + 4, y: baseY - 14))
            hat.addLine(to: CGPoint(x: pirateX + 6, y: baseY - 9))
            hat.closeSubpath()
            ctx.fill(hat, with: .color(Color(red: 0.10, green: 0.08, blue: 0.06).opacity(0.7)))

            // Arms flailing
            let flail1 = CGFloat(sin(time * 5)) * 8
            let flail2 = CGFloat(sin(time * 5 + 2)) * 8
            var arm1 = Path()
            arm1.move(to: CGPoint(x: pirateX - 3, y: baseY - 5))
            arm1.addLine(to: CGPoint(x: pirateX - 12, y: baseY - 14 + flail1))
            var arm2 = Path()
            arm2.move(to: CGPoint(x: pirateX + 3, y: baseY - 5))
            arm2.addLine(to: CGPoint(x: pirateX + 12, y: baseY - 12 - flail2))
            ctx.stroke(arm1, with: .color(coatRed.opacity(0.8)), lineWidth: 2)
            ctx.stroke(arm2, with: .color(coatRed.opacity(0.8)), lineWidth: 2)

            // Hands
            for hx in [pirateX - 12, pirateX + 12] {
                let hy = hx < pirateX ? baseY - 14 + flail1 : baseY - 12 - flail2
                let hand = Path(ellipseIn: CGRect(x: hx - 1.5, y: hy - 1.5, width: 3, height: 3))
                ctx.fill(hand, with: .color(skinTone))
            }

            // Splash rings
            for i in 0..<5 {
                let sx = pirateX + CGFloat(i * 6 - 12)
                let splashY = baseY - 2 + CGFloat(sin(time * 6 + Double(i) * 1.3)) * 2
                let splash = Path(ellipseIn: CGRect(x: sx, y: splashY, width: 4, height: 2))
                ctx.fill(splash, with: .color(.white.opacity(0.35)))
            }
        }
    }

    // MARK: - Drowning Hand

    private func drawDrowningHand(ctx: inout GraphicsContext, size: CGSize, time: Double) {
        let waterY = size.height * (1 - level * 0.93)
        let handX = size.width * 0.35
        let sink = CGFloat(max(0, waterLevel - 82) / 18.0 * 12)
        let handY = waterY - 8 + sink + CGFloat(sin(time * 2.5)) * 3

        // Arm with coat sleeve
        var arm = Path()
        arm.move(to: CGPoint(x: handX, y: handY + 15))
        arm.addLine(to: CGPoint(x: handX, y: handY))
        ctx.stroke(arm, with: .color(coatRed.opacity(0.7)), lineWidth: 3)

        // Coat cuff
        var cuff = Path()
        cuff.move(to: CGPoint(x: handX - 3, y: handY + 1))
        cuff.addLine(to: CGPoint(x: handX + 3, y: handY + 1))
        ctx.stroke(cuff, with: .color(goldTrim.opacity(0.5)), lineWidth: 1.5)

        // Hand reaching up
        let armColor = waterLevel > 95 ? Color(white: 0.85) : skinTone
        let spread = CGFloat(sin(time * 1.5)) * 2.5
        for i in -2...2 {
            var finger = Path()
            finger.move(to: CGPoint(x: handX, y: handY))
            finger.addLine(to: CGPoint(x: handX + CGFloat(i) * (2.5 + spread), y: handY - 7))
            ctx.stroke(finger, with: .color(armColor), lineWidth: 1.2)
        }

        // Ripples
        for i in 0..<3 {
            let rippleR = 5 + CGFloat(i) * 5 + CGFloat(sin(time * 2 + Double(i))) * 2
            let ripple = Path(ellipseIn: CGRect(
                x: handX - rippleR, y: waterY - 2, width: rippleR * 2, height: 3))
            ctx.stroke(ripple, with: .color(.white.opacity(0.15 - Double(i) * 0.04)), lineWidth: 0.6)
        }

        // Floating hat nearby
        let hatX = handX + 20 + CGFloat(sin(time * 0.8)) * 8
        let hatBob = CGFloat(sin(time * 1.5 + 1)) * 2
        var floatHat = Path()
        floatHat.move(to: CGPoint(x: hatX - 6, y: waterY - 1 + hatBob))
        floatHat.addLine(to: CGPoint(x: hatX - 2, y: waterY - 7 + hatBob))
        floatHat.addLine(to: CGPoint(x: hatX + 3, y: waterY - 6 + hatBob))
        floatHat.addLine(to: CGPoint(x: hatX + 6, y: waterY - 1 + hatBob))
        floatHat.closeSubpath()
        ctx.fill(floatHat, with: .color(Color(red: 0.10, green: 0.08, blue: 0.06).opacity(0.7)))
    }

    // MARK: - Seagulls

    private func drawSeagulls(ctx: inout GraphicsContext, size: CGSize, time: Double) {
        let gulls: [(y: CGFloat, speed: Double, wingSpeed: Double)] = [
            (20, 12, 3.5), (14, 8, 4.2), (26, 15, 3.0),
        ]
        for (i, g) in gulls.enumerated() {
            let x = CGFloat((time * g.speed + Double(i) * 100)
                .truncatingRemainder(dividingBy: Double(size.width + 40))) - 20
            let wing = CGFloat(sin(time * g.wingSpeed + Double(i))) * 4
            var gull = Path()
            gull.move(to: CGPoint(x: x - 6, y: g.y + wing))
            gull.addQuadCurve(to: CGPoint(x: x, y: g.y), control: CGPoint(x: x - 3, y: g.y - 3))
            gull.addQuadCurve(to: CGPoint(x: x + 6, y: g.y + wing), control: CGPoint(x: x + 3, y: g.y - 3))
            ctx.stroke(gull, with: .color(.white.opacity(0.55)), lineWidth: 1)
        }
    }

    // MARK: - Rain

    private func drawRain(ctx: inout GraphicsContext, size: CGSize, time: Double) {
        let intensity = min(1.0, (waterLevel - 40) / 40.0)
        let count = Int(15 + intensity * 40)
        let wind: CGFloat = waterLevel > 70 ? 0.35 : 0.15
        for i in 0..<count {
            let s = Double(i)
            let bx = hash(s) * Double(size.width + 20)
            let sp = 80 + hash(s + 1) * 60
            let ph = hash(s + 2) * Double(size.height)
            let y = CGFloat((time * sp + ph).truncatingRemainder(dividingBy: Double(size.height)))
            let x = CGFloat(bx) + y * wind
            let len: CGFloat = 4 + CGFloat(hash(s + 3) * 6)
            var drop = Path()
            drop.move(to: CGPoint(x: x, y: y))
            drop.addLine(to: CGPoint(x: x + len * wind, y: y + len))
            ctx.stroke(drop, with: .color(.white.opacity(0.08 + intensity * 0.12)), lineWidth: 0.5)
        }
    }

    // MARK: - Shark Fin

    private func drawSharkFin(ctx: inout GraphicsContext, size: CGSize, time: Double) {
        let waterY = size.height * (1 - level * 0.96)
        let x = CGFloat((time * 18).truncatingRemainder(dividingBy: Double(size.width + 60))) - 30
        let bob = CGFloat(sin(time * 2.5)) * 2
        var fin = Path()
        fin.move(to: CGPoint(x: x, y: waterY + bob))
        fin.addLine(to: CGPoint(x: x + 3, y: waterY - 12 + bob))
        fin.addQuadCurve(to: CGPoint(x: x + 12, y: waterY + bob),
                         control: CGPoint(x: x + 10, y: waterY - 7 + bob))
        fin.closeSubpath()
        ctx.fill(fin, with: .color(Color(red: 0.30, green: 0.32, blue: 0.38)))
        for i in 1..<4 {
            let wX = x - CGFloat(i) * 7
            let wW = 3 + CGFloat(i) * 2
            let wake = Path(ellipseIn: CGRect(x: wX - wW / 2, y: waterY - 0.5 + bob, width: wW, height: 1.5))
            ctx.fill(wake, with: .color(.white.opacity(0.12 - Double(i) * 0.03)))
        }
    }

    // MARK: - Debris

    private func drawDebris(ctx: inout GraphicsContext, size: CGSize, time: Double) {
        let waterY = size.height * (1 - level * 0.97)
        let planks: [(seed: Double, speed: Double, len: CGFloat)] = [
            (1, 6, 16), (2, 9, 11), (3, 4, 13),
        ]
        for p in planks {
            let tw = Double(size.width + 40)
            let x = CGFloat((time * p.speed + hash(p.seed) * tw).truncatingRemainder(dividingBy: tw)) - 20
            let bob = CGFloat(sin(time * 1.5 + p.seed * 2)) * 2
            let rot = sin(time * 0.8 + p.seed) * 8
            ctx.drawLayer { lctx in
                lctx.concatenate(CGAffineTransform.identity
                    .translatedBy(x: x, y: waterY + bob)
                    .rotated(by: rot * .pi / 180)
                    .translatedBy(x: -x, y: -(waterY + bob)))
                let plank = Path(CGRect(x: x - p.len / 2, y: waterY - 1.5 + bob, width: p.len, height: 3))
                lctx.fill(plank, with: .color(woodMid.opacity(0.65)))
            }
        }
        if waterLevel > 70 {
            let bx = CGFloat((time * 5 + 150).truncatingRemainder(dividingBy: Double(size.width + 30))) - 15
            let bb = CGFloat(sin(time * 1.8 + 3)) * 2
            let barrel = Path(ellipseIn: CGRect(x: bx - 6, y: waterY - 5 + bb, width: 12, height: 10))
            ctx.fill(barrel, with: .color(woodMid.opacity(0.55)))
            var band = Path()
            band.move(to: CGPoint(x: bx - 5, y: waterY - 1 + bb))
            band.addLine(to: CGPoint(x: bx + 5, y: waterY - 1 + bb))
            ctx.stroke(band, with: .color(woodDark.opacity(0.45)), lineWidth: 0.8)
        }
    }

    // MARK: - Sky

    private func drawSky(ctx: inout GraphicsContext, size: CGSize) {
        ctx.fill(Path(CGRect(origin: .zero, size: size)),
                 with: .linearGradient(Gradient(colors: skyColors),
                                       startPoint: .zero,
                                       endPoint: CGPoint(x: 0, y: size.height)))
    }

    // MARK: - Celestial

    private func drawCelestial(ctx: inout GraphicsContext, size: CGSize, time: Double) {
        let x = size.width * 0.82
        let baseY: CGFloat = 22
        let bob = CGFloat(sin(time * 0.3)) * 2
        if waterLevel > 50 {
            let r: CGFloat = 10
            ctx.fill(Path(ellipseIn: CGRect(x: x - r * 3, y: baseY + bob - r * 3, width: r * 6, height: r * 6)),
                     with: .color(Color(white: 0.8).opacity(0.06)))
            ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: baseY + bob - r, width: r * 2, height: r * 2)),
                     with: .color(Color(white: 0.9).opacity(0.7)))
        } else {
            let r: CGFloat = 14
            ctx.fill(Path(ellipseIn: CGRect(x: x - r * 3, y: baseY + bob - r * 3, width: r * 6, height: r * 6)),
                     with: .color(Color(red: 1.0, green: 0.85, blue: 0.3).opacity(0.1)))
            ctx.fill(Path(ellipseIn: CGRect(x: x - r * 1.8, y: baseY + bob - r * 1.8, width: r * 3.6, height: r * 3.6)),
                     with: .color(Color(red: 1.0, green: 0.85, blue: 0.3).opacity(0.18)))
            ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: baseY + bob - r, width: r * 2, height: r * 2)),
                     with: .color(Color(red: 1.0, green: 0.92, blue: 0.55).opacity(0.95)))
        }
    }

    // MARK: - Clouds

    private func drawClouds(ctx: inout GraphicsContext, size: CGSize, time: Double) {
        let clouds: [(y: CGFloat, speed: Double, w: CGFloat, h: CGFloat)] = [
            (14, 8, 55, 16), (24, 5, 70, 18), (8, 11, 40, 12), (18, 7, 48, 14),
        ]
        let op = waterLevel > 70 ? 0.04 : (waterLevel > 50 ? 0.12 : 0.25)
        for (i, c) in clouds.enumerated() {
            let tw = size.width + c.w * 2
            let x = CGFloat((time * c.speed + Double(i) * 80).truncatingRemainder(dividingBy: Double(tw))) - c.w
            ctx.fill(Path(ellipseIn: CGRect(x: x, y: c.y, width: c.w, height: c.h)),
                     with: .color(.white.opacity(op)))
            ctx.fill(Path(ellipseIn: CGRect(x: x + 5, y: c.y + 2, width: c.w * 0.6, height: c.h * 0.5)),
                     with: .color(.white.opacity(op * 0.5)))
        }
    }

    // MARK: - Stars

    private func drawStars(ctx: inout GraphicsContext, size: CGSize, time: Double) {
        for i in 0..<15 {
            let sx = hash(Double(i)) * Double(size.width)
            let sy = hash(Double(i) + 0.5) * Double(size.height * 0.35)
            let tw = (sin(time * (2 + hash(Double(i) + 1) * 3) + Double(i)) + 1) / 2
            let r = 0.8 + hash(Double(i) + 2) * 0.8
            ctx.fill(Path(ellipseIn: CGRect(x: sx - r, y: sy - r, width: r * 2, height: r * 2)),
                     with: .color(.white.opacity(tw * 0.6)))
        }
    }

    // MARK: - Waves / Caustics / Reflection / Foam / Bubbles

    private func drawWave(ctx: inout GraphicsContext, size: CGSize, time: Double,
                          speed: Double, amp: CGFloat, freq: CGFloat, levelMod: CGFloat, colors: [Color]) {
        let adj = level * levelMod
        let path = wavePath(in: size, time: time, speed: speed, amplitude: amp, frequency: freq, level: adj)
        let wy = size.height * (1 - adj)
        ctx.fill(path, with: .linearGradient(Gradient(colors: colors),
                                             startPoint: CGPoint(x: 0, y: wy),
                                             endPoint: CGPoint(x: 0, y: size.height)))
    }

    private func drawCaustics(ctx: inout GraphicsContext, size: CGSize, time: Double) {
        let wy = size.height * (1 - level * 0.93)
        for i in 0..<5 {
            let bx = hash(Double(i) * 3) * Double(size.width)
            let sway = sin(time * 0.5 + Double(i) * 1.2) * 15
            let x = CGFloat(bx + sway)
            var ray = Path()
            ray.move(to: CGPoint(x: x - 3, y: wy + 8))
            ray.addLine(to: CGPoint(x: x + 5, y: size.height))
            ray.addLine(to: CGPoint(x: x - 8, y: size.height))
            ray.closeSubpath()
            ctx.fill(ray, with: .color(.white.opacity((sin(time * 0.8 + Double(i) * 2) + 1) / 2 * 0.06)))
        }
    }

    private func drawReflection(ctx: inout GraphicsContext, size: CGSize, time: Double) {
        let wy = size.height * (1 - level)
        let sx = size.width * 0.82
        for i in 0..<6 {
            let y = wy + CGFloat(i) * 6 + 3
            guard y < size.height else { continue }
            let w = 12 - CGFloat(i) * 1.5
            let x = sx + CGFloat(sin(time * 1.5 + Double(i) * 0.8) * 8)
            ctx.fill(Path(ellipseIn: CGRect(x: x - w / 2, y: y, width: w, height: 2)),
                     with: .color(.white.opacity(max(0, (waterLevel > 50 ? 0.05 : 0.15) - Double(i) * 0.02))))
        }
    }

    private func drawFoam(ctx: inout GraphicsContext, size: CGSize, time: Double) {
        let wy = size.height * (1 - level)
        for i in 0..<18 {
            let bx = hash(Double(i) * 7) * Double(size.width)
            let drift = time * (8 + hash(Double(i) + 10) * 12)
            let x = CGFloat((bx + drift).truncatingRemainder(dividingBy: Double(size.width)))
            let waveOff = sin((Double(x / size.width) * 2 + time * 0.2) * .pi * 2) * 5
            let y = wy + CGFloat(waveOff + hash(Double(i) + 5) * 4 - 2)
            let r = 1 + hash(Double(i) + 3) * 1.5
            let fl = (sin(time * 2 + Double(i) * 1.5) + 1) / 2
            ctx.fill(Path(ellipseIn: CGRect(x: x - CGFloat(r), y: y - CGFloat(r),
                                            width: CGFloat(r * 2), height: CGFloat(r * 2))),
                     with: .color(.white.opacity(0.2 + fl * 0.15)))
        }
    }

    private func drawBubbles(ctx: inout GraphicsContext, size: CGSize, time: Double) {
        let wy = size.height * (1 - level)
        for i in 0..<8 {
            let bx = size.width * 0.3 + CGFloat(hash(Double(i) * 5) * Double(size.width) * 0.4)
            let sp = 15 + hash(Double(i) + 2) * 20
            let cl = Double(size.height) / sp
            let prog = ((time + hash(Double(i) + 8) * cl).truncatingRemainder(dividingBy: cl)) / cl
            let y = wy + CGFloat(1 - prog) * (size.height - wy)
            guard y > wy else { continue }
            let sway = CGFloat(sin(time * 2 + Double(i) * 1.7)) * 4
            let x = bx + sway
            let r = 1.5 + hash(Double(i) + 1) * 2.5
            let fade = 0.15 + (1 - prog) * 0.25
            ctx.stroke(Path(ellipseIn: CGRect(x: x - CGFloat(r), y: y - CGFloat(r),
                                              width: CGFloat(r * 2), height: CGFloat(r * 2))),
                       with: .color(.white.opacity(fade)), lineWidth: 0.5)
            ctx.fill(Path(ellipseIn: CGRect(x: x - CGFloat(r * 0.4), y: y - CGFloat(r * 0.6),
                                            width: CGFloat(r * 0.5), height: CGFloat(r * 0.4))),
                     with: .color(.white.opacity(fade * 0.5)))
        }
    }

    // MARK: - Caribbean Color Palettes

    private var skyColors: [Color] {
        switch waterLevel {
        case ..<25:  return [Color(red: 0.30, green: 0.72, blue: 0.95),  // Caribbean blue
                             Color(red: 0.55, green: 0.85, blue: 0.95)]
        case ..<50:  return [Color(red: 0.95, green: 0.60, blue: 0.20),  // Golden sunset
                             Color(red: 0.98, green: 0.78, blue: 0.35)]
        case ..<75:  return [Color(red: 0.22, green: 0.08, blue: 0.18),  // Stormy night
                             Color(red: 0.40, green: 0.10, blue: 0.08)]
        default:     return [Color(red: 0.04, green: 0.02, blue: 0.08),  // Abyss
                             Color(red: 0.08, green: 0.02, blue: 0.05)]
        }
    }

    private var deepWaterColors: [Color] {
        switch waterLevel {
        case ..<25:  return [Color(red: 0.0, green: 0.35, blue: 0.50).opacity(0.4),   // Turquoise deep
                             Color(red: 0.0, green: 0.22, blue: 0.40)]
        case ..<50:  return [Color(red: 0.45, green: 0.28, blue: 0.06).opacity(0.4),
                             Color(red: 0.30, green: 0.16, blue: 0.04)]
        case ..<75:  return [Color(red: 0.38, green: 0.06, blue: 0.04).opacity(0.4),
                             Color(red: 0.22, green: 0.03, blue: 0.02)]
        default:     return [Color(red: 0.15, green: 0.0, blue: 0.0).opacity(0.5),
                             Color(red: 0.06, green: 0.0, blue: 0.0)]
        }
    }

    private var midWaterColors: [Color] {
        switch waterLevel {
        case ..<25:  return [Color(red: 0.0, green: 0.50, blue: 0.65).opacity(0.55),  // Teal mid
                             Color(red: 0.0, green: 0.32, blue: 0.52)]
        case ..<50:  return [Color(red: 0.65, green: 0.38, blue: 0.10).opacity(0.5),
                             Color(red: 0.45, green: 0.22, blue: 0.05)]
        case ..<75:  return [Color(red: 0.50, green: 0.08, blue: 0.05).opacity(0.5),
                             Color(red: 0.35, green: 0.04, blue: 0.02)]
        default:     return [Color(red: 0.25, green: 0.0, blue: 0.0).opacity(0.6),
                             Color(red: 0.10, green: 0.0, blue: 0.0)]
        }
    }

    private var frontWaterColors: [Color] {
        switch waterLevel {
        case ..<25:  return [Color(red: 0.0, green: 0.58, blue: 0.72).opacity(0.3),   // Turquoise front
                             Color(red: 0.0, green: 0.40, blue: 0.58).opacity(0.5)]
        case ..<50:  return [Color(red: 0.70, green: 0.42, blue: 0.12).opacity(0.3),
                             Color(red: 0.50, green: 0.28, blue: 0.06).opacity(0.5)]
        case ..<75:  return [Color(red: 0.55, green: 0.10, blue: 0.06).opacity(0.3),
                             Color(red: 0.40, green: 0.06, blue: 0.03).opacity(0.5)]
        default:     return [Color(red: 0.30, green: 0.02, blue: 0.0).opacity(0.3),
                             Color(red: 0.12, green: 0.0, blue: 0.0).opacity(0.5)]
        }
    }
}
