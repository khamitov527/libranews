import Foundation

class NewsService: ObservableObject {
    @Published var articles: [Article] = []
    @Published var availableSources: [NewsSource] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var selectedTopics: Set<Topic> = []
    @Published var selectedSource: NewsSource?
    
    private let apiKey = Secrets.newsAPIKey
    
    var filteredSources: [NewsSource] {
        guard !selectedTopics.isEmpty else { return [] }
        return availableSources.filter { source in
            selectedTopics.contains { topic in
                source.category == topic.category
            }
        }
    }
    
    func fetchSources() {
        isLoading = true
        error = nil
        
        let urlString = "https://newsapi.org/v2/top-headlines/sources?language=en&apiKey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            isLoading = false
            error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = error
                    return
                }
                
                guard let data = data else {
                    self?.error = NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(SourcesResponse.self, from: data)
                    self?.availableSources = response.sources
                } catch {
                    self?.error = error
                }
            }
        }.resume()
    }
    
    func fetchNews(sourceId: String) {
        isLoading = true
        error = nil
        
        let urlString = "https://newsapi.org/v2/top-headlines?sources=\(sourceId)&apiKey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            isLoading = false
            error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = error
                    return
                }
                
                guard let data = data else {
                    self?.error = NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(NewsAPIResponse.self, from: data)
                    self?.articles = response.articles
                } catch {
                    self?.error = error
                }
            }
        }.resume()
    }
}
