// AgentContext.swift
import Foundation
import CoreData  // Ensure CoreData is imported

struct AgentContext {
    var hot: HotContext
    var warm: WarmContext
    var cold: ColdContext
    
    init(hot: HotContext = HotContext(),
         warm: WarmContext = WarmContext(),
         cold: ColdContext = ColdContext()) {
        self.hot = hot
        self.warm = warm
        self.cold = cold
    }
}

struct HotContext {
    var muted: Bool
    var deepFocus: Bool
    
    init(muted: Bool = false, deepFocus: Bool = false) {
        self.muted = muted
        self.deepFocus = deepFocus
    }
}

struct WarmContext {
    var tasks: [Task]  // Refers to the Core Data Task entity
    var summaries: [String]
    
    init(tasks: [Task] = [], summaries: [String] = []) {
        self.tasks = tasks
        self.summaries = summaries
    }
}

struct ColdContext {
    let userID: String
    let sessionID: String
    
    init(userID: String = "mock_user", sessionID: String = UUID().uuidString) {
        self.userID = userID
        self.sessionID = sessionID
    }
}
