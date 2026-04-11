//
//  StretchView.swift
//  DanceApp(iPhone)
//
//  Created by Prathithi Nellaiappan on 4/11/26.
//

import SwiftUI

struct StretchesView: View {
    @State private var animateGradient = false

    var body: some View {
        ZStack {
            // MARK: - Animated Gradient Background
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.75, green: 0.35, blue: 0.95),
                        Color(red: 0.88, green: 0.80, blue: 1.0)
                    ],
                    startPoint: animateGradient ? .topLeading : .bottomLeading,
                    endPoint: animateGradient ? .bottomTrailing : .topTrailing
                )

                LinearGradient(
                    colors: [
                        Color(red: 0.60, green: 0.50, blue: 0.90),
                        Color(red: 0.80, green: 0.70, blue: 1.0)
                    ],
                    startPoint: animateGradient ? .bottomTrailing : .topLeading,
                    endPoint: animateGradient ? .topLeading : .bottomTrailing
                )
                .opacity(animateGradient ? 0.7 : 0.0)

                // Soft glow in center
                RadialGradient(
                    colors: [Color.white.opacity(0.35), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 300
                )
            }
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }

            // MARK: - Content
            VStack(spacing: 60) {
                Spacer()

                Text("What are\nyour goals?")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(Color(red: 0.22, green: 0.12, blue: 0.50))
                    .multilineTextAlignment(.center)

                // MARK: - Buttons
                HStack(spacing: 40) {
                    GoalButton(label: "General", destination: AnyView(GeneralStretchesView()))
                    GoalButton(label: "Target", destination: AnyView(TargetStretchesView()))
                }

                Spacer()
                Spacer()
            }
            .padding(.horizontal, 30)

            // MARK: - Profile avatar top right
            VStack {
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 46, height: 46)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 22))
                        )
                        .padding(.trailing, 20)
                        .padding(.top, 60)
                }
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Goal Button
struct GoalButton: View {
    let label: String
    let destination: AnyView
    @State private var pressed = false

    var body: some View {
        NavigationLink(destination: destination) {
            ZStack {
                // Shadow circle behind
                Circle()
                    .fill(Color(red: 0.20, green: 0.10, blue: 0.45).opacity(0.4))
                    .frame(width: 130, height: 130)
                    .blur(radius: 16)
                    .offset(y: 10)

                // Main button circle
                Circle()
                    .fill(Color(red: 0.28, green: 0.18, blue: 0.55))
                    .frame(width: 130, height: 130)

                Text(label)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(pressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: pressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
    }
}



#Preview {
    NavigationStack {
        StretchesView()
    }
}
