// BoardEntity+CoreDataProperties.swift
// JeevesApp
//
// Created by Mitch Montelaro on 3/4/25.
//
//

import Foundation
import CoreData

extension BoardEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BoardEntity> {
        return NSFetchRequest<BoardEntity>(entityName: "BoardEntity")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var columns: NSSet?
    
    // Convenience methods
    public var wrappedId: UUID {
        id ?? UUID()
    }
    
    public var wrappedName: String {
        name ?? "Untitled Board"
    }
    
    public var wrappedTimestamp: Date {
        timestamp ?? Date()
    }
    
    public var columnsArray: [ColumnEntity] {
        let set = columns as? Set<ColumnEntity> ?? []
        return set.sorted {
            $0.wrappedName < $1.wrappedName
        }
    }
}

// MARK: Generated accessors for columns
extension BoardEntity {
    @objc(addColumnsObject:)
    @NSManaged public func addToColumns(_ value: ColumnEntity)
    
    @objc(removeColumnsObject:)
    @NSManaged public func removeFromColumns(_ value: ColumnEntity)
    
    @objc(addColumns:)
    @NSManaged public func addToColumns(_ values: NSSet)
    
    @objc(removeColumns:)
    @NSManaged public func removeFromColumns(_ values: NSSet)
}
