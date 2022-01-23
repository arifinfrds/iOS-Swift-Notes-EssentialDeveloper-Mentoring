//
//  NoteListViewController.swift
//  Notes
//
//  Created by Arifin Firdaus on 21/02/21.
//

import UIKit
import SwiftUI

final class NoteListViewController: UIViewController {
    
    var presenter: NoteListPresenter!
    var onAddNoteButtonTapped: ((_ currentViewController: NoteListViewController) -> Void)?
    var onItemTapped: ((_ item: Note) -> Void)?
    
    @IBOutlet weak var deleteAllBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalBalanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.onLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        let nib = UINib(nibName: "NoteCell", bundle: .main)
        tableView.register(nib, forCellReuseIdentifier: "NoteCell")
    }
    
    @IBAction func didTapAddButton(_ sender: UIBarButtonItem) {
        self.onAddNoteButtonTapped?(self)
    }
    
    @IBAction func didTapDeleteAllButton(_ sender: UIBarButtonItem) {
        presenter.onDeleteAllTapped()
    }
    
}

// MARK: - NoteListView

extension NoteListViewController: NoteListView {
    
    func display(_ notes: [Note]) { }
    
    func display(_ message: String) {
        showAlert(message)
    }
    
    func displayDeleteAllAlert(_ message: String) {
        let alertController = UIAlertController(title: "Perhatian", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in  self?.presenter.onConfirmDeleteAllNotes() }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func reloadView() {
        tableView.reloadData()
    }
    
    func reloadView(at row: Int) {
        
        let indexPath = IndexPath(row: row, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func removeView(at row: Int) {
        
        let indexPath = IndexPath(row: row, section: 0)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    private func showAlert(_ message: String) {
        
        let alertController = UIAlertController(title: "Sukses", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func displayHeaderText(_ balance: String) {
        
        totalBalanceLabel.text = balance
    }
    
    func setDeleteAllButtonEnabled(_ isEnabled: Bool) {
        deleteAllBarButtonItem.isEnabled = isEnabled
    }
    
}


// MARK: - UITableViewDataSource

extension NoteListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! NoteCell
        let note = presenter.notes[indexPath.row]
        cell.configure(with: note, dateDisplayViewModel: DateDisplayViewModel())
        return cell
    }
    
}


// MARK: - UITableViewDelegate

extension NoteListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let selectedNote = presenter.notes[indexPath.row]
            presenter.onDelete(selectedNote, at: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedNote = presenter.notes[indexPath.row]
        onItemTapped?(selectedNote)
    }
    
}

