//
//  ManagedNote+toModel.swift
//  Notes
//
//  Created by Arifin Firdaus on 24/02/21.
//

import Foundation

extension ManagedNote {
    
    func toModel() -> Note {
        return Note(
            id: self.identifier!,
            createdAt: self.createdAt!,
            updatedAt: self.updatedAt!,
            name: self.name!,
            description: self.noteDescription
        )
    }
    
}

extension ManagedNote {
    
    func createFromModel(_ note: Note) {
        self.identifier = note.id
        self.createdAt = note.createdAt
        self.updatedAt = note.updatedAt
        self.name = note.name
        self.noteDescription = note.description
    }
}
