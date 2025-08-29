//
//  DefaultView.swift
//  YT-Downloader
//
//  Created by workstation on 28/08/2025.
//

import SwiftUI

struct DefaultView: View {
    @ObservedObject var appState: AppState
    
    @State private var urlInput = ""
    
    var body: some View {
        VStack(spacing: 16) {
            // URL Input Section
            HStack {
                TextField("Enter YouTube URL", text: $urlInput)
                    .disabled(appState.isDownloading)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    fetchVideoInfo()
                }) {
                    Image(systemName: "magnifyingglass")
                }
                .disabled(urlInput.isEmpty || appState.isDownloading)
                .help("Fetch video information")
            }
            
            // Video Information Section
            if appState.isVideoInfoLoaded {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Title:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(appState.videoTitle)
                            .font(.caption)
                            .lineLimit(2)
                        Spacer()
                    }
                    
                    HStack {
                        Text("Duration:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatDuration(appState.videoDuration))
                            .font(.caption)
                        
                        Spacer()
                        
                        Text("Size:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(appState.videoSize) MB")
                            .font(.caption)
                        
                        Spacer()
                        
                        Text("Resolution:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(appState.videoResolution)
                            .font(.caption)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // Download Button
                Button(action: {
                    downloadVideo()
                }) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                        Text("Download")
                    }
                }
                .disabled(appState.isDownloading)
                .buttonStyle(.borderedProminent)
            }
            
            // Status and Error Messages
            if !appState.downloadStatus.isEmpty {
                Text(appState.downloadStatus)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            if !appState.errorMessage.isEmpty {
                Text(appState.errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
        }
        .padding()
    }
    
    private func fetchVideoInfo() {
        guard !urlInput.isEmpty else { return }
        
        // Lassen wir yt-dlp die URL-Validierung übernehmen und starten den Video-Prozess
        appState.startVideoProcess(from: urlInput.trimmingCharacters(in: .whitespacesAndNewlines))
        urlInput = ""  // Clear input field
    }
    
    private func downloadVideo() {
        appState.startDownload()
    }
    
    private func isValidYouTubeURL(_ url: String) -> Bool {
        let youtubePatterns = [
            "youtube.com/watch",
            "youtu.be/",
            "youtube.com/embed/",
            "youtube.com/v/",
            "m.youtube.com/watch",
            "www.youtube.com/watch"
        ]
        
        let lowercasedURL = url.lowercased()
        
        // Check if it contains any of the YouTube patterns
        let containsPattern = youtubePatterns.contains { lowercasedURL.contains($0) }
        
        // Additional check for proper URL format
        let isProperURL = lowercasedURL.hasPrefix("http://") || lowercasedURL.hasPrefix("https://") || !lowercasedURL.contains("://")
        
        return containsPattern && isProperURL
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
}
