import Foundation

class NewsService: ObservableObject {
    @Published var breakingArticles: [Article] = []
    @Published var trendingArticles: [Article] = []
    @Published var isLoadingBreaking = false
    @Published var isLoadingTrending = false
    @Published var error: Error?
    
    private let apiKey = Secrets.newsAPIKey
    
    func fetchBreakingNews() {
        isLoadingBreaking = true
        error = nil
        
        let urlString = "https://newsapi.org/v2/top-headlines?country=us&pageSize=10&apiKey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            isLoadingBreaking = false
            error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoadingBreaking = false
                
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
                    self?.breakingArticles = response.articles
                } catch {
                    self?.error = error
                }
            }
        }.resume()
    }
    
    func fetchTrendingNews() {
        isLoadingTrending = true
        error = nil
        
        // For trending, we'll use a broader search with sorting by popularity
        let urlString = "https://newsapi.org/v2/everything?language=en&sortBy=popularity&pageSize=10&apiKey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            isLoadingTrending = false
            error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoadingTrending = false
                
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
                    self?.trendingArticles = response.articles
                } catch {
                    self?.error = error
                }
            }
        }.resume()
    }
}
