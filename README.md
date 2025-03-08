# JeevesApp (Pomodoro Coach)

An AI-powered, voice-driven productivity companion that helps manage Pomodoro sessions, tasks, and Kanban boards through natural conversation—designed to feel like a coach in the room with you.

## 📱 App Vision

### Purpose & Experience
JeevesApp functions as a personal Pomodoro Coach with whom you can converse hands-free. It offers:

- **Conversational Interface**: Talk naturally to your coach—it understands context, remembers previous interactions, and adapts to your preferences
- **Dynamic Personality**: Choose between Motivational, Devil's Advocate, Professional, or Chatty/Witty personalities, adjustable on-the-fly ("Coach, more banter")
- **Continuous Interaction**: Conversations flow naturally—when you speak, the coach stops to listen; manual mute/unmute available
- **Proactive Coaching**: Coach initiates helpful suggestions based on your work patterns ("Mitch, you're slacking—speeding up!")
- **Offline Capability**: Full functionality when offline, with seamless transition to enhanced features when online
- **AirPods Integration**: Designed for voice interaction while you stay focused on your work

### Core Features & Tools

#### Pomodoro Timer
- Start, stop, pause, and reset timers through voice commands
- Adjust duration ("add 5 minutes") or speed ("speed up 20%")
- Coach confirms major changes before executing them ("Speeding up 20%—cool?")
- Visual feedback: timer ring pulses with speed changes

#### Task Management
- Add, edit, delete, and summarize tasks via voice
- Attach photos (JPEG/PNG, ≤10MB) and files (PDFs)
- Local storage with iCloud synchronization
- Voice annotations and priority setting

#### Kanban Board
- Drag-and-drop animated cards across columns
- Create and customize columns through voice or touch
- Save boards with timestamps for easy recall ("Load last Wednesday's board")
- Visual feedback: cards bounce when moved

### Design & Aesthetics
- **Color Theme**: Purple (`#4B0082`) and gold (`#FFD700`) for distinctive, attention-grabbing UI
- **Animations**: Timer ring pulses, Kanban cards bounce, confetti explosion after 4 completed Pomodoro sessions
- **Voice Indicators**: Mic glows gold when listening, purple when speaking
- **Visual Feedback**: Subtle animations reinforce actions and maintain engagement

### Persistence & Synchronization
- Checkpoint saves when closing the app ("Save this board?")
- Automatic backups every 25 minutes
- Full iCloud synchronization across devices
- Offline matches online experience with local-first architecture

### Voice Technology
- **STT (Speech-to-Text)**: Deepgram primary, Apple SFSpeechRecognizer as offline fallback
- **TTS (Text-to-Speech)**: Google Cloud TTS primary, Apple AVSpeechSynthesizer as offline fallback, ElevenLabs as premium option
- Switching providers through voice commands ("Talk like ElevenLabs") or UI controls

## 🧠 Technical Architecture

### Protocol Hierarchy

#### Base Protocol: `AIAgent`
```swift
protocol AIAgent {
    var agentName: String { get }
    var isLocal: Bool { get }
    var supportedCommands: [CommandPattern] { get }
    var capabilities: [AgentCapability] { get }
    var priority: Int { get }
    var version: String { get }
    var statePublisher: AnyPublisher<AgentState, Never> { get }
    
    func handle(input: AgentInput, context: AgentContext) async -> AgentResponse
    func start() async
    func stop() async
    func isAvailable() -> Bool
    func configure(with configuration: AgentConfiguration) async
    func dependencies() -> [String]
}
```

#### Proactive Extension
```swift
protocol ProactiveCapable {
    func shouldInitiateInteraction(context: AgentContext) async -> Bool
    func generateProactiveContent(context: AgentContext) async -> AgentResponse
}
```

### Agent Specializations

#### Speech-to-Text Agents
- **DeepgramSTTAgent**: Provides real-time transcription via WebSocket
- **AppleSTTAgent**: Uses SFSpeechRecognizer for offline capability

#### Text-to-Speech Agents
- **GoogleTTSAgent**: Cloud TTS API with high-quality voices
- **AppleTTSAgent**: AVSpeechSynthesizer for offline capability
- **ElevenLabsTTSAgent**: Premium voice option via REST API

#### Intent Parsing
- **LocalIntentParser**: Converts natural language to structured commands
  - Currently using pattern matching/regex
  - Future: OpenELM via Core ML for more sophisticated NLP

#### Task Agents
- **LocalTimerAgent**: Manages Pomodoro timer operations
- **LocalTaskAgent**: Handles task management
- **CloudSuggestionAgent**: Generates task suggestions (Grok/ChatGPT)
- **CloudSummaryAgent**: Summarizes sessions (Claude)
- **CloudPredictionAgent**: Predicts next actions (DeepSeek)

