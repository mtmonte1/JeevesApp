import Foundation
import CoreData

extension TaskEntity: Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var taskDescription: String?
    @NSManaged public var completed: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var column: String?
    
    @NSManaged public var attachments: NSSet?
    @NSManaged public var kanbanColumn: ColumnEntity?
    @NSManaged public var summary: SummaryEntity?
    
    // Convenience methods
    public var wrappedId: UUID {
        id ?? UUID()
    }
    
    public var wrappedTitle: String {
        title ?? "Untitled Task"
    }
    
    public var wrappedDescription: String {
        taskDescription ?? ""
    }
    
    public var wrappedCreatedAt: Date {
        createdAt ?? Date()
    }
    
    public var wrappedColumn: String {
        column ?? "To Do"
    }
    
    public var attachmentsArray: [AttachmentEntity] {
        let set = attachments as? Set<AttachmentEntity> ?? []
        return set.sorted {
            $0.wrappedCreatedAt < $1.wrappedCreatedAt
        }
    }
}

// MARK: Generated accessors for attachments
extension TaskEntity {
    @objc(addAttachmentsObject:)
    @NSManaged public func addToAttachments(_ value: AttachmentEntity)
    
    @objc(removeAttachmentsObject:)
    @NSManaged public func removeFromAttachments(_ value: AttachmentEntity)
    
    @objc(addAttachments:)
    @NSManaged public func addToAttachments(_ values: NSSet)
    
    @objc(removeAttachments:)
    @NSManaged public func removeFromAttachments(_ values: NSSet)
}
