//
//  AddNoteViewModel.swift
//  Notes
//
//  Created by Arifin Firdaus on 21/12/21.
//

import Foundation

final class AddNoteViewModel: ObservableObject {
	
	private let noteAdder: NoteAdder
	
	@Published var title = "Add Note"
	@Published var isLoading = false
	
	@Published var shouldShowErrorAlert = false
	@Published var errorTitle = ""
	@Published var errorMessage = ""
	
	@Published var shouldShowSuccessAddAlert = false
	@Published var successAddTitle = ""
	@Published var successAddMessage = ""
	
	@Published var noteName = ""
	@Published var noteDescription = ""
	@Published var noteDate = ""
	@Published var noteCreatedDate = Date()
	
	var createdAt = Date()
	var updatedAt = Date()
	
	private let dateDisplayViewModel: DateDisplayViewModel
	
	init(noteAdder: NoteAdder, dateDisplayViewModel: DateDisplayViewModel) {
		self.noteAdder = noteAdder
		self.dateDisplayViewModel = dateDisplayViewModel
	}
	
	func onAddNoteButtonTapped() {
		
		guard !noteName.isEmpty || noteName != "" else {
			shouldShowErrorAlert = true
			errorTitle = "Oops.."
			errorMessage = "Name field cannot be empty"
			return
		}
		
		isLoading = true
		
		guard let noteToAdd = createNote() else {
			return
		}
		
		noteAdder.add(noteToAdd) { [weak self] result in
			guard let self = self else { return }
			
			self.isLoading = false
			
			switch result {
			case let .success(addedNote):
				self.successAddTitle = "Succeeds"
				self.successAddMessage = "Successfully added a note : \(addedNote.name)"
				self.shouldShowSuccessAddAlert = true
				
			case .failure:
				break
			}
		}
	}
	
	private func createNote() -> Note? {
		
		return Note(
			id: UUID(),
			createdAt: createdAt,
			updatedAt: createdAt,
			name: noteName,
			description: noteDescription
		)
	}
	
	func onDismissedErrorAlert() {
		resetErrorState()
		resetSuccessState()
	}
	
	private func resetErrorState() {
		shouldShowErrorAlert = false
		errorTitle = ""
		errorMessage = ""
	}
	
	private func resetSuccessState() {
		shouldShowSuccessAddAlert = false
		successAddTitle = ""
		successAddMessage = ""
	}
	
}
