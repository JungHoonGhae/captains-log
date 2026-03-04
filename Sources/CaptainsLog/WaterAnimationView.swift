import SwiftUI

// MARK: - Wave Path Helper

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

// Deterministic pseudo-random from seed
private func hash(_ seed: Double) -> Double {
    let x = sin(seed * 127.1 + 311.7) * 43758.5453
    return x - x.rounded(.down)
}

// MARK: - Main Animation View

struct WaterAnimationView: View {
    let waterLevel: Double
    let rank: PirateRank

    private var level: CGFloat { min(CGFloat(waterLevel) / 100.0, 1.0) }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate

            ZStack {
                // All canvas layers
                sceneCanvas(time: t)

                // Character (SwiftUI overlay for emoji rendering)
                characterOverlay(time: t)

                // Death overlay
                if waterLevel >= 100 {
                    Color.black.opacity(0.5)
                        .allowsHitTesting(false)
                    Text("Commit to Resurrect")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .tracking(1)
                }

                // Lightning flash
                if waterLevel > 85 {
                    let flash = sin(t * 4.3) * sin(t * 7.1)
                    Color.white
                        .opacity(flash > 0.92 ? 0.25 : 0)
                        .allowsHitTesting(false)
                }
            }
        }
        .frame(height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Scene Canvas

    private func sceneCanvas(time: Double) -> some View {
        Canvas { ctx, size in
            // 1. Sky
            drawSky(ctx: &ctx, size: size)

            // 2. Celestial body (sun or moon)
            drawCelestial(ctx: &ctx, size: size, time: time)

            // 3. Clouds
            drawClouds(ctx: &ctx, size: size, time: time)

            // 4. Stars (danger mode)
            if waterLevel > 55 {
                drawStars(ctx: &ctx, size: size, time: time)
            }

            // 5. Back wave (slow, deep)
            drawWave(ctx: &ctx, size: size, time: time,
                     speed: 0.12, amp: 3, freq: 1.3, levelMod: 0.88,
                     colors: deepWaterColors)

            // 6. Underwater light rays
            if level > 0.3 {
                drawCaustics(ctx: &ctx, size: size, time: time)
            }

            // 7. Mid wave
            drawWave(ctx: &ctx, size: size, time: time,
                     speed: 0.2, amp: 5, freq: 2.0, levelMod: 0.95,
                     colors: midWaterColors)

            // 8. Water reflection (sun/moon shimmer)
            drawReflection(ctx: &ctx, size: size, time: time)

            // 9. Front wave (fast, translucent)
            drawWave(ctx: &ctx, size: size, time: time,
                     speed: 0.32, amp: 3.5, freq: 2.8, levelMod: 1.0,
                     colors: frontWaterColors)

            // 10. Foam
            drawFoam(ctx: &ctx, size: size, time: time)

            // 11. Bubbles
            if waterLevel > 45 {
                drawBubbles(ctx: &ctx, size: size, time: time)
            }
        }
    }

    // MARK: - Sky

    private func drawSky(ctx: inout GraphicsContext, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        ctx.fill(
            Path(rect),
            with: .linearGradient(
                Gradient(colors: skyColors),
                startPoint: .zero,
                endPoint: CGPoint(x: 0, y: size.height)
            )
        )
    }

    // MARK: - Celestial Body

    private func drawCelestial(ctx: inout GraphicsContext, size: CGSize, time: Double) {
        let x = size.width * 0.82
        let baseY: CGFloat = 20
        let bob = CGFloat(sin(time * 0.3)) * 2

        if waterLevel > 50 {
            // Moon
            let r: CGFloat = 9
            let glow = Path(ellipseIn: CGRect(x: x - r * 3, y: baseY + bob - r * 3, width: r * 6, height: r * 6))
            ctx.fill(glow, with: .color(Color(white: 0.8).opacity(0.06)))
            let moon = Path(ellipseIn: CGRect(x: x - r, y: baseY + bob - r, width: r * 2, height: r * 2))
            ctx.fill(moon, with: .color(Color(white: 0.9).opacity(0.7)))
        } else {
            // Sun
            let r: CGFloat = 12
            let glow = Path(ellipseIn: CGRect(x: x - r * 3, y: baseY + bob - r * 3, width: r * 6, height: r * 6))
            ctx.fill(glow, with: .color(Color.yellow.opacity(0.12)))
            let glow2 = Path(ellipseIn: CGRect(x: x - r * 1.8, y: baseY + bob - r * 1.8, width: r * 3.6, height: r * 3.6))
            ctx.fill(glow2, with: .color(Color.yellow.opacity(0.2)))
            let sun = Path(ellipseIn: CGRect(x: x - r, y: baseY + bob - r, width: r * 2, height: r * 2))
            ctx.fill(sun, with: .color(Color(red: 1.0, green: 0.92, blue: 0.6).opacity(0.95)))
        }
    }

    // MARK: - Clouds

    private func drawClouds(ctx: inout GraphicsContext, size: CGSize, time: Double) {
        let clouds: [(y: CGFloat, speed: Double, w: CGFloat, h: CGFloat)] = [
            (12, 8, 50, 14),
            (22, 5, 65, 16),
            (6, 11, 38, 10),
            (16, 7, 45, 12),
        ]

        let opacity = waterLevel > 70 ? 0.04 : (waterLevel > 50 ? 0.12 : 0.25)

        for (i, c) in clouds.enumerated() {
            let totalW = size.width + c.w * 2
            let x = CGFloat((time * c.speed + Double(i) * 80).truncatingRemainder(dividingBy: Double(totalW))) - c.w
            let path = Path(ellipseIn: CGRect(x: x, y: c.y, width: c.w, height: c.h))
            ctx.fill(path, with: .color(.white.opacity(opacity)))

            // Cloud highlight
            let highlight = Path(ellipseIn: CGRect(x: x + 5, y: c.y + 2, width: c.w * 0.6, height: c.h * 0.5))
            ctx.fill(highlight, with: .color(.white.opacity(opacity * 0.5)))
        }
    }

    // MARK: - Stars

    private func drawStars(ctx: inout GraphicsContext, size: CGSize, time: Double) {
        let count = 15
        for i in 0..<count {
            let sx = hash(Double(i)) * Double(size.width)
            let sy = hash(Double(i) + 0.5) * Double(size.height * 0.4)
            let twinkle = (sin(time * (2.0 + hash(Double(i) + 1.0) * 3.0) + Double(i)) + 1) / 2
            let r = 0.8 + hash(Double(i) + 2.0) * 0.8
            let star = Path(ellipseIn: CGRect(x: sx - r, y: sy - r, width: r * 2, height: r * 2))
            ctx.fill(star, with: .color(.white.opacity(twinkle * 0.6)))
        }
    }

    // MARK: - Wave Layer

    private func drawWave(
        ctx: inout GraphicsContext, size: CGSize, time: Double,
        speed: Double, amp: CGFloat, freq: CGFloat, levelMod: CGFloat,
        colors: [Color]
    ) {
        let adjustedLevel = level * levelMod
        let path = wavePath(in: size, time: time, speed: speed,
                            amplitude: amp, frequency: freq, level: adjustedLevel)
        let waterY = size.height * (1 - adjustedLevel)
        ctx.fill(path, with: .linearGradient(
            Gradient(colors: colors),
            startPoint: CGPoint(x: 0, y: waterY),
            endPoint: CGPoint(x: 0, y: size.height)
        ))
    }

    // MARK: - Caustics (underwater light)

    private func drawCaustics(ctx: inout GraphicsContext, size: CGSize, time: Double) {
        let waterY = size.height * (1 - level * 0.95)
        let count = 5

        for i in 0..<count {
            let baseX = hash(Double(i) * 3.0) * Double(size.width)
            let sway = sin(time * 0.5 + Double(i) * 1.2) * 15
            let x = CGFloat(baseX + sway)
            let topY = waterY + 8
            let bottomY = size.height

            var ray = Path()
            ray.move(to: CGPoint(x: x - 3, y: topY))
            ray.addLine(to: CGPoint(x: x + 5, y: bottomY))
            ray.addLine(to: CGPoint(x: x - 8, y: bottomY))
            ray.closeSubpath()

            let fade = (sin(time * 0.8 + Double(i) * 2.0) + 1) / 2 * 0.06
            ctx.fill(ray, with: .color(.white.opacity(fade)))
        }
    }

    // MARK: - Reflection

    private func drawReflection(ctx: inout GraphicsContext, size: CGSize, time: Double) {
        let waterY = size.height * (1 - level)
        let sunX = size.width * 0.82
        let shimmerCount = 6

        for i in 0..<shimmerCount {
            let yOff = CGFloat(i) * 6 + 3
            let y = waterY + yOff
            guard y < size.height else { continue }
            let wave = sin(time * 1.5 + Double(i) * 0.8) * 8
            let x = sunX + CGFloat(wave)
            let w = 12 - CGFloat(i) * 1.5
            let h: CGFloat = 2
            let shimmer = Path(ellipseIn: CGRect(x: x - w / 2, y: y, width: w, height: h))
            let opacity = waterLevel > 50
                ? 0.05 - Double(i) * 0.006
                : 0.15 - Double(i) * 0.02
            ctx.fill(shimmer, with: .color(.white.opacity(max(0, opacity))))
        }
    }

    // MARK: - Foam

    private func drawFoam(ctx: inout GraphicsContext, size: CGSize, time: Double) {
        let waterY = size.height * (1 - level)
        let count = 18

        for i in 0..<count {
            let baseX = hash(Double(i) * 7.0) * Double(size.width)
            let drift = time * (8 + hash(Double(i) + 10) * 12)
            let x = CGFloat((baseX + drift).truncatingRemainder(dividingBy: Double(size.width)))
            let relX = x / size.width
            let waveY = sin((Double(relX) * 2.0 + time * 0.2) * .pi * 2) * 5
            let y = waterY + CGFloat(waveY) + CGFloat(hash(Double(i) + 5) * 4 - 2)
            let r = 1.0 + hash(Double(i) + 3) * 1.5
            let dot = Path(ellipseIn: CGRect(x: x - CGFloat(r), y: y - CGFloat(r),
                                             width: CGFloat(r * 2), height: CGFloat(r * 2)))
            let flicker = (sin(time * 2 + Double(i) * 1.5) + 1) / 2
            ctx.fill(dot, with: .color(.white.opacity(0.2 + flicker * 0.15)))
        }
    }

    // MARK: - Bubbles

    private func drawBubbles(ctx: inout GraphicsContext, size: CGSize, time: Double) {
        let waterY = size.height * (1 - level)
        let count = 8

        for i in 0..<count {
            let baseX = size.width * 0.3 + CGFloat(hash(Double(i) * 5) * Double(size.width) * 0.4)
            let speed = 15 + hash(Double(i) + 2) * 20
            let cycleLen = Double(size.height) / speed
            let phase = hash(Double(i) + 8) * cycleLen
            let progress = ((time + phase).truncatingRemainder(dividingBy: cycleLen)) / cycleLen
            let y = waterY + CGFloat(1 - progress) * (size.height - waterY)
            guard y > waterY else { continue }

            let sway = CGFloat(sin(time * 2 + Double(i) * 1.7)) * 4
            let x = baseX + sway
            let r = 1.5 + hash(Double(i) + 1) * 2.5
            let bubble = Path(ellipseIn: CGRect(x: x - CGFloat(r), y: y - CGFloat(r),
                                                width: CGFloat(r * 2), height: CGFloat(r * 2)))
            let fade = 0.15 + (1 - progress) * 0.25
            ctx.stroke(bubble, with: .color(.white.opacity(fade)), lineWidth: 0.5)
            // Highlight
            let hl = Path(ellipseIn: CGRect(x: x - CGFloat(r * 0.4), y: y - CGFloat(r * 0.6),
                                            width: CGFloat(r * 0.5), height: CGFloat(r * 0.4)))
            ctx.fill(hl, with: .color(.white.opacity(fade * 0.5)))
        }
    }

    // MARK: - Character Overlay

    private func characterOverlay(time: Double) -> some View {
        GeometryReader { geo in
            let waterSurface = geo.size.height * (1 - level)
            let charY: CGFloat = {
                switch waterLevel {
                case ..<20:  return waterSurface - 18
                case ..<40:  return waterSurface - 10
                case ..<60:  return waterSurface - 2
                case ..<80:  return waterSurface + 6
                default:     return waterSurface + 14
                }
            }()

            let bob = CGFloat(sin(time * (waterLevel > 60 ? 2.5 : 1.2))) * (waterLevel > 60 ? 4 : 2)
            let rock = sin(time * (waterLevel > 60 ? 1.8 : 0.8)) * (waterLevel > 60 ? 10 : 3)

            Text(rank.sceneEmoji)
                .font(.system(size: waterLevel >= 100 ? 22 : 28))
                .rotationEffect(.degrees(rock))
                .offset(y: bob)
                .position(x: geo.size.width * 0.38, y: charY)
                .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
        }
    }

    // MARK: - Color Palettes

    private var skyColors: [Color] {
        switch waterLevel {
        case ..<25:  return [Color(red: 0.42, green: 0.75, blue: 0.96),
                             Color(red: 0.62, green: 0.86, blue: 0.97)]
        case ..<50:  return [Color(red: 0.94, green: 0.68, blue: 0.32),
                             Color(red: 0.96, green: 0.82, blue: 0.52)]
        case ..<75:  return [Color(red: 0.28, green: 0.12, blue: 0.22),
                             Color(red: 0.45, green: 0.15, blue: 0.12)]
        default:     return [Color(red: 0.06, green: 0.04, blue: 0.10),
                             Color(red: 0.10, green: 0.04, blue: 0.07)]
        }
    }

    private var deepWaterColors: [Color] {
        switch waterLevel {
        case ..<25:  return [Color(red: 0.08, green: 0.30, blue: 0.55).opacity(0.4),
                             Color(red: 0.04, green: 0.18, blue: 0.40)]
        case ..<50:  return [Color(red: 0.50, green: 0.30, blue: 0.08).opacity(0.4),
                             Color(red: 0.35, green: 0.18, blue: 0.05)]
        case ..<75:  return [Color(red: 0.40, green: 0.08, blue: 0.05).opacity(0.4),
                             Color(red: 0.25, green: 0.04, blue: 0.02)]
        default:     return [Color(red: 0.18, green: 0.0, blue: 0.0).opacity(0.5),
                             Color(red: 0.08, green: 0.0, blue: 0.0)]
        }
    }

    private var midWaterColors: [Color] {
        switch waterLevel {
        case ..<25:  return [Color(red: 0.12, green: 0.48, blue: 0.78).opacity(0.55),
                             Color(red: 0.06, green: 0.28, blue: 0.58)]
        case ..<50:  return [Color(red: 0.70, green: 0.42, blue: 0.12).opacity(0.5),
                             Color(red: 0.50, green: 0.25, blue: 0.06)]
        case ..<75:  return [Color(red: 0.55, green: 0.10, blue: 0.06).opacity(0.5),
                             Color(red: 0.38, green: 0.06, blue: 0.03)]
        default:     return [Color(red: 0.28, green: 0.0, blue: 0.0).opacity(0.6),
                             Color(red: 0.12, green: 0.0, blue: 0.0)]
        }
    }

    private var frontWaterColors: [Color] {
        switch waterLevel {
        case ..<25:  return [Color(red: 0.15, green: 0.55, blue: 0.85).opacity(0.3),
                             Color(red: 0.08, green: 0.35, blue: 0.65).opacity(0.5)]
        case ..<50:  return [Color(red: 0.75, green: 0.48, blue: 0.15).opacity(0.3),
                             Color(red: 0.55, green: 0.30, blue: 0.08).opacity(0.5)]
        case ..<75:  return [Color(red: 0.60, green: 0.12, blue: 0.08).opacity(0.3),
                             Color(red: 0.42, green: 0.08, blue: 0.04).opacity(0.5)]
        default:     return [Color(red: 0.32, green: 0.02, blue: 0.0).opacity(0.3),
                             Color(red: 0.15, green: 0.0, blue: 0.0).opacity(0.5)]
        }
    }
}
