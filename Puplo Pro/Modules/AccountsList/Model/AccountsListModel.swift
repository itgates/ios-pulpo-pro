//
//  AccountsListModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 07/01/2026.
//

import Foundation

// MARK: - Enums & Models
 enum SelectionFilterType {
    case division
    case brick
    case accountType
    case classes
}
// MARK: - Enums & Filter
struct SelectFilter {
    var division: Lines?
    var brick: Lines?
    var accountType: Lines?
    var classType: Lines?
}
