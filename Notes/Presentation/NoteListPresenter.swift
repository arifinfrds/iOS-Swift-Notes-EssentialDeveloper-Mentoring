//
//  NoteListPresenter.swift
//  Notes
//
//  Created by Arifin Firdaus on 24/02/21.
//

import Foundation

protocol NoteListPresenter {
    func onLoad()
	func onReload()
    func onDelete(_ note: Note, at row: Int)
    func onDeleteAllTapped()
    func onConfirmDeleteAllNotes()
    func onAdd(_ note: Note)
    
    var notes: [Note] { get }
}

protocol NoteListView {
    func display(_ notes: [Note])
    func display(_ message: String)
    func displayDeleteAllAlert(_ message: String)
    func reloadView()
    func reloadView(at row: Int)
    func removeView(at row: Int)
    func displayHeaderText(_ text: String)
    func setDeleteAllButtonEnabled(_ isEnabled: Bool)
}

final class DefaultNoteListPresenter: NoteListPresenter {
    private let loader: NoteLoader
    private let adder: NoteAdder
    private let deleter: NoteDeleter
    var view: NoteListView?
    
    var notes: [Note] = []
    
    init(loader: NoteLoader, adder: NoteAdder, deleter: NoteDeleter) {
        self.loader = loader
        self.adder = adder
        self.deleter = deleter
    }
    
    func onLoad() {
        loader.load { result in
            switch result {
            case .success(let notes):
                self.notes = notes.sorted(by: { $0.createdAt > $1.createdAt })
                self.view?.display(notes)
                self.view?.reloadView()
                self.view?.displayHeaderText(self.getNoteCountText())
                self.view?.setDeleteAllButtonEnabled(notes.isEmpty ? false : true)
            case .failure(let error):
                self.view?.display(error.localizedDescription)
            }
        }
    }
    
	func onReload() {
		onLoad()
	}
    
    func onDelete(_ note: Note, at row: Int) {
        deleter.delete(note) { result in
            switch result {
            case .success(let note):
                self.view?.display("Berhasil menghapus note dengan nama : \(note.name)")
                self.notes.remove(at: row)
                self.view?.removeView(at: row)
                self.view?.displayHeaderText(self.getNoteCountText())
                self.view?.setDeleteAllButtonEnabled(self.notes.isEmpty ? false : true)
            case .failure(let error):
                self.view?.display(error.localizedDescription)
            }
        }
    }
    
    func onDeleteAllTapped() {
        view?.displayDeleteAllAlert("Apakah Anda yakin ingin menghapus semua note?")
    }
    
    func onConfirmDeleteAllNotes() {
        deleter.deleteAll { result in
            switch result {
            case .success:
                self.notes.removeAll()
                self.view?.display("Berhasil menghapus semua note.")
                self.view?.reloadView()
                self.view?.displayHeaderText(self.getNoteCountText())
                self.view?.setDeleteAllButtonEnabled(false)
            case .failure(let error):
                self.view?.display(error.localizedDescription)
            }
        }
    }
    
    func onAdd(_ note: Note) {
        adder.add(note) { result in
            switch result {
            case .success(let note):
                self.notes.append(note)
                self.view?.display("Berhasil menambahkan note dengan nama: \(note.name)")
                self.view?.reloadView()
                self.view?.displayHeaderText(self.getNoteCountText())
            case .failure(let error):
                self.view?.display(error.localizedDescription)
            }
        }
    }
    
    private func getNoteCountText() -> String {
        return "You have \(getNoteCount()) notes"
    }
    
    private func getNoteCount() -> Int {
        notes.count
    }
    
}

extension DefaultNoteListPresenter: PresentationUpdateable {
    
    func update(_ note: Note) {
        var updateTargetIndex = 0
        notes.enumerated().forEach { (index, iteratedNote) in
            if note.id == iteratedNote.id {
                updateTargetIndex = index
            }
        }
        
        notes[updateTargetIndex] = note
        
        view?.displayHeaderText(getNoteCountText())
        view?.reloadView(at: updateTargetIndex)
    }
	
	func update() {
		view?.displayHeaderText(getNoteCountText())
		view?.reloadView()
	}
}
