//
//  DeleteNoteUseCaseTests.swift
//  NotesTests
//
//  Created by Arifin Firdaus on 23/02/21.
//

import XCTest
@testable import Notes

class DeleteNoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteAnyNotes() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_delete_deliverErrorOnDeletionError() {
        let (sut, store) = makeSUT()
        let noteToDelete = uniqueNote()
        
        var capturedErrors = [DeleteNoteError]()
        sut.delete(noteToDelete) { result in
            switch result {
            case .failure(let error):
                capturedErrors.append(error)
            default:
                XCTFail("Expect error, got success instead.")
            }
        }
        let deletionError = anyNSError()
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.messages, [ .deleteNote(noteToDelete) ])
        XCTAssertEqual(capturedErrors, [.unknown])
    }
    
    func test_delete_succedsOnDeletion() {
        let (sut, store) = makeSUT()
        
        let noteToDelete = uniqueNote()
        var capturedResults = [LocalNoteDeleter.DeleteNoteResult]()
        sut.delete(noteToDelete) { result in
            capturedResults.append(result)
        }
        store.completeDeletionSuccessfully(with: noteToDelete)
        
        XCTAssertEqual(store.messages, [ .deleteNote(noteToDelete) ])
        XCTAssertEqual(capturedResults, [.success(noteToDelete)])
    }
    
    // MARK: - Helpers
    
    private func anyUUID() -> UUID {
        return UUID()
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalNoteDeleter, store: NoteStoreSpy) {
        let store = NoteStoreSpy()
        let sut = LocalNoteDeleter(store: store)
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
}
