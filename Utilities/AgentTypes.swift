// Utilities/AgentTypes.swift
import Foundation
import Combine

struct CommandPattern {
    let verb: String
    let noun: String?
    let wildcard: Bool
    
    init(verb: String, noun: String? = nil, wildcard: Bool = false) {
        self.verb = verb
        self.noun = noun
        self.wildcard = wildcard
    }
}

enum AgentCapability {
    case processesText
    case processesAudio
    case needsNetwork
    case adjustableTone
}

enum AgentState {
    case ready
    case busy
    case failed
}

struct AgentConfiguration {
    let settings: [String: Any]
    
    init(settings: [String: Any] = [:]) {
        self.settings = settings
    }
}

struct CoachPersonality {
    enum Tone: String {
        case professional = "professional"
        case motivational = "motivational"
        case witty = "witty"
        case devilsAdvocate = "devilsAdvocate"
        case chattyWitty = "chattyWitty" // Added for SessionTester
    }
    
    let tone: Tone
    let proactivity: Float
    let frequency: TimeInterval
    
    init(tone: Tone = .professional, proactivity: Float = 0.5, frequency: TimeInterval = 300) {
        self.tone = tone
        self.proactivity = proactivity
        self.frequency = frequency
    }
}
