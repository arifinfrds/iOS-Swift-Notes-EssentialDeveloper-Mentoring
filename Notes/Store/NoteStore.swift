//
//  NoteStore.swift
//  Notes
//
//  Created by Arifin Firdaus on 22/02/21.
//

import Foundation

enum LoadableNoteStoreError: Swift.Error, Equatable {
    case unknown
    case notFound
}

protocol LoadableNoteStore {
    typealias LoadNotesCompletion = (Result<[Note], Error>) -> Void
    func loadNotes(completion: @escaping LoadNotesCompletion)
    
    typealias LoadNoteCompletion = (Result<Note, LoadableNoteStoreError>) -> Void
    func loadNote(id: UUID, completion: @escaping LoadNoteCompletion)
}

protocol AddableNoteStore {
    typealias AddNoteCompletion = (Result<Note, Error>) -> Void
    func add(_ note: Note, completion: @escaping AddNoteCompletion)
}

protocol DeletableNoteStore {
    typealias DeleteNoteCompletion = (Result<Note, Error>) -> Void
    func delete(_ note: Note, completion: @escaping DeleteNoteCompletion)
    
    typealias DeleteAllNotesCompletion = (Result<Void, Error>) -> Void
    func deleteAll(completion: @escaping DeleteAllNotesCompletion)
}

enum UpdateableNoteStoreError: Swift.Error {
    case unknown
    case idNotFound
}

protocol UpdateableNoteStore {
    typealias UpdateNoteCompletion = (Result<Note, UpdateableNoteStoreError>) -> Void
    func update(id: UUID, with note: Note, completion: @escaping UpdateNoteCompletion)
}

protocol NoteStore: LoadableNoteStore, AddableNoteStore, DeletableNoteStore, UpdateableNoteStore { }

protocol NoteStoreUpdateDelegate {
    func didUpdateNote(_ note: Note)
}
