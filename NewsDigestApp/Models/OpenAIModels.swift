import Foundation

enum OpenAIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(String)
    case noChoicesReturned
    case emptyContent
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from API"
        case .apiError(let message):
            return "API Error: \(message)"
        case .noChoicesReturned:
            return "No choices returned from API"
        case .emptyContent:
            return "Empty content returned"
        case .networkError(let error):
            return "Network Error: \(error.localizedDescription)"
        }
    }
}

struct OpenAIResponse: Codable {
    let choices: [Choice]
    let usage: Usage?
    let error: APIError?
    
    struct Choice: Codable {
        let message: Message
        let finishReason: String?
        
        enum CodingKeys: String, CodingKey {
            case message
            case finishReason = "finish_reason"
        }
    }
    
    struct Message: Codable {
        let role: String
        let content: String
    }
    
    struct Usage: Codable {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int
        
        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }
    
    struct APIError: Codable {
        let message: String
        let type: String?
        let param: String?
        let code: String?
    }
}
