import AVFoundation

@MainActor
class AudioService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    @Published var isPlaying = false
    @Published var progress: Double = 0
    @Published var debugMessage: String = ""
    
    private var timer: Timer?
    private var articles: [Article] = []
    private var currentUtterance: AVSpeechUtterance?
    private var shouldRestartPlayback = false
    
    override init() {
        super.init() // Call super.init() because of NSObject inheritance
        synthesizer.delegate = self
    }
    
    func setArticles(_ articles: [Article], restartPlayback: Bool = false) {
        debugMessage = "Articles updated: \(articles.count) articles"
        self.articles = articles
        self.shouldRestartPlayback = restartPlayback
        
        if restartPlayback && isPlaying {
            // Stop current playback and restart with new articles
            stopPlayback()
            playDigest()
        }
    }
    
    func playDigest() {
        debugMessage = "Attempting to play digest..."
        
        if articles.isEmpty {
            debugMessage += "\nNo articles available"
            return
        }
        
        if isPlaying && !shouldRestartPlayback {
            debugMessage += "\nPlayback already in progress"
            return
        }
        
        let headlines = articles.map { "Next headline: \($0.title)" }.joined(separator: ". ")
        debugMessage += "\nPrepared headlines text, length: \(headlines.count) characters"
        playText(headlines)
    }
    
    private func playText(_ text: String) {
        debugMessage += "\nCreating utterance..."
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        currentUtterance = utterance
        debugMessage += "\nAttempting to speak..."
        synthesizer.speak(utterance)
        isPlaying = true
        startProgressTimer()
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
