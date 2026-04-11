import SwiftUI

struct StretchItem: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String  // add image to Assets.xcassets with this name
    let instructions: String
    let muscleGroups: [String]
}

struct StretchSection: Identifiable {
    let id = UUID()
    let genre: String
    let stretches: [StretchItem]
}

struct GeneralStretchesView: View {
    
    let sections: [StretchSection] = [
        StretchSection(genre: "Hip Hop", stretches: [
            StretchItem(name: "Torso twists",
                        imageName: "torso_twists",
                        instructions: "Stand with feet shoulder-width apart. Place hands on hips. Slowly rotate your upper body to the left, then to the right. Keep hips facing forward. Repeat 10 times each side.",
                        muscleGroups: ["Obliques", "Core", "Spine"]),
            StretchItem(name: "Hip circles",
                        imageName: "hip_circles",
                        instructions: "Stand with feet hip-width apart and hands on hips. Slowly rotate your hips in a large circle clockwise for 10 reps, then counter-clockwise for 10 reps. Keep your upper body as still as possible.",
                        muscleGroups: ["Hip Flexors", "Glutes", "Lower Back"]),
            StretchItem(name: "Shoulder rolls",
                        imageName: "shoulder_rolls",
                        instructions: "Stand tall with arms relaxed at your sides. Roll both shoulders forward in a large circle 10 times, then backward 10 times. Breathe deeply throughout the movement.",
                        muscleGroups: ["Shoulders", "Trapezius", "Upper Back"]),
            StretchItem(name: "Calf + ankle bounces",
                        imageName: "calf_ankle_bounces",
                        instructions: "Stand near a wall for balance. Rise up onto your toes, then lower back down with a small bounce. Repeat 15–20 times. Then rotate each ankle clockwise and counter-clockwise 10 times each.",
                        muscleGroups: ["Calves", "Ankles", "Achilles"]),
            StretchItem(name: "Standing hamstring stretch",
                        imageName: "standing_hamstring",
                        instructions: "Stand tall and extend one leg forward, heel on the floor, toes up. Hinge at the hips and lean forward slightly until you feel a stretch in the back of your thigh. Hold 20–30 seconds each side.",
                        muscleGroups: ["Hamstrings", "Lower Back", "Glutes"]),
            StretchItem(name: "Neck rolls",
                        imageName: "neck_rolls",
                        instructions: "Sit or stand tall. Slowly drop your right ear toward your right shoulder, then roll your chin down to your chest and over to the left shoulder. Move slowly and never roll the head backward. Do 5 full rolls each direction.",
                        muscleGroups: ["Neck", "Traps", "Upper Shoulders"]),
        ]),
        StretchSection(genre: "Ballet", stretches: [
            StretchItem(name: "Frog stretch",
                        imageName: "frog_stretch",
                        instructions: "Lie face down and bring both knees out to the sides so your legs form a frog shape. Gently press your hips toward the floor. Hold for 30–60 seconds, breathing deeply to release tension.",
                        muscleGroups: ["Inner Thighs", "Hip Flexors", "Groin"]),
            StretchItem(name: "Quad stretch",
                        imageName: "quad_stretch",
                        instructions: "Stand on one leg and pull the opposite foot toward your glutes. Keep knees together and stand tall. Hold 20–30 seconds each side. Use a wall for balance if needed.",
                        muscleGroups: ["Quadriceps", "Hip Flexors", "Knees"]),
            StretchItem(name: "Back extension",
                        imageName: "back_extension",
                        instructions: "Lie face down with hands under your shoulders. Gently press up, lifting your chest off the floor while keeping hips down. Hold 15–20 seconds. Lower slowly and repeat 5 times.",
                        muscleGroups: ["Lower Back", "Spine", "Core"]),
        ]),
        StretchSection(genre: "Bhangra", stretches: [
            StretchItem(name: "Jumping jacks",
                        imageName: "jumping_jacks",
                        instructions: "Stand with feet together and arms at your sides. Jump feet out wide while raising arms overhead, then jump back to start. Perform 20–30 reps at a moderate pace to warm up the whole body.",
                        muscleGroups: ["Full Body", "Calves", "Shoulders"]),
            StretchItem(name: "Ankle rotations",
                        imageName: "ankle_rotations",
                        instructions: "Sit or stand and lift one foot slightly off the ground. Rotate the ankle slowly in a full circle — 10 times clockwise, 10 times counter-clockwise. Switch feet and repeat.",
                        muscleGroups: ["Ankles", "Calves", "Feet"]),
            StretchItem(name: "Wrist looseners",
                        imageName: "wrist_looseners",
                        instructions: "Extend both arms in front of you. Rotate wrists in slow circles — 10 times in each direction. Then shake hands out loosely for 10 seconds to release any remaining tension.",
                        muscleGroups: ["Wrists", "Forearms", "Hands"]),
        ]),
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                ForEach(sections) { section in
                    VStack(alignment: .leading, spacing: 12) {
                        
                        // Genre header
                        Text(section.genre)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
                        // First two stretches in a 2-column grid
                        let mainStretches = Array(section.stretches.prefix(2))
                        let thirdStretch = section.stretches.count > 2 ? [section.stretches[2]] : []
                        let extraStretches = thirdStretch
                        
                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible())],
                            spacing: 12
                        ) {
                            ForEach(mainStretches) { stretch in
                                NavigationLink(destination: StretchDetailView(stretch: stretch)) {
                                    StretchCard(stretch: stretch)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Second row: one stretch + Click for More
                        if !extraStretches.isEmpty {
                            HStack(spacing: 12) {
                                ForEach(extraStretches) { stretch in
                                    NavigationLink(destination: StretchDetailView(stretch: stretch)) {
                                        StretchCard(stretch: stretch)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                // Click for More button
                                NavigationLink(destination: AllStretchesView(genre: section.genre, stretches: section.stretches)) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(hex: "E5E5EA"))
                                            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                                        
                                        Text("CLICK\nFOR MORE")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(Color(hex: "636366"))
                                            .multilineTextAlignment(.center)
                                            .padding(.vertical, 24)
                                            .padding(.horizontal, 12)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(Color(hex: "F2F2F7"))
        .navigationTitle("Stretches")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Stretch Card
struct StretchCard: View {
    let stretch: StretchItem
    
    var body: some View {
        VStack(spacing: 0) {
            Image(stretch.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .background(Color.white)
            
            Text(stretch.name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "FFFFFF"))
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 2)
    }
}

// MARK: - All Stretches (Click for More destination)
struct AllStretchesView: View {
    let genre: String
    let stretches: [StretchItem]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 12
                ) {
                    ForEach(stretches) { stretch in
                        NavigationLink(destination: StretchDetailView(stretch: stretch)) {
                            StretchCard(stretch: stretch)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(Color(hex: "F2F2F7"))
        .navigationTitle(genre)
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Stretch Detail
struct StretchDetailView: View {
    let stretch: StretchItem
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Image
                Image(stretch.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 20)
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
                
                Text(stretch.name)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                // Instructions card
                VStack(alignment: .leading, spacing: 10) {
                    Text("How to do it")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(stretch.instructions)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(hex: "FFFFFF"))
                        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                )
                .padding(.horizontal, 20)
                
                // Muscle groups card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Muscle Groups Targeted")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    FlowLayout(items: stretch.muscleGroups) { muscle in
                        Text(muscle)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(red: 0.45, green: 0.25, blue: 0.85))
                            )
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(hex: "FFFFFF"))
                        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                )
                .padding(.horizontal, 20)
            }
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .background(Color(hex: "F2F2F7"))
        .navigationTitle(stretch.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Flow Layout (wraps tags to next line automatically)
struct FlowLayout<Item: Hashable, Content: View>: View {
    let items: [Item]
    let content: (Item) -> Content
    @State private var totalHeight: CGFloat = .zero

    var body: some View {
        GeometryReader { geo in
            self.generateContent(in: geo)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in geo: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0
        var lastHeight: CGFloat = 0

        return ZStack(alignment: .topLeading) {
            ForEach(items, id: \.self) { item in
                content(item)
                    .padding(.trailing, 8)
                    .padding(.bottom, 8)
                    .alignmentGuide(.leading) { d in
                        if abs(width - d.width) > geo.size.width {
                            width = 0
                            height -= lastHeight
                        }
                        lastHeight = d.height
                        let result = width
                        if item == items.last { width = 0 } else { width -= d.width }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if item == items.last { height = 0 }
                        return result
                    }
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geo in
            Color.clear.preference(key: HeightPreferenceKey.self, value: geo.size.height)
        }
        .onPreferenceChange(HeightPreferenceKey.self) { binding.wrappedValue = $0 }
    }
}

struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

#Preview {
    NavigationStack {
        GeneralStretchesView()
    }
}
