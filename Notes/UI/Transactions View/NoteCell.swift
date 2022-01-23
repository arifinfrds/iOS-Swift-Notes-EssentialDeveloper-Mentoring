//
//  NoteCell.swift
//  Notes
//
//  Created by Arifin Firdaus on 25/02/21.
//

import UIKit

class NoteCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func configure(with note: Note, dateDisplayViewModel: DateDisplayViewModel) {
        titleLabel.text = note.name
        descriptionLabel.text = note.description
        dateLabel.text = dateDisplayViewModel.displayDate(from: note.createdAt)
    }
    
}
