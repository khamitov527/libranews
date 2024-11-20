import Foundation

class NewsService: ObservableObject {
    @Published var breakingArticles: [Article] = []
    @Published var trendingArticles: [Article] = []
    @Published var isLoadingBreaking = false
    @Published var isLoadingTrending = false
    @Published var error: Error?
    @Published var topicArticles: [String: [Article]] = [:]
    @Published var isLoadingTopic = false
    
    private let apiKey = Secrets.newsAPIKey
    
    private let dummyArticles = [
        Article(
            source: ArticleSource(name: "The Washington Post"),
            author: "Patrick Svitek, Justine McDaniel, Azi Paybarah",
            title: "Live updates: Trump expected to attend SpaceX launch with Elon Musk in Texas",
            description: "Get the latest news on the transition to the new administration of President-elect Donald Trump and a new Congress.",
            url: "https://www.washingtonpost.com/politics/2024/11/19/trump-administration-transition/",
            urlToImage: "https://www.washingtonpost.com/wp-apps/imrs.php?src=https://arc-anglerfish-washpost-prod-washpost.s3.amazonaws.com/public/N5FRYXCCEPLDUESR32KPEKXB7Y_size-normalized.jpg&w=1440",
            publishedAt: Date(timeIntervalSince1970: 1732062735),
            content: "Dan Osborn, the independent candidate for Senate in Nebraska who ran a surprisingly strong but ultimately unsuccessful race..."
        ),
        Article(
            source: ArticleSource(name: "Reuters"),
            author: "Reuters",
            title: "US envoy in Beirut for talks after Lebanon, Hezbollah approve truce draft",
            description: "The visit indicates progress in US-led diplomacy aimed at ending a conflict which spiralled into all-out war in late September.",
            url: "https://www.reuters.com/world/middle-east/us-envoy-beirut-talks-after-lebanon-hezbollah-approve-truce-draft-2024-11-19/",
            urlToImage: "https://www.reuters.com/resizer/v2/YDLMO67NWBJGDNBW3GI7B6HD6Y.jpg?auth=4666e2b4ea94d213595c824c532c9a96909ceda34035cc60b98cd955c6afdd72&height=1005&width=1920&quality=80&smart=true",
            publishedAt: Date(timeIntervalSince1970: 1732062228),
            content: nil
        ),
        Article(
            source: ArticleSource(name: "The Associated Press"),
            author: "THE ASSOCIATED PRESS",
            title: "Putin lowers the threshold for using his nuclear arsenal after Biden's arms decision for Ukraine",
            description: "President Vladimir Putin formally lowered the threshold for Russia's use of nuclear weapons, following U.S. President Joe Biden's decision to let Ukraine strike targets inside Russian territory.",
            url: "https://apnews.com/article/russia-nuclear-doctrine-putin-91f20e0c9b0f9e5eaa3ed97c35789898",
            urlToImage: "https://dims.apnews.com/dims4/default/ad7e012/2147483647/strip/true/crop/5548x3121+0+289/resize/1440x810!/quality/90/?url=https%3A%2F%2Fassets.apnews.com%2Faf%2Ff7%2Fdb23953e5029be0581325d62610b%2Fdfcaf6d5df7c41a190f3f8950b175a4e",
            publishedAt: Date(timeIntervalSince1970: 1732061400),
            content: "President Vladimir Putin on Tuesday formally lowered the threshold for Russia's use of its nuclear weapons..."
        ),
        Article(
            source: ArticleSource(name: "CNN"),
            author: "Christian Edwards, Kostyantyn Gak, Lauren Kent",
            title: "Ukraine fires US-made longer-range missiles into Russia for the first time, Moscow says",
            description: "Ukraine hit a Russian weapons arsenal with US-made ATACMS missiles that it fired across the border for the first time, according to two US officials.",
            url: "https://www.cnn.com/2024/11/19/europe/ukraine-russia-atacms-biden-strike-intl/index.html",
            urlToImage: "https://media.cnn.com/api/v1/images/stellar/prod/ap24324406682880.jpg?c=16x9&q=w_800,c_fill",
            publishedAt: Date(timeIntervalSince1970: 1732060260),
            content: "Ukraine hit a Russian weapons arsenal with US-made ATACMS missiles..."
        ),
        Article(
            source: ArticleSource(name: "TechCrunch"),
            author: "Aisha Malik",
            title: "Google Lens can now check prices and inventory when shopping in the real world",
            description: "Google announced on Tuesday that it's updating Google Lens to help people when they're shopping in a physical store.",
            url: "https://techcrunch.com/2024/11/19/google-lens-new-feature-makes-it-easier-to-shop-products-in-store/",
            urlToImage: "https://techcrunch.com/wp-content/uploads/2024/10/GettyImages-1337403704.jpg?resize=1200,800",
            publishedAt: Date(timeIntervalSince1970: 1732059600),
            content: "After building out Google Lens to help users shop online more easily, Google is now updating the product..."
        )
    ]
    
    func fetchBreakingNews() {
        // uncomment to test with dummy data
        isLoadingBreaking = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.breakingArticles = Array(self?.dummyArticles.prefix(5) ?? [])
            self?.isLoadingBreaking = false
        }
        return
        //
        
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
                    print(response.articles)
                } catch {
                    self?.error = error
                }
            }
        }.resume()
    }
    
    func fetchTrendingNews() {

        // uncomment to test with dummy data
        isLoadingBreaking = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.breakingArticles = Array(self?.dummyArticles.prefix(5) ?? [])
            self?.isLoadingBreaking = false
        }
        return
        //

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
    
    func fetchArticlesForTopic(_ topic: String) {

        // uncomment to test with dummy data
        isLoadingBreaking = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.breakingArticles = Array(self?.dummyArticles.prefix(5) ?? [])
            self?.isLoadingBreaking = false
        }
        return
        //

        isLoadingTopic = true
        error = nil
        
        let urlString = "https://newsapi.org/v2/everything?q=\(topic)&language=en&sortBy=publishedAt&pageSize=10&apiKey=\(apiKey)"
        
        guard let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedString) else {
            isLoadingTopic = false
            error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoadingTopic = false
                
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
                    self?.topicArticles[topic] = response.articles
                } catch {
                    self?.error = error
                }
            }
        }.resume()
    }
}
