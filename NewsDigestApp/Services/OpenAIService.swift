import Foundation

class OpenAIService {
    private let apiKey = Secrets.openaiAPIKey
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    func generateNarration(for article: Article) async throws -> String {
        print("🚀 Starting narration generation for article: \(article.title)")
        
        guard !apiKey.isEmpty && apiKey != "YOUR-OPENAI-API-KEY" else {
            throw OpenAIError.apiError("API Key not configured")
        }
            
        let prompt = createPrompt(for: article)
        
        guard let url = URL(string: endpoint) else {
            throw OpenAIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let payload: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "system",
                    "content": """
                    You are a skilled podcast host creating an engaging news digest.
                    Create a natural, conversational narrative for this story.
                    Keep the length suitable for 40-second narration.
                    Maintain an engaging pace and natural tone.
                    Focus on the most important aspects of the story.
                    Add brief context when necessary.
                    Use clear transitions and natural pauses.
                    End with a concise conclusion.
                    """
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "temperature": 0.7,
            "max_tokens": 500,
            "presence_penalty": 0.6,  // Encourage more varied content
            "frequency_penalty": 0.3   // Reduce repetition
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
    
    private func createPrompt(for article: Article) -> String {
        """
        Generate a podcast-style narration for this article. Make it engaging and informative,
        suitable for a 40-second audio segment.

        Title: \(article.title)
        Summary: \(article.description ?? "")

        Guidelines:
        - Focus on the key points and most newsworthy elements
        - Add brief but relevant context to help listeners understand the story
        - Use natural, conversational language
        - Include a smooth introduction and brief conclusion
        - Keep the pace engaging but easy to follow
        - Aim for about 40 seconds when read aloud at a natural pace
        """
    }
}
