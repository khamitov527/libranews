import AVFoundation

@MainActor
class AudioService: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var isPlaying = false
    @Published var progress: Double = 0
    @Published var debugMessage: String = ""
    @Published var currentArticleIndex: Int = 0
    @Published var isGenerating = false
    @Published var selectedDuration: DigestDuration?
    
    // MARK: - Private Properties
    private var audioPlayer: AVAudioPlayer?
    private var _articles: [Article] = []
    private var timer: Timer?
    private let openAIService = OpenAIService()
    private let elevenLabsService = ElevenLabsService()
    private var generatedNarration: String?
    private var audioData: Data?
    
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
    
    // MARK: - Public Methods
    func setArticles(_ articles: [Article], duration: DigestDuration?) {
        self.selectedDuration = duration
        if let duration = duration {
            self._articles = Array(articles.prefix(duration.articleRange.upperBound))
        } else {
            self._articles = Array(articles.prefix(5))
        }
        self.generatedNarration = nil
        self.audioData = nil
        debugMessage = "Articles updated: \(self._articles.count) articles"
    }
    
    func generateAndPlayDigest(duration: DigestDuration?) async {
        guard !_articles.isEmpty else {
            debugMessage = "No articles available"
            return
        }
        
        isGenerating = true
        debugMessage = "Starting OpenAI narration generation..."
        
        do {
            // Generate text narration
            debugMessage += "\nSending request to OpenAI..."
            let narration = try await openAIService.generateNarration(for: _articles, duration: duration)
            debugMessage += "\nReceived narration from OpenAI"
            
            // Convert text to speech using ElevenLabs
            debugMessage += "\nSending request to ElevenLabs..."
            let audioData = try await elevenLabsService.synthesizeSpeech(text: narration)
            debugMessage += "\nReceived audio from ElevenLabs"
            
            self.audioData = audioData
            self.generatedNarration = narration
            
            startNewPlayback()
        } catch let error as OpenAIError {
            handleError(error)
        } catch let error as ElevenLabsError {
            handleError(error)
        } catch {
            debugMessage += "\nUnexpected error: \(error.localizedDescription)"
        }
        
        isGenerating = false
    }
    
    func startNewPlayback() {
        stopPlayback()
        currentArticleIndex = 0
        
        guard let audioData = audioData else {
            debugMessage += "\nNo audio available"
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
            startProgressTimer()
        } catch {
            debugMessage += "\nError playing audio: \(error.localizedDescription)"
        }
    }
    
    func pauseDigest() {
        debugMessage += "\nPausing playback..."
        audioPlayer?.pause()
        isPlaying = false
        timer?.invalidate()
    }
    
    func resumeDigest() {
        debugMessage += "\nResuming playback..."
        audioPlayer?.play()
        isPlaying = true
        startProgressTimer()
    }
    
    func stopPlayback() {
        debugMessage += "\nStopping playback..."
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        progress = 0
        timer?.invalidate()
        currentArticleIndex = 0
    }
    
    private func startProgressTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self,
                  let player = self.audioPlayer else { return }
            
            self.progress = player.currentTime / player.duration
            
            if self.progress >= 1.0 {
                self.timer?.invalidate()
                self.isPlaying = false
                self.progress = 0
            }
        }
    }
    
    private func handleError(_ error: Error) {
        debugMessage += "\nError: \(error.localizedDescription)"
        if let openAIError = error as? OpenAIError {
            debugMessage += "\nOpenAI Error: \(openAIError.errorDescription ?? "Unknown error")"
        } else if let elevenLabsError = error as? ElevenLabsError {
            debugMessage += "\nElevenLabs Error: \(elevenLabsError.errorDescription ?? "Unknown error")"
        }
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        debugMessage += "\nFinished playing"
        isPlaying = false
        progress = 1.0
        timer?.invalidate()
    }
}
