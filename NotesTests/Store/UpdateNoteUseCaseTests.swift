//
//  UpdateNoteUseCaseTests.swift
//  NotesTests
//
//  Created by Arifin Firdaus on 17/11/21.
//

import XCTest
@testable import Notes

class UpdateNoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestAnyNoteActions() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_update_performsUpdate() {
        let noteToUpdate = uniqueNote()
        let noteId = noteToUpdate.id
        let (sut, store) = makeSUT()
        
        sut.update(id: noteId, with: noteToUpdate) { _ in }
        
        XCTAssertEqual(store.messages, [ .update(id: noteId, value: noteToUpdate) ])
    }
    
    func test_updateTwice_performsUpdateTwice() {
        let noteToUpdate = uniqueNote()
        let noteId = noteToUpdate.id
        let (sut, store) = makeSUT()
        
        sut.update(id: noteId, with: noteToUpdate) { _ in }
        sut.update(id: noteId, with: noteToUpdate) { _ in }
        
        XCTAssertEqual(store.messages, [ .update(id: noteId, value: noteToUpdate), .update(id: noteId, value: noteToUpdate) ])
    }
    
    func test_update_deliversUnknownErrorOnStoreError() {
        let noteToUpdate = uniqueNote()
        let noteId = noteToUpdate.id
        let (sut, store) = makeSUT()
        
        expect(sut, toUpdateWithId: noteId, for: noteToUpdate, AndCompleteWith: .failure(.unknown), when: {
            store.completeUpdate(with: .unknown)
        })
    }
    
    func test_update_deliversNotFoundIdErrorOnStoreError() {
        let noteToUpdate = uniqueNote()
        let noteId = noteToUpdate.id
        let (sut, store) = makeSUT()
        
        expect(sut, toUpdateWithId: noteId, for: noteToUpdate, AndCompleteWith: .failure(.idNotFound), when: {
            store.completeUpdate(with: .idNotFound)
        })
    }
    
    func test_update_deliversSuccessUpdateNote() {
        let noteToUpdate = uniqueNote()
        let noteId = noteToUpdate.id
        let (sut, store) = makeSUT()
        
        expect(sut, toUpdateWithId: noteId, for: noteToUpdate, AndCompleteWith: .success(noteToUpdate), when: {
            store.completeUpdate(with: noteToUpdate)
        })
    }
    
    func test_update_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let noteToUpdate = uniqueNote()
        let noteId = noteToUpdate.id
        let store = NoteStoreSpy()
        var sut: NoteUpdater? = LocalNoteUpdater(store: store)
        var capturedResult = [NoteUpdater.Result]()
        
        sut?.update(id: noteId, with: noteToUpdate, completion: { result in
            capturedResult.append(result)
        })
        sut = nil
        store.completeUpdate(with: .unknown)
        
        XCTAssertTrue(capturedResult.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalNoteUpdater, store: NoteStoreSpy) {
        let store = NoteStoreSpy()
        let sut = LocalNoteUpdater(store: store)
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    func expect(_ sut: LocalNoteUpdater, toUpdateWithId id: UUID, for note: Note, AndCompleteWith expectedResult: Result<Note, NoteUpdaterError>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        
        sut.update(id: id, with: note) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let ( .failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            case let (.success(receivednote), .success(expectednote)):
                XCTAssertEqual(receivednote, expectednote, file: file, line: line)
            default:
                XCTFail("Expect failure or success case.", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: defaultTimout())
    }
    
}
