//
//  SessionManagerTests.swift
//  JeevesApp
//
//  Created by Mitch Montelaro on 3/3/25.
//


import XCTest
@testable import JeevesApp

final class SessionManagerTests: XCTestCase {
    
    var persistenceController: PersistenceController!
    var sessionManager: SessionManager!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        sessionManager = SessionManager(persistenceController: persistenceController)
    }
    
    override func tearDown() {
        persistenceController = nil
        sessionManager = nil
        super.tearDown()
    }
    
    func testSaveAndLoadSession() async {
        // Create a test AgentContext with custom data
        let timerState = TimerState(
            status: .running,
            remainingTime: 1200,
            speedMultiplier: 1.2
        )
        
        let personality = CoachPersonality(
            tone: .motivational,
            proactivity: 0.8,
            frequency: 300
        )
        
        let task1 = Task(title: "Task 1", completed: false)
        let task2 = Task(title: "Task 2", completed: true)
        
        let hotContext = HotContext(
            timerState: timerState,
            currentTasks: [task1, task2],
            personality: personality,
            muted: true,
            deepFocus: false
        )
        
        let board = KanbanBoard(name: "Test Board")
        let coldContext = ColdContext(boards: [board])
        
        let originalContext = AgentContext(
            hot: hotContext,
            cold: coldContext
        )
        
        do {
            // Save the session
            try await sessionManager.saveSession(context: originalContext)
            
            // Load the session
            let loadedContext = try await sessionManager.loadSession()
            
            // Verify the loaded context matches the original
            XCTAssertEqual(loadedContext.hot.timerState.status, originalContext.hot.timerState.status)
            XCTAssertEqual(loadedContext.hot.timerState.remainingTime, originalContext.hot.timerState.remainingTime)
            XCTAssertEqual(loadedContext.hot.timerState.speedMultiplier, originalContext.hot.timerState.speedMultiplier)
            
            XCTAssertEqual(loadedContext.hot.personality.tone, originalContext.hot.personality.tone)
            XCTAssertEqual(loadedContext.hot.personality.proactivity, originalContext.hot.personality.proactivity)
            XCTAssertEqual(loadedContext.hot.personality.frequency, originalContext.hot.personality.frequency)
            
            XCTAssertEqual(loadedContext.hot.muted, originalContext.hot.muted)
            XCTAssertEqual(loadedContext.hot.deepFocus, originalContext.hot.deepFocus)
            
            XCTAssertEqual(loadedContext.hot.currentTasks.count, originalContext.hot.currentTasks.count)
            
            XCTAssertEqual(loadedContext.cold.boards.count, originalContext.cold.boards.count)
            XCTAssertEqual(loadedContext.cold.boards.first?.name, originalContext.cold.boards.first?.name)
        } catch {
            XCTFail("Failed to save or load session: \(error)")
        }
    }
    
    func testSummarizeCycle() async {
        // Create a context with completed and uncompleted tasks
        let task1 = Task(title: "Completed task", completed: true)
        let task2 = Task(title: "Uncompleted task", completed: false)
        
        let hotContext = HotContext(
            currentTasks: [task1, task2]
        )
        
        let context = AgentContext(hot: hotContext)
        
        // Get the summary
        let summary = await sessionManager.summarizeCycle(context: context)
        
        // Verify the summary
        XCTAssertEqual(summary.completedTasks.count, 1, "Summary should only include completed tasks")
        XCTAssertEqual(summary.completedTasks.first?.title, "Completed task")
        XCTAssertEqual(summary.notes, "Completed 1 tasks")
    }
    
    func testEmptySessionLoad() async {
        do {
            // Load without saving first (should return default context)
            let context = try await sessionManager.loadSession()
            
            // Verify we get a default context
            XCTAssertEqual(context.hot.timerState.status, .stopped)
            XCTAssertTrue(context.hot.currentTasks.isEmpty)
            XCTAssertFalse(context.hot.muted)
            XCTAssertEqual(context.hot.personality.tone, .professional)
        } catch {
            XCTFail("Failed to load empty session: \(error)")
        }
    }
}