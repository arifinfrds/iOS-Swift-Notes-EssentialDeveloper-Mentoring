//
//  EditNoteViewModelTests.swift
//  NotesTests
//
//  Created by Arifin Firdaus on 23/11/21.
//

import XCTest
@testable import Notes

class EditNoteViewModelTests: XCTestCase {
    
    func test_init_doesNotPerformLoadNorUpdate() {
        let note = uniqueNote()
        let (_, loader, updater) = makeSUT(noteId: note.id)
        
        XCTAssertTrue(loader.messages.isEmpty)
        XCTAssertTrue(updater.messages.isEmpty)
    }
    
    func test_onAppear_performLoadsNoteOnly() {
        let note = uniqueNote()
        let (sut, loader, _) = makeSUT(noteId: note.id)
        
        sut.onAppear()
        
        XCTAssertEqual(loader.messages, [ .load(noteId: note.id) ])
    }
    
    func test_onAppearTwice_performLoadTwice() {
        let note = uniqueNote()
        let (sut, loader, _) = makeSUT(noteId: note.id)
        
        sut.onAppear()
        sut.onAppear()
        
        XCTAssertEqual(loader.messages, [ .load(noteId: note.id), .load(noteId: note.id) ])
    }
    
    func test_onAppear_deliversErrorOnLoadErrorWithCorrectNoteStates() {
        
        let errorInfos: [ LoadNoteErrorInfo ] = [
            .init(error: .unknown, title: "Oops..", message: "Terjadi kesalahan. Mohon coba lagi."),
            .init(error: .notFound, title: "Oops..", message: "Terjadi kesalahan. Id note tidak dapat ditemukan.")
        ]
        
        errorInfos.forEach { errorInfo in
            
            let note = uniqueNote()
            let (sut, loader, _) = makeSUT(noteId: note.id)
            
            assertThatInInitialState(sut, title: "Edit Note")
            
            sut.onAppear()
            
            loader.completeLoadNote(with: errorInfo.error)
            
            XCTAssertEqual(sut.isLoading, false)
            XCTAssertEqual(sut.shouldShowErrorAlert, true)
            XCTAssertEqual(sut.errorTitle, errorInfo.title)
            XCTAssertEqual(sut.errorMessage, errorInfo.message)
            XCTAssertEqual(sut.shouldShowSuccessUpdateAlert, false)
            XCTAssertEqual(sut.successUpdateTitle, "")
            XCTAssertEqual(sut.successUpdateMessage, "")
            
            sut.onDismissLoadNoteErrorAlert()
            
            XCTAssertEqual(sut.isLoading, false)
            XCTAssertEqual(sut.shouldShowErrorAlert, false)
            XCTAssertEqual(sut.errorTitle, "")
            XCTAssertEqual(sut.errorMessage, "")
            XCTAssertEqual(sut.shouldShowSuccessUpdateAlert, false)
            XCTAssertEqual(sut.successUpdateTitle, "")
            XCTAssertEqual(sut.successUpdateMessage, "")
        }
    }
    
    func test_onAppear_performLoadsNoteWithCorrectTransitionedStateOnSuccessfulLoadIncomeNote() {
        let createdDate = anySampleDate()
        let note = uniqueNote(createdDate: createdDate)
        let (sut, loader, _) = makeSUT(noteId: note.id)
        
        XCTAssertEqual(sut.isLoading, false)
        
        sut.onAppear()
        
        XCTAssertEqual(sut.isLoading, true)
        
        loader.completeLoadNote(with: note)
        
        XCTAssertEqual(loader.messages, [ .load(noteId: note.id) ])
        XCTAssertEqual(sut.isLoading, false)
        XCTAssertEqual(sut.title, "Edit Note")
        XCTAssertEqual(sut.shouldShowErrorAlert, false)
        XCTAssertEqual(sut.errorTitle, "")
        XCTAssertEqual(sut.errorMessage, "")
        XCTAssertEqual(sut.noteName, note.name)
        XCTAssertEqual(sut.noteDate, "November 10, 2021")
        XCTAssertEqual(sut.noteCreatedDate, note.createdAt)
    }
    
    func test_onSave_performSaveOnNonEmptyField() {
        let createdDate = anySampleDate()
        let updatedDate = createdDate
        let noteToLoad = uniqueNote(createdDate: createdDate, updatedDate: updatedDate)
        let loader = CollaboratorSpy()
        let updater = CollaboratorSpy()
        let sut = EditNoteViewModel(noteId: noteToLoad.id, noteLoader: loader, noteUpdater: updater, dateDisplayViewModel: DateDisplayViewModel())
        trackMemoryLeaks(sut)
        sut.noteDescription = "a new description"
        sut.noteName = "a new name"
        
        XCTAssertEqual(sut.isLoading, false)
        
        sut.onAppear()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak sut] in
            guard let sut = sut else { return }
            
