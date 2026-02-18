//
//  PlanningVisitsModel.swift
//  Gemstone Pro
//
//  Created by Ahmed on 30/11/2025.
//

import Foundation
struct PlanningVisitsData : Codable {
    let id : String?
    let account_id: String?
    let name : String
    let hosptal : String
    var shift: AccountShift? = .other
    let div_id : String?
    let brick_id : String?
    let class_id : String?
    let account_type : String?
    let type_id : String?
    let line_id : String?
    let lat : String?
    let lng : String?
}
enum AccountShift: Int, Codable {
    case am = 2
    case pm = 1
    case other = 4

    var title: String {
        switch self {
        case .am: return "AM Account"
        case .pm: return "PM Account"
        case .other: return "Other Account"
        }
    }
}

