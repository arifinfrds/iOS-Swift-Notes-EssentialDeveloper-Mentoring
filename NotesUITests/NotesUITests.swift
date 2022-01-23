//
//  NotesUITests.swift
//  NotesUITests
//
//  Created by Arifin Firdaus on 23/01/22.
//

import XCTest

class NotesUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func test_simulateAppAsUser() {
        
        let app = XCUIApplication()
        app.launch()
        
        let notesNavigationBar = app.navigationBars["Notes"]
        notesNavigationBar.buttons["Add"].tap()
        
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.textFields["Name"]/*[[".cells[\"Name\"].textFields[\"Name\"]",".textFields[\"Name\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let textView = tablesQuery.children(matching: .cell).element(boundBy: 1).children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .textView).element
        textView.tap()
        textView.tap()
        app.navigationBars["Add Note"].buttons["Add"].tap()
        
        let okButton = app.alerts["Succeeds"].scrollViews.otherElements.buttons["OK"]
        okButton.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Some desc"]/*[[".cells.staticTexts[\"Some desc\"]",".staticTexts[\"Some desc\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let someNotesNavigationBar = app.navigationBars["Some notes"]
        someNotesNavigationBar.buttons["Edit"].tap()
        app.navigationBars["Edit Note"].buttons["Save"].tap()
        app.alerts["Update Sukses"].scrollViews.otherElements.buttons["OK"].tap()
        someNotesNavigationBar.buttons["Notes"].tap()
        notesNavigationBar.buttons["Delete"].tap()
        app.alerts["Oops.."].scrollViews.otherElements.buttons["OK"].tap()
        okButton.tap()
        
        
    }
}
