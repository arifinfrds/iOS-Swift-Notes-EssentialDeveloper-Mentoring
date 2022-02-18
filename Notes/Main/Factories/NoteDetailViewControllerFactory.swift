//
//  NoteDetailViewControllerFactory.swift
//  Notes
//
//  Created by Arifin Firdaus on 18/02/22.
//

import SwiftUI

final class NoteDetailViewControllerFactory {
    
    static func createNoteDetail(
        item: Note,
        onEditButtonTapped: @escaping () -> Void
    ) -> (viewController: UIViewController, viewModel: NoteDetailViewModel) {
        let store = CoreDataNoteStore(.persistent)
        let loader = LocalNoteLoader(store: store)
        let dateDisplayViewModel = DateDisplayViewModel()
        
        let noteDetailViewModel = NoteDetailViewModel(
            noteLoader: loader,
            noteId: item.id,
            dateDisplayViewModel: dateDisplayViewModel
        )
        var noteDetailView = NoteDetailView(viewModel: noteDetailViewModel)
        
        noteDetailView.onEditButtonTapped = onEditButtonTapped
        
        store.updateDelegate = NotesStoreToAnyPresentationUpdateAdapter(
            presentations: [noteDetailViewModel]
        )
        let noteDetailViewController = UIHostingController(rootView: noteDetailView)
        
        return (noteDetailViewController, noteDetailViewModel)
    }
}
