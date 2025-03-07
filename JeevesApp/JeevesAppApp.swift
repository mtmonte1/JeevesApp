// JeevesApp.swift
import SwiftUI

@main
struct JeevesApp: App {
    let persistence = PersistenceController.shared
    let sessionManager = SessionManager.shared
    @State private var cloudKitError: String? = nil
    
    init() {
        NSLog("JeevesApp initialized")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(sessionManager: sessionManager)
                .environment(\.managedObjectContext, persistence.viewContext)
                .task {
                    NSLog("JeevesApp task started")
                    do {
                        let tasks = try persistence.fetchTasks()
                        NSLog("iCloud: Fetched \(tasks.count) tasks: \(tasks.map { $0.title ?? "Untitled" })")
                        if tasks.isEmpty {
                            try persistence.saveTestTask()
                            NSLog("Saved new Test Task")
                        }
                        let iCloudAvailable = await persistence.checkiCloudStatus()
                        NSLog("iCloud available: \(iCloudAvailable)")
                        if !iCloudAvailable {
                            cloudKitError = "iCloud is unavailable. Syncing may be limited."
                        }
                    } catch {
                        NSLog("Error syncing tasks: \(error.localizedDescription)")
                        cloudKitError = "Error syncing with iCloud: \(error.localizedDescription)"
                    }
                    NSLog("JeevesApp task completed")
                }
                .onAppear {
                    NSLog("JeevesApp WindowGroup onAppear called")
                    if let error = cloudKitError {
                        NSLog("CloudKit error: \(error)")
                    }
                }
        }
    }
}
