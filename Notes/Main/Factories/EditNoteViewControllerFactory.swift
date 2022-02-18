//
//  EditNoteViewControllerFactory.swift
//  Notes
//
//  Created by Arifin Firdaus on 18/02/22.
//

import SwiftUI

final class EditNoteViewControllerFactory {
    
    static func createEditNote(
        item: Note,
        loader: NoteLoader,
        updater: NoteUpdater,
        dateDisplayViewModel: DateDisplayViewModel,
        onCancelTapped: @escaping () -> Void,
        onUpdateSuccessAlertTapped: @escaping () -> Void
    ) -> UIHostingController<EditNoteView> {
        
        let viewModel = EditNoteViewModel(
            noteId: item.id,
            noteLoader: loader,
            noteUpdater: updater,
            dateDisplayViewModel: dateDisplayViewModel
        )
        var editNoteView = EditNoteView(viewModel: viewModel)
        editNoteView.onCancelTapped = onCancelTapped
        editNoteView.onUpdateSuccessAlertTapped = onUpdateSuccessAlertTapped
        
        let editNoteViewController = UIHostingController(rootView: editNoteView)
        
        return editNoteViewController
    }
}
