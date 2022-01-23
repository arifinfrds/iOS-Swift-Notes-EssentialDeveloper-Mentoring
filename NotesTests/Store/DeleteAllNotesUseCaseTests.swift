//
//  DeleteAllNotesUseCaseTests.swift
//  NotesTests
//
//  Created by Arifin Firdaus on 23/02/21.
//

import XCTest
@testable import Notes

class DeleteAllNotesUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteAnyNotes() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_deleteAll_deliversErrorOnDeleteAllNotes() {
        let (sut, store) = makeSUT()
        
        var capturedErrors = [DeleteNoteError]()
        sut.deleteAll { result in
            switch result {
            case .failure(let error):
                capturedErrors.append(error)
            default:
                XCTFail("Expect error, got success instead.")
            }
        }
        let deleteAllNotesError = anyNSError()
        store.completeAllNotesDeletion(with: deleteAllNotesError)
        
        XCTAssertEqual(store.messages, [ .deleteAllNotes ])
        XCTAssertEqual(capturedErrors, [.unknown])
    }
    
    func test_deleteAll_succcedsOnDeleteAllNotes() {
        let (sut, store) = makeSUT()
        
        var capturedResults = [LocalNoteDeleter.DeleteAllNotessResult]()
        sut.deleteAll { result in
            capturedResults.append(result)
        }
        store.completeDeleteAllNotesSuccessfully()
        
        XCTAssertEqual(store.messages, [ .deleteAllNotes ])
        XCTAssertEqual(capturedResults, [.success])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalNoteDeleter, store: NoteStoreSpy) {
        let store = NoteStoreSpy()
        let sut = LocalNoteDeleter(store: store)
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
}
