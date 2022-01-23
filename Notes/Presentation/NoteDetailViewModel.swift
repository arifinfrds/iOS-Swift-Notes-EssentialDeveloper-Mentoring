//
//  NoteDetailViewModel.swift
//  Notes
//
//  Created by Arifin Firdaus on 10/11/21.
//

import Foundation

class NoteDetailViewModel: ObservableObject {
    
    @Published var title = ""
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
    
    private let noteLoader: NoteLoader
    private let noteId: UUID
    private let dateDisplayViewModel: DateDisplayViewModel
    
    init(noteLoader: NoteLoader, noteId: UUID, dateDisplayViewModel: DateDisplayViewModel) {
        self.noteLoader = noteLoader
        self.noteId = noteId
        self.dateDisplayViewModel = dateDisplayViewModel
    }
    
    func onAppear() {
        
        isLoading = true
        
        noteLoader.load(noteId: noteId) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case let .success(note):
                self.handleOnSuccess(note)
            case let .failure(error):
                self.handleOnFailure(error)
            }
        }
    }
    
    func onDismissErrorAlert() {
        resetErrorAlertData()
    }
    
    private func resetErrorAlertData() {
        shouldShowErrorAlert = false
        errorTitle = ""
        errorMessage = ""
    }
    
    private func handleOnSuccess(_ note: Note) {
        title = note.name
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
    
    private func handleOnFailure(_ error: NoteLoaderError) {
        switch error {
        case .notFound:
            errorMessage = "Note tidak ditemukan"
        case .unknown:
            errorMessage = "Terjadi kesalahan. Mohon coba lagi."
        }
        errorTitle = "Error"
        
        shouldShowErrorAlert = true
    }
}

extension NoteDetailViewModel: PresentationUpdateable {
    
    func update(_ note: Note) {
        handleOnSuccess(note)
    }
}
