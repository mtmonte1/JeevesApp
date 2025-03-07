// SessionManager.swift
import Foundation
import CoreData  // Add this import

class SessionManager {
    static let shared = SessionManager()
    
    let context: AgentContext
    private let persistence: PersistenceController
    
    init(persistence: PersistenceController = .shared) {
        self.persistence = persistence
        self.context = AgentContext(
            hot: HotContext(),
            warm: WarmContext(tasks: [], summaries: []),
            cold: ColdContext()
        )
        NSLog("SessionManager initialized with persistence: \(persistence)")
    }
    
    func saveSession(context: AgentContext) throws {
        let tasks = try persistence.fetchTasks()
        NSLog("Saving session with \(tasks.count) tasks")
        try persistence.viewContext.save()
    }
    
    func loadSession() throws -> AgentContext {
        let tasks = try persistence.fetchTasks()
        let loadedContext = AgentContext(
            warm: WarmContext(tasks: tasks, summaries: context.warm.summaries),
            cold: context.cold
        )
        NSLog("Loaded session with \(tasks.count) tasks")
        return loadedContext
    }
}
