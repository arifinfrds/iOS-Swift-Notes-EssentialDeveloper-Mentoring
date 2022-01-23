//
//  DateDisplayViewModelTests.swift
//  NotesTests
//
//  Created by Arifin Firdaus on 25/02/21.
//

import XCTest
@testable import Notes

class DateDisplayViewModelTests: XCTestCase {

    func test_displayDate_shouldReturnCorrectDateFormat() {
        let sut = DateDisplayViewModel()
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 10
        dateComponents.day = 24
        dateComponents.timeZone = .current

        let userCalendar = Calendar.current
        let givenDate = userCalendar.date(from: dateComponents)!
        
        let result = sut.displayDate(from: givenDate)
        
        XCTAssertEqual(result, "October 24, 2020")
    }

}

