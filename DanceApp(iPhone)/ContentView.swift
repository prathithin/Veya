import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

struct AnimatedGradientHeader: View {
    @State private var animateGradient = false

    let colors1: [Color] = [
        Color(red: 0.72, green: 0.60, blue: 0.95),
        Color(red: 0.95, green: 0.72, blue: 0.60)
    ]
    let colors2: [Color] = [
        Color(red: 0.60, green: 0.75, blue: 0.98),
        Color(red: 0.85, green: 0.60, blue: 0.95)
    ]

    var body: some View {
        ZStack {
            // Layer 1
            LinearGradient(
                colors: colors1,
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .frame(height: 220)
            .ignoresSafeArea(edges: .top)

            // Layer 2 (crossfades)
            LinearGradient(
                colors: colors2,
                startPoint: animateGradient ? .bottomTrailing : .topLeading,
                endPoint: animateGradient ? .topLeading : .bottomTrailing
            )
            .frame(height: 220)
            .ignoresSafeArea(edges: .top)
            .opacity(animateGradient ? 0.6 : 0.0)

            // Fade to background at bottom
            VStack(spacing: 0) {
                Spacer()
                LinearGradient(
                    colors: [
                        Color(hex: "F2F2F7").opacity(0),
                        Color(hex: "F2F2F7")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 90)
            }
            .frame(height: 220)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

struct HomeView: View {
    
    let userName = "Prathithi"
    
    let notifications = [
        "You have one assigned video to upload!",
        "You have one assigned video to upload!",
        "You have one assigned video to upload!"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // MARK: - Animated Gradient Header
                    ZStack(alignment: .topLeading) {
                        AnimatedGradientHeader()

                        // Header text + avatar
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Welcome back")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.white)
                                Text("\(userName)...")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Circle()
                                .fill(Color.white.opacity(0.4))
                                .frame(width: 46, height: 46)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 22))
                                )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 90)
                    }
                    .frame(height: 220)
                    
                    // MARK: - Body Content
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // MARK: - Announcements Card
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Today's Announcements")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                            
                            ZStack(alignment: .topTrailing) {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(hex: "FFFFFF"))
                                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
                                
                                // Centered text
                                VStack {
                                    Spacer()
                                    Text("Over the past week, you have uploaded 3 videos and improved your accuracy by 20%. You have completed 30 stretches to prevent injuries.")
                                        .font(.system(size: 15))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity)
                                    Spacer()
                                }
                                .padding(16)
                                
                                HStack(spacing: 2) {
                                    Image(systemName: "sparkle")
                                        .foregroundColor(Color(red: 0.45, green: 0.25, blue: 0.85))
                                        .font(.system(size: 18, weight: .bold))
                                    Image(systemName: "sparkle")
                                        .foregroundColor(Color(red: 0.55, green: 0.75, blue: 0.95))
                                        .font(.system(size: 12))
                                }
                                .padding(12)
                            }
                            .frame(minHeight: 110)
                        }
                        
                        // MARK: - Feature Grid (equal spacing)
                        GeometryReader { geo in
                        let cardSize: CGFloat = (geo.size.width - 14) / 2
                        VStack(spacing: 14) {
                            HStack(spacing: 14) {
                                NavigationLink(destination: StretchesView()) {
                                    FeatureCard(
                                        icon: "figure.dance",
                                        label: "Stretches",
                                        badge: nil,
                                        accentColor: Color(red: 0.45, green: 0.25, blue: 0.85)
                                    )
                                    .frame(width: cardSize, height: cardSize * 0.65)
                                }
                                .buttonStyle(PlainButtonStyle())

                                NavigationLink(destination: UploadView()) {
                                    FeatureCard(
                                        icon: "camera.fill",
                                        label: "Upload",
                                        badge: 1,
                                        accentColor: Color(red: 0.45, green: 0.25, blue: 0.85)
                                    )
                                    .frame(width: cardSize, height: cardSize * 0.65)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }

                            HStack(spacing: 14) {
                                NavigationLink(destination: GalleryView()) {
                                    FeatureCard(
                                        icon: "photo.on.rectangle.angled",
                                        label: "Gallery",
                                        badge: 1,
                                        accentColor: Color(red: 0.25, green: 0.45, blue: 0.95)
                                    )
                                    .frame(width: cardSize, height: cardSize * 0.65)
                                }
                                .buttonStyle(PlainButtonStyle())

                                NavigationLink(destination: AliciaChatView()) {
                                    FeatureCard(
                                        icon: "bubble.left.and.bubble.right",
                                        label: "Chat",
                                        badge: nil,
                                        accentColor: Color(red: 0.25, green: 0.45, blue: 0.95)
                                    )
                                    .frame(width: cardSize, height: cardSize * 0.65)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        }
                        .frame(height: (UIScreen.main.bounds.width - 40 - 14) / 2 * 0.65 * 2 + 14)
                        
                        // MARK: - Notifications
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Notifications")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 8) {
                                ForEach(notifications, id: \.self) { note in
                                    NotificationRow(message: note)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                    .background(Color(hex: "F2F2F7"))
                }
            }
            .background(Color(hex: "F2F2F7"))
            .ignoresSafeArea(edges: .top)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Feature Card
struct FeatureCard: View {
    let icon: String
    let label: String
    let badge: Int?
    let accentColor: Color
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "FFFFFF"))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(accentColor)
                
                Text(label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if let badge = badge {
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 22, height: 22)
                    Text("\(badge)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(x: -10, y: 10)
            }
        }
    }
}

// MARK: - Notification Row
struct NotificationRow: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(red: 0.55, green: 0.70, blue: 0.95))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                )
            
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "FFFFFF"))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        )
    }
}

// MARK: - Placeholder Views


#Preview {
    HomeView()
}
