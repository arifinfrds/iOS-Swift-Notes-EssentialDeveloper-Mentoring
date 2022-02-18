//
//  NoteFlow.swift
//  Notes
//
//  Created by Arifin Firdaus on 18/02/22.
//

import UIKit
import SwiftUI

final class NoteFlow {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    private var store: CoreDataNoteStore {
        return CoreDataNoteStore(.persistent)
    }
    
    private var loader: NoteLoader {
        return LocalNoteLoader(store: store)
    }
    
    private var updater: NoteUpdater {
        return LocalNoteUpdater(store: store)
    }
    
    private var adder: NoteAdder {
        return LocalNoteAdder(store: store)
    }
    
    private var deleter: NoteDeleter {
        return LocalNoteDeleter(store: store)
    }
    
    private let dateDisplayViewModel = DateDisplayViewModel()
    
    private var presentationUpdateables = [PresentationUpdateable]()
    
    func start() {
        let (noteListViewController, noteListPresenter) = NoteListViewControllerFactory.makeNoteListViewController(
            loader: loader,
            adder: adder,
            deleter: deleter,
            onItemTapped: presentNoteDetailUI(item:),
            onAddNoteButtonTapped: presentAddNoteUI(fromCurrentViewController:)
        )
        
        presentationUpdateables.append(noteListPresenter)
        store.updateDelegate = NotesStoreToAnyPresentationUpdateAdapter(presentations: presentationUpdateables)
        
        navigationController.setViewControllers([noteListViewController], animated: false)
    }
    
    private func presentNoteDetailUI(item: Note) {
        let (noteDetailViewController, noteDetailViewModel) = NoteDetailViewControllerFactory.createNoteDetail(
            item: item,
            onEditButtonTapped: { self.presentEditNoteUI(item: item) }
        )
        
        self.presentationUpdateables.append(noteDetailViewModel)
        
        self.navigationController.pushViewController(noteDetailViewController, animated: true)
    }
    
    
    private func presentEditNoteUI(item: Note) {
        let (editNoteViewController) = EditNoteViewControllerFactory.createEditNote(
            item: item,
            loader: self.loader,
            updater: self.updater,
            dateDisplayViewModel: self.dateDisplayViewModel,
            onCancelTapped: {
                self.navigationController.visibleViewController?.dismiss(animated: true, completion: nil)
            },
            onUpdateSuccessAlertTapped: {
                self.navigationController.visibleViewController?.dismiss(animated: true, completion: nil)
            }
        )
        
        guard let detailViewController = navigationController.visibleViewController as? UIHostingController<NoteDetailView> else {
            return
        }
        detailViewController.present(editNoteViewController, animated: true, completion: nil)
    }
    
    private func presentAddNoteUI(fromCurrentViewController viewController: UIViewController) {
        guard let noteListVC = viewController as? NoteListViewController else {
            return
        }
        let addNoteVC = AddNoteViewControllerFactory.makeAddNoteViewController(
            adder: adder,
            onCancelTapped: {
                noteListVC.dismiss(animated: true, completion: nil)
            },
            onUpdateSuccessAlertTapped: {
                noteListVC.presenter.onReload()
                noteListVC.dismiss(animated: true, completion: nil)
            }
        )
        noteListVC.present(addNoteVC, animated: true, completion: nil)
    }
}
