//
//  DefaultNoteListPresenterTests.swift
//  NotesTests
//
//  Created by Arifin Firdaus on 24/02/21.
//

import XCTest
@testable import Notes

class DefaultNoteListPresenterTests: XCTestCase {
    
    func test_onLoad_shouldDisplaysInitialStateWithEmptyNotes() {
        let (sut, view) = makeSUT()
        
        sut.onLoad()
        
        XCTAssertTrue(view.notes.isEmpty)
        XCTAssertEqual(view.message, nil)
        XCTAssertEqual(view.isDeleteAllButtonEnabled, false)
    }
    
    func test_onLoad_shouldDisplaysInitialStateWithNonEmptyNotes() {
        let (sut, view) = makeSUT()
        let expectedNotes = [uniqueNote(), uniqueNote()]
        
        sut.onLoad()
        view.complete(with: expectedNotes)
        view.setDeleteAllButtonEnabled(true)
        
        XCTAssertEqual(view.notes, expectedNotes)
        XCTAssertEqual(view.message, nil)
        XCTAssertEqual(view.isDeleteAllButtonEnabled, true)
    }
    
    func test_onLoad_shouldLoadNotes() {
        let (sut, view) = makeSUT()
        let expectedNotes = [uniqueNote(), uniqueNote()]
        
        sut.onLoad()
        view.complete(with: expectedNotes)
        
        let actualTotalNote = view.notes.count
        
        let expectedTotalNote = expectedNotes.count
        
        XCTAssertEqual(view.notes, expectedNotes)
        XCTAssertEqual(view.isReloaded, true)
        XCTAssertEqual(actualTotalNote, expectedTotalNote)
    }
    
    func test_onLoad_deliversErrorMessage() {
        let (sut, view) = makeSUT()
        
        sut.onLoad()
        let errorMessage = "some error message"
        view.complete(with: errorMessage)
        
        XCTAssertEqual(view.message, errorMessage)
        XCTAssertEqual(view.isReloaded, true)
    }
	
	func test_onReload_shouldreloadNotes() {
		let (sut, view) = makeSUT()
		let expectedNotes = [uniqueNote(), uniqueNote()]
		
		sut.onReload()
		view.complete(with: expectedNotes)
		
        let actualTotalBalance = view.notes.count
		
        let expectedTotalBalance = expectedNotes.count
		
		XCTAssertEqual(view.notes, expectedNotes)
		XCTAssertEqual(view.isReloaded, true)
		XCTAssertEqual(actualTotalBalance, expectedTotalBalance)
	}
    
    func test_onDelete_deliverCorrectStateOnOnlyHasSingleItem() {
        let (sut, view) = makeSUT()
        
        let selectedNote = uniqueNote()
        sut.onAdd(selectedNote)
        
        let selectedRow = 0
        sut.onDelete(selectedNote, at: selectedRow)
        let successfullMessage = "Berhasil menghapus note dengan nama : \(selectedNote.name)"
        view.complete(with: successfullMessage)
        
        XCTAssertEqual(view.message, successfullMessage)
        XCTAssertEqual(view.isReloaded, true)
        XCTAssertEqual(view.isDeleteAllButtonEnabled, false)
    }
    
    func test_onDelete_deliverCorrectStateOnMoreThanOneItems() {
        let (sut, view) = makeSUT()
        
        let selectedNote = uniqueNote()
        sut.onAdd(selectedNote)
        sut.onAdd(uniqueNote())
        
        let selectedRow = 0
        sut.onDelete(selectedNote, at: selectedRow)
        let successfullMessage = "Berhasil menghapus note dengan nama : \(selectedNote.name)"
        view.complete(with: successfullMessage)
        
        XCTAssertEqual(view.message, successfullMessage)
        XCTAssertEqual(view.isReloaded, true)
        XCTAssertEqual(view.isDeleteAllButtonEnabled, true)
    }
    
    func test_onDeleteAllTapped_showsAlertForDeleteAllNotesOnAvailableNotes() {
        let (sut, view) = makeSUT()
        for _ in 1...100 { sut.onAdd(uniqueNote()) }
        
        sut.onDeleteAllTapped()
        
        let alertMessage = "Apakah Anda yakin ingin menghapus semua note?"
        XCTAssertEqual(view.message, alertMessage)
    }
    
    func test_onConfirmDeleteAllNotes_deliverSucessfullMessageWithCorrectState() {
        let (sut, view) = makeSUT()
        
        sut.onConfirmDeleteAllNotes()
        let successfullMessage = "Berhasil menghapus semua note."
        view.complete(with: successfullMessage)
        view.complete(with: [])
        
        XCTAssertEqual(view.message, successfullMessage)
        XCTAssertEqual(view.isReloaded, true)
        XCTAssertEqual(view.notes, [])
        XCTAssertEqual(view.isDeleteAllButtonEnabled, false)
    }
    
    func test_onAdd_deliverSucessfullMessageWithAddedNote() {
        let (sut, view) = makeSUT()
        
        let newNote = uniqueNote()
        sut.onAdd(newNote)
        let successfullMessage = "Berhasil menambahkan note dengan nama: \(newNote.name)"
        view.complete(with: successfullMessage)
        view.complete(with: [newNote])
        
        XCTAssertEqual(view.message, successfullMessage)
        XCTAssertEqual(view.isReloaded, true)
        XCTAssertEqual(view.notes, [newNote])
    }
    
    func test_deinit_SUTInstanceShouldHaveBeenDeallocated() {
        let store = CoreDataNoteStore(.inMemory)
        let loader = LocalNoteLoader(store: store)
        let adder = LocalNoteAdder(store: store)
        let deleter = LocalNoteDeleter(store: store)
        let view = NoteListViewSpy()
        var sut: DefaultNoteListPresenter? = DefaultNoteListPresenter(loader: loader, adder: adder, deleter: deleter)
        sut?.view = view
        
        sut?.onLoad()
        sut = nil
        view.complete(with: [])
        
        XCTAssertTrue(view.notes.isEmpty)
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: NoteListPresenter, view: NoteListViewSpy) {
        let store = CoreDataNoteStore(.inMemory)
        let loader = LocalNoteLoader(store: store)
        let adder = LocalNoteAdder(store: store)
        let deleter = LocalNoteDeleter(store: store)
        let view = NoteListViewSpy()
        let sut = DefaultNoteListPresenter(loader: loader, adder: adder, deleter: deleter)
        sut.view = view
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(view, file: file, line: line)
        trackMemoryLeaks(loader, file: file, line: line)
        return (sut, view)
    }
    
    private class NoteListViewSpy: NoteListView {
        var message: String?
        var notes: [Note] = []
        var isReloaded = false
        var isDeleteAllButtonEnabled = false
        
        func display(_ notes: [Note]) {
            self.notes = notes
        }
        
        func display(_ message: String) {
            self.message = message
        }
        
        func displayDeleteAllAlert(_ message: String) {
            self.message = message
        }
        
        func reloadView() {
            isReloaded = true
        }
        
        func reloadView(at row: Int) {
            isReloaded = true
        }
        
        func removeView(at row: Int) {
            isReloaded = true
        }
        
        func displayHeaderText(_ balance: String) {
            
        }
        
        func setDeleteAllButtonEnabled(_ isEnabled: Bool) {
            isDeleteAllButtonEnabled = isEnabled
        }
        
        func complete(with notes: [Note]) {
            self.notes = notes
        }
        
        func complete(with message: String) {
            self.message = message
        }
    }
    
}
