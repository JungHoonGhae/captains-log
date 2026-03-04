import SwiftUI

struct WaveShape: Shape {
    var offset: CGFloat
    var level: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(offset, level) }
        set { offset = newValue.first; level = newValue.second }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let waterY = rect.height * (1 - level)
        path.move(to: CGPoint(x: 0, y: waterY))

        for x in stride(from: CGFloat(0), through: rect.width, by: 1) {
            let relX = x / rect.width
            let sine = sin((relX * 2 + offset) * .pi * 2)
            let y = waterY + sine * 4
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

struct BubbleView: View {
    let startX: CGFloat
    let size: CGFloat
    let duration: Double
    @State private var yOffset: CGFloat = 0
    @State private var opacity: Double = 0.7

    var body: some View {
        Circle()
            .fill(Color.white.opacity(opacity))
            .frame(width: size, height: size)
            .offset(x: startX, y: yOffset)
            .onAppear {
                withAnimation(
                    .easeOut(duration: duration)
                    .repeatForever(autoreverses: false)
                ) {
                    yOffset = -50
                    opacity = 0
                }
            }
    }
}

struct WaterAnimationView: View {
    let waterLevel: Double
    let rank: PirateRank
    @State private var waveOffset: CGFloat = 0
    @State private var bobOffset: CGFloat = 0
    @State private var rockAngle: Double = 0

    private var level: CGFloat { min(CGFloat(waterLevel) / 100.0, 1.0) }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Sky
                LinearGradient(
                    colors: skyColors,
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Stars when dark (danger)
                if waterLevel > 60 {
                    ForEach(0..<8, id: \.self) { i in
                        Circle()
                            .fill(Color.white.opacity(Double.random(in: 0.3...0.7)))
                            .frame(width: 2, height: 2)
                            .position(
                                x: CGFloat(20 + i * 35),
                                y: CGFloat.random(in: 5...30)
                            )
                    }
                }

                // Deep water layer
                WaveShape(offset: waveOffset - 0.3, level: level * 0.92)
                    .fill(
                        LinearGradient(
                            colors: deepWaterColors,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // Main water
                WaveShape(offset: waveOffset, level: level)
                    .fill(
                        LinearGradient(
                            colors: waterColors,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // Front wave shimmer
                WaveShape(offset: waveOffset + 0.5, level: level * 0.96)
                    .fill(Color.white.opacity(0.08))

                // Bubbles when drowning
                if waterLevel > 50 {
                    ForEach(0..<4, id: \.self) { i in
                        BubbleView(
                            startX: 0,
                            size: CGFloat.random(in: 3...7),
                            duration: Double.random(in: 2...4)
                        )
                        .position(
                            x: geo.size.width * CGFloat(0.2 + Double(i) * 0.2),
                            y: geo.size.height * (1 - level) + 15
                        )
                    }
                }

                // Character / Ship
                characterView(in: geo)

                // Death overlay
                if waterLevel >= 100 {
                    Color.black.opacity(0.5)
                    Text("Commit to Resurrect")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .tracking(1)
                }
            }
        }
        .frame(height: 110)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onAppear { startAnimations() }
    }

    @ViewBuilder
    private func characterView(in geo: GeometryProxy) -> some View {
        let waterSurface = geo.size.height * (1 - level)
        let charY: CGFloat = {
            switch waterLevel {
            case ..<20:  return waterSurface - 22
            case ..<40:  return waterSurface - 12
            case ..<60:  return waterSurface - 2
            case ..<80:  return waterSurface + 8
            default:     return waterSurface + 18
            }
        }()

        Text(rank.sceneEmoji)
            .font(.system(size: waterLevel >= 100 ? 26 : 32))
            .rotationEffect(.degrees(rockAngle))
            .offset(y: bobOffset)
            .position(x: geo.size.width / 2, y: charY)
            .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
    }

    private func startAnimations() {
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
            waveOffset = 1
        }
        withAnimation(.easeInOut(duration: waterLevel > 60 ? 0.8 : 2.0).repeatForever(autoreverses: true)) {
            bobOffset = waterLevel > 60 ? 6 : 3
        }
        withAnimation(.easeInOut(duration: waterLevel > 60 ? 0.6 : 3.0).repeatForever(autoreverses: true)) {
            rockAngle = waterLevel > 60 ? 12 : 3
        }
    }

    private var skyColors: [Color] {
        switch waterLevel {
        case ..<25:  return [Color(red: 0.4, green: 0.75, blue: 0.95), Color(red: 0.6, green: 0.85, blue: 0.95)]
        case ..<50:  return [Color(red: 0.95, green: 0.7, blue: 0.3), Color(red: 0.95, green: 0.82, blue: 0.55)]
        case ..<75:  return [Color(red: 0.6, green: 0.2, blue: 0.15), Color(red: 0.4, green: 0.15, blue: 0.1)]
        default:     return [Color(red: 0.08, green: 0.05, blue: 0.12), Color(red: 0.12, green: 0.05, blue: 0.08)]
        }
    }

    private var waterColors: [Color] {
        switch waterLevel {
        case ..<25:  return [Color(red: 0.1, green: 0.5, blue: 0.8).opacity(0.6), Color(red: 0.05, green: 0.3, blue: 0.6)]
        case ..<50:  return [Color.orange.opacity(0.5), Color(red: 0.7, green: 0.4, blue: 0.1)]
        case ..<75:  return [Color.red.opacity(0.5), Color(red: 0.5, green: 0.1, blue: 0.05)]
        default:     return [Color(red: 0.3, green: 0, blue: 0), Color(red: 0.15, green: 0, blue: 0)]
        }
    }

    private var deepWaterColors: [Color] {
        switch waterLevel {
        case ..<25:  return [Color.blue.opacity(0.2), Color.blue.opacity(0.5)]
        case ..<50:  return [Color.orange.opacity(0.3), Color.orange.opacity(0.5)]
        case ..<75:  return [Color.red.opacity(0.3), Color.red.opacity(0.5)]
        default:     return [Color(red: 0.2, green: 0, blue: 0), Color(red: 0.1, green: 0, blue: 0)]
        }
    }
}
