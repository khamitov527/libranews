import Foundation

class NewsService: ObservableObject {
    @Published var articles: [Article] = []
    @Published var availableSources: [NewsSource] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var selectedTopics: Set<Topic> = []
    @Published var selectedSources: Set<NewsSource> = []
    @Published var selectedDuration: DigestDuration? = nil
    @Published var selectedTimeRange: TimeRange = TimeRange.available[0]
    
    private let apiKey = Secrets.newsAPIKey
    
    func selectAllSourcesForCurrentTopics() {
        selectedSources = Set(filteredSources)
        fetchNewsForSelectedSources()
    }
    
    func clearSelectedSources() {
        selectedSources.removeAll()
        articles.removeAll()
    }
    
    var hasAllSourcesSelected: Bool {
        !filteredSources.isEmpty && Set(filteredSources) == selectedSources
    }
    
    func clearArticles() {
        articles = []
    }
    
    var filteredSources: [NewsSource] {
        guard !selectedTopics.isEmpty else { return [] }
        return availableSources.filter { source in
            selectedTopics.contains { topic in
                source.category == topic.category
            }
        }
    }
    
    func toggleSourceSelection(_ source: NewsSource) {
        if selectedSources.contains(source) {
            selectedSources.remove(source)
        } else {
            selectedSources.insert(source)
        }
        fetchNewsForSelectedSources()
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
    
    func fetchNewsForSelectedSources() {
        guard !selectedSources.isEmpty else {
            articles = []
            return
        }
        
        isLoading = true
        error = nil
        
        let sourceIds = selectedSources.map { $0.id }.joined(separator: ",")
        let pageSize = selectedDuration?.articleRange.upperBound ?? 5
        
        // Calculate the from date based on selected time range
        let fromDate: Date
        if selectedTimeRange.days > 0 {
            fromDate = Calendar.current.date(byAdding: .day, value: -selectedTimeRange.days, to: Date()) ?? Date()
        } else {
            // For "Latest News", use last 24 hours
            fromDate = Calendar.current.date(byAdding: .hour, value: -24, to: Date()) ?? Date()
        }
        
        // Format the date for the API
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fromDateString = dateFormatter.string(from: fromDate)
        
        let urlString = "https://newsapi.org/v2/top-headlines?sources=\(sourceIds)&pageSize=\(pageSize)&from=\(fromDateString)&apiKey=\(apiKey)"
        
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
