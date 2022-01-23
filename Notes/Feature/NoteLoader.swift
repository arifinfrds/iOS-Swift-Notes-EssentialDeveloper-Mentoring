//
//  NoteLoader.swift
//  Notes
//
//  Created by Arifin Firdaus on 25/02/21.
//

import Foundation

protocol NoteLoader {
    typealias LoadNotesResult = Result<[Note], NoteLoaderError>
    func load(completion: @escaping (LoadNotesResult) -> Void)
    
    typealias LoadNoteResult = Result<Note, NoteLoaderError>
    func load(noteId: UUID, completion: @escaping (LoadNoteResult) -> Void)
}

enum NoteLoaderError: Error, Equatable {
    case unknown
    case notFound
}
