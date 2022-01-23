//
//  NoteUpdater.swift
//  Notes
//
//  Created by Arifin Firdaus on 17/11/21.
//

import Foundation

protocol NoteUpdater {
    typealias Result = Swift.Result<Note, NoteUpdaterError>
    func update(id: UUID, with note: Note, completion: @escaping (Result) -> Void)
}

enum NoteUpdaterError: Swift.Error, Equatable {
    case unknown
    case idNotFound
}

final class LocalNoteUpdater: NoteUpdater {
    private let store: NoteStore
    
    init(store: NoteStore) {
        self.store = store
    }
    
    func update(id: UUID, with note: Note, completion: @escaping (NoteUpdater.Result) -> Void) {
        store.update(id: id, with: note) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .failure(error):
                switch error {
                case .idNotFound:
                    completion(.failure(.idNotFound))
                case .unknown:
                    completion(.failure(.unknown))
                }
            case let .success(updatedNote):
                completion(.success(updatedNote))
            }
        }
    }
}
