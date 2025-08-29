//
//  YT_DownloaderApp.swift
//  YT-Downloader
//
//  Created by cipher-shad0w on 27/08/2025.
//

import SwiftUI
import Combine
import Combine

@main
struct YT_DownloaderApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(appState)
        } label: {
            Image(systemName: "tray.and.arrow.down.fill")
                .resizable()
                .frame(width: 22, height: 22)
        }
        .menuBarExtraStyle(.window)
    }
}

class AppState: ObservableObject {
    @Published var isDownloading = false
    @Published var downloadStatus = ""
    @Published var downloadProgress = 0
    @Published var errorMessage = ""
    @Published var currentVideoURL: String = ""
    @Published var isProcessingVideo = false
    @Published var isDownloadCompleted = false
    @Published var hasError = false

    // Video information
    @Published var videoTitle = ""
    @Published var videoDuration = 0
    @Published var videoSize = 0
    @Published var videoThumbnailUrl = ""
    @Published var videoResolution = ""
    @Published var isVideoInfoLoaded = false
    
    private let youtubeDownloader = YouTubeDownloader()
    
    init() {
        // Bind YouTubeDownloader properties to AppState
        youtubeDownloader.$isDownloading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isDownloading in
                let wasDownloading = self?.isDownloading ?? false
                self?.isDownloading = isDownloading
                
                // Check if download just finished
                if wasDownloading && !isDownloading && self?.downloadProgress == 100 {
                    self?.isDownloadCompleted = true
                }
            }
            .store(in: &cancellables)
        
        youtubeDownloader.$downloadStatus
            .receive(on: DispatchQueue.main)
            .assign(to: &$downloadStatus)
        
        youtubeDownloader.$downloadProgress
            .receive(on: DispatchQueue.main)
            .assign(to: &$downloadProgress)
        
        youtubeDownloader.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.errorMessage = errorMessage
                self?.hasError = !errorMessage.isEmpty
            }
            .store(in: &cancellables)
        
        youtubeDownloader.$videoTitle
            .receive(on: DispatchQueue.main)
            .assign(to: &$videoTitle)
        
        youtubeDownloader.$videoDuration
            .receive(on: DispatchQueue.main)
            .assign(to: &$videoDuration)
        
        youtubeDownloader.$videoSize
            .receive(on: DispatchQueue.main)
            .assign(to: &$videoSize)
        
        youtubeDownloader.$videoThumbnailUrl
            .receive(on: DispatchQueue.main)
            .assign(to: &$videoThumbnailUrl)
        
        youtubeDownloader.$videoResolution
            .receive(on: DispatchQueue.main)
            .assign(to: &$videoResolution)
        
        youtubeDownloader.$isVideoInfoLoaded
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoaded in
                self?.isVideoInfoLoaded = isLoaded
                // Auto-start download when video info is loaded
                if isLoaded && self?.isProcessingVideo == true {
                    self?.startDownload()
                }
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    func startVideoProcess(from url: String) {
        currentVideoURL = url
        isProcessingVideo = true
        isDownloadCompleted = false
        youtubeDownloader.setVideoURL(url)
    }
    
    func startDownload() {
        youtubeDownloader.download()
    }
    
    func cancelDownload() {
        youtubeDownloader.cancelDownload()
        reset() // Reset everything to return to the start screen
    }
    
    func reset() {
        youtubeDownloader.reset()
        currentVideoURL = ""
        isProcessingVideo = false
        isDownloadCompleted = false
        hasError = false
        errorMessage = ""
        downloadStatus = ""
        downloadProgress = 0
        
        // Reset video information
        videoTitle = ""
        videoDuration = 0
        videoSize = 0
        videoThumbnailUrl = ""
        videoResolution = ""
        isVideoInfoLoaded = false
        isDownloading = false
    }
}
