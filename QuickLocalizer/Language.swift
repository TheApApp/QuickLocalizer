//
//  Language.swift
//  QuickLocalizer
//
//  Created by Michael Rowe1 on 1/4/25.
//

import Foundation

struct Language: Hashable, Identifiable {
    var id: String
    var name: String
    var isSelected: Bool
}
