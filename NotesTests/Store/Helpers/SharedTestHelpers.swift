//
//  SharedTestHelpers.swift
//  NotesTests
//
//  Created by Arifin Firdaus on 08/03/21.
//

import XCTest
@testable import Notes

extension XCTestCase {
    
    func anyNSError() -> NSError {
        return NSError(domain: "ny error", code: 0, userInfo: nil)
    }

    func uniqueNotes() -> [Note] {
        return [uniqueNote(), uniqueNote()]
    }

    func emptyNotes() -> [Note] {
        return []
    }
    
    func uniqueNote(createdDate: Date? = nil, updatedDate: Date? = nil, name: String = "Any") -> Note {
        var date: Date?
        if let createdAt = createdDate {
            date = createdAt
        } else {
            date = Date()
        }
        return Note(
            id: UUID(),
            createdAt: date!,
            updatedAt: updatedDate == nil ? Date() : updatedDate!,
            name: name,
            description: "some description"
        )
    }

    func defaultTimout() -> TimeInterval {
        return 1.0
    }
    
}
