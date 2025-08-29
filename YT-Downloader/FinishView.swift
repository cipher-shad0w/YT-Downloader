//
//  FinishView.swift
//  YT-Downloader
//
//  Created by workstation on 29/08/2025.
//

import SwiftUI

struct FinishView: View {
    @ObservedObject var appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Success message with icon
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
                
                Text("Download Completed!")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            // Video information
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Title:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                Text(appState.videoTitle)
                    .font(.caption)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Duration:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatDuration(appState.videoDuration))
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Size:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(appState.videoSize) MB")
                            .font(.caption)
                    }
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Resolution:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(appState.videoResolution)
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Location:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Downloads")
                            .font(.caption)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            Spacer()
            
            // Action buttons - nur Download Another
            Button("Download Another") {
                appState.reset()
            }
            .buttonStyle(.borderedProminent)
            .font(.caption)
        }
        .padding()
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
    
    private func openDownloadsFolder() {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let downloadsURL = homeDirectory.appendingPathComponent("Downloads")
        NSWorkspace.shared.open(downloadsURL)
    }
}

#Preview {
    let appState = AppState()
    appState.videoTitle = "Sample Video Title That Might Be Long"
    appState.videoDuration = 3725 // 1 hour, 2 minutes, 5 seconds
    appState.videoSize = 250
    appState.videoResolution = "1920x1080"
    appState.isDownloadCompleted = true
    
    return FinishView(appState: appState)
}
