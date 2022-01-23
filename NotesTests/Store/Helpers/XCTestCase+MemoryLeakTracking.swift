//
//  XCTestCase+MemoryLeakTracking.swift
//  NotesTests
//
//  Created by Arifin Firdaus on 23/02/21.
//

import XCTest
@testable import Notes

extension XCTestCase {
    
    func trackMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leaks.", file: file, line: line)
        }
    }
    
}
