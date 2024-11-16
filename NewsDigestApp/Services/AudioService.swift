import AVFoundation

struct ArticleAudioSegment {
    let article: Article
    let audioData: Data
    let duration: TimeInterval
    var isPlayed: Bool = false
}

@MainActor
class AudioService: NSObject, ObservableObject {
    // MARK: - Configuration
    enum VoiceServiceType {
        case elevenlabs, ios, openai
    }
    
    // MARK: - Published States
    @Published var isPlaying = false
    @Published var progress: Double = 0
    @Published var isGenerating = false
    @Published var voiceServiceType: VoiceServiceType = .ios {
        didSet { setupVoiceService() }
    }
    @Published private(set) var audioQueue: [ArticleAudioSegment] = []
    @Published private(set) var currentSegment: ArticleAudioSegment?
    
    // MARK: - Private Properties
    var audioPlayer: AVAudioPlayer?
    private var _articles: [Article] = []
    private var timer: Timer?
    private var _currentSegmentIndex: Int = 0
    private let openAIService = OpenAIService()
    private var voiceService: VoiceService!
    
    var currentSegmentIndex: Int {
        _currentSegmentIndex
    }
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupVoiceService()
    }
    
    // MARK: - Main Workflow
    
    /// Step 1: Set articles and start playback
    func setArticles(_ articles: [Article]) {
        print("📚 Setting new articles")
        reset() // Clear everything first
        _articles = Array(articles.prefix(3))
        print("📚 Articles set: \(_articles.count) articles")
    }
    
    /// Step 2: Initial playback trigger
    func startPlayback() async {
        guard !_articles.isEmpty else {
            print("⚠️ No articles available")
            return
        }
        
        audioQueue.removeAll()
        _currentSegmentIndex = 0
        isGenerating = true
        
        // Process and play first article
        if let firstArticle = _articles.first {
            await processAndPlayArticle(firstArticle)
        }
    }
    
    /// Step 3: Process article and begin playback
    private func processAndPlayArticle(_ article: Article) async {
        do {
            print("🎙 Processing article: \(article.title)")
            let narration = try await openAIService.generateNarration(for: article)
            let audioData = try await voiceService.synthesizeSpeech(text: narration)
            
            let player = try AVAudioPlayer(data: audioData)
            let segment = ArticleAudioSegment(
                article: article,
                audioData: audioData,
                duration: player.duration
            )
            
            audioQueue.append(segment)
            startPlayingCurrentSegment()
            isGenerating = false
            
            // Trigger loading of next article
            loadNextArticle()
        } catch {
            print("❌ Error: \(error.localizedDescription)")
            isGenerating = false
        }
    }
    
    /// Step 4: Queue next article for processing
    private func loadNextArticle() {
        let nextIndex = currentSegmentIndex + 1
        if nextIndex < _articles.count {
            Task {
                await processAndQueueArticle(_articles[nextIndex])
            }
        }
    }
    
    /// Step 5: Process and queue next article
    private func processAndQueueArticle(_ article: Article) async {
        do {
            print("📦 Preparing next article: \(article.title)")
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
            print("❌ Error preparing next article: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Playback Controls
    
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
    
    // MARK: - Utilities
    
    func reset() {
        print("🔄 Resetting audio service")
        audioPlayer?.stop()
        audioPlayer = nil
        audioQueue.removeAll()
        _currentSegmentIndex = 0
        isPlaying = false
        isGenerating = false
        progress = 0
        timer?.invalidate()
        _articles.removeAll()
        currentSegment = nil
    }
    
    private func startPlayingCurrentSegment() {
        guard currentSegmentIndex < audioQueue.count else {
            isPlaying = false
            // Update current segment when playback ends
            currentSegment = audioQueue.last
            return
        }
        
        do {
            // Update current segment when starting new playback
            currentSegment = audioQueue[currentSegmentIndex]
            audioPlayer = try AVAudioPlayer(data: audioQueue[currentSegmentIndex].audioData)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
            startProgressTimer()
        } catch {
            print("❌ Playback error: \(error.localizedDescription)")
        }
    }
    
    private func setupVoiceService() {
        voiceService = switch voiceServiceType {
            case .elevenlabs: ElevenLabsService()
            case .ios: IOSVoiceService()
            case .openai: OpenAITTSService()
        }
        print("🎵 Voice service switched to \(voiceServiceType)")
    }
    
    private func startProgressTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            self.progress = player.currentTime / player.duration
        }
    }
    
    func playPreviousSegment() {
        guard currentSegmentIndex > 0 else { return }
        _currentSegmentIndex -= 1
        startPlayingCurrentSegment()
    }
    
    func playNextSegment() {
        guard currentSegmentIndex < audioQueue.count - 1 else { return }
        audioQueue[currentSegmentIndex].isPlayed = true
        _currentSegmentIndex += 1
        startPlayingCurrentSegment()
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            audioQueue[currentSegmentIndex].isPlayed = true
            _currentSegmentIndex += 1
            if currentSegmentIndex < audioQueue.count {
                startPlayingCurrentSegment()
                loadNextArticle()
            } else {
                isPlaying = false
                progress = 1.0
                timer?.invalidate()
            }
        }
    }
}
