//
//  PersistenceTests.swift
//  JeevesApp
//
//  Created by Mitch Montelaro on 3/3/25.
//


import XCTest
import CoreData
@testable import JeevesApp

final class PersistenceTests: XCTestCase {
    
    // Test in-memory Core Data initialization
    func testPersistenceControllerInit() {
        let controller = PersistenceController(inMemory: true)
        XCTAssertNotNil(controller.container)
        XCTAssertNotNil(controller.viewContext)
    }
    
    // Test saving and fetching a task
    func testSaveAndFetchTask() {
        // Create an in-memory persistence controller for testing
        let controller = PersistenceController(inMemory: true)
        
        do {
            // Save a test task
            try controller.saveTestTask()
            
            // Fetch all tasks
            let fetchedTasks = try controller.fetchTasks()
            
            // Verify we got back exactly one task
            XCTAssertEqual(fetchedTasks.count, 1, "Should have fetched exactly one task")
            
            // Verify the task properties
            if let task = fetchedTasks.first {
                XCTAssertEqual(task.title, "Test Task")
                //XCTAssertNil(task.taskDescription)
                XCTAssertFalse(task.completed)
                XCTAssertEqual(task.column, "To Do")
                XCTAssertNotNil(task.createdAt)
                XCTAssertNotNil(task.id)
            } else {
                XCTFail("Failed to fetch the test task")
            }
            
        } catch {
            XCTFail("Failed to save or fetch from Core Data: \(error)")
        }
    }
    
    // Test saving multiple tasks and fetching them
    func testMultipleTasks() {
        let controller = PersistenceController(inMemory: true)
        let context = controller.viewContext
        
        // Create and save 3 tasks
        for i in 1...3 {
            let task = TaskEntity(context: context)
            task.id = UUID()
            task.title = "Task \(i)"
            task.completed = (i == 3) // Mark the third task as completed
            task.createdAt = Date()
            task.column = (i == 1) ? "To Do" : ((i == 2) ? "In Progress" : "Done")
        }
        
        do {
            try context.save()
            
            // Fetch all tasks
            let fetchedTasks = try controller.fetchTasks()
            
            // Verify we got back all three tasks
            XCTAssertEqual(fetchedTasks.count, 3, "Should have fetched 3 tasks")
            
            // Count tasks in each column
            let todoTasks = fetchedTasks.filter { $0.column == "To Do" }
            let inProgressTasks = fetchedTasks.filter { $0.column == "In Progress" }
            let doneTasks = fetchedTasks.filter { $0.column == "Done" }
            
            XCTAssertEqual(todoTasks.count, 1, "Should have 1 task in To Do")
            XCTAssertEqual(inProgressTasks.count, 1, "Should have 1 task in In Progress")
            XCTAssertEqual(doneTasks.count, 1, "Should have 1 task in Done")
            
            // Verify completed status
            let completedTasks = fetchedTasks.filter { $0.completed }
            XCTAssertEqual(completedTasks.count, 1, "Should have 1 completed task")
            XCTAssertEqual(completedTasks.first?.column, "Done", "Completed task should be in Done column")
            
        } catch {
            XCTFail("Failed to save or fetch multiple tasks: \(error)")
        }
    }
    
    // Test modifying a task
    func testModifyTask() {
        let controller = PersistenceController(inMemory: true)
        
        do {
            // Save a test task
            try controller.saveTestTask()
            
            // Fetch the test task
            var fetchedTasks = try controller.fetchTasks()
            XCTAssertEqual(fetchedTasks.count, 1, "Should have fetched exactly one task")
            
            // Modify the task
            if let task = fetchedTasks.first {
                task.title = "Updated Task Title"
                task.completed = true
                task.column = "Done"
                try controller.viewContext.save()
            }
            
            // Fetch the task again
            fetchedTasks = try controller.fetchTasks()
            XCTAssertEqual(fetchedTasks.count, 1, "Should still have exactly one task")
            
            // Verify the changes
            if let updatedTask = fetchedTasks.first {
                XCTAssertEqual(updatedTask.title, "Updated Task Title", "Title should be updated")
                XCTAssertTrue(updatedTask.completed, "Task should be marked as completed")
                XCTAssertEqual(updatedTask.column, "Done", "Task should be moved to Done column")
            }
            
        } catch {
            XCTFail("Failed to modify task: \(error)")
        }
    }
    
    // Test deleting a task
    func testDeleteTask() {
        let controller = PersistenceController(inMemory: true)
        
        do {
            // Save a test task
            try controller.saveTestTask()
            
            // Verify it was saved
            var fetchedTasks = try controller.fetchTasks()
            XCTAssertEqual(fetchedTasks.count, 1, "Should have fetched exactly one task")
            
            // Delete the task
            if let taskToDelete = fetchedTasks.first {
                controller.viewContext.delete(taskToDelete)
                try controller.viewContext.save()
            }
            
            // Verify the task was deleted
            fetchedTasks = try controller.fetchTasks()
            XCTAssertEqual(fetchedTasks.count, 0, "Should have no tasks after deletion")
            
        } catch {
            XCTFail("Failed to delete task: \(error)")
        }
    }
}
