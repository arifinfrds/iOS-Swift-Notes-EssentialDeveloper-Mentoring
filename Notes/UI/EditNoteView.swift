//
//  EditNoteView.swift
//  Notes
//
//  Created by Arifin Firdaus on 26/11/21.
//

import SwiftUI

struct EditNoteView: View {
    
    @ObservedObject var viewModel: EditNoteViewModel
    
    var onCancelTapped: (() -> Void)?
    var onUpdateSuccessAlertTapped: (() -> Void)?
    
    var body: some View {
        NavigationView {
            EditNoteContentView(viewModel: viewModel)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel", action: { onCancelTapped?() })
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save", action: { viewModel.onSave() })
                    }
                }
                .navigationBarTitle(Text(viewModel.title), displayMode: .large)
                .alert(isPresented: $viewModel.shouldShowSuccessUpdateAlert) {
                    Alert(
                        title: Text(viewModel.successUpdateTitle),
                        message: Text(viewModel.successUpdateMessage),
                        dismissButton: .default(
                            Text("OK"),
                            action: {
                                viewModel.onDismissSuccessUpdateAlert()
                                onUpdateSuccessAlertTapped?()
                            }
                        )
                    )
                }
                .onAppear { viewModel.onAppear() }
        }
    }
}

private struct EditNoteContentView: View {
    
    @ObservedObject var viewModel: EditNoteViewModel
    
    var body: some View {
        if viewModel.isLoading {
            ProgressView()
        } else {
            Form {
                Section(header: Text("General")) {
                    TextField("Nama", text: $viewModel.noteName)
                }
                
                Section(header: Text("Description")) {
                    TextEditor(text: $viewModel.noteDescription)
                }
                
                Section {
                    HStack {
                        DatePicker(
                            "Tanggal",
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
							action: { viewModel.onDismissLoadNoteErrorAlert() }
						)
					)
				}
			}
        }
    }
}

struct EditNoteView_Previews: PreviewProvider {
    static var previews: some View {
        
        let viewModel = EditNoteViewModel(
            noteId: UUID(),
            noteLoader: NoteloaderPreviewStub(result: .success(uniqueNote())),
            noteUpdater: NoteUpdaterPreviewStub(),
            dateDisplayViewModel: DateDisplayViewModel()
        )
        
        let loadingViewModel = EditNoteViewModel(
            noteId: UUID(),
            noteLoader: NoteloaderPreviewStub(result: .success(uniqueNote())),
            noteUpdater: NoteUpdaterPreviewStub(),
            dateDisplayViewModel: DateDisplayViewModel()
        )
        loadingViewModel.isLoading = true
		
		let errorAlertViewModel = EditNoteViewModel(
			noteId: UUID(),
			noteLoader: NoteloaderPreviewStub(result: .success(uniqueNote())),
			noteUpdater: NoteUpdaterPreviewStub(),
			dateDisplayViewModel: DateDisplayViewModel()
		)
		errorAlertViewModel.shouldShowErrorAlert = true
		errorAlertViewModel.errorTitle = "Error"
		errorAlertViewModel.errorMessage = "Some error message"
		
		let successAlertViewModel = EditNoteViewModel(
			noteId: UUID(),
			noteLoader: NoteloaderPreviewStub(result: .success(uniqueNote())),
			noteUpdater: NoteUpdaterPreviewStub(),
			dateDisplayViewModel: DateDisplayViewModel()
		)
		successAlertViewModel.shouldShowSuccessUpdateAlert = true
		successAlertViewModel.successUpdateTitle = "Success"
		successAlertViewModel.successUpdateMessage = "Some message"
        
        return Group {
            EditNoteView(viewModel: viewModel)
                .previewDevice("iPhone 12")
            EditNoteView(viewModel: viewModel)
                .preferredColorScheme(.dark)
                .previewDevice("iPhone 12 Mini")
            EditNoteView(viewModel: viewModel)
                .previewDevice("iPhone 8")
                .preferredColorScheme(.dark)
            EditNoteView(viewModel: loadingViewModel)
                .previewDevice("iPhone 8")
                .preferredColorScheme(.dark)
			EditNoteView(viewModel: errorAlertViewModel)
				.previewDevice("iPhone 8")
				.preferredColorScheme(.dark)
			EditNoteView(viewModel: successAlertViewModel)
				.previewDevice("iPhone 8")
				.preferredColorScheme(.dark)
        }
        
    }
    
    static func uniqueNote() -> Note {
        return Note(id: UUID(), createdAt: Date(), updatedAt: Date(), name: "Buy SwiftUI Book", description: "some description")
    }
}

fileprivate final class NoteloaderPreviewStub: NoteLoader {
    private let result: Result<Note, Error>
    
    init(result: Result<Note, Error>) {
        self.result = result
    }
    
    func load(completion: @escaping (LoadNotesResult) -> Void) {
        
    }
    
    func load(noteId: UUID, completion: @escaping (LoadNoteResult) -> Void) {
        switch result {
        case let .success(note):
            completion(.success(note))
        case .failure:
            completion(.failure(.notFound))
        }
    }
}

fileprivate final class NoteUpdaterPreviewStub: NoteUpdater {
    
    func update(id: UUID, with note: Note, completion: @escaping (NoteUpdater.Result) -> Void) {
        
    }
}




