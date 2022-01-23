//
//  LoadNoteUseCaseTests.swift
//  NotesTests
//
//  Created by Arifin Firdaus on 09/11/21.
//

import XCTest
@testable import Notes

class LoadNoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotPerformAnything() {
        let (_, storeSpy) = makeSUT()
        
        XCTAssertTrue(storeSpy.messages.isEmpty)
    }
    
    func test_load_requestsToLoadNote() {
        let noteId = anyNoteId()
        let (sut, storeSpy) = makeSUT()
        
        sut.load(noteId: noteId) { _ in }
        
        XCTAssertEqual(storeSpy.messages, [ .loadNote(noteId) ])
    }
    
    func test_loadTwice_requestLoadNotesTwice() {
        let noteId = anyNoteId()
        let (sut, storeSpy) = makeSUT()
        
        sut.load(noteId: noteId) { _ in }
        sut.load(noteId: noteId) { _ in }
        
        XCTAssertEqual(storeSpy.messages, [ .loadNote(noteId), .loadNote(noteId) ])
    }
    
    func test_load_deliversErrorOnLoadNotesError() {
        let noteId = anyNoteId()
        let (sut, storeSpy) = makeSUT()
        
        expect(sut, toLoad: noteId, andCompleteWith: .failure(.unknown), when: {
            storeSpy.completeLoadNote(with: LoadableNoteStoreError.unknown)
        })
    }
    
    func test_load_deliversNotFoundErrorOnNotFoundNote() {
        let note = uniqueNote()
        let (sut, storeSpy) = makeSUT()
        
        expect(sut, toLoad: note.id, andCompleteWith: .failure(NoteLoaderError.notFound), when: {
            storeSpy.completeLoadNote(with: LoadableNoteStoreError.notFound)
        })
    }
    
    func test_load_deliversNotenOnFoundNote() {
        let note = uniqueNote()
        let (sut, storeSpy) = makeSUT()
        
        expect(sut, toLoad: note.id, andCompleteWith: .success(note), when: {
            storeSpy.completeLoadNote(with: note)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalNoteLoader, store: NoteStoreSpy) {
        let storeSpy = NoteStoreSpy()
        let sut = LocalNoteLoader(store: storeSpy)
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(storeSpy, file: file, line: line)
        return (sut, storeSpy)
    }
    
    private func anyNoteId() -> UUID {
        return UUID()
    }
    
    private func expect(_ sut: LocalNoteLoader, toLoad noteId: UUID, andCompleteWith expectedResult: LocalNoteLoader.LoadNoteResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        
        sut.load(noteId: noteId) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            case let (.success(receivednote), .success(expectednote)):
                XCTAssertEqual(receivednote, expectednote, file: file, line: line)
            default:
                XCTFail("Expect failure, got other instead.")
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: defaultTimout())
    }
    
}
