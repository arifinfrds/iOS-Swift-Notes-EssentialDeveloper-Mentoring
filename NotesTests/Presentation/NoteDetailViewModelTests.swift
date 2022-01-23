//
//  NoteDetailViewModelTests.swift
//  NotesTests
//
//  Created by Arifin Firdaus on 10/11/21.
//

import XCTest
@testable import Notes

class NoteDetailViewModelTests: XCTestCase {
    
    func test_init_doesNotPerformAnything() {
        let note = uniqueNote()
        let (_, loaderSpy) = makeSUT(noteId: note.id)
        
        XCTAssertTrue(loaderSpy.messages.isEmpty)
    }
    
    func test_init_instantiateInInitialState() {
        let note = uniqueNote()
        let (sut, _) = makeSUT(noteId: note.id)
        
        assertThatInInitialState(sut)
    }
    
    func test_onAppear_performLoadsOnFirstTimeLoadView() {
        let createdDate = anySampleDate()
        let note = uniqueNote(createdDate: createdDate)
        let (sut, loaderSpy) = makeSUT(noteId: note.id)
        
        assertThatInInitialState(sut)
        
        sut.onAppear()
        
        XCTAssertEqual(loaderSpy.messages, [ .load(id: note.id) ])
    }
    
    func test_onAppear_performLoadsNoteWithCorrectTransitionedStateOnSuccessfulLoadNote() {
        let createdDate = anySampleDate()
        let note = uniqueNote(createdDate: createdDate)
        let (sut, loaderSpy) = makeSUT(noteId: note.id)
        
        XCTAssertEqual(sut.isLoading, false)
        
        sut.onAppear()
        
        XCTAssertEqual(sut.isLoading, true)
        
        loaderSpy.complete(with: note)
        
        XCTAssertEqual(loaderSpy.messages, [ .load(id: note.id) ])
        XCTAssertEqual(sut.isLoading, false)
        XCTAssertEqual(sut.title, note.name)
        XCTAssertEqual(sut.shouldShowErrorAlert, false)
        XCTAssertEqual(sut.errorTitle, "")
        XCTAssertEqual(sut.errorMessage, "")
        XCTAssertEqual(sut.noteName, note.name)
        XCTAssertEqual(sut.noteDescription, note.description)
        XCTAssertEqual(sut.noteDate, "November 10, 2021")
        XCTAssertEqual(sut.noteCreatedDate, note.createdAt)
    }
    
    func test_onAppear_performLoadsNoteWithCorrectTransitionedStateOnNotFoundLoadNote() {
        let note = uniqueNote()
        let (sut, loaderSpy) = makeSUT(noteId: note.id)
        
        XCTAssertEqual(sut.isLoading, false)
        
        sut.onAppear()
        
        XCTAssertEqual(sut.isLoading, true)
        XCTAssertEqual(loaderSpy.messages, [ .load(id: note.id) ])
        
        loaderSpy.complete(with: .notFound)
        
        XCTAssertEqual(sut.isLoading, false)
        XCTAssertEqual(sut.title, "")
        XCTAssertEqual(sut.shouldShowErrorAlert, true)
        XCTAssertEqual(sut.errorTitle, "Error")
        XCTAssertEqual(sut.errorMessage, "Note tidak ditemukan")
        XCTAssertEqual(sut.noteName, "")
        XCTAssertEqual(sut.noteDescription, "")
        XCTAssertEqual(sut.noteDate, "")
    }
    
    func test_onAppear_performLoadsNoteWithCorrectTransitionedStateOnErrorLoadNote() {
        let note = uniqueNote()
        let (sut, loaderSpy) = makeSUT(noteId: note.id)
        
        XCTAssertEqual(sut.isLoading, false)
        
        sut.onAppear()
        
        XCTAssertEqual(sut.isLoading, true)
        XCTAssertEqual(loaderSpy.messages, [ .load(id: note.id) ])
        
        loaderSpy.complete(with: .unknown)
        
        XCTAssertEqual(sut.isLoading, false)
        XCTAssertEqual(sut.title, "")
        XCTAssertEqual(sut.shouldShowErrorAlert, true)
        XCTAssertEqual(sut.errorTitle, "Error")
        XCTAssertEqual(sut.errorMessage, "Terjadi kesalahan. Mohon coba lagi.")
        XCTAssertEqual(sut.noteName, "")
        XCTAssertEqual(sut.noteDescription, "")
        XCTAssertEqual(sut.noteDate, "")
    }
    
