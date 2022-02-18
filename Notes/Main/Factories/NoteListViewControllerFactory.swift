//
//  NoteListViewControllerFactory.swift
//  Notes
//
//  Created by Arifin Firdaus on 08/03/21.
//

import UIKit

final class NoteListViewControllerFactory {
    
    private init() { }
    
    static func makeNoteListViewController(
        loader: NoteLoader,
        adder: NoteAdder,
        deleter: NoteDeleter,
        onItemTapped: @escaping (_ item: Note) -> Void,
        onAddNoteButtonTapped: @escaping (_ viewController: UIViewController) -> Void
    ) -> (viewController: UIViewController, presenter: DefaultNoteListPresenter) {
        
        let makeViewController: () -> NoteListViewController = {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let identifier = "NoteListViewController"
            let viewController = storyboard.instantiateViewController(identifier: identifier) as! NoteListViewController
            return viewController
        }
        let noteListViewController = makeViewController()
        
        let noteListPresenter = DefaultNoteListPresenter(loader: loader, adder: adder, deleter: deleter)
        
        noteListViewController.presenter = noteListPresenter
        noteListViewController.onAddNoteButtonTapped = onAddNoteButtonTapped
        noteListPresenter.view = noteListViewController
        
        noteListViewController.onItemTapped = onItemTapped
        
        return (noteListViewController, noteListPresenter)
    }
    
}
