import SwiftUI
import PhotosUI
import AVKit

struct UploadView: View {
    
    @State private var referencePlayer = AVPlayer(url: Bundle.main.url(forResource: "reference_video", withExtension: "mp4") ?? URL(fileURLWithPath: ""))
    @State private var isFullscreen = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var uploadedVideoURL: URL? = nil
    @State private var isLoadingVideo = false
    @State private var navigateToAnalysis = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - Instructor Row
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color(red: 0.25, green: 0.35, blue: 0.75))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20))
                            )
                        Text("Savvy Dusaad shared:")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    // MARK: - Reference Video Player
                    ZStack(alignment: .bottomTrailing) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 2)
                        VideoPlayer(player: referencePlayer)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .frame(height: 280)
                            .onAppear { referencePlayer.pause() }
                        Button(action: { isFullscreen = true }) {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.45))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .padding(10)
                    }
                    .frame(height: 280)
                    .padding(.horizontal, 20)
                    .fullScreenCover(isPresented: $isFullscreen) {
                        ZStack(alignment: .topTrailing) {
                            Color.black.ignoresSafeArea()
                            VideoPlayer(player: referencePlayer).ignoresSafeArea()
                            Button(action: { isFullscreen = false }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                    .padding()
                            }
                        }
                    }

                    // MARK: - Caption
                    Text("Savvy: Hey guys, this is the choreography we will be working on for this week. Record the first song in the set, make sure to focus on facial expressions and the angles of your arms.")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)

                    // MARK: - Now You Try
                    Text("Now you Try!")
                        .font(.system(size: 18, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    // MARK: - Upload Button
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .videos,
                        photoLibrary: .shared()
                    ) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "E5E5EA"))
                                .frame(height: 100)

                            if isLoadingVideo {
                                ProgressView()
                                    .scaleEffect(1.2)
                            } else if uploadedVideoURL != nil {
                                VStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 36))
                                        .foregroundColor(Color(red: 0.45, green: 0.25, blue: 0.85))
                                    Text("Video Selected! Tap to change")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(red: 0.45, green: 0.25, blue: 0.85))
                                }
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 36, weight: .light))
                                        .foregroundColor(Color(hex: "8E8E93"))
                                    Text("Select your video")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "8E8E93"))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .onChange(of: selectedItem) {
                        Task {
                            guard let newItem = selectedItem else { return }
                            await MainActor.run { isLoadingVideo = true; uploadedVideoURL = nil }

                            // Load video as a movie file transferable
                            if let movie = try? await newItem.loadTransferable(type: VideoTransferable.self) {
                                await MainActor.run {
                                    uploadedVideoURL = movie.url
                                    isLoadingVideo = false
                                }
                            } else {
                                await MainActor.run { isLoadingVideo = false }
                            }
                        }
                    }

                    // MARK: - Analyze Button (shown after video selected)
                    if let videoURL = uploadedVideoURL {
                        NavigationLink(destination: AnalysisLoadingView(dancerVideoURL: videoURL)) {
                            HStack(spacing: 10) {
                                Image(systemName: "wand.and.stars")
                                Text("Analyze My Dance")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(red: 0.45, green: 0.25, blue: 0.85))
                            )
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 32)
                }
            }
            .background(Color(hex: "F2F2F7"))
            .navigationTitle("Choreo Practice")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Video Transferable wrapper
struct VideoTransferable: Transferable {
    let url: URL
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { video in
            SentTransferredFile(video.url)
        } importing: { received in
            // Copy to temp directory so it persists
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString + ".mp4")
            try FileManager.default.copyItem(at: received.file, to: tempURL)
            return VideoTransferable(url: tempURL)
        }
    }
}

#Preview {
    UploadView()
}
