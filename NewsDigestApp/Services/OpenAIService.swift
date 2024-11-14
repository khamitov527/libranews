import Foundation

class OpenAIService {
    private let apiKey = Secrets.openaiAPIKey
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    func generateNarration(for articles: [Article], duration: DigestDuration?) async throws -> String {
        print("🚀 Starting narration generation")
        
        guard !apiKey.isEmpty && apiKey != "YOUR-OPENAI-API-KEY" else {
            print("❌ API Key not set")
            throw OpenAIError.apiError("API Key not configured")
        }
        
        let prompt = createPrompt(for: articles, duration: duration)
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
                    Keep the total length suitable for the specified duration.
                    Use clear transitions and maintain an engaging pace.
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
    
    private func createPrompt(for articles: [Article], duration: DigestDuration?) -> String {
        if let duration = duration {
            var prompt = """
            Create a podcast-style news digest for these articles that will take approximately \(duration.minutes) minutes to read aloud.
            Aim for \(duration.timePerArticle.lowerBound)-\(duration.timePerArticle.upperBound) seconds per article.
            Use clear transitions between stories and maintain an engaging, conversational tone.
            
            Key requirements:
            - Total duration: \(duration.minutes) minutes
            - Articles: \(articles.count)
            - Pacing: Natural, broadcast-style delivery
            - Include brief intro and outro
            
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
        } else {
            // Default prompt for when no duration is specified
            var prompt = """
            Create a podcast-style news digest for these articles.
            Use clear transitions between stories and maintain an engaging pace.
            Keep the total length suitable for a 5-minute digest.
            Include a brief intro and outro.
            
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
}
