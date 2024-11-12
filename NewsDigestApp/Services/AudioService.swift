import AVFoundation

@MainActor
class AudioService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    @Published var isPlaying = false
    @Published var progress: Double = 0
    @Published var debugMessage: String = ""
    @Published var currentArticleIndex: Int = 0
    
    private var timer: Timer?
    private var articles: [Article] = []
    private var currentUtterance: AVSpeechUtterance?
    private var shouldRestartPlayback = false
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func setArticles(_ articles: [Article], restartPlayback: Bool = false) {
        self.articles = articles
        self.shouldRestartPlayback = restartPlayback
        self.currentArticleIndex = 0
        debugMessage = "Articles updated: \(articles.count) articles"
        
        if restartPlayback && isPlaying {
            stopPlayback()
            playDigest()
        }
    }
    
    func playDigest() {
        guard !articles.isEmpty else {
            debugMessage = "No articles available"
            return
        }
        
        if isPlaying && !shouldRestartPlayback {
            debugMessage = "Playback already in progress"
            return
        }
        
        // Create a more engaging narrative
        let digestText = createDigestText()
        debugMessage = "Prepared digest text, length: \(digestText.count) characters"
        playText(digestText)
    }
    
    private func createDigestText() -> String {
        var digestParts: [String] = []
        
        // Introduction
        digestParts.append("Welcome to your news digest. Here are today's top stories from \(articles.first?.source.name ?? "your selected sources").")
        
        // Articles
        for (index, article) in articles.enumerated() {
            // Add a pause marker
            digestParts.append("...")
            
            // Headline introduction
            digestParts.append("Headline \(index + 1):")
            
            // Title with emphasis
            digestParts.append(article.title)
            
            // Description if available
            if let description = article.description, !description.isEmpty {
                digestParts.append("Here's more detail:")
                digestParts.append(description)
            }
        }
        
        // Conclusion
        digestParts.append("...")
        digestParts.append("That's all for now. Thank you for listening.")
        
        return digestParts.joined(separator: "\n\n")
    }
    
    private func playText(_ text: String) {
        debugMessage = "Creating utterance..."
        let utterance = AVSpeechUtterance(string: text)
        
        // Customize voice and speaking style
        utterance.rate = 0.52  // Slightly slower for better comprehension
        utterance.pitchMultiplier = 1.1  // Slightly higher pitch for engagement
        utterance.volume = 1.0
        
        // Use a high-quality voice if available
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
    
    var currentArticleTitle: String {
        guard !articles.isEmpty && currentArticleIndex < articles.count else {
            return "No article playing"
        }
        return articles[currentArticleIndex].title
    }
    
    func stopPlayback() {
        debugMessage += "\nStopping playback..."
        synthesizer.stopSpeaking(at: .immediate)
        isPlaying = false
        progress = 0
        timer?.invalidate()
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
    
    // AVSpeechSynthesizerDelegate methods
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
