//
//  JeevesDataStructuresTests.swift
//  JeevesApp
//
//  Created by Mitch Montelaro on 3/3/25.
//


import XCTest
@testable import JeevesApp // Adjust to your actual module name

final class JeevesDataStructuresTests: XCTestCase {
    
    // MARK: - AgentContext Tests
    
    func testAgentContextInitialization() {
        let context = AgentContext()
        
        // Test default initialization
        XCTAssertEqual(context.hot.timerState.status, .stopped)
        XCTAssertEqual(context.hot.timerState.remainingTime, 1500) // 25 mins
        XCTAssertEqual(context.hot.timerState.speedMultiplier, 1.0)
        XCTAssertTrue(context.hot.currentTasks.isEmpty)
        XCTAssertFalse(context.hot.muted)
        XCTAssertFalse(context.hot.deepFocus)
        XCTAssertTrue(context.warm.summaries.isEmpty)
        XCTAssertTrue(context.warm.commands.isEmpty)
        XCTAssertTrue(context.cold.boards.isEmpty)
    }
    
    func testAgentContextCustomInitialization() {
        let task = Task(title: "Test Task")
        let summary = SessionSummary(completedTasks: [task])
        let command = CommandHistory(command: "start timer")
        let board = KanbanBoard(name: "Test Board")
        let personality = CoachPersonality(tone: .chattyWitty)
        
        let hotContext = HotContext(
            currentTasks: [task], personality: personality,
            muted: true
        )
        
        let warmContext = WarmContext(
            summaries: [summary],
            commands: [command]
        )
        
        let coldContext = ColdContext(
            boards: [board]
        )
        
        let context = AgentContext(
            hot: hotContext,
            warm: warmContext,
            cold: coldContext
        )
        
        // Verify hot context
        XCTAssertEqual(context.hot.personality.tone, .chattyWitty)
        XCTAssertEqual(context.hot.currentTasks.count, 1)
        XCTAssertEqual(context.hot.currentTasks[0].title, "Test Task")
        XCTAssertTrue(context.hot.muted)
        
        // Verify warm context
        XCTAssertEqual(context.warm.summaries.count, 1)
        XCTAssertEqual(context.warm.commands.count, 1)
        XCTAssertEqual(context.warm.commands[0].command, "start timer")
        
        // Verify cold context
        XCTAssertEqual(context.cold.boards.count, 1)
        XCTAssertEqual(context.cold.boards[0].name, "Test Board")
    }
    
    // MARK: - TimerState Tests
    
    func testTimerStateInitialization() {
        let defaultTimer = TimerState()
        XCTAssertEqual(defaultTimer.status, .stopped)
        XCTAssertEqual(defaultTimer.remainingTime, 1500)
        XCTAssertEqual(defaultTimer.speedMultiplier, 1.0)
        XCTAssertNil(defaultTimer.startTime)
        XCTAssertEqual(defaultTimer.totalDuration, 1500)
        
        let now = Date()
        let customTimer = TimerState(
            status: .running,
            remainingTime: 600,
            speedMultiplier: 1.2,
            startTime: now,
            totalDuration: 1200
        )
        
        XCTAssertEqual(customTimer.status, .running)
        XCTAssertEqual(customTimer.remainingTime, 600)
        XCTAssertEqual(customTimer.speedMultiplier, 1.2)
        XCTAssertEqual(customTimer.startTime, now)
        XCTAssertEqual(customTimer.totalDuration, 1200)
    }
    
    // MARK: - CoachPersonality Tests
    
    func testCoachPersonalityInitialization() {
        let defaultPersonality = CoachPersonality()
        XCTAssertEqual(defaultPersonality.tone, .professional)
        XCTAssertEqual(defaultPersonality.proactivity, 0.5)
        XCTAssertEqual(defaultPersonality.frequency, 600) // 10 minutes
        
        let customPersonality = CoachPersonality(
            tone: .motivational,
            proactivity: 0.8,
            frequency: 300
        )
        
        XCTAssertEqual(customPersonality.tone, .motivational)
        XCTAssertEqual(customPersonality.proactivity, 0.8)
        XCTAssertEqual(customPersonality.frequency, 300) // 5 minutes
    }
    
    func testCoachPersonalityEquality() {
        let personality1 = CoachPersonality(tone: .motivational, proactivity: 0.7)
        let personality2 = CoachPersonality(tone: .motivational, proactivity: 0.7)
        let personality3 = CoachPersonality(tone: .devilsAdvocate, proactivity: 0.7)
        
        XCTAssertEqual(personality1, personality2)
        XCTAssertNotEqual(personality1, personality3)
    }
    
