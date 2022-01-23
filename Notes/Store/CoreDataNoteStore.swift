//
//  CoreDataNoteStore.swift
//  Notes
//
//  Created by Arifin Firdaus on 24/02/21.
//

import Foundation
import CoreData

final class CoreDataNoteStore: NoteStore {
    
    private let persistentContainer: NSPersistentContainer
    
    var updateDelegate: NoteStoreUpdateDelegate?
    
    enum StorageType {
        case persistent
        case inMemory
    }
    
    init(_ storageType: StorageType = .persistent) {
        self.persistentContainer = NSPersistentContainer(name: "Notes")
        
        if storageType == .inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            self.persistentContainer.persistentStoreDescriptions = [description]
        }
        
        self.persistentContainer.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Unresolved error: \(error)")
            }
        }
    }
    
    enum Error {
        case idNotFound
        case unknown
    }
    
    func loadNotes(completion: @escaping LoadNotesCompletion) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ManagedNote> = ManagedNote.fetchRequest()
        do {
            let managedNotes = try context.fetch(fetchRequest)
            let notes = managedNotes.map { $0.toModel() }
            completion(.success(notes))
        } catch {
            completion(.failure(error))
        }
    }
    
    func loadNote(id: UUID, completion: @escaping LoadNoteCompletion) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ManagedNote> = ManagedNote.fetchRequest()
        do {
            let managedNotes = try context.fetch(fetchRequest)
            let filteredNotes = managedNotes
                .map { $0.toModel() }
                .filter { $0.id == id }
            
            if let foundNote = filteredNotes.first {
                completion(.success(foundNote))
            } else {
                completion(.failure(.notFound))
            }
        } catch {
            completion(.failure(.unknown))
        }
    }
    
    func add(_ note: Note, completion: @escaping AddNoteCompletion) {
        let context = persistentContainer.viewContext
        do {
            let managedNote = ManagedNote(context: context)
            managedNote.createFromModel(note)
            try context.save()
            let savedNote = managedNote.toModel()
            completion(.success(savedNote))
        } catch {
            completion(.failure(error))
        }
    }
    
    func delete(_ note: Note, completion: @escaping DeleteNoteCompletion) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ManagedNote> = ManagedNote.fetchRequest()
        do {
            let managedNotes = try context.fetch(fetchRequest)
            _ = managedNotes
                .filter { $0.identifier == note.id }
                .map { context.delete($0) }
            try context.save()
            completion(.success(note))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteAll(completion: @escaping DeleteAllNotesCompletion) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ManagedNote> = ManagedNote.fetchRequest()
        do {
            let managedNotes = try context.fetch(fetchRequest)
            managedNotes.forEach { context.delete($0) }
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func update(id: UUID, with note: Note, completion: @escaping UpdateNoteCompletion) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ManagedNote> = ManagedNote.fetchRequest()
        do {
            let managedNotes = try context.fetch(fetchRequest)
            let filteredNotes = managedNotes
                .filter { $0.identifier == id }
            
            guard let targetNote = filteredNotes.first else {
                completion(.failure(.idNotFound))
                return
            }
            
            targetNote.identifier = id
            targetNote.name = note.name
            targetNote.createdAt = note.createdAt
            targetNote.updatedAt = note.updatedAt
            targetNote.noteDescription = note.description
            
            try context.save()
            
            completion(.success(targetNote.toModel()))
            
            updateDelegate?.didUpdateNote(note)
        } catch {
            completion(.failure(.unknown))
        }
    }
}
