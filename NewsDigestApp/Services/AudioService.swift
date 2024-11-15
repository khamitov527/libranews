import AVFoundation

struct ArticleAudioSegment {
    let article: Article
    let audioData: Data
    let duration: TimeInterval
    var isPlayed: Bool = false
}

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
    @Published private(set) var audioQueue: [ArticleAudioSegment] = []
    @Published private(set) var isProcessingQueue = false
    private var currentSegmentIndex: Int = 0
    
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
    
    func processArticlesSequentially() async {
        isGenerating = true
        isProcessingQueue = true
        
        // Process articles one by one
        for (index, article) in _articles.enumerated() {
            if index == 0 {
                // Process and play first article
                await processAndPlayArticle(article)
            } else {
                // Process remaining articles in background
                await processArticle(article)
            }
        }
        
        isProcessingQueue = false
        isGenerating = false
    }
    
    private func processAndPlayArticle(_ article: Article) async {
        do {
            debugMessage += "\nProcessing first article: \(article.title)"
            let narration = try await openAIService.generateNarration(for: article)
            let audioData = try await voiceService.synthesizeSpeech(text: narration)
            
            let player = try AVAudioPlayer(data: audioData)
            let segment = ArticleAudioSegment(
                article: article,
                audioData: audioData,
                duration: player.duration
            )
            
            audioQueue.append(segment)
            
            if audioQueue.count == 1 {
                startPlayingCurrentSegment()
            }
        } catch {
            handleError(error)
        }
    }
    
    private func startPlayingCurrentSegment() {
        guard currentSegmentIndex < audioQueue.count else {
            isPlaying = false
            return
        }
        
        let segment = audioQueue[currentSegmentIndex]
        
        do {
            audioPlayer = try AVAudioPlayer(data: segment.audioData)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
            startProgressTimer()
        } catch {
            handleError(error)
        }
    }
    
    private func processArticle(_ article: Article) async {
        do {
            debugMessage += "\nProcessing next article: \(article.title)"
            let narration = try await openAIService.generateNarration(for: article)
            let audioData = try await voiceService.synthesizeSpeech(text: narration)
            
            let player = try AVAudioPlayer(data: audioData)
            let segment = ArticleAudioSegment(
                article: article,
                audioData: audioData,
                duration: player.duration
            )
            
            audioQueue.append(segment)
        } catch {
            handleError(error)
        }
    }
    
    func setArticles(_ articles: [Article]) {
        self._articles = Array(articles.prefix(3))
        self.audioQueue.removeAll()
        self.currentSegmentIndex = 0
        debugMessage = "Articles updated: \(self._articles.count) articles"
    }
    
    func startPlayback() async {
        guard !_articles.isEmpty else {
            debugMessage = "No articles available"
            return
        }
        
        // Clear existing queue and reset index
        audioQueue.removeAll()
        currentSegmentIndex = 0
        
        await processArticlesSequentially()
    }
    
    func startNewPlayback() {
        Task {
            await startPlayback()
        }
    }
    
    func pauseDigest() {
        audioPlayer?.pause()
        isPlaying = false
        timer?.invalidate()
    }
    
    func resumeDigest() {
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
        currentSegmentIndex = 0
        audioQueue.removeAll()
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
        if flag {
            audioQueue[currentSegmentIndex].isPlayed = true
            currentSegmentIndex += 1
            if currentSegmentIndex < audioQueue.count {
                startPlayingCurrentSegment()
            } else {
                isPlaying = false
                progress = 1.0
                timer?.invalidate()
            }
        }
    }
}
