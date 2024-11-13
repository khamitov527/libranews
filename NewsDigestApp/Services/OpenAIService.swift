import Foundation

class OpenAIService {
    private let apiKey = Secrets.openaiAPIKey
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    func generateNarration(for articles: [Article]) async throws -> String {
        print("🚀 Starting narration generation")
        
        guard !apiKey.isEmpty && apiKey != "YOUR-OPENAI-API-KEY" else {
            print("❌ API Key not set")
            throw OpenAIError.apiError("API Key not configured")
        }
        
        let prompt = createPrompt(for: articles)
        print("📝 Generated prompt:\n\(prompt)")
        
        guard let url = URL(string: endpoint) else {
            print("❌ Invalid URL")
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
                    Create a natural, conversational narrative connecting these stories.
                    Keep the total length suitable for a 5-minute digest.
                    """
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "temperature": 0.7,
            "max_tokens": 1000
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload)
            request.httpBody = jsonData
            print("📤 Sending request to OpenAI")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw OpenAIError.invalidResponse
            }
            
            print("🔍 HTTP Status Code: \(httpResponse.statusCode)")
            print("📥 Raw Response: \(String(data: data, encoding: .utf8) ?? "Unable to read response")")
            
            if httpResponse.statusCode != 200 {
                let errorResponse = try? JSONDecoder().decode(OpenAIResponse.self, from: data)
                if let errorMessage = errorResponse?.error?.message {
                    throw OpenAIError.apiError(errorMessage)
                } else {
                    throw OpenAIError.apiError("Unknown error occurred")
                }
            }
            
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            guard let choice = openAIResponse.choices.first else {
                throw OpenAIError.noChoicesReturned
            }
            
            let content = choice.message.content
            guard !content.isEmpty else {
                throw OpenAIError.emptyContent
            }
            
            print("✅ Successfully generated narration")
            return content
            
        } catch let error as OpenAIError {
            throw error
        } catch {
            throw OpenAIError.networkError(error)
        }
    }
    private func createPrompt(for articles: [Article]) -> String {
        var prompt = """
        Create a podcast-style news digest for these articles.
        Use clear transitions between stories.
        
        """
        
        for (index, article) in articles.enumerated() {
            prompt += "Article \(index + 1):\n"
            prompt += "Title: \(article.title)\n"
            if let description = article.description {
                prompt += "Description: \(description)\n"
            }
            prompt += "\n"
        }
        
        return prompt
    }
}
