// LocalIntentParser.swift
import Foundation

/// Represents a parsed intent with action and optional parameters.
struct Intent {
    enum Action {
        case startTimer(duration: TimeInterval?)
        case stopTimer
        case pauseTimer
        case resumeTimer
        case mute
        case unmute
        case deepFocus(enabled: Bool)
        case summarizeSession
        case triggerAgent(name: String, command: String)
    }
    
    let action: Action
    let rawInput: String
}

/// A class to parse user input into actionable intents.
class LocalIntentParser {
    private let intentPatterns: [String: (String) -> Intent?] = [
        // Timer-related intents
        "start timer": { input in
            let components = input.lowercased().components(separatedBy: .whitespaces)
            if components.contains("start") && components.contains("timer") {
                if let duration = LocalIntentParser.parseDuration(from: components) {
                    return Intent(action: .startTimer(duration: duration), rawInput: input)
                }
                return Intent(action: .startTimer(duration: nil), rawInput: input)
            }
            return nil
        },
        "stop timer": { input in
            if input.lowercased().contains("stop timer") {
                return Intent(action: .stopTimer, rawInput: input)
            }
            return nil
        },
        "pause timer": { input in
            if input.lowercased().contains("pause timer") {
                return Intent(action: .pauseTimer, rawInput: input)
            }
            return nil
        },
        "resume timer": { input in
            if input.lowercased().contains("resume timer") {
                return Intent(action: .resumeTimer, rawInput: input)
            }
            return nil
        },
        // Audio-related intents
        "mute": { input in
            if input.lowercased().contains("mute") {
                return Intent(action: .mute, rawInput: input)
            }
            return nil
        },
        "unmute": { input in
            if input.lowercased().contains("unmute") {
                return Intent(action: .unmute, rawInput: input)
            }
            return nil
        },
        // Focus-related intents
        "deep focus": { input in
            if input.lowercased().contains("deep focus") {
                let enabled = !input.lowercased().contains("off")
                return Intent(action: .deepFocus(enabled: enabled), rawInput: input)
            }
            return nil
        },
        // Summary intent
        "summarize session": { input in
            if input.lowercased().contains("summarize session") {
                return Intent(action: .summarizeSession, rawInput: input)
            }
            return nil
        },
        // Agent trigger intent
        "trigger agent": { input in
            let components = input.lowercased().components(separatedBy: .whitespaces)
            if components.contains("trigger") && components.contains("agent") {
                if let agentIndex = components.firstIndex(of: "agent"),
                   components.count > agentIndex + 1 {
                    let agentName = components[agentIndex + 1]
                    let command = components.suffix(from: agentIndex + 2).joined(separator: " ")
                    return Intent(action: .triggerAgent(name: agentName, command: command), rawInput: input)
                }
            }
            return nil
        }
    ]
    
    /// Parses the input string into an Intent, if recognized.
    func parse(_ input: String) -> Intent? {
        let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        for (pattern, parser) in intentPatterns {
            if trimmedInput.lowercased().contains(pattern) {
                return parser(trimmedInput)
            }
        }
        return nil
    }
    
    /// Helper to parse duration from input (e.g., "25 minutes", "30 mins").
    private static func parseDuration(from components: [String]) -> TimeInterval? {
        for (index, component) in components.enumerated() {
            if let value = Int(component) {
                let nextWord = index + 1 < components.count ? components[index + 1] : ""
                switch nextWord.lowercased() {
                case "minutes", "mins", "min":
                    return TimeInterval(value * 60)
                case "seconds", "secs", "sec":
                    return TimeInterval(value)
                default:
                    continue
                }
            }
        }
        return nil
    }
}

// Extension to support debug printing
extension Intent: CustomStringConvertible {
    var description: String {
        switch action {
        case .startTimer(let duration):
            return "Intent: StartTimer\(duration.map { " (\($0 / 60) minutes)" } ?? "")"
        case .stopTimer:
            return "Intent: StopTimer"
        case .pauseTimer:
            return "Intent: PauseTimer"
        case .resumeTimer:
            return "Intent: ResumeTimer"
        case .mute:
            return "Intent: Mute"
        case .unmute:
            return "Intent: Unmute"
        case .deepFocus(let enabled):
            return "Intent: DeepFocus (enabled: \(enabled))"
        case .summarizeSession:
            return "Intent: SummarizeSession"
        case .triggerAgent(let name, let command):
            return "Intent: TriggerAgent (name: \(name), command: \(command))"
        }
    }
}
