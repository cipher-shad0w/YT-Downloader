# YT Downloader 📥

<div align="center">
  <img src="https://img.shields.io/badge/Platform-macOS-blue?style=for-the-badge&logo=apple" alt="Platform: macOS">
  <img src="https://img.shields.io/badge/Swift-5.9-orange?style=for-the-badge&logo=swift" alt="Swift 5.9">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License: MIT">
  <img src="https://img.shields.io/badge/UI-SwiftUI-purple?style=for-the-badge&logo=swift" alt="SwiftUI">
</div>

<div align="center">
  <h3>A sleek, modern YouTube downloader that lives entirely in your macOS menu bar</h3>
  <p><em>Built with SwiftUI • Powered by yt-dlp • Menu bar only design</em></p>
</div>

---

## ✨ Features

- **🎯 Menu Bar Only**: Lightweight app that lives entirely in your menu bar - no dock icon, no main window
- **🔍 Smart Video Detection**: Automatically fetches video information including title, duration, and thumbnail
- **📊 Real-time Progress**: Live download progress with detailed status updates
- **🎨 Modern UI**: Beautiful glass-morphism design with smooth animations in a compact menu bar window
- **⚡ Fast Downloads**: Powered by yt-dlp for reliable, high-speed downloads
- **📁 Organized Storage**: Downloads automatically saved to your Downloads folder
- **🚫 Error Handling**: Comprehensive error handling with user-friendly messages
- **🔄 State Management**: Robust state management for seamless user experience
- **💾 Minimal Footprint**: Zero interference with your desktop workflow

## 🎬 Demo

<img src="assets/app-demo.gif" alt="Demo" width="400"/>

## 🛠 Installation

### Option 1: Homebrew (Recommended)

```bash
# Install via Homebrew
brew install --cask yt-downloader

# Launch the app
open -a "YT Downloader"
```

The app will automatically appear in your menu bar after launch.

## 🚀 Usage

1. **Launch the app**: After building, the YT Downloader icon (⬇️) appears in your menu bar (top-right corner)
2. **Access the interface**: Click the menu bar icon to open the compact download window
3. **Paste URL**: Enter any YouTube video URL in the input field
4. **Preview**: The app automatically fetches and displays video information (title, duration, thumbnail)
5. **Download**: Click the download button to start downloading
6. **Monitor Progress**: Watch real-time download progress in the menu bar window
7. **Access Files**: Downloads are automatically saved to your Downloads folder
8. **Close**: Click outside the window or press Escape to close the interface

> **Note**: The app runs exclusively in the menu bar - there's no main application window or dock icon. This keeps your workspace clean while providing instant access to download functionality.

### Supported Platforms

- YouTube
- YouTube Music
- And many more platforms supported by yt-dlp

### Key Components

- **AppState**: Centralized state management using `@StateObject`
- **YouTubeDownloader**: Core business logic with `@Published` properties
- **Modular Views**: Separate views for different app states (Default, Progress, Finish, Error)
- **MenuBarExtra**: Native macOS menu bar integration (no dock icon, no main window)

## 🔧 Technical Details

### Technologies Used

- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for state management
- **Foundation**: Core system integration
- **yt-dlp**: Robust YouTube downloading backend

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style

- Follow Swift naming conventions
- Use SwiftUI best practices
- Add comments for complex logic
- Ensure proper error handling

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <p>⭐ If you found this project helpful, please give it a star!</p>
  <p>Made with ❤️ by cipher-shad0w</p>
</div>