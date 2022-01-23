//
//  NoteStoreSpy.swift
//  NotesTests
//
//  Created by Arifin Firdaus on 08/03/21.
//

import Foundation
@testable import Notes

final class NoteStoreSpy: NoteStore {
    
    enum Message: Equatable {
        case loadNotes
        case deleteNote(_ note: Note)
        case deleteAllNotes
        case loadNote(_ noteId: UUID)
        case update(id: UUID, value: Note)
    }
    
    private(set) var messages = [Message]()
    
    
    // MARK: - Load
    
    private var loadNotesCompletions = [LoadNotesCompletion]()
    private var loadNoteCompletions = [LoadNoteCompletion]()
    
    func loadNotes(completion: @escaping LoadNotesCompletion) {
        messages.append(.loadNotes)
        loadNotesCompletions.append(completion)
    }
    
    func completeLoad(with error: LoadableNoteStoreError, at index: Int = 0) {
        loadNotesCompletions[index](.failure(error))
    }
    
    func completeLoad(with notes: [Note], at index: Int = 0) {
        loadNotesCompletions[index](.success(notes))
    }

    func loadNote(id: UUID, completion: @escaping LoadNoteCompletion) {
        messages.append(.loadNote(id))
        loadNoteCompletions.append(completion)
    }
    
    func completeLoadNote(with error: LoadableNoteStoreError, at index: Int = 0) {
        loadNoteCompletions[index](.failure(error))
    }
    
    func completeLoadNote(with note: Note, index: Int = 0) {
        loadNoteCompletions[index](.success(note))
    }
    
    // MARK: - Insertion
    
    private var noteInsertionCompletions = [AddNoteCompletion]()
    
    func add(_ note: Note, completion: @escaping AddNoteCompletion) {
        noteInsertionCompletions.append(completion)
    }
    
    func completeAddNote(with error: Error, at index: Int = 0) {
        noteInsertionCompletions[index](.failure(error))
    }
    
    func completeAddNote(with note: Note, at index: Int = 0) {
        noteInsertionCompletions[index](.success(note))
    }
    
    
    // MARK: - Deletion
    
    private var DeleteNoteCompletions = [DeleteNoteCompletion]()
    
    func delete(_ note: Note, completion: @escaping DeleteNoteCompletion) {
        messages.append(.deleteNote(note))
        DeleteNoteCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        DeleteNoteCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(with note: Note, at index: Int = 0) {
        DeleteNoteCompletions[index](.success(note))
    }
    
    
    // MARK: - Delete all
    
    private var DeleteAllNotesCompletions = [DeleteAllNotesCompletion]()
    
    func deleteAll(completion: @escaping DeleteAllNotesCompletion) {
        messages.append(.deleteAllNotes)
        DeleteAllNotesCompletions.append(completion)
    }
    
    func completeAllNotesDeletion(with error: Error, at index: Int = 0) {
        DeleteAllNotesCompletions[index](.failure(error))
    }
    
    func completeDeleteAllNotesSuccessfully(at index: Int = 0) {
        DeleteAllNotesCompletions[index](.success(()))
    }
    
    // MARK: - Update
    
    private var UpdateNoteCompletions = [UpdateNoteCompletion]()
    
    func update(id: UUID, with note: Note, completion: @escaping UpdateNoteCompletion) {
        messages.append(.update(id: id, value: note))
        UpdateNoteCompletions.append(completion)
    }
    
    func completeUpdate(with error: UpdateableNoteStoreError, at index: Int = 0) {
        UpdateNoteCompletions[index](.failure(error))
    }
    
    func completeUpdate(with note: Note, at index: Int = 0) {
        UpdateNoteCompletions[index](.success(note))
    }
}
