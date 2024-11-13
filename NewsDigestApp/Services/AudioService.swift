import AVFoundation

@MainActor
class AudioService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    // MARK: - Published Properties
    @Published var isPlaying = false
    @Published var progress: Double = 0
    @Published var debugMessage: String = ""
    @Published var currentArticleIndex: Int = 0
    
    // MARK: - Private Properties
    private let synthesizer = AVSpeechSynthesizer()
    private var _articles: [Article] = []
    private var timer: Timer?
    private var currentUtterance: AVSpeechUtterance?
    private var articleBoundaries: [String] = []
    
    // MARK: - Public Properties
    
    var displayArticleIndex: Int {
        currentArticleIndex + 1
    }
    
    var totalArticles: Int {
        _articles.count
    }
    
    var articles: [Article] {
        _articles
    }
    
    var currentArticleTitle: String {
        guard !_articles.isEmpty && currentArticleIndex < _articles.count else {
            return "No article playing"
        }
        return _articles[currentArticleIndex].title
    }
    
    // MARK: - Initialization
    override init() {
        super.init()
        synthesizer.delegate = self
        debugMessage = "AudioService initialized"
    }
    
    // MARK: - Public Methods
    func setArticles(_ articles: [Article]) {
        self._articles = Array(articles.prefix(3))
        debugMessage = "Articles updated: \(self._articles.count) articles"
    }
    
    func startNewPlayback() {
        stopPlayback()
        currentArticleIndex = 0
        playDigest()
    }
    
    func playDigest() {
        guard !_articles.isEmpty else {
            debugMessage = "No articles available"
            return
        }
        
        if isPlaying {
            debugMessage = "Playback already in progress"
            return
        }
        
        let digestText = createDigestText()
        debugMessage = "Prepared digest text, length: \(digestText.count) characters"
        playText(digestText)
    }
    
    func pauseDigest() {
        debugMessage += "\nPausing playback..."
        synthesizer.pauseSpeaking(at: .immediate)
        isPlaying = false
        timer?.invalidate()
    }
    
    func resumeDigest() {
        debugMessage += "\nResuming playback..."
        if let currentUtterance = currentUtterance, !synthesizer.isSpeaking {
            synthesizer.speak(currentUtterance)
        } else {
            synthesizer.continueSpeaking()
        }
        isPlaying = true
        startProgressTimer()
    }
    
    func stopPlayback() {
        debugMessage += "\nStopping playback..."
        synthesizer.stopSpeaking(at: .immediate)
        isPlaying = false
        progress = 0
        timer?.invalidate()
        currentArticleIndex = 0
    }
    
    // MARK: - Private Methods
    private func createDigestText() -> String {
        var digestParts: [String] = []
        articleBoundaries = []
        
        // Introduction
        digestParts.append("Welcome to your news digest. Here are today's top stories from \(_articles.first?.source.name ?? "your selected sources").")
        
        // Articles
        for (index, article) in _articles.enumerated() {
            // Add article boundary marker
            let boundary = "---ARTICLE\(index)---"
            digestParts.append(boundary)
            articleBoundaries.append(boundary)
            
            // Article content
            digestParts.append("Article \(index + 1):")
            digestParts.append(article.title)
            
            if let description = article.description, !description.isEmpty {
                digestParts.append("Here's more detail:")
                digestParts.append(description)
            }
            
            // Add pause between articles
            digestParts.append("...")
        }
        
        // Conclusion
        digestParts.append("---END---")
        digestParts.append("That's all for now. Thank you for listening.")
        
        return digestParts.joined(separator: "\n\n")
    }
    
    private func playText(_ text: String) {
        debugMessage += "\nCreating utterance..."
        let utterance = AVSpeechUtterance(string: text)
        
        // Configure voice properties
        utterance.rate = 0.52  // Slightly slower for better comprehension
        utterance.pitchMultiplier = 1.1  // Slightly higher pitch for engagement
        utterance.volume = 1.0
        
        // Use premium voice if available
        if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.premium.en-US.samantha") {
            utterance.voice = voice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        
        currentUtterance = utterance
        debugMessage += "\nAttempting to speak..."
        synthesizer.speak(utterance)
        isPlaying = true
        startProgressTimer()
    }
    
    private func startProgressTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.progress < 1.0 {
                self.progress += 0.001
            } else {
                self.timer?.invalidate()
                self.isPlaying = false
                self.progress = 0
            }
        }
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let text = utterance.speechString as NSString
        let currentText = text.substring(with: characterRange)
        
        // Check if we've hit an article boundary
        for (index, boundary) in articleBoundaries.enumerated() {
            if currentText.contains(boundary) {
                DispatchQueue.main.async {
                    self.currentArticleIndex = index
                    self.debugMessage += "\nNow playing article \(index + 1)"
                }
                break
            }
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        debugMessage += "\nStarted speaking"
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        debugMessage += "\nFinished speaking"
        isPlaying = false
        progress = 1.0
        timer?.invalidate()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        debugMessage += "\nPaused speaking"
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        debugMessage += "\nContinued speaking"
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        debugMessage += "\nCanceled speaking"
        isPlaying = false
    }
}
