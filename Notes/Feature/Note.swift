//
//  Note.swift
//  Notes
//
//  Created by Arifin Firdaus on 22/02/21.
//

import Foundation

struct Note: Equatable {
    let id: UUID
    let createdAt: Date
    let updatedAt: Date
    let name: String
    let description: String?
}
