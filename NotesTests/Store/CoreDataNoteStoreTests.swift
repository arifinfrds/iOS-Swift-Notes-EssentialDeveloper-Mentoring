//
//  CoreDataNoteStoreTests.swift
//  NotesTests
//
//  Created by Arifin Firdaus on 24/02/21.
//

import XCTest
@testable import Notes

class CoreDataNoteStoreTests: XCTestCase {
    
    func test_loadNotes_deliversEmptyNotes() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion")
        var capturedNotes = [Note]()
        sut.loadNotes { result in
            switch result {
            case .success(let notes):
                capturedNotes = notes
            case .failure(let error):
                XCTFail("Expect success, got error instead, error: \(error)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: defaultTimout())
        
        XCTAssertTrue(capturedNotes.isEmpty)
    }
    
    func test_loadNote_deliversNotFoundError() {
        let noteId = anyUUID()
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")
        var capturedErrors = [LoadableNoteStoreError]()
        
        sut.loadNote(id: noteId) { result in
            switch result {
            case let .failure(error):
                capturedErrors.append(error)
            case .success:
                XCTFail("Expect failure, got success instead.")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: defaultTimout())
        
        XCTAssertEqual(capturedErrors, [ .notFound ])
    }
    
    func test_add_successAddNote() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion")
        var capturedNotes = [Note]()
        let noteToAdd = uniqueNote()
        sut.add(noteToAdd) { result in
            switch result {
            case .success(let addedNote):
                capturedNotes.append(addedNote)
            case .failure(let error):
                XCTFail("Expect success, got error instead, error: \(error)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: defaultTimout())
        
        XCTAssertEqual(capturedNotes, [noteToAdd])
    }
    
    func test_addThenLoad_shouldSuccessWithSavedNote() {
        let sut = makeSUT()
        
        let exp1 = expectation(description: "Wait for completion")
        var addCapturedNotes = [Note]()
        let noteToAdd = uniqueNote()
        sut.add(noteToAdd) { result in
            switch result {
            case .success(let addedNote):
                addCapturedNotes.append(addedNote)
            case .failure(let error):
                XCTFail("Expect success, got error instead, error: \(error)")
            }
            exp1.fulfill()
        }
        
        wait(for: [exp1], timeout: defaultTimout())
        
        
        let exp2 = expectation(description: "Wait for completion")
        var loadCapturedNotes = [Note]()
        sut.loadNotes { result in
            switch result {
            case .success(let notes):
                loadCapturedNotes = notes
            case .failure(let error):
                XCTFail("Expect success, got error instead, error: \(error)")
            }
            exp2.fulfill()
        }
        wait(for: [exp2], timeout: defaultTimout())
        
        XCTAssertEqual(loadCapturedNotes.count, 1)
    }
    
    func test_loadNote_deliversNote() {
        let sut = makeSUT()
        
        let exp1 = expectation(description: "Wait for completion")
        var addCapturedNotes = [Note]()
        let noteToAdd = uniqueNote()
        sut.add(noteToAdd) { result in
            switch result {
            case .success(let addedNote):
                addCapturedNotes.append(addedNote)
            case .failure(let error):
                XCTFail("Expect success, got error instead, error: \(error)")
            }
            exp1.fulfill()
        }
        
        wait(for: [exp1], timeout: defaultTimout())
        
        let exp2 = expectation(description: "Wait for completion")
        var loadCapturedNotes = [Note]()
        sut.loadNote(id: noteToAdd.id) { result in
            switch result {
            case .success(let note):
                loadCapturedNotes.append(note)
            case .failure(let error):
                XCTFail("Expect success, got error instead, error: \(error)")
            }
            exp2.fulfill()
        }
        
        wait(for: [exp2], timeout: defaultTimout())
        
        XCTAssertEqual(loadCapturedNotes.count, 1)
        XCTAssertEqual(loadCapturedNotes, [ noteToAdd ])
    }
    
    func test_delete_shouldDeleteANote() {
        let sut = makeSUT()
        
        let exp1 = expectation(description: "Wait for completion")
        var capturedNotes = [Note]()
        let noteToAdd = uniqueNote()
        sut.add(noteToAdd) { result in
            switch result {
            case .success(let addedNote):
                capturedNotes.append(addedNote)
            case .failure(let error):
                XCTFail("Expect success, got error instead, error: \(error)")
            }
            exp1.fulfill()
        }
        
        wait(for: [exp1], timeout: defaultTimout())
        
        let exp2 = expectation(description: "Wait for completion")
        var capturedDeletedNotes = [Note]()
        let noteToDelete = noteToAdd
        sut.delete(noteToDelete) { result in
            switch result {
            case .success(let addedNote):
                capturedDeletedNotes.append(addedNote)
            case .failure(let error):
                XCTFail("Expect success, got error instead, error: \(error)")
            }
            exp2.fulfill()
        }
        wait(for: [exp2], timeout: defaultTimout())
        
        XCTAssertEqual(capturedDeletedNotes, [noteToDelete])
    }
    
    func test_deleteAll_succedsOnDeleteAllNotes() {
        let sut = makeSUT()
        
        let exp1 = expectation(description: "Wait for completion")
        exp1.expectedFulfillmentCount = 2
        sut.add(uniqueNote()) { _ in exp1.fulfill() }
        sut.add(uniqueNote()) { _ in exp1.fulfill() }
        wait(for: [exp1], timeout: defaultTimout())
        
        
        let exp2 = expectation(description: "Wait for completion")
        sut.deleteAll { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                XCTFail("Expect success, got error instead, error: \(error)")
            }
            exp2.fulfill()
        }
        wait(for: [exp2], timeout: defaultTimout())
        
        
        let exp3 = expectation(description: "Wait for completion")
        var capturedNotes = [Note]()
        sut.loadNotes { result in
            switch result {
            case .success(let notes):
                capturedNotes = notes
            case .failure(let error):
                XCTFail("Expect success, got error instead, error: \(error)")
            }
            exp3.fulfill()
        }
        wait(for: [exp3], timeout: defaultTimout())
        
        XCTAssertTrue(capturedNotes.isEmpty)
    }
    
    func test_update_failsOnNotFoundnoteId() {
        let noteToUpdate = uniqueNote()
        let noteId = noteToUpdate.id
        let sut = makeSUT()
        var capturedErrors = [UpdateableNoteStoreError]()
        let exp = expectation(description: "Wait for completion")
        
        sut.update(id: noteId, with: noteToUpdate) { result in
            switch result {
            case .failure(let error):
                capturedErrors.append(error)
            case .success:
                XCTFail("Expect to fail, got success instead.")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: defaultTimout())
        
        XCTAssertEqual(capturedErrors, [ .idNotFound ])
    }
    
    func test_update_succedsUpdateNote() {
        let fixedDate = sampleFixedDate()
        let sut = makeSUT()
        let exp1 = expectation(description: "Wait for add completion")
        var addCapturedNotes = [Note]()
        let noteToAdd = uniqueNote(createdDate: fixedDate, name: "old name")
        sut.add(noteToAdd) { result in
            switch result {
            case .success(let addedNote):
                addCapturedNotes.append(addedNote)
            case .failure(let error):
                XCTFail("Expect success, got error instead, error: \(error)")
            }
            exp1.fulfill()
        }
        wait(for: [exp1], timeout: defaultTimout())
        
        let noteToUpdate = Note(id: noteToAdd.id, createdAt: noteToAdd.createdAt, updatedAt: Date(), name: "new name", description: "new update!")
        let noteId = noteToUpdate.id
        var receivedNotes = [Note]()
        let exp2 = expectation(description: "Wait for update completion")
        
        sut.update(id: noteId, with: noteToUpdate) { result in
            switch result {
            case .success(let note):
                receivedNotes.append(note)
            case .failure(let error):
                XCTFail("Expect to fail, got success instead with error: \(error)")
            }
            exp2.fulfill()
        }
        wait(for: [exp2], timeout: defaultTimout())
        
        XCTAssertFalse(receivedNotes.isEmpty)
        XCTAssertEqual(noteToAdd.id, receivedNotes.first?.id)
        XCTAssertEqual(receivedNotes.first?.name, noteToUpdate.name)
        XCTAssertEqual(receivedNotes.first?.description, noteToUpdate.description)
        XCTAssertEqual(receivedNotes.first?.createdAt, noteToUpdate.createdAt)
        XCTAssertEqual(receivedNotes.first?.updatedAt, noteToUpdate.updatedAt)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataNoteStore {
        let sut = CoreDataNoteStore(.inMemory)
        trackMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func anyUUID() -> UUID {
        return UUID()
    }
    
    private func sampleFixedDate() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let timeZone = TimeZone(secondsFromGMT: 0)
        let components = DateComponents(calendar: calendar, timeZone: timeZone, year: 2021, month: 11, day: 10)
        let createdDate = calendar.date(from: components)!
        return createdDate
    }

}