    func test_onDismissErrorAlert_resetsErrorTexts() {
        let note = uniqueNote()
        let (sut, _) = makeSUT(noteId: note.id)
        
        sut.onDismissErrorAlert()
        
        XCTAssertEqual(sut.shouldShowErrorAlert, false)
        XCTAssertEqual(sut.errorTitle, "")
        XCTAssertEqual(sut.errorMessage, "")
    }
    
    func test_onDismissErrorAlert_resetsErrorStateAfterAlertIsPresentedOnNotFoundError() {
        let note = uniqueNote()
        let (sut, loaderSpy) = makeSUT(noteId: note.id)
        
        XCTAssertEqual(sut.isLoading, false)
        
        sut.onAppear()
        
        XCTAssertEqual(sut.isLoading, true)
        XCTAssertEqual(loaderSpy.messages, [ .load(id: note.id) ])
        
        loaderSpy.complete(with: .notFound)
        
        XCTAssertEqual(sut.shouldShowErrorAlert, true)
        XCTAssertEqual(sut.errorTitle, "Error")
        XCTAssertEqual(sut.errorMessage, "Note tidak ditemukan")
        
        sut.onDismissErrorAlert()
        
        XCTAssertEqual(sut.shouldShowErrorAlert, false)
        XCTAssertEqual(sut.errorTitle, "")
        XCTAssertEqual(sut.errorMessage, "")
    }
    
    func test_onDismissErrorAlert_resetsErrorStateAfterAlertIsPresentedOnUnknownError() {
        let note = uniqueNote()
        let (sut, loaderSpy) = makeSUT(noteId: note.id)
        
        XCTAssertEqual(sut.isLoading, false)
        
        sut.onAppear()
        
        XCTAssertEqual(sut.isLoading, true)
        XCTAssertEqual(loaderSpy.messages, [ .load(id: note.id) ])
        
        loaderSpy.complete(with: .unknown)
        
        XCTAssertEqual(sut.shouldShowErrorAlert, true)
        XCTAssertEqual(sut.errorTitle, "Error")
        XCTAssertEqual(sut.errorMessage, "Terjadi kesalahan. Mohon coba lagi.")
        
        sut.onDismissErrorAlert()
        
        XCTAssertEqual(sut.shouldShowErrorAlert, false)
        XCTAssertEqual(sut.errorTitle, "")
        XCTAssertEqual(sut.errorMessage, "")
    }

    // MARK: - Helpers
    
    private func makeSUT(noteId: UUID, file: StaticString = #filePath, line: UInt = #line) -> (sut: NoteDetailViewModel, loaderSpy: LocalNoteUseCaseSpy) {
        let loaderSpy = LocalNoteUseCaseSpy()
        let sut = NoteDetailViewModel(noteLoader: loaderSpy, noteId: noteId, dateDisplayViewModel: DateDisplayViewModel())
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(loaderSpy, file: file, line: line)
        return (sut, loaderSpy)
    }
    
    private func anySampleDate() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let timeZone = TimeZone(secondsFromGMT: 0)
        let components = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 11, day: 10)
        let createdDate = calendar.date(from: components)!
        return createdDate
    }
    
    private func assertThatInInitialState(_ sut: NoteDetailViewModel) {
        XCTAssertEqual(sut.title, "")
        XCTAssertEqual(sut.isLoading, false)
        XCTAssertEqual(sut.shouldShowErrorAlert, false)
        XCTAssertEqual(sut.errorTitle, "")
        XCTAssertEqual(sut.errorMessage, "")
        XCTAssertEqual(sut.noteName, "")
        XCTAssertEqual(sut.noteDescription, "")
        XCTAssertEqual(sut.noteDate, "")
    }
    
    private class LocalNoteUseCaseSpy: NoteLoader {
        
        enum Message: Equatable {
            case load(id: UUID)
            case update(id: UUID, note: Note)
        }
        
        private(set) var messages = [Message]()
        private(set) var loadNoteCompletions = [(LoadNoteResult) -> Void]()
        
        // MARK: - noteLoader
        
        func load(completion: @escaping (LoadNotesResult) -> Void) {
            
        }
        
        func load(noteId: UUID, completion: @escaping (LoadNoteResult) -> Void) {
            messages.append(.load(id: noteId))
            loadNoteCompletions.append(completion)
        }
        
        func complete(with note: Note, at index: Int = 0) {
            loadNoteCompletions[index](.success(note))
        }
        
        func complete(with error: NoteLoaderError, at index: Int = 0) {
            loadNoteCompletions[index](.failure(error))
        }
    }
    
}
