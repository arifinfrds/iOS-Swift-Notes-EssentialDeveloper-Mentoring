//
//  AddNoteUseCaseTests.swift
//  NotesTests
//
//  Created by Arifin Firdaus on 22/02/21.
//

import XCTest
@testable import Notes

class AddNoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestAnyNoteActions() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_add_requestNoteInsertionOnNoteError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteAddNoteWithResult: .failure(.unknown), when: {
            let noteInsertionError = anyNSError()
            store.completeAddNote(with: noteInsertionError)
        })        
    }
    
    func test_add_successdsOnNoteInsertion() {
        let (sut, store) = makeSUT()
        
        let insertedNote = uniqueNote()
        expect(sut, toCompleteAddNoteWithResult: .success(insertedNote), when: {
            store.completeAddNote(with: insertedNote)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalNoteAdder, store: NoteStoreSpy) {
        let store = NoteStoreSpy()
        let sut = LocalNoteAdder(store: store)
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalNoteAdder, toCompleteAddNoteWithResult expectedResult: NoteAdder.Result, when action: () -> Void) {
        
        let exp = expectation(description: "Wait for completion")
        
        sut.add(uniqueNote()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success(let receivednote), .success(let expectednote)):
                XCTAssertEqual(receivednote, expectednote)
            case (.failure(let receivedError), .failure(let expectedError)):
                XCTAssertEqual(receivedError, expectedError)
            default:
                XCTFail("expect to completeLoad with result: \(expectedResult), got \(receivedResult) instead.")
            }
            exp.fulfill()
        }
        action()
        
        wait(for: [exp], timeout: defaultTimout())
    }

}
