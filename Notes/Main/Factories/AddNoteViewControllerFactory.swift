//
//  AddNoteViewControllerFactory.swift
//  Notes
//
//  Created by Arifin Firdaus on 18/02/22.
//

import SwiftUI

final class AddNoteViewControllerFactory {
    
    private init() { }
    
    static func makeAddNoteViewController(
        adder: NoteAdder,
        onCancelTapped: @escaping () -> Void,
        onUpdateSuccessAlertTapped: @escaping () -> Void
    ) -> UIHostingController<AddNoteView> {
        
        let viewModel = AddNoteViewModel(
            noteAdder: adder,
            dateDisplayViewModel: DateDisplayViewModel()
        )
        
        var view = AddNoteView(viewModel: viewModel)
        
        view.onCancelTapped = onCancelTapped
        view.onUpdateSuccessAlertTapped = onUpdateSuccessAlertTapped
        
        let viewController = UIHostingController<AddNoteView>(rootView: view)
        
        return viewController
    }
}
