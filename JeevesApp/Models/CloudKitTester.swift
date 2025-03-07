//
//  CloudKitTester.swift
//  JeevesApp
//
//  Created by Mitch Montelaro on 3/4/25.
//


// CloudKitTester.swift
import Foundation
import CoreData
import SwiftUI

class CloudKitTester: ObservableObject {
    @Published var testResults: String = ""
    @Published var testTasks: [TaskEntity] = []
    
    private let persistenceController: PersistenceController
    
    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }
    
    func runTest() {
        let testId = UUID().uuidString.prefix(8)
        createTestData(testId: String(testId))
        listAllTestData()
    }
    
    func createTestData(testId: String) {
        let viewContext = persistenceController.viewContext
        
        let task = TaskEntity(context: viewContext)
        task.id = UUID()
        task.title = "CloudKit Test Task - \(testId)"
        task.completed = false
        task.createdAt = Date()
        task.column = "To Do"
        
        do {
            try viewContext.save()
            addToResults("✅ Created test task with ID: \(testId)")
            addToResults("Test data created at: \(Date().formatted())")
        } catch {
            addToResults("❌ Failed to save test task: \(error.localizedDescription)")
        }
    }
    
    func listAllTestData() {
        let viewContext = persistenceController.viewContext
        let request = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS %@", "CloudKit Test Task")
        
        do {
            let tasks = try viewContext.fetch(request)
            testTasks = tasks
            
            addToResults("📋 Found \(tasks.count) test tasks:")
            for task in tasks {
                addToResults("- \(task.title ?? "Untitled")")
            }
        } catch {
            addToResults("❌ Failed to fetch test tasks: \(error.localizedDescription)")
        }
    }
    
    func clearAllTestData() {
        let viewContext = persistenceController.viewContext
        let request = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS %@", "CloudKit Test Task")
        
        do {
            let tasks = try viewContext.fetch(request)
            for task in tasks {
                viewContext.delete(task)
            }
            try viewContext.save()
            addToResults("🧹 Deleted all test tasks")
            testTasks = []
        } catch {
            addToResults("❌ Failed to delete test tasks: \(error.localizedDescription)")
        }
    }
    
    private func addToResults(_ text: String) {
        testResults += text + "\n"
        print(text)
    }
}