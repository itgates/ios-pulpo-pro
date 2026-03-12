//
//  MasterDataModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 03/02/2026.
//

import Foundation

struct MasterDataModel: Codable {
    let Status: Int?
    let Status_Message: String?
    let Data: MasterData?
}
struct MasterData: Codable {
    let account_types: [Account_types]?
    let lines: [IdNameModel]?
    let specialties: [IdNameModel]?
    let divisions: [Divisions]?
    let giveaways: [IdNameModel]?
    let office_work_types: [IdNameModel]?
    let products: [IdNameModel]?
    let bricks: [Bricks]?
    let managers: [IdNameModel]?
    let classes: [IdNameModel]?
    let settings: [Settings]?
    let forms: [String]?
    let actions: [String]?
    let comments: [IdNameModel]?
    let vacation_types: [IdNameModel]?
}
struct Account_types: Codable {
    let id: String?
    let name: String?
    let tbl: String?
    let shortcut: String?
    let sorting: String?
    let cat_id: String?
    let accepted_distance: String?
    let created_at: String?
    let sheet_id: String?
}
struct Bricks: Codable {
    let id: String?
    let name: String?
    let notes: String?
    let team_id: String?
    let ter_id: String?
}
struct Divisions: Codable {
    let id: String?
    let team_id: String?
    let name: String?
    let notes: String?
    let parent_id: String?
    let type_id: String?
    let date_from: String?
    let date_to: String?
    let contribution_rate: String?
    let hidden: String?
    let sorting: String?
    let shared: String?
    let related_id: String?
    let is_kol: String?
    let sheet_id: String?
    let created_at: String?
}
struct IdNameModel: Codable {
    let id: String?
    var name: String?
    var tbl: String? = ""
    var cat_id: String? = ""
    var unplanned_limit: String? = ""
    var line_id: String? = ""
    var line_division_id: String? = ""
    var shift_id: String? = ""
    var count: String? = ""
    var ll: String? = ""
    var lg: String? = ""
    var ter_id: String? = ""
}
struct Settings: Codable {
    let id: String?
    let attribute_name: String?
    let attribute_value: String?
}
extension IdNameModel {
    var isValid: Bool {
        let hasID = (id ?? "").trimmingCharacters(in: .whitespacesAndNewlines) != ""
        let hasName = (name ?? "").trimmingCharacters(in: .whitespacesAndNewlines) != ""
        return hasID && hasName
    }
}
