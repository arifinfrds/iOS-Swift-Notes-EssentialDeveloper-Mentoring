//
//  NoteDeleter.swift
//  Notes
//
//  Created by Arifin Firdaus on 23/11/21.
//

import Foundation

enum DeleteAllNoteResultType: Equatable {
    case success
    case failure(DeleteNoteError)
}

protocol NoteDeleter {
    typealias DeleteNoteResult = Result<Note, DeleteNoteError>
    func delete(_ note: Note, completion: @escaping (DeleteNoteResult) -> Void)
    
    typealias DeleteAllNotessResult = DeleteAllNoteResultType
    func deleteAll(completion: @escaping (DeleteAllNotessResult) -> Void)
}

enum DeleteNoteError: Swift.Error, Equatable {
    case unknown
    case notFound
}
