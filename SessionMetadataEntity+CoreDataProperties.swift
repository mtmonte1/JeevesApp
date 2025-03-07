// SessionMetadataEntity+CoreDataProperties.swift
// JeevesApp
//
// Created by Mitch Montelaro on 3/4/25.
//
//

import Foundation
import CoreData

extension SessionMetadataEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SessionMetadataEntity> {
        return NSFetchRequest<SessionMetadataEntity>(entityName: "SessionMetadataEntity")
    }
    
    @NSManaged public var version: Int16
    @NSManaged public var savedAt: Date?
    @NSManaged public var timerStatus: String?
    @NSManaged public var timerRemainingTime: Double
    @NSManaged public var timerSpeedMultiplier: Float
    @NSManaged public var personalityTone: String?
    @NSManaged public var personalityProactivity: Float
    @NSManaged public var personalityFrequency: Double
    @NSManaged public var muted: Bool
    @NSManaged public var deepFocus: Bool
    
    // Convenience methods
    public var wrappedSavedAt: Date {
        savedAt ?? Date()
    }
    
    public var wrappedTimerStatus: String {
        timerStatus ?? "stopped"
    }
    
    public var wrappedPersonalityTone: String {
        personalityTone ?? "professional"
    }
}
