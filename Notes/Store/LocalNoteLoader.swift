//
//  LocalNoteLoader.swift
//  Notes
//
//  Created by Arifin Firdaus on 22/02/21.
//

import Foundation

final class LocalNoteLoader: NoteLoader {
    private let store: NoteStore
    
    init(store: NoteStore) {
        self.store = store
    }
}
 
extension LocalNoteLoader {
    func load(completion: @escaping (LoadNotesResult) -> Void) {
        store.loadNotes { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success(notes):
                completion(.success(notes))
            case .failure:
                completion(.failure(.unknown))
            }
        }
    }
    
    func load(noteId: UUID, completion: @escaping (LoadNoteResult) -> Void) {
        store.loadNote(id: noteId) { result in
            switch result {
            case let .failure(error):
                switch error {
                case .unknown:
                    completion(.failure(.unknown))
                case .notFound:
                    completion(.failure(.notFound))
                }
            case let .success(note):
                completion(.success(note))
            }
        }
    }
}
