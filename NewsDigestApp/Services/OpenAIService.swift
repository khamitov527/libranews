import Foundation

class OpenAIService {
    private let apiKey = Secrets.openaiAPIKey
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    private let systemPrompt = """
    You are a skilled podcast host creating engaging news digests. Your task is to:
    - Create natural, conversational narratives
    - Keep segments to 20 seconds when read at natural pace
    - Focus on key points and newsworthy elements
    - Add brief context when necessary
    - Use natural transitions and appropriate pauses
    - Maintain engaging but clear pacing
    - Keep to the point and do not include unnecesary things
    - Do not include any greetings, intro, outro, or anything unrelated to story
    """
    
    func generateNarration(for article: Article) async throws -> String {
        print("🚀 Starting narration generation for article: \(article.title)")
        
        guard !apiKey.isEmpty && apiKey != "YOUR-OPENAI-API-KEY" else {
            throw OpenAIError.apiError("API Key not configured")
        }
        
        guard let url = URL(string: endpoint) else {
            throw OpenAIError.invalidURL
        }
//        
//        return "blah blah blaaaaah"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let userPrompt = """
        Create a 20-second news segment for this article:
        
        Title: \(article.title)
        Summary: \(article.description ?? "")
        """
        
        let payload: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "temperature": 0.7,
            "max_tokens": 500,
            "presence_penalty": 0.6,
            "frequency_penalty": 0.3
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJson["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw OpenAIError.apiError(message)
            }
            throw OpenAIError.apiError("Unknown error occurred")
        }
        
        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        guard let choice = openAIResponse.choices.first,
              !choice.message.content.isEmpty else {
            throw OpenAIError.noChoicesReturned
        }
        
        return choice.message.content
    }
}
