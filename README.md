# libra news

A SwiftUI app that creates personalized audio news digests from selected sources and topics using NewsAPI and OpenAI TTS.

## Features

- Topic and source selection from NewsAPI providers
- Text-to-speech news digest generation
- Audio playback 

## Requirements

- iOS 15.0+
- Xcode 13.0+
- NewsAPI Key
- OpenAI API Key
- ElevenLabs API Key (Optional)

## Setup

1. Clone the repository
```bash
git clone https://github.com/khamitov527/libranews.git
```

2. Add your api keys
- Create `Secrets.swift`
```
enum Secrets {
    static let newsAPIKey = "API-KEY-GOES-HERE"
    static let openaiAPIKey = "API-KEY-GOES-HERE"
    static let elevenLabsAPIKey = "API-KEY-GOES-HERE"
}

```

## License

This project is licensed under the MIT License - see the LICENSE file for details
