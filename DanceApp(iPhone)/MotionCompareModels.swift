//
//  MotionCompareModels.swift
//  DanceApp(iPhone)
//
//  Created by Prathithi Nellaiappan on 4/11/26.
//
import SwiftUI
import AVFoundation
import Combine

// MARK: - Result Model
struct ComparisonResult {
    let accuracyPercent: Int
    let feedback: [String]
    let overallSummary: String
}

// MARK: - ViewModel
final class MotionCompareViewModel: ObservableObject {
    @Published var isAnalyzing = false
    @Published var result: ComparisonResult? = nil
    @Published var errorMessage: String? = nil

    private let geminiAPIKey = "AIzaSyB7BwYoZ4Dsn9dwBxJOzJxA1ksPCzPwALA"

    func extractFrame(from url: URL, at time: Double = 1.0) async -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 256, height: 256)
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        return try? await withCheckedThrowingContinuation { continuation in
            generator.generateCGImageAsynchronously(for: cmTime) { cgImage, _, error in
                if let cgImage { continuation.resume(returning: UIImage(cgImage: cgImage)) }
                else { continuation.resume(throwing: error ?? NSError()) }
            }
        }
    }

    func analyze(choreoURL: URL, dancerURL: URL) async {
        await MainActor.run {
            isAnalyzing = true
            result = nil
            errorMessage = nil
        }

        let choreoImg = await extractFrame(from: choreoURL, at: 1.0)
        let dancerImg = await extractFrame(from: dancerURL, at: 1.0)
        print("🎞 Choreo frame: \(choreoImg != nil ? "OK" : "FAILED")")
        print("🎞 Dancer frame: \(dancerImg != nil ? "OK" : "FAILED")")

        guard let choreo = choreoImg, let dancer = dancerImg else {
            await MainActor.run { errorMessage = "Could not extract frames."; isAnalyzing = false }
            return
        }

        guard let choreoData = choreo.jpegData(compressionQuality: 0.4),
              let dancerData = dancer.jpegData(compressionQuality: 0.4) else {
            await MainActor.run { errorMessage = "Could not process images."; isAnalyzing = false }
            return
        }

        do {
            print("📤 Sending frames to Gemini... choreo: \(choreoData.count) bytes, dancer: \(dancerData.count) bytes")
            let result = try await callGeminiVision(choreoData: choreoData, dancerData: dancerData)
            print("✅ Got result: \(result.accuracyPercent)%")
            await MainActor.run { self.result = result; isAnalyzing = false }
        } catch {
            print("❌ Gemini error: \(error.localizedDescription)")
            await MainActor.run { errorMessage = error.localizedDescription; isAnalyzing = false }
        }
    }

    private func callGeminiVision(choreoData: Data, dancerData: Data) async throws -> ComparisonResult {
        var components = URLComponents(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent")!
        components.queryItems = [URLQueryItem(name: "key", value: geminiAPIKey)]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60

        let prompt = """
        Compare these two dance images. Image 1 = choreographer, Image 2 = dancer.
        Reply ONLY with this JSON, no extra text, no markdown:
        {"accuracy":75,"feedback":["tip 1","tip 2","tip 3"],"summary":"one sentence"}
        accuracy = 0-100 match score. feedback = 3 short specific tips on arms, legs, posture, or expression. summary = one sentence overall.
        """

        let body: [String: Any] = [
            "contents": [[
                "parts": [
                    ["text": prompt],
                    ["inline_data": ["mime_type": "image/jpeg", "data": choreoData.base64EncodedString()]],
                    ["inline_data": ["mime_type": "image/jpeg", "data": dancerData.base64EncodedString()]]
                ]
            ]],
            "generationConfig": [
                "temperature": 0.3,
                "maxOutputTokens": 500,
                "thinkingConfig": ["thinkingBudget": 0]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, _) = try await URLSession.shared.data(for: request)

        print("🌐 Raw Gemini response: \(String(data: data, encoding: .utf8) ?? "nil")")

        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let candidates = json["candidates"] as? [[String: Any]],
            let first = candidates.first,
            let content = first["content"] as? [String: Any],
            let parts = content["parts"] as? [[String: Any]],
            let text = parts.first?["text"] as? String
        else {
            throw NSError(domain: "GeminiVision", code: -1, userInfo: [NSLocalizedDescriptionKey: String(data: data, encoding: .utf8) ?? "unknown"])
        }

        let clean = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard
            let jsonData = clean.data(using: .utf8),
            let parsed = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
            let accuracy = parsed["accuracy"] as? Int,
            let feedback = parsed["feedback"] as? [String],
            let summary = parsed["summary"] as? String
        else {
            throw NSError(domain: "GeminiVision", code: -2, userInfo: [NSLocalizedDescriptionKey: "Parse failed: \(text)"])
        }

        return ComparisonResult(accuracyPercent: accuracy, feedback: feedback, overallSummary: summary)
    }
}
