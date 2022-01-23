//
//  AddNoteView.swift
//  Notes
//
//  Created by Arifin Firdaus on 25/02/21.
//

import SwiftUI

struct AddNoteView: View {
	
	@ObservedObject var viewModel: AddNoteViewModel
	
	var onCancelTapped: (() -> Void)?
	var onUpdateSuccessAlertTapped: (() -> Void)?
	
	var body: some View {
		NavigationView {
			AddNoteContentView(viewModel: viewModel)
				.toolbar {
					ToolbarItem(placement: .navigationBarLeading) {
						Button("Cancel", action: { onCancelTapped?() })
					}
					ToolbarItem(placement: .navigationBarTrailing) {
						Button("Add", action: { viewModel.onAddNoteButtonTapped() })
					}
				}
				.navigationBarTitle(Text(viewModel.title), displayMode: .large)
				.alert(isPresented: $viewModel.shouldShowSuccessAddAlert) {
					Alert(
						title: Text(viewModel.successAddTitle),
						message: Text(viewModel.successAddMessage),
						dismissButton: .default(
							Text("OK"),
							action: {
								viewModel.onDismissedErrorAlert()
								onUpdateSuccessAlertTapped?()
							}
						)
					)
				}
		}
	}
}

private struct AddNoteContentView: View {
	
	@ObservedObject var viewModel: AddNoteViewModel
	
	var body: some View {
		if viewModel.isLoading {
			ProgressView()
		} else {
			Form {
				Section(header: Text("General")) {
					TextField("Name", text: $viewModel.noteName)
				}
				
				Section(header: Text("Description")) {
					TextEditor(text: $viewModel.noteDescription)
                }
				
				Section {
					HStack {
						DatePicker(
							"Date",
							selection: $viewModel.noteCreatedDate,
							displayedComponents: [.date]
						)
					}
				}
				.alert(isPresented: $viewModel.shouldShowErrorAlert) {
					Alert(
						title: Text(viewModel.errorTitle),
						message: Text(viewModel.errorMessage),
						dismissButton: .default(
							Text("OK"),
							action: { viewModel.onDismissedErrorAlert() }
						)
					)
				}
			}
		}
	}
}

struct AddNoteView_Previews: PreviewProvider {
	
	static var previews: some View {
		
		let viewModel = AddNoteViewModel(
			noteAdder: NoteAdderPreviewStub(result: .success(uniqueNote())),
			dateDisplayViewModel: DateDisplayViewModel()
		)
		
		let errorAlertViewModel = AddNoteViewModel(
			noteAdder: NoteAdderPreviewStub(result: .success(uniqueNote())),
			dateDisplayViewModel: DateDisplayViewModel()
		)
		errorAlertViewModel.shouldShowErrorAlert = true
		errorAlertViewModel.errorTitle = "Error"
		errorAlertViewModel.errorMessage = "Some error message"
		
		let loadingViewModel = AddNoteViewModel(
			noteAdder: NoteAdderPreviewStub(result: .success(uniqueNote())),
			dateDisplayViewModel: DateDisplayViewModel()
		)
		loadingViewModel.isLoading = true
		
		let successAlertViewModel = AddNoteViewModel(
			noteAdder: NoteAdderPreviewStub(result: .success(uniqueNote())),
			dateDisplayViewModel: DateDisplayViewModel()
		)
		successAlertViewModel.shouldShowSuccessAddAlert = true
		successAlertViewModel.successAddTitle = "Success"
		successAlertViewModel.successAddMessage = "some message"
		
		return Group {
			AddNoteView(viewModel: viewModel)
				.previewDevice("iPhone 12")
			AddNoteView(viewModel: viewModel)
				.preferredColorScheme(.dark)
				.previewDevice("iPhone 12 Mini")
			AddNoteView(viewModel: viewModel)
				.previewDevice("iPhone 8")
				.preferredColorScheme(.dark)
			AddNoteView(viewModel: loadingViewModel)
				.previewDevice("iPhone 8")
				.preferredColorScheme(.dark)
			AddNoteView(viewModel: errorAlertViewModel)
				.previewDevice("iPhone 8")
				.preferredColorScheme(.dark)
			AddNoteView(viewModel: successAlertViewModel)
				.previewDevice("iPhone 8")
				.preferredColorScheme(.dark)
		}
		
	}
	
	static func uniqueNote() -> Note {
		return Note(id: UUID(), createdAt: Date(), updatedAt: Date(), name: "Buy SwiftUI Book", description: "some description")
	}
}

fileprivate final class NoteAdderPreviewStub: NoteAdder {
	
	private let result: Result<Note, Error>
	
	init(result: Result<Note, Error>) {
		self.result = result
	}
	
	func add(_ note: Note, completion: @escaping (NoteAdder.Result) -> Void) {
		switch result {
		case let .success(note):
			completion(.success(note))
		case .failure:
			completion(.failure(.notFound))
		}
	}
	
}
