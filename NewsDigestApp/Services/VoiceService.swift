
// MARK: - NOT USED ANYMORE (KEEPING FOR POTENTIAL FUTURE USE)

import Foundation
import AVFoundation

// Protocol for voice services
protocol VoiceService {
    func synthesizeSpeech(text: String) async throws -> Data
}

enum ElevenLabsError: LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(String)
    case audioDecodingError
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from API"
        case .apiError(let message):
            return "API Error: \(message)"
        case .audioDecodingError:
            return "Failed to decode audio data"
        case .networkError(let error):
            return "Network Error: \(error.localizedDescription)"
        }
    }
}

// ElevenLabs implementation
actor ElevenLabsService: VoiceService {
    private let apiKey: String
    private let voiceId = "D38z5RcWu1voky8WS1ja" // Chris voice ID
    private let baseURL = "https://api.elevenlabs.io/v1"
    private var audioPlayer: AVAudioPlayer?
    
    init(apiKey: String = Secrets.elevenLabsAPIKey) {
        self.apiKey = apiKey
    }
    
    func synthesizeSpeech(text: String) async throws -> Data {
        let endpoint = "\(baseURL)/text-to-speech/\(voiceId)"
        guard let url = URL(string: endpoint) else {
            throw ElevenLabsError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        
        let payload: [String: Any] = [
            "text": text,
            "model_id": "eleven_monolingual_v1",
            "voice_settings": [
                "stability": 0.5,
                "similarity_boost": 0.75
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ElevenLabsError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = errorJson["detail"] as? String {
                throw ElevenLabsError.apiError(errorMessage)
            }
            throw ElevenLabsError.apiError("Unknown error occurred")
        }
        
        return data
    }
}

// iOS Voice implementation
actor IOSVoiceService: VoiceService {
    private let synthesizer = AVSpeechSynthesizer()
    
    func synthesizeSpeech(text: String) async throws -> Data {
        // Create an utterance
        let utterance = AVSpeechUtterance(string: text)
        
        // Configure voice and settings
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        // Use a good quality voice
        if let voice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = voice
        }
        
        // Create a pipe to capture audio data
        let pipe = Pipe()
        let audioEngine = AVAudioEngine()
        let mixer = audioEngine.mainMixerNode
        
        // Convert speech to audio data
        return try await withCheckedThrowingContinuation { continuation in
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(true)
                
                // Create and configure audio format
                let format = mixer.outputFormat(forBus: 0)
                let settings: [String: Any] = [
                    AVFormatIDKey: kAudioFormatLinearPCM,
                    AVSampleRateKey: format.sampleRate,
                    AVNumberOfChannelsKey: 1,
                    AVLinearPCMBitDepthKey: 16,
                    AVLinearPCMIsFloatKey: false
                ]
                
                // Create audio file
                let audioFile = try AVAudioFile(
                    forWriting: FileManager.default.temporaryDirectory.appendingPathComponent("speech.wav"),
                    settings: settings
                )
                
                // Start audio engine
                try audioEngine.start()
                
                // Speak the text
                synthesizer.speak(utterance)
                
                // Convert to audio data
                let audioData = try Data(contentsOf: audioFile.url)
                continuation.resume(returning: audioData)
                
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
