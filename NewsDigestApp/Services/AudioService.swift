import AVFoundation

@MainActor
class AudioService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    // MARK: - Published Properties
    @Published var isPlaying = false
    @Published var progress: Double = 0
    @Published var debugMessage: String = ""
    @Published var currentArticleIndex: Int = 0
    @Published var isGenerating = false
    
    // MARK: - Private Properties
    private let synthesizer = AVSpeechSynthesizer()
    private var _articles: [Article] = []
    private var timer: Timer?
    private var currentUtterance: AVSpeechUtterance?
    private let openAIService = OpenAIService()
    private var generatedNarration: String?
    
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
        // Reset the generated narration when new articles are set
        self.generatedNarration = nil
        debugMessage = "Articles updated: \(self._articles.count) articles"
    }
    
    func startNewPlayback() {
        stopPlayback()
        currentArticleIndex = 0
        
        guard let narration = generatedNarration else {
            debugMessage += "\nNo narration available"
            return
        }
        
        playText(narration)
    }
    
    func playDigest() {
        if let narration = generatedNarration {
            playText(narration)
        } else {
            debugMessage += "\nNo narration available"
        }
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
    
    func generateAndPlayDigest() async {
        guard !_articles.isEmpty else {
            debugMessage = "No articles available"
            return
        }
        
        isGenerating = true
        debugMessage = "Starting OpenAI narration generation..."
        
        do {
            debugMessage += "\nSending request to OpenAI..."
            let narration = try await openAIService.generateNarration(for: _articles)
            debugMessage += "\nReceived narration from OpenAI (length: \(narration.count) characters)"
            
            self.generatedNarration = narration
            debugMessage += "\nNarration set successfully"
            
            startNewPlayback()
        } catch let error as OpenAIError {
            debugMessage += "\nOpenAI Error: \(error.errorDescription ?? "Unknown error")"
            switch error {
            case .apiError(let message):
                debugMessage += "\nAPI Error Details: \(message)"
            case .networkError(let underlyingError):
                debugMessage += "\nNetwork Error Details: \(underlyingError.localizedDescription)"
            default:
                debugMessage += "\nOther OpenAI Error: \(error.localizedDescription)"
            }
        } catch {
            debugMessage += "\nUnexpected error: \(error.localizedDescription)"
        }
        
        isGenerating = false
    }
    private func playText(_ text: String) {
        debugMessage = "Creating utterance..."
        let utterance = AVSpeechUtterance(string: text)
        
        // Configure voice properties
        utterance.rate = 0.52
        utterance.pitchMultiplier = 1.1
        utterance.volume = 1.0
        
        // Better voice selection logic
        let voice = selectBestAvailableVoice()
        utterance.voice = voice
        debugMessage += "\nSelected voice: \(voice.name)"
        
        currentUtterance = utterance
        debugMessage += "\nAttempting to speak..."
        synthesizer.speak(utterance)
        isPlaying = true
        startProgressTimer()
    }
    
    private func selectBestAvailableVoice() -> AVSpeechSynthesisVoice {
        debugMessage += "\nSearching for available voices..."
        
        // Try premium voice first
        if let premiumVoice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.premium.en-US.samantha") {
            debugMessage += "\nFound premium voice"
            return premiumVoice
        }
        
        // Try enhanced quality voice
        if let enhancedVoice = AVSpeechSynthesisVoice(language: "en-US")?.voice(with: .enhanced) {
            debugMessage += "\nFound enhanced voice"
            return enhancedVoice
        }
        
        // List all available voices for debugging
        let availableVoices = AVSpeechSynthesisVoice.speechVoices()
        debugMessage += "\nAvailable voices: \(availableVoices.map { $0.name }.joined(separator: ", "))"
        
        // Try to find any English voice
        let englishVoices = availableVoices.filter { $0.language.starts(with: "en") }
        if let bestEnglishVoice = englishVoices.first {
            debugMessage += "\nUsing English voice: \(bestEnglishVoice.name)"
            return bestEnglishVoice
        }
        
        // Fallback to default voice
        debugMessage += "\nFalling back to default voice"
        return AVSpeechSynthesisVoice(language: "en-US") ?? AVSpeechSynthesisVoice()
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


extension AVSpeechSynthesisVoice {
    enum Quality {
        case enhanced
        case standard
    }
    
    func voice(with quality: Quality) -> AVSpeechSynthesisVoice? {
        switch quality {
        case .enhanced:
            return AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_female_en-US_compact")
        case .standard:
            return self
        }
    }
}
