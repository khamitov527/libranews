# News Digest App

A SwiftUI app that creates personalized audio news digests from selected sources using NewsAPI.

## Features

- Source selection from NewsAPI providers
- Text-to-speech news digest generation
- Audio playback controls
- Clean, modern SwiftUI interface

## Requirements

- iOS 15.0+
- Xcode 13.0+
- NewsAPI Key

## Setup

1. Clone the repository
```bash
git clone https://github.com/YourUsername/news-digest-app.git
```

2. Add your NewsAPI key
- Open `NewsService.swift`
- Replace the empty `apiKey` string with your NewsAPI key

3. Build and run the project in Xcode

## Configuration

The app uses NewsAPI.org for fetching news content. To get an API key:
1. Visit [NewsAPI.org](https://newsapi.org)
2. Sign up for a free account
3. Copy your API key

## Architecture

The app follows a clean architecture pattern with:
- Models for data structures
- Services for business logic
- SwiftUI views for UI components

## License

This project is licensed under the MIT License - see the LICENSE file for details
