// AIAgentCoordinator.swift
import Foundation
import Combine

class AIAgentCoordinator: ObservableObject {
    private var agents: [String: AIAgent] = [:]
    private var cancellables = Set<AnyCancellable>()
    private let agentTimeout: TimeInterval = 5.0
    let sessionManager: SessionManager
    @Published private var responseText: String = "Waiting for response..."
    
    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
        NSLog("AIAgentCoordinator initialized")
    }
    
    func registerAgent(_ agent: AIAgent) {
        agents[agent.agentName] = agent
        NSLog("Registering agent: \(agent.agentName) with capabilities: \(agent.capabilities)")
        NSLog("Current agents: \(agents.keys)")
        
        agent.statePublisher
            .sink { [weak self] state in
                self?.handleAgentStateChange(agent: agent, newState: state)
            }
            .store(in: &cancellables)
        
        startAgent(agent)
        startDependencies(for: agent)
        
        NSLog("Registered agent: \(agent.agentName)")
    }
    
    func unregisterAgent(named agentName: String) {
        guard let agent = agents[agentName] else {
            NSLog("Cannot unregister agent \(agentName): not found")
            return
        }
        
        agent.stop { }
        agents.removeValue(forKey: agentName)
        NSLog("Unregistered agent: \(agentName)")
    }
    
    private func startAgent(_ agent: AIAgent) {
        if !agent.isAvailable() {
            NSLog("Agent \(agent.agentName) is not available, skipping start")
            return
        }
        
        NSLog("Starting agent: \(agent.agentName)")
        agent.start { }
    }
    
    private func startDependencies(for agent: AIAgent) {
        let dependencies = agent.dependencies()
        for dependencyName in dependencies {
            guard let dependency = agents[dependencyName] else {
                NSLog("Warning: Dependency \(dependencyName) for agent \(agent.agentName) not found")
                continue
            }
            
            if !dependency.isAvailable() {
                NSLog("Dependency \(dependencyName) is not available")
                continue
            }
            
            NSLog("Starting dependency \(dependencyName) for agent \(agent.agentName)")
            dependency.start { }
        }
    }
    
    private func handleAgentStateChange(agent: AIAgent, newState: AgentState) {
        switch newState {
        case .ready:
            NSLog("Agent \(agent.agentName) is ready")
        case .busy:
            NSLog("Agent \(agent.agentName) is busy")
        case .failed:
            NSLog("Agent \(agent.agentName) has failed")
        }
    }
    
    func process(input: AgentInput, context: AgentContext, completion: @escaping (AgentResponse) -> Void) {
        NSLog("AIAgentCoordinator processing input: \(input.data), source: \(input.source)")
        NSLog("Available agents: \(agents.keys)")
        let matchingAgents = findMatchingAgents(for: input)
        NSLog("Found \(matchingAgents.count) matching agents: \(matchingAgents.map { $0.agentName })")
        
        if matchingAgents.isEmpty {
            let fallback = createFallbackResponse(for: input)
            NSLog("No matching agents, returning fallback: \(fallback.text)")
            completion(fallback)
            return
        }
        
        var processed = false
        let dispatchGroup = DispatchGroup()
        
        for agent in matchingAgents {
            dispatchGroup.enter()
            
            let timeoutWorkItem = DispatchWorkItem {
                if !processed {
                    let timeoutResponse = AgentResponse(text: "Timeout", success: false, metadata: [:], error: nil, actions: [])
                    NSLog("Timeout for agent \(agent.agentName)")
                    completion(timeoutResponse)
                    dispatchGroup.leave()
                }
            }
            
            DispatchQueue.global().async(execute: timeoutWorkItem)
            DispatchQueue.global().async {
                agent.handle(input: input, context: context) { response in
                    if !processed {
                        timeoutWorkItem.cancel()
                        processed = true
                        NSLog("Agent \(agent.agentName) responded with: \(response.text)")
                        
                        DispatchQueue.global().async {
                            self.processActions(in: response, context: context) { updatedContext in
                                if response.success {
                                    self.responseText = response.text
                                    if let error = response.error {
                                        self.responseText += "\nError: \(error.message)"
                                    }
                                    completion(response)
                                } else if let error = response.error, !error.retryable {
                                    self.responseText = response.text + "\nError: \(error.message)"
                                    completion(response)
                                } else {
                                    NSLog("Agent \(agent.agentName) unsuccessful, trying next")
                                    dispatchGroup.leave()
                                }
                            }
                        }
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if !processed {
                let fallback = self.createFallbackResponse(for: input)
                self.responseText = fallback.text
                NSLog("All agents failed, returning fallback: \(fallback.text)")
                completion(fallback)
            }
        }
    }
    
    private func findMatchingAgents(for input: AgentInput) -> [AIAgent] {
        if case .text = input.source {
            guard let textInput = input.data as? String else { return [] } // Remove unnecessary cast
            let matchingAgents = agents.values.filter { agent in
                let matches = agent.isAvailable() &&
                    (agent.capabilities.contains(.processesText) || agent.capabilities.contains(.processesAudio)) &&
                    isCommandSupported(textInput, by: agent)
                NSLog("Agent \(agent.agentName) matches: \(matches)")
                return matches
            }
            return matchingAgents.sorted { $0.priority > $1.priority }
        }
        
        if case .audio = input.source {
            let audioAgents = agents.values.filter { agent in
                agent.isAvailable() && agent.capabilities.contains(.processesAudio)
            }
            return audioAgents.sorted { $0.priority > $1.priority }
        }
        
        if case .ui = input.source {
            return agents.values
                .filter { $0.isAvailable() }
                .sorted { $0.priority > $1.priority }
        }
        
        return []
    }
    
    private func isCommandSupported(_ command: String, by agent: AIAgent) -> Bool {
        for pattern in agent.supportedCommands {
            if pattern.wildcard {
                if command.lowercased().hasPrefix(pattern.verb.lowercased()) {
                    NSLog("Wildcard match for \(command) with pattern \(pattern.verb)")
                    return true
                }
            } else if let noun = pattern.noun {
                if command.lowercased().contains(pattern.verb.lowercased()) &&
                   command.lowercased().contains(noun.lowercased()) {
                    NSLog("Exact match for \(command) with pattern \(pattern.verb) \(noun)")
                    return true
                }
            } else {
                if command.lowercased().contains(pattern.verb.lowercased()) {
                    NSLog("Verb match for \(command) with pattern \(pattern.verb)")
                    return true
                }
            }
        }
        NSLog("No match for \(command) in agent commands")
        return false
    }
    
    private func createFallbackResponse(for input: AgentInput) -> AgentResponse {
        var message = "I'm not sure how to help with that."
        if case .text = input.source {
            message = "I don't understand '\(input.data)'. Try again."
        }
        let response = AgentResponse(
            text: message,
            success: false,
            metadata: ["input": input.data],
            error: AgentError(code: 404, message: "No agent available", retryable: false),
            actions: []
        )
        NSLog("Fallback response created: \(message)")
        return response
    }
    
    private func processActions(in response: AgentResponse, context: AgentContext, completion: @escaping (AgentContext) -> Void) {
        var updatedContext = context
        let dispatchGroup = DispatchGroup()
        
        for action in response.actions {
            dispatchGroup.enter()
            
            switch action {
            case .updateContext(let key, let value):
                if key == "muted", let boolValue = Bool(value) {
                    updatedContext.hot.muted = boolValue
                } else if key == "deepFocus", let boolValue = Bool(value) {
                    updatedContext.hot.deepFocus = boolValue
                }
                NSLog("Updated context: \(key) = \(value)")
                dispatchGroup.leave()
                
            case .triggerAgent(let agentName, let command):
                if let agent = agents[agentName], agent.isAvailable() {
                    let triggerInput = AgentInput(source: .text, data: command)
                    agent.handle(input: triggerInput, context: updatedContext) { _ in
                        dispatchGroup.leave()
                    }
                } else {
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            do {
                try self.sessionManager.saveSession(context: updatedContext)
                completion(updatedContext)
            } catch {
                NSLog("Failed to save context: \(error)")
                completion(updatedContext)
            }
        }
    }
    
    func setPersonality(personality: CoachPersonality, completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        
        for agent in agents.values where agent.capabilities.contains(.adjustableTone) {
            dispatchGroup.enter()
            let config = AgentConfiguration(settings: [
                "tone": personality.tone.rawValue,
                "proactivity": String(personality.proactivity),
                "frequency": String(personality.frequency)
            ])
            DispatchQueue.global().async {
                agent.configure(with: config) { }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            NSLog("Updated personality for supported agents")
            completion()
        }
    }
    
    func switchProvider(type: String, provider: String, completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            NSLog("Switching \(type) to \(provider) - full implementation later")
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    private func withTimeout<T>(timeout: TimeInterval, task: @escaping () throws -> T, completion: @escaping (Result<T, Error>) -> Void) {
        let timeoutWorkItem = DispatchWorkItem {
            completion(.failure(TimeoutError()))
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + timeout, execute: timeoutWorkItem)
        
        DispatchQueue.global().async {
            do {
                let result = try task()
                timeoutWorkItem.cancel()
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } catch {
                timeoutWorkItem.cancel()
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    private struct TimeoutError: Error {
        var localizedDescription: String { "Operation timed out" }
    }
}
