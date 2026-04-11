//
//  GalleryView.swift
//  DanceApp(iPhone)
//
//  Created by Prathithi Nellaiappan on 4/11/26.
//

import SwiftUI
import AVKit

struct GalleryVideo: Identifiable {
    let id = UUID()
    let title: String
    let fileName: String
    let fileExtension: String
    
    var player: AVPlayer {
        if let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) {
            return AVPlayer(url: url)
        }
        return AVPlayer()
    }
}

struct GalleryView: View {
    
    // MARK: - Hard coded videos (replace fileName with your actual file names)
    let videos: [GalleryVideo] = [
        GalleryVideo(title: "Anjali Matthews, April 11, 2026: Bhangra",   fileName: "bhangra_anjali",  fileExtension: "mp4"),
        GalleryVideo(title: "Savvy Dusaad, April 8, 2026: Hip Hop",       fileName: "hiphop_savvy",    fileExtension: "mp4"),
        GalleryVideo(title: "Savvy Dusaad, April 6, 2026: Kutthu",        fileName: "kutthu_savvy",    fileExtension: "mp4"),
        GalleryVideo(title: "Savvy Dusaad, April 5, 2026: Kutthu Pt 2",        fileName: "kathak_anjali",    fileExtension: "mp4"),
        GalleryVideo(title: "Savvy Dusaad, April 1, 2026: Contemp",        fileName: "contemp_anjali",    fileExtension: "mp4"),
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(videos) { video in
                    GalleryVideoRow(video: video)
                    
                    if video.id != videos.last?.id {
                        Divider()
                            .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 32)
        }
        .background(Color(hex: "F2F2F7"))
        .navigationTitle("Gallery")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct GalleryVideoRow: View {
    let video: GalleryVideo
    @State private var player: AVPlayer
    @State private var isFullscreen = false
    
    init(video: GalleryVideo) {
        self.video = video
        _player = State(initialValue: video.player)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(video.title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
            
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 2)
                
                VideoPlayer(player: player)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .frame(height: 220)
                    .onAppear { player.pause() }
                
                // Fullscreen button
                Button(action: { isFullscreen = true }) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .padding(7)
                        .background(Color.black.opacity(0.45))
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                }
                .padding(10)
            }
            .frame(height: 220)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            .fullScreenCover(isPresented: $isFullscreen) {
                ZStack(alignment: .topTrailing) {
                    Color.black.ignoresSafeArea()
                    VideoPlayer(player: player)
                        .ignoresSafeArea()
                    Button(action: { isFullscreen = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        GalleryView()
    }
}
