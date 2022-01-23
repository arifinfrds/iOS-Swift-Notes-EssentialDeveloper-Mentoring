//
//  AddNoteViewModelTests.swift
//  NotesTests
//
//  Created by Arifin Firdaus on 20/12/21.
//

import XCTest
@testable import Notes

class AddNoteViewModelTests: XCTestCase {
    
    func test_init_doesNotRequestAddNote() {
        let (_, adder) = makeSUT()
        
        XCTAssertTrue(adder.messages.isEmpty)
    }
    
    func test_onAddNoteButtonTapped_doesNotPerformAddNoteRequestOnEmptyNoteFields() {
        let (sut, adder) = makeSUT()
        
        sut.onAddNoteButtonTapped()
        
        XCTAssertTrue(adder.messages.isEmpty)
        
        XCTAssertEqual(sut.errorTitle, "Oops..")
        XCTAssertEqual(sut.errorMessage, "Name field cannot be empty")
        XCTAssertTrue(sut.shouldShowErrorAlert)
        
        sut.onDismissedErrorAlert()
        
        XCTAssertFalse(sut.shouldShowErrorAlert)
        XCTAssertTrue(sut.errorTitle.isEmpty)
        XCTAssertTrue(sut.errorMessage.isEmpty)
        
        XCTAssertFalse(sut.shouldShowSuccessAddAlert)
        XCTAssertEqual(sut.successAddTitle, "")
        XCTAssertEqual(sut.successAddMessage, "")
    }
    
    func test_onAddNoteButtonTapped_performAddNoteRequestOnNonEmptyNoteFields() {
        let (sut, adder) = makeSUT()
        let anyDate = anySampleDate()
        let name = "some name"
        let noteToAdd = uniqueNote(createdDate: anyDate, updatedDate: anyDate, name: name)
        
        sut.simulateFillFields(with: noteToAdd)
        sut.onAddNoteButtonTapped()
        
        let spiedNote = adder.addedNote()
        XCTAssertEqual(spiedNote?.createdAt, noteToAdd.createdAt)
        XCTAssertEqual(spiedNote?.updatedAt, noteToAdd.updatedAt)
        XCTAssertEqual(spiedNote?.name, noteToAdd.name)
        XCTAssertEqual(spiedNote?.description, noteToAdd.description)
    }
    
    func test_onAddNoteButtonTapped_succeedsOnAddNote() {
        let (sut, adder) = makeSUT()
        let anyDate = anySampleDate()
        let name = "some name"
        let noteToAdd = uniqueNote(createdDate: anyDate, updatedDate: anyDate, name: name)
        
        XCTAssertEqual(sut.isLoading, false)
        
        sut.simulateFillFields(with: noteToAdd)
        sut.onAddNoteButtonTapped()
        
        XCTAssertEqual(sut.isLoading, true)
        
        adder.complete(with: noteToAdd)
        
        XCTAssertEqual(sut.isLoading, false)
        
        XCTAssertFalse(sut.shouldShowErrorAlert)
        XCTAssertTrue(sut.errorTitle.isEmpty)
        XCTAssertTrue(sut.errorMessage.isEmpty)
        
        XCTAssertTrue(sut.shouldShowSuccessAddAlert)
        XCTAssertEqual(sut.successAddTitle, "Succeeds")
        XCTAssertEqual(sut.successAddMessage, "Successfully added a note : \(noteToAdd.name)")
        
        sut.onDismissedErrorAlert()
        
        XCTAssertFalse(sut.shouldShowErrorAlert)
        XCTAssertTrue(sut.errorTitle.isEmpty)
        XCTAssertTrue(sut.errorMessage.isEmpty)
        
        XCTAssertFalse(sut.shouldShowSuccessAddAlert)
        XCTAssertEqual(sut.successAddTitle, "")
        XCTAssertEqual(sut.successAddMessage, "")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: AddNoteViewModel, adder: NoteAdderSpy) {
        let adder = NoteAdderSpy()
        let sut = AddNoteViewModel(noteAdder: adder, dateDisplayViewModel: DateDisplayViewModel())
        trackMemoryLeaks(adder, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut, adder)
    }
    
    private func anySampleDate() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let timeZone = TimeZone(secondsFromGMT: 0)
        let components = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 11, day: 10)
        let createdDate = calendar.date(from: components)!
        return createdDate
    }
    
    final class NoteAdderSpy: NoteAdder {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case add(Note)
        }
        
        private var addNoteCompletions = [(NoteAdder.Result) -> Void]()
        
        func add(_ note: Note, completion: @escaping (NoteAdder.Result) -> Void) {
            messages.append(.add(note))
            addNoteCompletions.append(completion)
        }
        
        func complete(with note: Note, at index: Int = 0) {
            addNoteCompletions[index](.success(note))
        }
        
        func addedNote() -> Note? {
            messages.map { message -> Note in
                switch message {
                case .add(let note):
                    return note
                }
            }
            .first
        }
        
        func addedNotes() -> [Note] {
            let receivedNotes = messages.map { message -> Note in
                switch message {
                case .add(let note):
                    return note
                }
            }
            return receivedNotes
        }
    }
    
}

private extension AddNoteViewModel {
    
    func simulateFillFields(with note: Note) {
        noteName = note.name
        noteDescription = note.description ?? ""
        createdAt = note.createdAt
    }
    
}
