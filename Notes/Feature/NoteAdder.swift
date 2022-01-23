//
//  NoteAdder.swift
//  Notes
//
//  Created by Arifin Firdaus on 23/11/21.
//

import Foundation

protocol NoteAdder {
    typealias Result = Swift.Result<Note, NoteAdderError>
    func add(_ note: Note, completion: @escaping (Result) -> Void)
}

enum NoteAdderError: Swift.Error, Equatable {
    case unknown
    case notFound
}
