//
//  DateDisplayViewModel.swift
//  Notes
//
//  Created by Arifin Firdaus on 10/11/21.
//

import Foundation

final class DateDisplayViewModel {
    func displayDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        return dateFormatter.string(from: date)
    }
}