            sut.onSave()
            
            XCTAssertEqual(sut.isLoading, true)
            
            updater.completeUpdateNote(with: noteToLoad)
            
            XCTAssertEqual(sut.isLoading, false)
            
            XCTAssertFalse(updater.messages.isEmpty)
            
            let updatedNote = updater.getUpdatedNote()
            
            XCTAssertEqual(updatedNote.id, noteToLoad.id)
            XCTAssertEqual(updatedNote.createdAt, noteToLoad.createdAt)
            XCTAssertNotEqual(updatedNote.updatedAt, noteToLoad.updatedAt)
            XCTAssertEqual(updatedNote.name, "a new name")
            XCTAssertEqual(updatedNote.description, "a new description")
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(noteId: UUID, file: StaticString = #filePath, line: UInt = #line) -> (sut: EditNoteViewModel, loader: CollaboratorSpy, updater: CollaboratorSpy) {
        let loader = CollaboratorSpy()
        let updater = CollaboratorSpy()
        let sut = EditNoteViewModel(noteId: noteId, noteLoader: loader, noteUpdater: updater, dateDisplayViewModel: DateDisplayViewModel())
        trackMemoryLeaks(loader, file: file, line: line)
        trackMemoryLeaks(updater, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut, loader, updater)
    }
    
    private func assertThatInInitialState(_ sut: EditNoteViewModel, title: String = "") {
        XCTAssertEqual(sut.title, title)
        XCTAssertEqual(sut.isLoading, false)
        XCTAssertEqual(sut.shouldShowErrorAlert, false)
        XCTAssertEqual(sut.errorTitle, "")
        XCTAssertEqual(sut.errorMessage, "")
        XCTAssertEqual(sut.shouldShowSuccessUpdateAlert, false)
        XCTAssertEqual(sut.successUpdateTitle, "")
        XCTAssertEqual(sut.successUpdateMessage, "")
        XCTAssertEqual(sut.noteName, "")
        XCTAssertEqual(sut.noteDescription, "")
        XCTAssertEqual(sut.noteDate, "")
    }
    
    private struct LoadNoteErrorInfo {
        let error: NoteLoaderError
        let title: String
        let message: String
    }
    
    private func anySampleDate() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let timeZone = TimeZone(secondsFromGMT: 0)
        let components = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 11, day: 10)
        let createdDate = calendar.date(from: components)!
        return createdDate
    }
    
}

private class CollaboratorSpy: NoteLoader, NoteUpdater {
    private(set) var messages = [Message]()
    
    enum Message: Equatable {
        case loadAll
        case load(noteId: UUID)
        case update(noteId: UUID, note: Note)
    }
    
    // MARK: - NoteLoader
    
    private(set) var loadNoteCompletions = [(LoadNoteResult) -> Void]()
    
    func load(completion: @escaping (LoadNotesResult) -> Void) {
        messages.append(.loadAll)
    }
    
    func load(noteId: UUID, completion: @escaping (LoadNoteResult) -> Void) {
        messages.append(.load(noteId: noteId))
        loadNoteCompletions.append(completion)
    }
    
    func completeLoadNote(with error: NoteLoaderError, at index: Int = 0) {
        loadNoteCompletions[index](.failure(error))
    }
    
    func completeLoadNote(with note: Note, at index: Int = 0) {
        loadNoteCompletions[index](.success(note))
    }
    
    // MARK: - NoteUpdater
    
    private(set) var updateNoteCompletions = [(NoteUpdater.Result) -> Void]()
    
    func update(id: UUID, with note: Note, completion: @escaping (NoteUpdater.Result) -> Void) {
        messages.append(.update(noteId: id, note: note))
        updateNoteCompletions.append(completion)
    }
    
    func completeUpdateNote(with note: Note, at index: Int = 0) {
        updateNoteCompletions[index](.success(note))
    }
}

private extension CollaboratorSpy {
    
    func getUpdatedNote() -> Note {
        let updatedNote = messages
            .map { message -> Note? in
                switch message {
                case let .update(_, note):
                    return note
                default:
                    return nil
                }
            }
            .compactMap { $0 }
            .first!
        
        return updatedNote
    }
}
