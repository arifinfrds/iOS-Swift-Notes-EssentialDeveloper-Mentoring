//
//  NoteDetailItemCell.swift
//  Notes
//
//  Created by Arifin Firdaus on 05/11/21.
//

import SwiftUI

struct NoteDetailItemCell: View {
    
    var title: String
    var subtitle: Binding<String>
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(subtitle.wrappedValue)
                .foregroundColor(.secondary)
        }
    }
}

struct NoteDetailItemCell_Previews: PreviewProvider {
    
    @State private static var _subtitle: String = "subtitle"
    
    static let subtitle = Binding<String>(
        get: { Self._subtitle },
        set: { _ in }
    )
    
    static var previews: some View {
        NoteDetailItemCell(title: "Title", subtitle: Self.subtitle)
    }

}
