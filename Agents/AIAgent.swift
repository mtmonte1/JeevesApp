// AIAgent.swift (assumed)
import Foundation
import Combine

protocol AIAgent {
    var agentName: String { get }
    var capabilities: [AgentCapability] { get }
    var supportedCommands: [CommandPattern] { get }
    var priority: Int { get }
    var statePublisher: AnyPublisher<AgentState, Never> { get }
    var isLocal: Bool { get }
    var version: String { get }
    
    func handle(input: AgentInput, context: AgentContext, completion: @escaping (AgentResponse) -> Void)
    func start(completion: @escaping () -> Void)
    func stop(completion: @escaping () -> Void)
    func configure(with config: AgentConfiguration, completion: @escaping () -> Void)
    func isAvailable() -> Bool
    func dependencies() -> [String]
}

enum AgentState {
    case ready
    case busy
    case failed
}

struct AgentCapability: Hashable {
    static let processesText = AgentCapability()
    static let processesAudio = AgentCapability()
    static let adjustableTone = AgentCapability()
}

struct CommandPattern {
    let verb: String
    let noun: String?
    let wildcard: Bool
    
    init(verb: String, noun: String?, wildcard: Bool) {
        self.verb = verb
        self.noun = noun
        self.wildcard = wildcard
    }
}

struct AgentInput {
    enum Source {
        case text
        case audio
        case ui
    }
    
    let source: Source
    let data: Any
}

struct AgentResponse {
    let text: String
    let success: Bool
    let metadata: [String: Any]
    let error: AgentError?
    let actions: [AgentAction]
}

struct AgentError {
    let code: Int
    let message: String
    let retryable: Bool
}

enum AgentAction {
    case updateContext(key: String, value: String)
    case triggerAgent(agentName: String, command: String)
}

struct AgentConfiguration {
    let settings: [String: String]
}

struct CoachPersonality {
    let tone: Tone
    let proactivity: Int
    let frequency: Int
    
    enum Tone: String {
        case friendly
        case strict
        case neutral
    }
}
