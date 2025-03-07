// ColumnEntity+CoreDataProperties.swift
// JeevesApp
//
// Created by Mitch Montelaro on 3/4/25.
//
//

import Foundation
import CoreData

extension ColumnEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ColumnEntity> {
        return NSFetchRequest<ColumnEntity>(entityName: "ColumnEntity")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var board: BoardEntity?
    @NSManaged public var tasks: NSSet?
    
    // Convenience methods
    public var wrappedId: UUID {
        id ?? UUID()
    }
    
    public var wrappedName: String {
        name ?? "Untitled Column"
    }
    
    public var tasksArray: [TaskEntity] {
        let set = tasks as? Set<TaskEntity> ?? []
        return set.sorted {
            $0.wrappedCreatedAt < $1.wrappedCreatedAt
        }
    }
}

// MARK: Generated accessors for tasks
extension ColumnEntity {
    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: TaskEntity)
    
    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: TaskEntity)
    
    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)
    
    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)
}
