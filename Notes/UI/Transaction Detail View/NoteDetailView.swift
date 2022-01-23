//
//  NoteDetailView.swift
//  Notes
//
//  Created by Arifin Firdaus on 05/11/21.
//

import SwiftUI

struct NoteDetailView: View {
    
    @ObservedObject var viewModel: NoteDetailViewModel
    
    var onEditButtonTapped: (() -> Void)?
    
    var body: some View {
        if viewModel.isLoading {
            ProgressView()
        } else {
            Form {
                Section {
                    NoteDetailItemCell(title: "Name", subtitle: $viewModel.noteName)
                }
                
                Section {
                    NoteDetailItemCell(title: "Description", subtitle: $viewModel.noteDescription)
                }
                
                Section {
                    HStack {
                        DatePicker(
                            "Date",
                            selection: $viewModel.noteCreatedDate,
                            displayedComponents: [.date]
                        )
                            .datePickerStyle(.automatic)
                            .disabled(true)
                    }
                }
            }
            .navigationBarTitle(Text(viewModel.title), displayMode: .inline)
            .onAppear {
                viewModel.onAppear()
            }
            .alert(isPresented: $viewModel.shouldShowErrorAlert) {
                Alert(
                    title: Text(viewModel.errorTitle),
                    message: Text(viewModel.errorMessage),
                    dismissButton: .default(Text("OK"), action: { viewModel.onDismissErrorAlert() })
                )
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") { onEditButtonTapped?() }
                }
            }
        }
    }
}

struct NoteDetailView_Previews: PreviewProvider {
    
    static let successStateViewModel = makeSuccessStateViewModel()
    static let notFoundStateViewModel = makeFailureStateViewModel(.notFound)
    static let unknownStateViewModel = makeFailureStateViewModel(.unknown)
    
    static var previews: some View {
        NavigationView {
            NoteDetailView(viewModel: successStateViewModel)
                .preferredColorScheme(.light)
        }
        NavigationView {
            NoteDetailView(viewModel: successStateViewModel)
                .preferredColorScheme(.dark)
        }
        
        NavigationView {
            NoteDetailView(viewModel: notFoundStateViewModel)
                .preferredColorScheme(.light)
        }
        NavigationView {
            NoteDetailView(viewModel: notFoundStateViewModel)
                .preferredColorScheme(.dark)
        }
        
        NavigationView {
            NoteDetailView(viewModel: unknownStateViewModel)
                .preferredColorScheme(.light)
        }
        NavigationView {
            NoteDetailView(viewModel: unknownStateViewModel)
                .preferredColorScheme(.dark)
        }
    }
}

extension NoteDetailView_Previews {
    
    static func makeSuccessStateViewModel() -> NoteDetailViewModel {
        let note = uniqueNote()
        
        let viewModel = NoteDetailViewModel(
            noteLoader: NoteLoaderPreviewStub(result: .success(note)),
            noteId: note.id,
            dateDisplayViewModel: DateDisplayViewModel()
        )
        
        return viewModel
    }
    
    static func makeFailureStateViewModel(_ error: NoteLoaderError) -> NoteDetailViewModel {
        let note = uniqueNote()
        
        let viewModel = NoteDetailViewModel(
            noteLoader: NoteLoaderPreviewStub(result: .failure(error)),
            noteId: note.id,
            dateDisplayViewModel: DateDisplayViewModel()
        )
        
        return viewModel
    }
    
    static func uniqueNote() -> Note {
        return Note(id: UUID(), createdAt: Date(), updatedAt: Date(), name: "Buy SwiftUI Book", description: "some description")
    }
    
    fileprivate final class NoteLoaderPreviewStub: NoteLoader {
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
}
