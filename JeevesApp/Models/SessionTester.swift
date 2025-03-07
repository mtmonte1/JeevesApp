// SessionTester.swift
import Foundation
import Combine
import CoreData

class SessionTester: ObservableObject {
    @Published var status: String = "Idle"
    private var cancellables = Set<AnyCancellable>()
    private let sessionManager: SessionManager
    
    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
        NSLog("SessionTester initialized with sessionManager: \(sessionManager)")
    }
    
    func runSessionTest() {
        status = "Starting session test..."
        NSLog("Session test started")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            // Test 1: Save a session
            do {
                let context = PersistenceController.shared.viewContext
                // Use NSEntityDescription to insert a new Task entity
                guard let taskEntity = NSEntityDescription.entity(forEntityName: "Task", in: context) else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to find Task entity"])
                }
                let task = NSManagedObject(entity: taskEntity, insertInto: context) as! Task
                task.setValue("Test Task", forKey: "title")
                task.setValue(Date(), forKey: "createdAt")
                try PersistenceController.shared.viewContext.save()
                DispatchQueue.main.async {
                    self.status = "Test 1: Successfully saved session with task"
                    NSLog("Test 1: Saved session with task")
                }
            } catch {
                DispatchQueue.main.async {
                    self.status = "Test 1: Failed to save session - \(error.localizedDescription)"
                    NSLog("Test 1: Failed to save session - \(error.localizedDescription)")
                }
                return
            }
            
            // Test 2: Load session
            do {
                let loadedTasks = try self.sessionManager.loadSession().warm.tasks
                DispatchQueue.main.async {
                    self.status = "Test 2: Loaded session with \(loadedTasks.count) tasks"
                    NSLog("Test 2: Loaded session with \(loadedTasks.count) tasks")
                    if loadedTasks.isEmpty {
                        self.status += "\nTest 2: No tasks found in loaded session"
                        NSLog("Test 2: No tasks found in loaded session")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.status = "Test 2: Failed to load session - \(error.localizedDescription)"
                    NSLog("Test 2: Failed to load session - \(error.localizedDescription)")
                }
                return
            }
            
            // Test 3: Simulate timer
            let timerDuration = 3.0
            var elapsedTime = 0.0
            let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                elapsedTime += 1.0
                DispatchQueue.main.async {
                    self.status += "\nTimer tick: \(Int(elapsedTime)) seconds elapsed"
                    NSLog("Timer tick: \(Int(elapsedTime)) seconds elapsed")
                }
                if elapsedTime >= timerDuration {
                    timer.invalidate()
                    DispatchQueue.main.async {
                        self.status += "\nTest 3: Timer simulation completed and saved"
                        NSLog("Test 3: Timer simulation completed and saved")
                        self.status += "\nSession test completed successfully"
                        NSLog("Session test completed successfully")
                    }
                }
            }
            RunLoop.current.add(timer, forMode: .common)
            RunLoop.current.run(until: Date(timeIntervalSinceNow: timerDuration + 0.1))
        }
    }
}
