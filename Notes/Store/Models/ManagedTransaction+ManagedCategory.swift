//
//  ManagedTransaction+ManagedCategory.swift
//  Tabunganku
//
//  Created by Arifin Firdaus on 24/02/21.
//

import Foundation

extension ManagedTransaction {
    var category: ManagedCategory {
        get {
            return ManagedCategory(rawValue: self.categoryValue) ?? .education
        }
        set {
            self.categoryValue = newValue.rawValue
        }
    }
}
