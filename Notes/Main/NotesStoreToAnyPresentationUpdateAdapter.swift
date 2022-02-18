//
//  NotesStoreToAnyPresentationUpdateAdapter.swift
//  Notes
//
//  Created by Arifin Firdaus on 18/02/22.
//

import Foundation

final class NotesStoreToAnyPresentationUpdateAdapter: NoteStoreUpdateDelegate {
    private let presentations: [PresentationUpdateable]
    
    init(presentations: [PresentationUpdateable]) {
        self.presentations = presentations
    }
    
    func didUpdateNote(_ note: Note) {
        presentations.forEach { presentation in
            presentation.update(note)
        }
    }
}
