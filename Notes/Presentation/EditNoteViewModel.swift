//
//  EditNoteViewModel.swift
//  Notes
//
//  Created by Arifin Firdaus on 26/11/21.
//

import Foundation

final class EditNoteViewModel: ObservableObject {
    
    private let noteId: UUID
    private let noteLoader: NoteLoader
    private let noteUpdater: NoteUpdater
    
    @Published var title = "Edit Note"
    @Published var isLoading = false
    
    @Published var shouldShowErrorAlert = false
    @Published var errorTitle = ""
    @Published var errorMessage = ""
    
    @Published var shouldShowSuccessUpdateAlert = false
    @Published var successUpdateTitle = ""
    @Published var successUpdateMessage = ""
    
    @Published var noteName = ""
    @Published var noteDescription = ""
    @Published var noteDate = ""
    @Published var noteCreatedDate = Date()
    
    private let dateDisplayViewModel: DateDisplayViewModel
    
    init(noteId: UUID, noteLoader: NoteLoader, noteUpdater: NoteUpdater, dateDisplayViewModel: DateDisplayViewModel) {
        self.noteId = noteId
        self.noteLoader = noteLoader
        self.noteUpdater = noteUpdater
        self.dateDisplayViewModel = dateDisplayViewModel
    }
}

extension EditNoteViewModel {
    
    func onAppear() {
        
        isLoading = true
        
        noteLoader.load(noteId: noteId) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case let .success(note):
                self.handleOnSuccess(note)
            case let .failure(error):
                self.handleLoadNoteFailure(error)
            }
        }
    }
    
    private func handleOnSuccess(_ note: Note) {
        noteName = note.name
        setNoteDescription(from: note)
        noteDate = dateDisplayViewModel.displayDate(from: note.createdAt)
        noteCreatedDate = note.createdAt
    }
    
    private func setNoteDescription(from note: Note) {
        if let description = note.description {
            noteDescription = description
        } else {
            noteDescription = ""
        }
    }
    
    private func handleLoadNoteFailure(_ error: NoteLoaderError) {
        switch error {
        case .unknown:
            errorTitle = "Oops.."
            errorMessage = "Terjadi kesalahan. Mohon coba lagi."
        case .notFound:
            errorTitle = "Oops.."
            errorMessage = "Terjadi kesalahan. Id note tidak dapat ditemukan."
        }
        shouldShowErrorAlert = true
    }
    
    func onDismissLoadNoteErrorAlert() {
        resetErrorAlertData()
    }
    
    private func resetErrorAlertData() {
        shouldShowErrorAlert = false
        errorTitle = ""
        errorMessage = ""
    }
}

extension EditNoteViewModel {
    
    func onSave() {
        
        guard let noteToUpdate = createNoteToUpdate() else {
            return
        }
        
        isLoading = true
        
        noteUpdater.update(id: noteId, with: noteToUpdate) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success:
                self.handleOnSaveSuccess()
            case let .failure(error):
                self.handleOnSaveFailure(error)
            }
        }
    }
    
    private func createNoteToUpdate() -> Note? {
        
        let currentNoteId = noteId
        let updatedDate = Date()
        
        let noteToUpdate = Note(
            id: currentNoteId,
            createdAt: noteCreatedDate,
            updatedAt: updatedDate,
            name: noteName,
            description: noteDescription
        )
        
        return noteToUpdate
    }
    
    private func handleOnSaveSuccess() {
        successUpdateTitle = "Update Sukses"
        successUpdateMessage = "Berhasil mengupdate note"
        shouldShowSuccessUpdateAlert = true
    }
    
    private func handleOnSaveFailure(_ error: NoteUpdaterError) {
        switch error {
        case .unknown:
            shouldShowErrorAlert = true
            errorTitle = "Oops.."
            errorMessage = "Terjadi kesalahan. Mohon coba lagi."
        case .idNotFound:
            shouldShowErrorAlert = true
            errorTitle = "Oops.."
            errorMessage = "Terjadi kesalahan. Id note tidak dapat ditemukan."
        }
    }
    
    func onDismissSuccessUpdateAlert() {
        resetSuccessUpdateAlertData()
    }
    
    private func resetSuccessUpdateAlertData() {
        shouldShowSuccessUpdateAlert = false
        successUpdateTitle = ""
        successUpdateMessage = ""
    }
}
