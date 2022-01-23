//
//  LoadNotesUseCaseTests.swift
//  NotesTests
//
//  Created by Arifin Firdaus on 21/02/21.
//

import XCTest
@testable import Notes

class LoadNotesUseCaseTests: XCTestCase {
    
    func test_init_doesNotLoadAnyNotes() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_load_requestLoadNotes() {
        let (sut, store) = makeSUT()
        
        sut.load() { _ in }
        
        XCTAssertEqual(store.messages, [ .loadNotes ])
    }
    
    func test_loadTwice_requestLoadNotesTwice() {
        let (sut, store) = makeSUT()
        
        sut.load() { _ in }
        sut.load() { _ in }
        
        XCTAssertEqual(store.messages, [ .loadNotes, .loadNotes ])
    }
    
    func test_load_deliversErrorOnLoadNotesError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteLoadWithResult: .failure(.unknown), when: {
            let loadNotesError = LoadableNoteStoreError.unknown
            store.completeLoad(with: loadNotesError)
        })
    }
    
    func test_load_succedsWithEmptyNotes() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteLoadWithResult: .success(emptyNotes()), when: {
            store.completeLoad(with: emptyNotes())
        })
    }
    
    func test_load_succedsWithNotes() {
        let (sut, store) = makeSUT()
        
        let expectedNotes = uniqueNotes()
        expect(sut, toCompleteLoadWithResult: .success(expectedNotes), when: {
            store.completeLoad(with: expectedNotes)
        })
    }
    
    func test_load_shouldNotDeliverValuesWhenSUTInstanceHasBeenDeallocated() {
        let store = NoteStoreSpy()
        var sut: LocalNoteLoader? = LocalNoteLoader(store: store)
        
        var capturedResults = [LocalNoteLoader.LoadNotesResult]()
        sut?.load(completion: { result in
            capturedResults.append(result)
        })
        sut = nil
        store.completeLoad(with: uniqueNotes())
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalNoteLoader, store: NoteStoreSpy) {
        let store = NoteStoreSpy()
        let sut = LocalNoteLoader(store: store)
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalNoteLoader, toCompleteLoadWithResult expectedResult: LocalNoteLoader.LoadNotesResult, when action: () -> Void) {
        
        let exp = expectation(description: "Wait for completion")
        
        sut.load { recievedResult in
            switch (recievedResult, expectedResult) {
            case (.success(let receivednotes), .success(let expectednotes)):
                XCTAssertEqual(receivednotes, expectednotes)
            case (.failure(let receivedError), .failure(let expectedError)):
                XCTAssertEqual(receivedError, expectedError)
            default:
                XCTFail("expect to completeLoad with result: \(expectedResult), got \(recievedResult) instead.")
            }
            exp.fulfill()
        }
        action()
        
        wait(for: [exp], timeout: defaultTimout())
    }
    
}
