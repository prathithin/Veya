import SwiftUI

struct MuscleGroup: Identifiable {
    let id = UUID()
    let name: String
    let bodyPart: String
    let stretches: [StretchItem]
    // Position on body diagram (normalized 0-1)
    let dotX: CGFloat
    let dotY: CGFloat
}

struct TargetStretchesView: View {
    @State private var selectedGroup: MuscleGroup? = nil
    @State private var animateGradient = false

    // MARK: - Adjust dotX/dotY (0.0 = left/top, 1.0 = right/bottom) to move dots on the body
    let muscleGroups: [MuscleGroup] = [
        MuscleGroup(name: "Shoulders & Traps", bodyPart: "shoulders",
            stretches: [
                StretchItem(name: "Shoulder rolls", imageName: "shoulder_rolls",
                    instructions: "Stand tall with arms relaxed at your sides. Roll both shoulders forward in a large circle 10 times, then backward 10 times.",
                    muscleGroups: ["Shoulders", "Trapezius", "Upper Back"]),
                StretchItem(name: "Neck rolls", imageName: "neck_rolls",
                    instructions: "Sit or stand tall. Slowly drop your right ear toward your right shoulder, then roll your chin down to your chest and over to the left shoulder.",
                    muscleGroups: ["Neck", "Traps", "Upper Shoulders"]),
            ], dotX: 0.62, dotY: 0.22),

        MuscleGroup(name: "Core & Obliques", bodyPart: "core",
            stretches: [
                StretchItem(name: "Torso twists", imageName: "torso_twists",
                    instructions: "Stand with feet shoulder-width apart. Place hands on hips. Slowly rotate your upper body to the left, then to the right. Keep hips facing forward.",
                    muscleGroups: ["Obliques", "Core", "Spine"]),
            ], dotX: 0.50, dotY: 0.40),

        MuscleGroup(name: "Hips & Glutes", bodyPart: "hips",
            stretches: [
                StretchItem(name: "Hip circles", imageName: "hip_circles",
                    instructions: "Stand with feet hip-width apart and hands on hips. Slowly rotate your hips in a large circle clockwise for 10 reps, then counter-clockwise for 10 reps.",
                    muscleGroups: ["Hip Flexors", "Glutes", "Lower Back"]),
                StretchItem(name: "Frog stretch", imageName: "frog_stretch",
                    instructions: "Lie face down and bring both knees out to the sides so your legs form a frog shape. Gently press your hips toward the floor.",
                    muscleGroups: ["Inner Thighs", "Hip Flexors", "Groin"]),
            ], dotX: 0.60, dotY: 0.50),

        MuscleGroup(name: "Hamstrings & Quads", bodyPart: "thighs",
            stretches: [
                StretchItem(name: "Standing hamstring stretch", imageName: "standing_hamstring",
                    instructions: "Stand tall and extend one leg forward, heel on the floor, toes up. Hinge at the hips and lean forward slightly until you feel a stretch in the back of your thigh.",
                    muscleGroups: ["Hamstrings", "Lower Back", "Glutes"]),
                StretchItem(name: "Quad stretch", imageName: "quad_stretch",
                    instructions: "Stand on one leg and pull the opposite foot toward your glutes. Keep knees together and stand tall. Hold 20–30 seconds each side.",
                    muscleGroups: ["Quadriceps", "Hip Flexors", "Knees"]),
            ], dotX: 0.59, dotY: 0.63),

        MuscleGroup(name: "Calves & Ankles", bodyPart: "calves",
            stretches: [
                StretchItem(name: "Calf + ankle bounces", imageName: "calf_ankle_bounces",
                    instructions: "Stand near a wall for balance. Rise up onto your toes, then lower back down with a small bounce. Then rotate each ankle clockwise and counter-clockwise.",
                    muscleGroups: ["Calves", "Ankles", "Achilles"]),
                StretchItem(name: "Ankle rotations", imageName: "ankle_rotations",
                    instructions: "Sit or stand and lift one foot slightly off the ground. Rotate the ankle slowly in a full circle — 10 times each direction.",
                    muscleGroups: ["Ankles", "Calves", "Feet"]),
            ], dotX: 0.37, dotY: 0.80),

        MuscleGroup(name: "Wrists & Arms", bodyPart: "wrists",
            stretches: [
                StretchItem(name: "Wrist looseners", imageName: "wrist_looseners",
                    instructions: "Extend both arms in front of you. Rotate wrists in slow circles — 10 times in each direction. Then shake hands out loosely.",
                    muscleGroups: ["Wrists", "Forearms", "Hands"]),
            ], dotX: 0.25, dotY: 0.52),
    ]

    var body: some View {
        ZStack {
            // Animated gradient background
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.72, green: 0.60, blue: 0.95), Color(red: 0.88, green: 0.80, blue: 1.0)],
                    startPoint: animateGradient ? .topLeading : .bottomLeading,
                    endPoint: animateGradient ? .bottomTrailing : .topTrailing
                )
                LinearGradient(
                    colors: [Color(red: 0.60, green: 0.50, blue: 0.90), Color(red: 0.80, green: 0.70, blue: 1.0)],
                    startPoint: animateGradient ? .bottomTrailing : .topLeading,
                    endPoint: animateGradient ? .topLeading : .bottomTrailing
                )
                .opacity(animateGradient ? 0.7 : 0.0)
                RadialGradient(colors: [Color.white.opacity(0.30), Color.clear], center: .center, startRadius: 0, endRadius: 300)
            }
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }

            VStack(spacing: 0) {
                // Title
                Text("Target")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(Color(red: 0.22, green: 0.12, blue: 0.50))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)
                    .padding(.bottom, 10)

                // Body diagram with dots
                GeometryReader { geo in
                    ZStack {
                        // Body image
                        Image("body_diagram")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                        // Dots on muscle groups
                        ForEach(muscleGroups) { group in
                            let x = group.dotX * geo.size.width
                            let y = group.dotY * geo.size.height
                            let isSelected = selectedGroup?.id == group.id

                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    if selectedGroup?.id == group.id {
                                        selectedGroup = nil
                                    } else {
                                        selectedGroup = group
                                    }
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(isSelected ? Color(red: 0.28, green: 0.18, blue: 0.55) : Color(red: 0.45, green: 0.30, blue: 0.85).opacity(0.85))
                                        .frame(width: isSelected ? 22 : 16, height: isSelected ? 22 : 16)
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                        .frame(width: isSelected ? 22 : 16, height: isSelected ? 22 : 16)
                                }
                            }
                            .position(x: x, y: y)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 550)
                .padding(.leading, 40).padding(.trailing, 20)

                // Bottom panel
                if let group = selectedGroup {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header
                        HStack {
                            Text(group.name)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(group.stretches.count) stretches")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 12)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(group.stretches) { stretch in
                                    NavigationLink(destination: StretchDetailView(stretch: stretch)) {
                                        VStack(spacing: 0) {
                                            Image(stretch.imageName)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 100, height: 90)
                                                .background(Color.white)

                                            Text(stretch.name)
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.primary)
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 8)
                                                .frame(maxWidth: .infinity)
                                                .background(Color.white)
                                        }
                                        .frame(width: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                    .background(Color(hex: "F2F2F7"))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.10), radius: 12, x: 0, y: -4)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: "hand.tap")
                            .font(.system(size: 24))
                            .foregroundColor(Color(red: 0.45, green: 0.25, blue: 0.85).opacity(0.7))
                        Text("Tap a dot to see stretches")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.22, green: 0.12, blue: 0.50).opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .transition(.opacity)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TargetStretchesView()
    }
}
