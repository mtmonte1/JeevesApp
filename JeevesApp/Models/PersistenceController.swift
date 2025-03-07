import CoreData
import CloudKit
import os.log

class PersistenceController {
    static let shared = PersistenceController()
    private let logger = Logger(subsystem: "com.mitch.JeevesApp", category: "persistence")
    
    let container: NSPersistentCloudKitContainer
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    private(set) var lastSyncTime: Date?
    private(set) var lastSyncError: Error?
    
    init(inMemory: Bool = false, containerIdentifier: String = "iCloud.com.mitch.JeevesApp") {
        container = NSPersistentCloudKitContainer(name: "JeevesAppModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            guard let description = container.persistentStoreDescriptions.first else {
                fatalError("Failed to retrieve persistent store description")
            }
            description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
                containerIdentifier: containerIdentifier
            )
            // Optional: Add history tracking for future robustness
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        }
        
        container.loadPersistentStores { [weak self] _, error in
            if let error = error as NSError? {
                self?.logger.error("Failed to load persistent store: \(error.localizedDescription)")
                self?.lastSyncError = error
                #if DEBUG
                fatalError("Persistent store failed: \(error), \(error.userInfo)")
                #endif
            } else {
                self?.logger.info("Successfully loaded persistent store")
            }
        }
        
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Log sync events
        NotificationCenter.default.addObserver(self,
            selector: #selector(storeRemoteChange(_:)),
            name: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator
        )
    }
    
    @objc private func storeRemoteChange(_ notification: Notification) {
        logger.info("Received remote change from iCloud")
        lastSyncTime = Date()
        lastSyncError = nil
    }
    
    func checkiCloudStatus() async -> Bool {
        do {
            let status = try await CKContainer(identifier: "iCloud.com.mitch.JeevesApp").accountStatus()
            let available = status == .available
            logger.info("iCloud status: \(available ? "available" : "unavailable")")
            return available
        } catch {
            logger.error("Failed to check iCloud status: \(error.localizedDescription)")
            lastSyncError = error
            return false
        }
    }
    
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
                logger.info("Saved context changes")
                lastSyncTime = Date()  // CloudKit syncs automatically on save
                lastSyncError = nil
            } catch {
                lastSyncError = error
                logger.error("Failed to save: \(error.localizedDescription)")
            }
        }
    }
    
    func saveTestTask() throws {
        let context = container.viewContext
        let task = TaskEntity(context: context)
        task.id = UUID()  // Ensure UUID is set here
        task.title = "Test Task"
        task.taskDescription = nil
        task.completed = false
        task.createdAt = Date()
        task.column = "To Do"
        try context.save()
        logger.info("Test task saved")
    }
    
    func fetchTasks() throws -> [TaskEntity] {
        let context = container.viewContext
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        return try context.fetch(request)
    }

    // Add this for previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.viewContext
        
        // Create sample tasks
        let task1 = TaskEntity(context: context)
        task1.id = UUID()
        task1.title = "Implement Core Data"
        task1.completed = false
        task1.createdAt = Date()
        task1.column = "To Do"
        
        let task2 = TaskEntity(context: context)
        task2.id = UUID()
        task2.title = "Set up voice interface"
        task2.completed = true
        task2.createdAt = Date().addingTimeInterval(-86400) // 1 day ago
        task2.column = "Done"
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
}

extension Notification.Name {
    static let cdDataChanged = Notification.Name("CDDataChangedNotification")
}
