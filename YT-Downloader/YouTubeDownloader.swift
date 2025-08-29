//
//  YouTubeDownloader.swift
//  YT-Downloader
//
//  Created by cipher-shad0w on 27/08/2025.
//

import Foundation
import Combine

class YouTubeDownloader: ObservableObject {
    @Published var isDownloading: Bool = false
    @Published var downloadProgress: Int = 0
    @Published var downloadStatus: String = ""
    @Published var errorMessage: String = ""

    // video info
    @Published var videoTitle: String = ""
    @Published var videoDuration: Int = 0
    @Published var videoSize: Int = 0 // in MB
    @Published var videoUrl: String = "" {
        didSet {
            if !videoUrl.isEmpty && videoUrl != oldValue {
                fetchVideoInfo()
            }
        }
    }
    @Published var videoThumbnailUrl: String = ""
    @Published var videoResolution: String = ""
    @Published var isVideoInfoLoaded: Bool = false

    private var downloadProcess: Process?
    private let fileManager: FileManager = FileManager.default
    private let ytDlpPath: String = "/opt/homebrew/bin/yt-dlp"
    
    // Download folder path
    private var downloadFolder: String {
        let homeDirectory = fileManager.homeDirectoryForCurrentUser
        return homeDirectory.appendingPathComponent("Downloads").path
    }
    
    init() {
        checkYtDlpInstallation()
    }
    
    // MARK: - Public Methods
    
    /// Set the video URL and automatically fetch video information
    func setVideoURL(_ url: String) {
        DispatchQueue.main.async {
            self.videoUrl = url
        }
    }
    
    /// Start the download process
    func download() {
        guard !videoUrl.isEmpty else {
            setError("No video URL provided")
            return
        }
        
        guard isVideoInfoLoaded else {
            setError("Video information not loaded. Please wait for the video info to be fetched.")
            return
        }
        
        guard !isDownloading else {
            setError("Download already in progress")
            return
        }
        
        startDownload()
    }
    
    // MARK: - Private Methods
    
    private func checkYtDlpInstallation() {
        guard fileManager.fileExists(atPath: ytDlpPath) else {
            setError("yt-dlp not found at \(ytDlpPath). Please install it using 'brew install yt-dlp'")
            return
        }
    }
    
