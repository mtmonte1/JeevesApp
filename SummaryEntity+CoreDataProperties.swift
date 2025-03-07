// SummaryEntity+CoreDataProperties.swift
// JeevesApp
//
// Created by Mitch Montelaro on 3/4/25.
//
//

import Foundation
import CoreData

extension SummaryEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SummaryEntity> {
        return NSFetchRequest<SummaryEntity>(entityName: "SummaryEntity")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var duration: Double
    @NSManaged public var notes: String?
    @NSManaged public var completedTasks: NSSet?
    
    // Convenience methods
    public var wrappedId: UUID {
        id ?? UUID()
    }
    
    public var wrappedDate: Date {
        date ?? Date()
    }
    
    public var wrappedNotes: String {
        notes ?? ""
    }
    
    public var completedTasksArray: [TaskEntity] {
        let set = completedTasks as? Set<TaskEntity> ?? []
        return set.sorted {
            $0.wrappedCreatedAt < $1.wrappedCreatedAt
        }
    }
}

// MARK: Generated accessors for completedTasks
extension SummaryEntity {
    @objc(addCompletedTasksObject:)
    @NSManaged public func addToCompletedTasks(_ value: TaskEntity)
    
    @objc(removeCompletedTasksObject:)
    @NSManaged public func removeFromCompletedTasks(_ value: TaskEntity)
    
    @objc(addCompletedTasks:)
    @NSManaged public func addToCompletedTasks(_ values: NSSet)
    
    @objc(removeCompletedTasks:)
    @NSManaged public func removeFromCompletedTasks(_ values: NSSet)
}
