//
//  NoteListViewControllerFactory.swift
//  Notes
//
//  Created by Arifin Firdaus on 08/03/21.
//

import UIKit
import SwiftUI

final class NoteListViewControllerFactory {
    
    private init() { }
    
    static func makeNoteListViewController() -> UIViewController {
        
        let makeViewController: () -> NoteListViewController = {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let identifier = "NoteListViewController"
            let viewController = storyboard.instantiateViewController(identifier: identifier) as! NoteListViewController
            return viewController
        }
        let noteListViewController = makeViewController()
        
        let store = CoreDataNoteStore(.persistent)
        let loader = LocalNoteLoader(store: store)
        let adder = LocalNoteAdder(store: store)
        let deleter = LocalNoteDeleter(store: store)
        let noteListPresenter = DefaultNoteListPresenter(loader: loader, adder: adder, deleter: deleter)
        
        noteListViewController.presenter = noteListPresenter
        noteListViewController.onAddNoteButtonTapped = self.presentAddNoteViewController(_:)
        noteListPresenter.view = noteListViewController
		
        noteListViewController.onItemTapped = { item in
            let store = CoreDataNoteStore(.persistent)
            let loader = LocalNoteLoader(store: store)
            let dateDisplayViewModel = DateDisplayViewModel()
            
            let noteDetailViewModel = NoteDetailViewModel(
                noteLoader: loader,
                noteId: item.id,
                dateDisplayViewModel: dateDisplayViewModel
            )
            var noteDetailView = NoteDetailView(viewModel: noteDetailViewModel)
            
			store.updateDelegate = NotesStoreToAnyPresentationUpdateAdapter(
				presentations: [noteListPresenter, noteDetailViewModel]
			)
            
            noteDetailView.onEditButtonTapped = {
                let updater: NoteUpdater = LocalNoteUpdater(store: store)
                let viewModel = EditNoteViewModel(
                    noteId: item.id,
                    noteLoader: loader,
                    noteUpdater: updater,
                    dateDisplayViewModel: dateDisplayViewModel
                )
                var editNoteView = EditNoteView(viewModel: viewModel)
                editNoteView.onCancelTapped = {
                    noteListViewController.dismiss(animated: true, completion: nil)
                }
                editNoteView.onUpdateSuccessAlertTapped = {
                    noteListViewController.dismiss(animated: true, completion: nil)
                }
                let editNoteViewController = UIHostingController(rootView: editNoteView)
                noteListViewController.present(editNoteViewController, animated: true, completion: nil)
            }
            
            let noteDetailViewController = UIHostingController(rootView: noteDetailView)
            noteListViewController.navigationController?.pushViewController(noteDetailViewController, animated: true)
        }
        
        return noteListViewController
    }
    
	private static func presentAddNoteViewController(_ noteListVC: NoteListViewController) -> Void {
		
		let addNoteVC = AddNoteViewControllerFactory.makeAddNoteViewController(noteListVC: noteListVC)
		noteListVC.present(addNoteVC, animated: true, completion: nil)
	}
    
}

final class AddNoteViewControllerFactory {
    
    private init() { }
	
	static func makeAddNoteViewController(noteListVC: NoteListViewController) -> UIHostingController<AddNoteView> {
		
		let store = CoreDataNoteStore(.persistent)
		
		let viewModel = AddNoteViewModel(
			noteAdder: LocalNoteAdder(store: store),
			dateDisplayViewModel: DateDisplayViewModel()
		)
		
		var view = AddNoteView(viewModel: viewModel)
		
		view.onCancelTapped = {
			noteListVC.dismiss(animated: true, completion: nil)
		}
		
		view.onUpdateSuccessAlertTapped = {
			noteListVC.presenter.onReload()
			noteListVC.dismiss(animated: true, completion: nil)
		}
		let viewController = UIHostingController<AddNoteView>(rootView: view)
		
		return viewController
	}
}

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
