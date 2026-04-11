import SwiftUI
import AVKit

struct AnalysisResultView: View {
    let result: ComparisonResult
    let dancerVideoURL: URL
    @Environment(\.dismiss) private var dismiss

    @State private var player: AVPlayer? = nil
    @State private var currentTime: Double = 0
    @State private var duration: Double = 1
    @State private var timeObserver: Any? = nil
    @State private var selectedFlagIndex: Int? = nil
    @State private var showPopup: Bool = false

    private let pageBackground = Color(red: 242/255, green: 242/255, blue: 246/255)
    private let cardBackground  = Color.white
    private let accentGreen     = Color(red: 0.27, green: 0.73, blue: 0.35)
    private let flagPurple      = Color(red: 0.47, green: 0.42, blue: 0.73)

    // Generate flag positions evenly across the video from feedback
    private var flags: [(fraction: Double, comment: String)] {
        let count = result.feedback.count
        return result.feedback.enumerated().map { i, text in
            let fraction = count == 1 ? 0.5 : Double(i) / Double(count - 1) * 0.8 + 0.1
            return (fraction: fraction, comment: text)
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            pageBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    headerBar
                    Text("Your video from \(formattedDate())")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)

                    // Video + timeline
                    videoSection
                        .padding(.horizontal, 16)

                    Text("[Click on the pins to view your choreographer's feedback]")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    accuracySection
                    overallFeedbackCard
                    aiFeedbackSection

                    Button(action: {
                        dismiss()
                    }) {
                        Text("Try Again")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(RoundedRectangle(cornerRadius: 16).fill(flagPurple))
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }

            // Popup overlay
            if showPopup, let idx = selectedFlagIndex {
                flagPopup(index: idx)
            }
        }
        .navigationBarHidden(true)
        .onAppear { setupPlayer() }
        .onDisappear { teardownPlayer() }
    }

    // MARK: - Header
    private var headerBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
            }
            Spacer()
            Text("Feedback")
                .font(.system(size: 22, weight: .bold))
            Spacer()
            Circle()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 38, height: 38)
                .overlay(Image(systemName: "person.fill").foregroundColor(.white))
                .padding(.trailing, 8)
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
    }

    // MARK: - Video + Timeline
    private var videoSection: some View {
        VStack(spacing: 0) {
            if let player = player {
                VideoPlayer(player: player)
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .onTapGesture { withAnimation { showPopup = false } }
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black)
                    .frame(height: 240)
            }

            // Timeline bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 4)
                    // Progress
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.black)
                        .frame(width: geo.size.width * CGFloat(currentTime / max(duration, 1)), height: 4)
                    // Flag pins
                    ForEach(flags.indices, id: \.self) { i in
                        let xPos = geo.size.width * CGFloat(flags[i].fraction)
                        VStack(spacing: 0) {
                            Circle()
                                .fill(flagPurple)
                                .frame(width: 14, height: 14)
                            Rectangle()
                                .fill(flagPurple)
                                .frame(width: 2, height: 10)
                        }
                        .offset(x: xPos - 7, y: -16)
                        .onTapGesture {
                            // Seek to that point in video
                            let seekTime = flags[i].fraction * duration
                            player?.seek(to: CMTime(seconds: seekTime, preferredTimescale: 600))
                            withAnimation(.spring(response: 0.3)) {
                                selectedFlagIndex = i
                                showPopup = true
                            }
                        }
                    }
                }
            }
            .frame(height: 36)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardBackground)
                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 1)
            )
            .padding(.top, 6)
        }
    }

    // MARK: - Flag Popup
    private func flagPopup(index: Int) -> some View {
        let hasPrev = index > 0
        let hasNext = index < flags.count - 1

        return VStack {
            Spacer().frame(height: 220)
            HStack(alignment: .center, spacing: 8) {
                // Prev arrow
                Button(action: {
                    if hasPrev {
                        let prev = index - 1
                        let seekTime = flags[prev].fraction * duration
                        player?.seek(to: CMTime(seconds: seekTime, preferredTimescale: 600))
                        withAnimation(.spring(response: 0.3)) { selectedFlagIndex = prev }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(hasPrev ? flagPurple : Color.gray.opacity(0.3))
                            .frame(width: 36, height: 36)
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .disabled(!hasPrev)

                // Comment card
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(flagPurple)
                        Text("Note \(index + 1) of \(flags.count)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(flagPurple)
                        Spacer()
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                showPopup = false
                                selectedFlagIndex = nil
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.92, green: 0.92, blue: 0.94))
                                    .frame(width: 26, height: 26)
                                Image(systemName: "xmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    Text(flags[index].comment)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
                )
                .frame(maxWidth: 220)

                // Next arrow
                Button(action: {
                    if hasNext {
                        let next = index + 1
                        let seekTime = flags[next].fraction * duration
                        player?.seek(to: CMTime(seconds: seekTime, preferredTimescale: 600))
                        withAnimation(.spring(response: 0.3)) { selectedFlagIndex = next }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(hasNext ? flagPurple : Color.gray.opacity(0.3))
                            .frame(width: 36, height: 36)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .disabled(!hasNext)
            }
            .padding(.horizontal, 16)
            Spacer()
        }
        .transition(.scale(scale: 0.9).combined(with: .opacity))
        .zIndex(10)
    }

    // MARK: - Accuracy Gauge
    private var accuracySection: some View {
        VStack(spacing: 8) {
            GaugeArcShape(value: Double(result.accuracyPercent) / 100, color: accentGreen)
                .frame(width: 180, height: 100)
            Text("\(result.accuracyPercent)%")
                .font(.system(size: 36, weight: .semibold))
                .foregroundColor(accentGreen)
                .offset(y: -60)
                .padding(.bottom, -65)
            Text("Your Accuracy")
                .font(.system(size: 22, weight: .bold))
            Text("Your score is calculated by comparing\nyour movements with the choreographer.")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    // MARK: - Overall Feedback
    private var overallFeedbackCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.22, green: 0.35, blue: 0.70))
                        .frame(width: 40, height: 40)
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                }
                Text("Overall feedback:")
                    .font(.system(size: 16, weight: .bold))
            }
            Text(result.overallSummary)
                .font(.system(size: 15))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBackground)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
    }

    // MARK: - AI Feedback
    private var aiFeedbackSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Spacer()
                Text("Your AI Feedback")
                    .font(.system(size: 17, weight: .bold))
                Spacer()
                ZStack {
                    Image(systemName: "sparkle")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(red: 0.27, green: 0.18, blue: 0.58))
                        .offset(x: -6, y: 4)
                    Image(systemName: "sparkle")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.55, green: 0.65, blue: 0.90))
                        .offset(x: 8, y: 10)
                    Image(systemName: "sparkle")
                        .font(.system(size: 10))
                        .foregroundColor(Color(red: 0.70, green: 0.62, blue: 0.86))
                        .offset(x: 4, y: -2)
                }
                .frame(width: 40, height: 30)
                .padding(.trailing, 16)
            }
            VStack(alignment: .leading, spacing: 14) {
                ForEach(result.feedback, id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(Color.primary)
                            .frame(width: 5, height: 5)
                            .padding(.top, 6)
                        Text(item)
                            .font(.system(size: 15))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(cardBackground)
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            )
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Player Setup
    private func setupPlayer() {
        let avPlayer = AVPlayer(url: dancerVideoURL)
        player = avPlayer
        let asset = AVAsset(url: dancerVideoURL)
        Task {
            if let dur = try? await asset.load(.duration) {
                await MainActor.run { duration = CMTimeGetSeconds(dur) }
            }
        }
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserver = avPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            currentTime = CMTimeGetSeconds(time)
        }
    }

    private func teardownPlayer() {
        if let obs = timeObserver { player?.removeTimeObserver(obs) }
        player?.pause()
        player = nil
        timeObserver = nil
    }

    private func formattedDate() -> String {
        let f = DateFormatter()
        f.dateStyle = .long
        return f.string(from: Date())
    }
}

