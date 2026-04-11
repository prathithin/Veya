//
//  AliciaChatView.swift
//  DanceApp(iPhone)
//
//  AliciaChatView.swift
//  DanceApp(iPhone)
//
//
//  AliciaChatView.swift
//  DanceApp(iPhone)
//

import SwiftUI
import PhotosUI
import Combine

// MARK: - Models
struct ChatMessage: Identifiable {
    let id = UUID()
    let role: MessageRole
    let text: String
    let imageData: Data?
    let timestamp: Date
    enum MessageRole {
        case user, assistant
    }
    init(role: MessageRole, text: String, imageData: Data? = nil) {
        self.role = role
        self.text = text
        self.imageData = imageData
        self.timestamp = Date()
    }
}

// MARK: - ViewModel
final class AliciaChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    private let geminiAPIKey = "AIzaSyB7BwYoZ4Dsn9dwBxJOzJxA1ksPCzPwALA"
    private let systemPrompt = """
    You are Alicia, a dance coach assistant. You help dancers with:
    - Creating personalized meal plans
    - Addressing dance injuries and recovery
    - Making practice schedules
    - General dance advice and motivation
    Always be warm, encouraging, and professional. Keep responses concise and friendly.
    """
    init() {
        // Start with empty messages — welcome message shown at bottom via special view
        messages = []
    }
    @MainActor
    func sendMessage(imageData: Data? = nil) async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty || imageData != nil else { return }
        // Add welcome message as first real message when user sends first message
        if messages.isEmpty {
            messages.append(ChatMessage(
                role: .assistant,
                text: "Hey! I'm Alicia and I'm here to help with all your dance worries!\nI can help with...\n• creating a meal plan\n• addressing injuries\n• making a practice schedule\n• and more!"
            ))
        }
        messages.append(ChatMessage(role: .user, text: text, imageData: imageData))
        inputText = ""
        isLoading = true
        do {
            let reply = try await callGeminiAPI(userText: text, imageData: imageData)
            messages.append(ChatMessage(role: .assistant, text: reply))
        } catch {
            print("CHAT ERROR: \(error)")
            messages.append(ChatMessage(role: .assistant, text: "DEBUG ERROR: \(error.localizedDescription)"))
        }
        isLoading = false
    }
    private func callGeminiAPI(userText: String, imageData: Data?) async throws -> String {
        // Use URLComponents to build URL safely
        var components = URLComponents(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent")!
        components.queryItems = [URLQueryItem(name: "key", value: geminiAPIKey)]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        // Build prompt as plain text
        var fullPrompt = systemPrompt + "\n\n"
        for msg in messages.dropLast() {
            fullPrompt += (msg.role == .user ? "User: " : "Alicia: ") + msg.text + "\n"
        }
        fullPrompt += "User: " + userText + "\nAlicia:"

        // Encode body as JSON string manually to avoid any type issues
        let bodyDict: [String: Any] = [
            "contents": [
                [
                    "role": "user",
                    "parts": [["text": fullPrompt]]
                ]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: bodyDict, options: [])

        print("Sending to: \(components.url!)")
        print("Body: \(String(data: request.httpBody!, encoding: .utf8) ?? "nil")")

        let (data, response) = try await URLSession.shared.data(for: request)

        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        let raw = String(data: data, encoding: .utf8) ?? "nil"
        print("Gemini status: \(statusCode)")
        print("Gemini raw: \(raw)")

        guard statusCode == 200 else {
            throw NSError(domain: "GeminiAPI", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(statusCode): \(raw)"])
        }

        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let candidates = json["candidates"] as? [[String: Any]],
            let first = candidates.first,
            let content = first["content"] as? [String: Any],
            let parts = content["parts"] as? [[String: Any]],
            let text = parts.first?["text"] as? String
        else {
            throw NSError(domain: "GeminiAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Parse failed: \(raw)"])
        }
        return text
    }
}

// MARK: - Main View
struct AliciaChatView: View {
    @StateObject private var viewModel = AliciaChatViewModel()
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @FocusState private var inputFocused: Bool

    private let pageBackground = Color(red: 242/255, green: 242/255, blue: 246/255)
    private let secondaryBg = Color(red: 242/255, green: 242/255, blue: 246/255)
    private let tertiaryFill = Color(red: 242/255, green: 242/255, blue: 246/255)
    private let separatorColor = Color(red: 242/255, green: 242/255, blue: 246/255)

    var body: some View {
        ZStack(alignment: .top) {
            pageBackground.ignoresSafeArea()
            GeometryReader { geo in
                LinearGradient(
                    stops: [
                        .init(color: Color(red: 0.70, green: 0.62, blue: 0.86), location: 0.00),
                        .init(color: Color(red: 0.96, green: 0.56, blue: 0.69), location: 0.45),
                        .init(color: Color(red: 1.00, green: 0.85, blue: 0.65), location: 0.75),
                        .init(color: pageBackground, location: 1.00)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: geo.size.height * 0.26)
                .ignoresSafeArea(edges: .top)
            }
            VStack(spacing: 0) {
                headerBar
                messageList
                inputBar
            }
        }
        .navigationBarHidden(true)
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    await viewModel.sendMessage(imageData: data)
                    selectedPhoto = nil
                }
            }
        }
    }

    // MARK: - Header
    @Environment(\.dismiss) private var dismiss

    private var headerBar: some View {
        HStack(alignment: .center) {
            Button(action: { dismiss() }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.leading, 4)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 4)
        .overlay(
            Text("Chat with Alicia")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 12)
        )
    }

    // MARK: - Message List
    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    // Show welcome card at bottom when no messages yet
                    if viewModel.messages.isEmpty {
                        Color.clear.frame(height: 1).id("top")
                        Spacer().frame(minHeight: UIScreen.main.bounds.height * 0.6)
                        welcomeCard
                            .id("welcome")
                    } else {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message, secondaryBg: secondaryBg)
                                .id(message.id)
                        }
                        if viewModel.isLoading {
                            TypingIndicator(secondaryBg: secondaryBg).id("typing")
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    proxy.scrollTo("welcome", anchor: .bottom)
                }
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                withAnimation(.easeOut(duration: 0.25)) {
                    proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                }
            }
            .onChange(of: viewModel.isLoading) { _, newValue in
                if newValue {
                    withAnimation(.easeOut(duration: 0.25)) {
                        proxy.scrollTo("typing", anchor: .bottom)
                    }
                }
            }
        }
    }

    // MARK: - Welcome Card (shown at bottom before first message)
    private var welcomeCard: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color(red: 0.60, green: 0.48, blue: 0.82), Color(red: 0.88, green: 0.44, blue: 0.62)],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 34, height: 34)
                Image(systemName: "person.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }
            Text("Hey! I'm Alicia and I'm here to help with all your dance worries!\nI can help with...\n• creating a meal plan\n• addressing injuries\n• making a practice schedule\n• and more!")
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(secondaryBg)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
            Spacer(minLength: 60)
        }
    }

    // MARK: - Input Bar
    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: 10) {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                ZStack {
                    Circle()
                        .fill(tertiaryFill)
                        .frame(width: 36, height: 36)
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
            HStack(alignment: .bottom, spacing: 8) {
                TextField("Type here...", text: $viewModel.inputText, axis: .vertical)
                    .font(.system(size: 15))
                    .lineLimit(1...6)
                    .focused($inputFocused)
                    .padding(.vertical, 2)
                if !viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Button {
                        Task { await viewModel.sendMessage() }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(LinearGradient(
                                colors: [Color(red: 0.60, green: 0.48, blue: 0.82), Color(red: 0.88, green: 0.44, blue: 0.62)],
                                startPoint: .topLeading, endPoint: .bottomTrailing))
                    }
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.25), value: viewModel.inputText.isEmpty)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(secondaryBg)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(separatorColor.opacity(0.35), lineWidth: 0.5))
            .contentShape(Rectangle())
            .onTapGesture { inputFocused = true }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 16)
        .background(pageBackground)
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: ChatMessage
    let secondaryBg: Color
    private var isUser: Bool { message.role == .user }
    private let bubbleGradient = LinearGradient(
        colors: [Color(red: 0.60, green: 0.48, blue: 0.82), Color(red: 0.88, green: 0.44, blue: 0.62)],
        startPoint: .topLeading, endPoint: .bottomTrailing)
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isUser {
                Spacer(minLength: 60)
                bubbleContent
            } else {
                avatarView
                bubbleContent
                Spacer(minLength: 60)
            }
        }
    }
    @ViewBuilder
    private var bubbleContent: some View {
        VStack(alignment: isUser ? .trailing : .leading, spacing: 6) {
            if let data = message.imageData, let image = loadImage(from: data) {
                image.resizable().scaledToFill()
                    .frame(maxWidth: 200, maxHeight: 200).clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            if !message.text.isEmpty {
                Text(message.text)
                    .font(.system(size: 14))
                    .foregroundColor(isUser ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(isUser ? AnyShapeStyle(bubbleGradient) : AnyShapeStyle(secondaryBg))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
            }
        }
    }
    private var avatarView: some View {
        ZStack {
            Circle().fill(bubbleGradient).frame(width: 34, height: 34)
            Image(systemName: "person.fill").font(.system(size: 16)).foregroundColor(.white)
        }
    }
    private func loadImage(from data: Data) -> Image? {
        #if canImport(UIKit)
        if let ui = UIImage(data: data) { return Image(uiImage: ui) }
        #endif
        return nil
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    let secondaryBg: Color
    @State private var animating = false
    private let bubbleGradient = LinearGradient(
        colors: [Color(red: 0.60, green: 0.48, blue: 0.82), Color(red: 0.88, green: 0.44, blue: 0.62)],
        startPoint: .topLeading, endPoint: .bottomTrailing)
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ZStack {
                Circle().fill(bubbleGradient).frame(width: 34, height: 34)
                Image(systemName: "person.fill").font(.system(size: 16)).foregroundColor(.white)
            }
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    Circle().fill(Color.secondary.opacity(0.5)).frame(width: 7, height: 7)
                        .scaleEffect(animating ? 1.2 : 0.6)
                        .animation(.easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.18), value: animating)
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(secondaryBg).clipShape(RoundedRectangle(cornerRadius: 18))
            Spacer(minLength: 60)
        }
        .onAppear { animating = true }
    }
}

#Preview {
    NavigationStack { AliciaChatView() }
}
