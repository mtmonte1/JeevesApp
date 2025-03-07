// MockAgent.swift (updated again for statePublisher)
import Foundation
import Combine

class MockAgent: AIAgent {
    var agentName: String = "MockAgent"
    var capabilities: [AgentCapability] = [.processesText, .adjustableTone]
    var supportedCommands: [CommandPattern] = [
        CommandPattern(verb: "start", noun: "timer", wildcard: false),
        CommandPattern(verb: "stop", noun: "timer", wildcard: false),
        CommandPattern(verb: "pause", noun: "timer", wildcard: false),
        CommandPattern(verb: "resume", noun: "timer", wildcard: false),
        CommandPattern(verb: "mute", noun: nil, wildcard: false),
        CommandPattern(verb: "unmute", noun: nil, wildcard: false),
        CommandPattern(verb: "deep", noun: "focus", wildcard: false),
        CommandPattern(verb: "summarize", noun: "session", wildcard: false),
        CommandPattern(verb: "start", noun: nil, wildcard: true),
        CommandPattern(verb: "trigger", noun: nil, wildcard: true)
    ]
    var priority: Int = 1
    private let stateSubject = PassthroughSubject<AgentState, Never>()
    var statePublisher: AnyPublisher<AgentState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    var isLocal: Bool = true
    var version: String = "1.0"
    
    func handle(input: AgentInput, context: AgentContext, completion: @escaping (AgentResponse) -> Void) {
        if case .text = input.source {
            guard let text = input.data as? String else {
                completion(AgentResponse(text: "Invalid input", success: false, metadata: [:], error: nil, actions: []))
                return
            }
            
            switch text {
            case "start_timer":
                completion(AgentResponse(text: "Timer started", success: true, metadata: [:], error: nil, actions: []))
            case "stop_timer":
                completion(AgentResponse(text: "Timer stopped", success: true, metadata: [:], error: nil, actions: []))
            case "pause_timer":
                completion(AgentResponse(text: "Timer paused", success: true, metadata: [:], error: nil, actions: []))
            case "resume_timer":
                completion(AgentResponse(text: "Timer resumed", success: true, metadata: [:], error: nil, actions: []))
            case "mute":
                completion(AgentResponse(text: "Muted", success: true, metadata: [:], error: nil, actions: [
                    .updateContext(key: "muted", value: "true")
                ]))
            case "unmute":
                completion(AgentResponse(text: "Unmuted", success: true, metadata: [:], error: nil, actions: [
                    .updateContext(key: "muted", value: "false")
                ]))
            case "deep_focus_true":
                completion(AgentResponse(text: "Deep focus enabled", success: true, metadata: [:], error: nil, actions: [
                    .updateContext(key: "deepFocus", value: "true")
                ]))
            case "deep_focus_false":
                completion(AgentResponse(text: "Deep focus disabled", success: true, metadata: [:], error: nil, actions: [
                    .updateContext(key: "deepFocus", value: "false")
                ]))
            case "summarize_session":
                let summary = context.warm.summaries.joined(separator: "\n")
                let responseText = summary.isEmpty ? "No summaries available" : "Session Summary:\n\(summary)"
                completion(AgentResponse(text: responseText, success: true, metadata: [:], error: nil, actions: []))
            default:
                if text.hasPrefix("start_timer_") {
                    let components = text.split(separator: "_")
                    if components.count > 2, let duration = Int(components[2]) {
                        completion(AgentResponse(text: "Timer started for \(duration) minutes", success: true, metadata: [:], error: nil, actions: []))
                    } else {
                        completion(AgentResponse(text: "Invalid duration", success: false, metadata: [:], error: nil, actions: []))
                    }
                } else if text.hasPrefix("trigger_") {
                    let components = text.split(separator: "_")
                    if components.count >= 3 {
                        let agentName = String(components[1])
                        let command = components[2...].joined(separator: "_")
                        completion(AgentResponse(text: "Triggering \(agentName) with \(command)", success: true, metadata: [:], error: nil, actions: [
                            .triggerAgent(agentName: agentName, command: command)
                        ]))
                    } else {
                        completion(AgentResponse(text: "Invalid trigger command", success: false, metadata: [:], error: nil, actions: []))
                    }
                } else {
                    completion(AgentResponse(text: "Unrecognized command: \(text)", success: false, metadata: [:], error: nil, actions: []))
                }
            }
        } else {
            completion(AgentResponse(text: "Unsupported input type", success: false, metadata: [:], error: nil, actions: []))
        }
    }
    
    func start(completion: @escaping () -> Void) {
        stateSubject.send(AgentState.ready)
        completion()
    }
    
    func stop(completion: @escaping () -> Void) {
        stateSubject.send(AgentState.failed)
        completion()
    }
    
    func configure(with config: AgentConfiguration, completion: @escaping () -> Void) {
        completion()
    }
    
    func isAvailable() -> Bool {
        return true
    }
    
    func dependencies() -> [String] {
        return []
    }
}
