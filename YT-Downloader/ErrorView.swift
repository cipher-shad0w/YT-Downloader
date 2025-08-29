//
//  ErrorView.swift
//  YT-Downloader
//
//  Created by cipher-shad0w on 29/08/2025.
//

import SwiftUI

struct ErrorView: View {
    @ObservedObject var appState: AppState
    let errorMessage: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Error Icon
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
            
            // Error Title
            Text("An Error Occurred")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Error Message
            Text(errorMessage)
                .font(.caption)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true)
            
            // Restart Button
            Button ("Download Another") {
                restartApplication()
            }
            .buttonStyle(.borderedProminent)
            .font(.caption)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
    }
    
    private func restartApplication() {
        // Reset the app state completely
        appState.reset()
    }
}

#Preview {
    ErrorView(
        appState: AppState(),
        errorMessage: "Example error message: The video could not be downloaded."
    )
}
