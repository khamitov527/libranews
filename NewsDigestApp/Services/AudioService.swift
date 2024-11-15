import AVFoundation

@MainActor
class AudioService: NSObject, ObservableObject {
    
    enum VoiceServiceType {
        case elevenlabs
        case ios
        case openai
    }
    
    // MARK: - Published Properties
    @Published var isPlaying = false
    @Published var progress: Double = 0
    @Published var debugMessage: String = ""
    @Published var currentArticleIndex: Int = 0
    @Published var isGenerating = false
    @Published var voiceServiceType: VoiceServiceType = .ios {
        didSet {
            setupVoiceService()
        }
    }
    
    // MARK: - Private Properties
    var audioPlayer: AVAudioPlayer?
    private var _articles: [Article] = []
    private var timer: Timer?
    private let openAIService = OpenAIService()
    private var voiceService: VoiceService!
    private var generatedNarration: String?
    private var audioData: Data?
    
    private func setupVoiceService() {
        switch voiceServiceType {
        case .elevenlabs:
            voiceService = ElevenLabsService()
        case .ios:
            voiceService = IOSVoiceService()
        case .openai:
            voiceService = OpenAITTSService()
        }
        debugMessage += "\nVoice service switched to \(voiceServiceType)"
    }
    
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
    override init() {
        super.init()
        setupVoiceService()
    }
    
    func setArticles(_ articles: [Article]) {
        self._articles = Array(articles.prefix(3))
        self.generatedNarration = nil
        self.audioData = nil
        debugMessage = "Articles updated: \(self._articles.count) articles"
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
            debugMessage += "\nReceived narration from OpenAI"
            
            debugMessage += "\nGenerating speech..."
            let audioData = try await voiceService.synthesizeSpeech(text: narration)
            debugMessage += "\nReceived audio data"
            
            self.audioData = audioData
            self.generatedNarration = narration
            
            startNewPlayback()
        } catch {
            handleError(error)
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
        } else if let openAITTSError = error as? OpenAITTSError {
            debugMessage += "\nOpenAI TTS Error: \(openAITTSError.errorDescription ?? "Unknown error")"
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
