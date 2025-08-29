//
//  ProgressView.swift
//  YT-Downloader
//
//  Created by workstation on 29/08/2025.
//

import SwiftUI

struct ProgressView: View {
    @ObservedObject var appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    var body: some View {
        VStack(spacing: 16) {
            // Video title or loading state
            HStack {
                if appState.isVideoInfoLoaded {
                    Text(appState.videoTitle.isEmpty ? "Downloading..." : appState.videoTitle)
                        .font(.headline)
                        .lineLimit(2)
                } else {
                    Text("Loading video information...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }

            // Progress bar and percentage (only show when downloading)
            if appState.isDownloading {
                VStack(spacing: 8) {
                    HStack {
                        SwiftUI.ProgressView(value: Double(appState.downloadProgress) / 100.0)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .frame(height: 8)
                        
                        Text("\(appState.downloadProgress)%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .monospacedDigit()
                            .frame(minWidth: 40, alignment: .trailing)
                    }
                    
                    // Download size progress
                    if appState.videoSize > 0 {
                        HStack {
                            Text("\(Int(Double(appState.downloadProgress) / 100.0 * Double(appState.videoSize)))/\(appState.videoSize) MB")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button("Cancel") {
                                appState.cancelDownload()
                            }
                            .buttonStyle(.borderless)
                            .foregroundColor(.red)
                            .font(.caption)
                        }
                    }
                }
            } else if !appState.isVideoInfoLoaded {
                // Loading indicator for video info
                SwiftUI.ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(0.8)
            }
            
            // Status message - nur für Loading, nicht für Download
            if !appState.downloadStatus.isEmpty && !appState.isDownloading {
                HStack {
                    Text(appState.downloadStatus)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            
            // Error message
            if !appState.errorMessage.isEmpty {
                HStack {
                    Text(appState.errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                    Spacer()
                }
            }
            
            Spacer()
        }
        .padding()
    }
}
