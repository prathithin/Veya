import SwiftUI

struct AnalysisLoadingView: View {
    let dancerVideoURL: URL
    @StateObject private var vm = MotionCompareViewModel()
    @State private var currentStep = 0
    @State private var animateGradient = false
    @State private var readyToNavigate = false
    @State private var stepsFinished = false
    @State private var analysisFinished = false
    @Environment(\.dismiss) private var dismiss

    private let purple = Color(red: 0.45, green: 0.25, blue: 0.85)
    private let stepDuration = 0.9

    private let steps = [
        ("video.fill",          "Loading your video"),
        ("figure.dance",        "Extracting key frames"),
        ("eye.fill",            "Analyzing body position"),
        ("ruler.fill",          "Measuring arm & leg angles"),
        ("face.smiling.fill",   "Checking expressions"),
        ("checkmark.seal.fill", "Generating feedback"),
    ]

    var body: some View {
        ZStack {
            // Animated gradient
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.72, green: 0.60, blue: 0.95),
                             Color(red: 0.95, green: 0.72, blue: 0.60)],
                    startPoint: animateGradient ? .topLeading : .bottomLeading,
                    endPoint:   animateGradient ? .bottomTrailing : .topTrailing
                )
                LinearGradient(
                    colors: [Color(red: 0.60, green: 0.50, blue: 0.90),
                             Color(red: 0.80, green: 0.70, blue: 1.0)],
                    startPoint: animateGradient ? .bottomTrailing : .topLeading,
                    endPoint:   animateGradient ? .topLeading : .bottomTrailing
                )
                .opacity(animateGradient ? 0.65 : 0.0)
            }
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }

            VStack(spacing: 40) {
                // Cancel button top right
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.trailing, 24)
                    .padding(.top, 16)
                }

                Spacer()

                VStack(spacing: 8) {
                    Text("Analyzing\nyour dance")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("Powered by Gemini AI")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.75))
                }

                // Spinner
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 8)
                        .frame(width: 100, height: 100)
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(animateGradient ? 360 : 0))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: animateGradient)
                    Image(systemName: steps[min(currentStep, steps.count - 1)].0)
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }

                // Steps
                VStack(spacing: 12) {
                    ForEach(0..<steps.count, id: \.self) { i in
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(i < currentStep ? Color.white : Color.white.opacity(0.2))
                                    .frame(width: 28, height: 28)
                                if i < currentStep {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(purple)
                                } else if i == currentStep {
                                    ProgressView().tint(.white).scaleEffect(0.7)
                                }
                            }
                            Text(steps[i].1)
                                .font(.system(size: 15, weight: i <= currentStep ? .semibold : .regular))
                                .foregroundColor(i <= currentStep ? .white : .white.opacity(0.5))
                            Spacer()
                        }
                        .padding(.horizontal, 40)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                    }
                }

                Spacer()
                Spacer()
            }

            // Hidden navigation link — fires only when both are ready
            if let result = vm.result {
                NavigationLink(
                    destination: AnalysisResultView(result: result, dancerVideoURL: dancerVideoURL),
                    isActive: $readyToNavigate
                ) { EmptyView() }
            }
        }
        .navigationBarHidden(true)
        .onAppear { startAnalysis() }
        // Watch for both conditions — navigate when both done
        .onChange(of: analysisFinished) { _, done in
            if done && stepsFinished { triggerNavigation() }
        }
        .onChange(of: stepsFinished) { _, done in
            if done && analysisFinished { triggerNavigation() }
        }
    }

    private func triggerNavigation() {
        guard vm.result != nil else { return }
        withAnimation { currentStep = steps.count }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            readyToNavigate = true
        }
    }

    private func startAnalysis() {
        // Animate steps
        for i in 0..<steps.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * stepDuration) {
                withAnimation { currentStep = i }
            }
        }
        // Mark steps done after animation finishes
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(steps.count) * stepDuration) {
            stepsFinished = true
        }

        // Run Gemini analysis
        Task {
            guard let choreoURL = Bundle.main.url(forResource: "reference_video", withExtension: "mp4") else {
                print("❌ Could not find reference_video.mp4")
                return
            }
            await vm.analyze(choreoURL: choreoURL, dancerURL: dancerVideoURL)
            await MainActor.run {
                print("✅ Analysis done. Result: \(String(describing: vm.result))")
                analysisFinished = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        AnalysisLoadingView(dancerVideoURL: URL(fileURLWithPath: ""))
    }
}
