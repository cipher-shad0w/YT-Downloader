//
//  ContentView.swift
//  YT-Downloader
//
//  Created by cipher-shad0w on 27/08/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        GlassEffectContainer {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                Text("YT Downloader")
                    .font(.system(size: 12.5))
                    .fontWeight(.semibold)
                    .opacity(0.7)
                    .padding(.top, 8)
                
                Divider()
                
                VStack {
                    if appState.isDownloadCompleted {
                        FinishView(appState: appState)
                    } else if appState.isProcessingVideo {
                        ProgressView(appState: appState)
                    } else {
                        DefaultView(appState: appState)
                    }
                }
                .frame(minHeight: 100)
            }
            .padding()
            .frame(width: appState.isDownloadCompleted ? 350 : 300, 
                   height: appState.isDownloadCompleted ? 250 : 200)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
