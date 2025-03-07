// AttachmentEntity+CoreDataProperties.swift
// JeevesApp
//
// Created by Mitch Montelaro on 3/4/25.
//
//

import Foundation
import CoreData

extension AttachmentEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AttachmentEntity> {
        return NSFetchRequest<AttachmentEntity>(entityName: "AttachmentEntity")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var filename: String?
    @NSManaged public var type: String?
    @NSManaged public var url: URL?
    @NSManaged public var createdAt: Date?
    @NSManaged public var task: TaskEntity?
    
    // Convenience methods
    public var wrappedId: UUID {
        id ?? UUID()
    }
    
    public var wrappedFilename: String {
        filename ?? "Unknown File"
    }
    
    public var wrappedType: String {
        type ?? "other"
    }
    
    public var wrappedCreatedAt: Date {
        createdAt ?? Date()
    }
    
    public var wrappedURL: URL? {
        url
    }
}
