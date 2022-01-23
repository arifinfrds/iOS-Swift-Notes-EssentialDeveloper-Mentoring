//
//  LocalNoteDeleter.swift
//  Notes
//
//  Created by Arifin Firdaus on 23/11/21.
//

import Foundation

final class LocalNoteDeleter: NoteDeleter {
    private let store: NoteStore
    
    init(store: NoteStore) {
        self.store = store
    }
    
    func delete(_ note: Note, completion: @escaping (DeleteNoteResult) -> Void) {
        store.delete(note) { result in
            switch result {
            case .success(let note):
                completion(.success(note))
            case .failure:
                completion(.failure(.unknown))
            }
        }
    }
    
    func deleteAll(completion: @escaping (DeleteAllNotessResult) -> Void) {
        store.deleteAll { result in
            switch result {
            case .success:
                completion(.success)
            case .failure:
                completion(.failure(.unknown))
            }
        }
    }
}

