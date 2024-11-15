import Foundation

enum OpenAITTSError: LocalizedError {
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

// OpenAI TTS implementation
actor OpenAITTSService: VoiceService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/audio/speech"
    
    init(apiKey: String = Secrets.openaiAPIKey) {
        self.apiKey = apiKey
    }
    
    func synthesizeSpeech(text: String) async throws -> Data {
        guard let url = URL(string: baseURL) else {
            throw OpenAITTSError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let payload: [String: Any] = [
            "model": "tts-1",
            "input": text,
            "voice": "alloy", // Options: alloy, echo, fable, onyx, nova, shimmer
            "response_format": "mp3",
            "speed": 1.0
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAITTSError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJson["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw OpenAITTSError.apiError(message)
            }
            throw OpenAITTSError.apiError("Unknown error occurred")
        }
        
        return data
    }
}