### Core Components

#### AIAgentCoordinator
```swift
class AIAgentCoordinator {
    private var agents: [String: AIAgent] = [:]
    private var cancellables = Set<AnyCancellable>()
    private let agentTimeout: TimeInterval = 5.0
    let sessionManager: SessionManager
    
    func registerAgent(_ agent: AIAgent)
    func process(input: AgentInput, context: AgentContext) async -> AgentResponse
    func setPersonality(personality: CoachPersonality) async
    func switchProvider(type: String, provider: String) async
}
```

#### SessionManager
```swift
class SessionManager {
    func saveSession(context: AgentContext) async throws
    func loadSession(date: Date) async throws -> AgentContext
    func summarizeCycle(context: AgentContext) async -> SessionSummary
}
```

### Data Structures

#### AgentContext
Hierarchical structure holding the app's state:
- **Hot (real-time)**: `timerState`, `currentTasks`, `personality`, `muted`, `deepFocus`
- **Warm (recent history)**: `summaries` (last 5), `commands` (last 10)
- **Cold (long-term)**: `boards` (timestamped Kanban boards)

#### CommandPattern
```swift
struct CommandPattern {
    let verb: String
    let noun: String?
    let wildcard: Bool
}
```

#### AgentResponse
```swift
struct AgentResponse {
    let text: String
    let success: Bool
    let metadata: [String: Any]
    let error: AgentError?
    let actions: [AgentAction]
}
```

#### ParsedIntent
```swift
struct ParsedIntent {
    let domain: String
    let intent: String
    let params: [String: Any]
    let confidence: Float?
    let rawInput: String
}
```

## 🔄 Data Flow & Processing

### Command Processing Workflow
1. User input (voice/text) → AgentInput
2. Deepgram STT → Text (if voice input)
3. IntentParserService → ParsedIntent(s)
4. AIAgentCoordinator routes to appropriate agent(s) based on supportedCommands
5. Agent(s) process and return AgentResponse(s)
6. GoogleTTS speaks response (if appropriate)
7. UI updates based on response metadata

### Proactivity Workflow
1. ProactiveCapable agents check `shouldInitiateInteraction()` every 5-15 mins (personality-driven)
2. If true, agent calls `generateProactiveContent()`
3. Content is presented (max 3 proactive interactions per Pomodoro cycle)
4. Example: "Mitch, Task X next?" after 8 minutes of work

### Interruption Handling
1. Deepgram detects user voice during TTS playback
2. TTS is immediately paused
3. Voice input is processed
4. New response is generated

### State Persistence
1. Explicit saves ("Save this board?") at user discretion
2. Automatic backup every 25 minutes
3. iCloud synchronization for cross-device access
4. No automatic state resumption on app open (explicit load required)

## 📊 Development Roadmap

### Phase 1: Skeleton & Session Management ✅
- **Goals**: Setup data persistence layer, Core Data schema, session management
- **Components Built**:
  - AgentContext data structures (hot/warm/cold)
  - Core Data entities (Task, Board, TimerState, Summary)
  - SessionManager with save/load/summarize functionality
  - iCloud integration
- **Outcome**: A robust persistence foundation that saves/loads/syncs app state

### Phase 2: Coordinator & Intent Parsing 🚧
- **Goals**: Build the "brain" of the app that routes commands to agents
- **Components Building**:
  - AIAgent protocol definition
  - AIAgentCoordinator implementation
  - Command pattern matching
  - Basic intent parsing
  - Agent registry
- **Outcome**: A command routing system that directs inputs to the right handlers

### Phase 3: Voice I/O (STT/TTS)
- **Goals**: Implement speech capabilities for hands-free operation
- **Components to Build**:
  - DeepgramSTTAgent with WebSocket for real-time transcription
  - GoogleTTSAgent for high-quality speech output
  - Apple frameworks integration for offline fallback
  - Voice interrupt handling
- **Outcome**: A coach that listens and speaks naturally

### Phase 4: Core Agents (Timer & Tasks)
- **Goals**: Implement the fundamental productivity features
- **Components to Build**:
  - LocalTimerAgent for Pomodoro functionality
  - LocalTaskAgent for task management
  - Photo/file attachment handling
  - Integration with AIAgentCoordinator
- **Outcome**: Core productivity features functional and voice-controlled

### Phase 5: UI & Visuals
- **Goals**: Create an engaging, beautiful interface
- **Components to Build**:
  - Timer ring visualization with pulse animation
  - Kanban board with drag-drop and animations
  - Mic indicators (gold/purple)
  - Purple and gold themed components
