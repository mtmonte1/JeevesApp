// CommandEntity+CoreDataProperties.swift
// JeevesApp
//
// Created by Mitch Montelaro on 3/4/25.
//
//

import Foundation
import CoreData

extension CommandEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CommandEntity> {
        return NSFetchRequest<CommandEntity>(entityName: "CommandEntity")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var command: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var successful: Bool
    
    // Convenience methods
    public var wrappedId: UUID {
        id ?? UUID()
    }
    
    public var wrappedCommand: String {
        command ?? ""
    }
    
    public var wrappedTimestamp: Date {
        timestamp ?? Date()
    }
}