    private func fetchVideoInfo() {
        DispatchQueue.main.async {
            self.isVideoInfoLoaded = false
            self.downloadStatus = "Fetching video information..."
            self.errorMessage = ""
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: ytDlpPath)
        process.arguments = [
            "--dump-json",
            "--no-playlist",
            "--quiet",  // Reduce verbose output
            videoUrl
        ]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        do {
            try process.run()
            
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            
            let output = String(data: outputData, encoding: .utf8) ?? ""
            let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
            
            process.waitUntilExit()
            
            if process.terminationStatus == 0 {
                parseVideoInfo(from: output)
            } else {
                DispatchQueue.main.async {
                    let errorMessage = errorOutput.isEmpty ? "Unknown error occurred" : errorOutput
                    self.setError("Failed to fetch video information: \(errorMessage)")
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.setError("Failed to run yt-dlp: \(error.localizedDescription)")
            }
        }
    }
    
    private func parseVideoInfo(from jsonString: String) {
        // Debug: Print the raw output to see what we're getting
        print("Raw yt-dlp output: \(jsonString.prefix(500))...")
        
        // Clean up the JSON string - remove any non-JSON content
        let lines = jsonString.components(separatedBy: .newlines)
        var jsonLine = ""
        
        // Find the line that looks like JSON (starts with {)
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedLine.hasPrefix("{") && trimmedLine.hasSuffix("}") {
                jsonLine = trimmedLine
                break
            }
        }
        
        guard !jsonLine.isEmpty else {
            setError("No valid JSON found in yt-dlp output")
            return
        }
        
        guard let data = jsonLine.data(using: .utf8) else {
            setError("Failed to convert JSON string to data")
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    self.videoTitle = json["title"] as? String ?? "Unknown Title"
                    self.videoDuration = json["duration"] as? Int ?? 0
                    self.videoThumbnailUrl = json["thumbnail"] as? String ?? ""
                    
                    // Get best format info
                    if let formats = json["formats"] as? [[String: Any]],
                       let bestFormat = formats.last {
                        self.videoResolution = bestFormat["resolution"] as? String ?? "Unknown"
                        if let filesize = bestFormat["filesize"] as? Int {
                            self.videoSize = filesize / (1024 * 1024) // Convert to MB
                        }
                    }
                    
                    self.isVideoInfoLoaded = true
                    self.downloadStatus = "Video information loaded successfully"
                }
            } else {
                setError("Invalid JSON format received from yt-dlp")
            }
        } catch {
            setError("JSON parsing error: \(error.localizedDescription)")
        }
    }
    
    private func startDownload() {
        DispatchQueue.main.async {
            self.isDownloading = true
            self.downloadProgress = 0
            self.downloadStatus = "Starting download..."
            self.errorMessage = ""
        }
        
        downloadProcess = Process()
        downloadProcess?.executableURL = URL(fileURLWithPath: ytDlpPath)
        downloadProcess?.arguments = [
            "--output", "\(downloadFolder)/%(title)s.%(ext)s",
            "--format", "best",
            "--progress",
            "--no-playlist",
            videoUrl
        ]
        
        let pipe = Pipe()
        downloadProcess?.standardOutput = pipe
        downloadProcess?.standardError = pipe
        
        // Read output in real-time to track progress
        pipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if !data.isEmpty {
                let output = String(data: data, encoding: .utf8) ?? ""
                self.parseDownloadProgress(from: output)
            }
        }
        
        do {
            try downloadProcess?.run()
            
            DispatchQueue.global(qos: .background).async {
                self.downloadProcess?.waitUntilExit()
                
                DispatchQueue.main.async {
                    if self.downloadProcess?.terminationStatus == 0 {
                        self.downloadProgress = 100
                        self.downloadStatus = "Download completed successfully!"
                    } else {
                        self.setError("Download failed")
                    }
                    self.isDownloading = false
                    self.downloadProcess = nil
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.setError("Failed to start download: \(error.localizedDescription)")
                self.isDownloading = false
            }
        }
    }
    
    private func parseDownloadProgress(from output: String) {
        // Parse yt-dlp progress output
        let lines = output.components(separatedBy: .newlines)
        
        for line in lines {
            if line.contains("%") {
                // Extract percentage from progress line
                let components = line.components(separatedBy: .whitespaces)
                for component in components {
                    if component.hasSuffix("%") {
                        let percentageString = String(component.dropLast())
                        if let percentage = Double(percentageString) {
                            DispatchQueue.main.async {
                                self.downloadProgress = Int(percentage)
                                self.downloadStatus = "Downloading... \(Int(percentage))%"
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func setError(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.downloadStatus = ""
        }
    }
    
    // MARK: - Public Utility Methods
    
    /// Cancel current download
    func cancelDownload() {
        downloadProcess?.terminate()
        DispatchQueue.main.async {
            self.isDownloading = false
            self.downloadStatus = "Download cancelled"
            self.downloadProcess = nil
        }
    }
    
    /// Reset all video information
    func reset() {
        DispatchQueue.main.async {
            self.videoUrl = ""
            self.videoTitle = ""
            self.videoDuration = 0
            self.videoSize = 0
            self.videoThumbnailUrl = ""
            self.videoResolution = ""
            self.isVideoInfoLoaded = false
            self.downloadProgress = 0
            self.downloadStatus = ""
            self.errorMessage = ""
            self.isDownloading = false
        }
    }
}

enum DownloadError: LocalizedError {
    case ytDlpNotFound
    case invalidVideoInfo
    case downloadFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .ytDlpNotFound:
            return "yt-dlp is not installed. Please install it using 'brew install yt-dlp'"
        case .invalidVideoInfo:
            return "Could not retrieve video information"
        case .downloadFailed(let message):
            return "Download failed: \(message)"
        }
    }
}
