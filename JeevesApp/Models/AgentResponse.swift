// AgentResponse.swift
import Foundation

struct AgentResponse {
    let text: String
    let success: Bool
    let metadata: [String: String]
    let error: AgentError?
    let actions: [Action]
    
    enum Action {
        case updateContext(key: String, value: String)
        case triggerAgent(agentName: String, command: String)
    }
}

struct AgentError: Error {
    let code: Int
    let message: String
    let retryable: Bool
}
