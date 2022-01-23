//
//  ManagedNote+CoreDataProperties.swift
//  Notes
//
//  Created by Arifin Firdaus on 23/01/22.
//
//

import Foundation
import CoreData


extension ManagedNote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedNote> {
        return NSFetchRequest<ManagedNote>(entityName: "ManagedNote")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var identifier: UUID?
    @NSManaged public var name: String?
    @NSManaged public var noteDescription: String?
    @NSManaged public var updatedAt: Date?

}

extension ManagedNote : Identifiable {

}