// MARK: - Gauge Arc
struct GaugeArcShape: View {
    let value: Double
    let color: Color
    var body: some View {
        ZStack {
            ArcShape(startAngle: .degrees(180), endAngle: .degrees(360))
                .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 18, lineCap: .round))
            ArcShape(startAngle: .degrees(180), endAngle: .degrees(180 + 180 * value))
                .stroke(color, style: StrokeStyle(lineWidth: 18, lineCap: .round))
        }
    }
}

struct ArcShape: Shape {
    var startAngle: Angle
    var endAngle: Angle
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addArc(center: CGPoint(x: rect.midX, y: rect.maxY),
                 radius: min(rect.width, rect.height * 2) / 2,
                 startAngle: startAngle, endAngle: endAngle, clockwise: false)
        return p
    }
}

#Preview {
    NavigationStack {
        AnalysisResultView(
            result: ComparisonResult(
                accuracyPercent: 80,
                feedback: [
                    "Extend your arms fully at shoulder height for the opening move.",
                    "Your jump timing is slightly off — try to hit the beat more precisely.",
                    "Great energy in the middle section — maintain this throughout."
                ],
                overallSummary: "Overall great effort! You know the choreo well. Focus on arm extension and sharper transitions."
            ),
            dancerVideoURL: URL(fileURLWithPath: "")
        )
    }
}