- **Outcome**: A visually polished app that provides clear feedback

### Phase 6: Proactivity & Personality
- **Goals**: Add the "coach" personality and proactive interactions
- **Components to Build**:
  - ProactiveCapable implementation
  - CoachPersonality customization
  - Tone adjustments for TTS
  - Adaptive behavior based on user preferences
- **Outcome**: A coach that initiates helpful interactions and adapts to the user

### Phase 7: Cloud Agents & Polish
- **Goals**: Add advanced AI features and final polish
- **Components to Build**:
  - Cloud-based suggestion and summary agents
  - Integration with external AI services
  - Confetti and celebration animations
  - Final refinements and performance optimizations
- **Outcome**: A complete, intelligent productivity companion

## 🧪 Testing Strategy

Each phase includes specific tests to verify functionality:

- **Phase 1**: Save/load test with dummy session data
- **Phase 2**: Command routing tests with mock agents
- **Phase 3**: Voice recognition and synthesis accuracy tests
- **Phase 4**: Timer and task operation verification
- **Phase 5**: UI responsiveness and animation testing
- **Phase 6**: Proactivity timing and personality adjustment tests
- **Phase 7**: End-to-end flow testing and performance benchmarks

## 📋 Example Interaction

```
User: "Summarize my day and speed up 20%."

1. DeepgramSTTAgent converts to text
2. LocalIntentParser identifies two intents:
   - {domain: "summary", intent: "summarize", params: {timeframe: "day"}}
   - {domain: "timer", intent: "speed_up", params: {percent: 20}}

3. AIAgentCoordinator routes to:
   - CloudSummaryAgent → "4 tasks done."
   - LocalTimerAgent → "Speeding up 20%—cool?"

4. User: "Yes"

5. GoogleTTSAgent speaks: "4 tasks done. Timer sped up—nice hustle!"

6. After 8 minutes: LocalTaskAgent proactively asks: "Task X next?"
```

## 🛠️ Implementation Technologies

- **Framework**: SwiftUI for UI, Core Data for storage
- **Sync**: CloudKit for iCloud integration
- **Concurrency**: Swift async/await for responsive performance
- **APIs**: Deepgram, Google Cloud, ElevenLabs (with Apple fallbacks)
- **NLP**: Pattern matching initially, OpenELM via Core ML later
- **Testing**: XCTest with mock agents and Core Data test store

## 📝 Current Status

The project is currently in Phase 2: Coordinator & Intent Parsing.

- **Completed**: Phase 1 - Session Management with full iCloud integration
- **In Progress**: Building the agent coordinator and command routing system
- **Next**: Implementing the LocalIntentParser for natural language understanding

## 💻 Development Setup

### Requirements
- Xcode 14.0+ on macOS 13.0+
- iOS 16.0+ for deployment targets
- Apple Developer account for CloudKit integration
- API keys for Deepgram, Google Cloud, and ElevenLabs

### Configuration
1. Clone the repository
2. Open JeevesApp.xcodeproj
3. Create a `Config.swift` file based on the template provided
4. Add your API keys to `Config.swift`
5. Configure your Apple Developer team for signing
6. Enable iCloud capabilities in your Xcode project settings

### Running the Project
- Build and run on your iPhone 15 for best experience
- Use the iPhone simulator for basic testing
- To test voice features, configure microphone permissions

## 📚 Project Structure

```
JeevesApp/
├── Models/
│   ├── AgentInput.swift
│   ├── AgentResponse.swift
│   ├── ParsedIntent.swift
│   └── AgentContext.swift
├── Agents/
│   ├── AIAgent.swift
│   ├── MockAgent.swift
│   └── (future agent implementations)
├── Coordinators/
│   └── AIAgentCoordinator.swift
├── Persistence/
│   ├── JeevesAppModel.xcdatamodeld
│   ├── PersistenceController.swift
│   └── SessionManager.swift
├── Utilities/
│   └── AgentTypes.swift
├── Views/
│   └── ContentView.swift
└── JeevesApp.swift
```

## 🔜 Next Development Tasks

1. Complete AIAgentCoordinator implementation
2. Create and test the LocalIntentParser
3. Implement state change management
4. Develop tests for coordinator and parser
5. Prepare for Phase 3: Voice integration with Deepgram and Google

---

This project aims to transform productivity by creating a voice-driven Pomodoro coach that feels like a supportive companion rather than just a tool. By combining state-of-the-art voice technology with thoughtful AI design, JeevesApp delivers a uniquely helpful and engaging productivity experience.