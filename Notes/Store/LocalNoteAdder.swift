//
//  LocalNoteAdder.swift
//  Notes
//
//  Created by Arifin Firdaus on 23/11/21.
//

import Foundation

final class LocalNoteAdder: NoteAdder {
    private let store: NoteStore
    
    init(store: NoteStore) {
        self.store = store
    }
    
    func add(_ note: Note, completion: @escaping (NoteAdder.Result) -> Void) {
        store.add(note) { result in
            switch result {
            case .success(let note):
                completion(.success(note))
            case .failure:
                completion(.failure(.unknown))
            }
        }
    }
}