    // MARK: - Task Tests
    
    func testTaskInitialization() {
        let defaultTask = Task(title: "Default Task")
        XCTAssertEqual(defaultTask.title, "Default Task")
        XCTAssertNil(defaultTask.description)
        XCTAssertFalse(defaultTask.completed)
        XCTAssertNil(defaultTask.attachments)
        XCTAssertEqual(defaultTask.column, "To Do")
        
        let attachment = Attachment(
            filename: "test.jpg",
            type: .image,
            url: URL(string: "file:///test.jpg")!
        )
        
        let customTask = Task(
            title: "Custom Task",
            description: "Task description",
            completed: true,
            attachments: [attachment],
            column: "Done"
        )
        
        XCTAssertEqual(customTask.title, "Custom Task")
        XCTAssertEqual(customTask.description, "Task description")
        XCTAssertTrue(customTask.completed)
        XCTAssertEqual(customTask.attachments?.count, 1)
        XCTAssertEqual(customTask.attachments?[0].filename, "test.jpg")
        XCTAssertEqual(customTask.column, "Done")
    }
    
    // MARK: - Attachment Tests
    
    func testAttachmentInitialization() {
        let url = URL(string: "file:///document.pdf")!
        let attachment = Attachment(
            filename: "document.pdf",
            type: .pdf,
            url: url
        )
        
        XCTAssertEqual(attachment.filename, "document.pdf")
        XCTAssertEqual(attachment.type, .pdf)
        XCTAssertEqual(attachment.url, url)
    }
    
    // MARK: - Kanban Tests
    
    func testKanbanBoardInitialization() {
        let defaultBoard = KanbanBoard(name: "Project Board")
        
        XCTAssertEqual(defaultBoard.name, "Project Board")
        XCTAssertEqual(defaultBoard.columns.count, 3)
        XCTAssertEqual(defaultBoard.columns[0].name, "To Do")
        XCTAssertEqual(defaultBoard.columns[1].name, "In Progress")
        XCTAssertEqual(defaultBoard.columns[2].name, "Done")
        
        // Create a custom board with tasks
        let task1 = Task(title: "Task 1", column: "Backlog")
        let task2 = Task(title: "Task 2", column: "Backlog")
        let backlogColumn = KanbanColumn(name: "Backlog", tasks: [task1, task2])
        let inProgressColumn = KanbanColumn(name: "Working")
        let doneColumn = KanbanColumn(name: "Completed")
        
        let customBoard = KanbanBoard(
            name: "Custom Board",
            columns: [backlogColumn, inProgressColumn, doneColumn]
        )
        
        XCTAssertEqual(customBoard.name, "Custom Board")
        XCTAssertEqual(customBoard.columns.count, 3)
        XCTAssertEqual(customBoard.columns[0].name, "Backlog")
        XCTAssertEqual(customBoard.columns[0].tasks.count, 2)
        XCTAssertEqual(customBoard.columns[1].name, "Working")
        XCTAssertEqual(customBoard.columns[2].name, "Completed")
    }
    
    // MARK: - Command History Tests
    
    func testCommandHistoryInitialization() {
        let command = CommandHistory(command: "start timer")
        
        XCTAssertEqual(command.command, "start timer")
        XCTAssertTrue(command.successful)
        
        let failedCommand = CommandHistory(
            command: "invalid command",
            successful: false
        )
        
        XCTAssertEqual(failedCommand.command, "invalid command")
        XCTAssertFalse(failedCommand.successful)
    }
    
    // MARK: - WarmContext Command Limit
    
    func testWarmContextCommandLimit() {
        // Create more than 10 commands
        var commands: [CommandHistory] = []
        for i in 1...15 {
            commands.append(CommandHistory(command: "command \(i)"))
        }
        
        let warmContext = WarmContext(commands: commands)
        
        // Verify commands are capped at 10
        XCTAssertEqual(warmContext.commands.count, 10)
        XCTAssertEqual(warmContext.commands[0].command, "command 1")
        XCTAssertEqual(warmContext.commands[9].command, "command 10")
    }
    
    // MARK: - SessionSummary Tests
    
    func testSessionSummaryInitialization() {
        let task = Task(title: "Completed Task", completed: true)
        let summary = SessionSummary(
            completedTasks: [task],
            duration: 1500,
            notes: "Great session!"
        )
        
        XCTAssertEqual(summary.completedTasks.count, 1)
        XCTAssertEqual(summary.completedTasks[0].title, "Completed Task")
        XCTAssertEqual(summary.duration, 1500)
        XCTAssertEqual(summary.notes, "Great session!")
    }
}
