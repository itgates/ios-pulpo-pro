//
//  SavePlansModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 27/11/2025.
//

import Foundation
struct SavePlanResponse : Codable {
    let Status : Int?
    let Status_Message : String?
    let Data : [ResponseData]?
}
struct ResponseData: Codable {
    let planned_id: Int?
    let visit_id: Int?
    let offline_id: Int?

    enum CodingKeys: String, CodingKey {
        case planned_id
        case visit_id
        case offline_id
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // planned_id
        if let intValue = try? container.decode(Int.self, forKey: .planned_id) {
            planned_id = intValue
        } else if let stringValue = try? container.decode(String.self, forKey: .planned_id),
                  let intValue = Int(stringValue) {
            planned_id = intValue
        } else {
            planned_id = nil
        }

        // visit_id
        if let intValue = try? container.decode(Int.self, forKey: .visit_id) {
            visit_id = intValue
        } else if let stringValue = try? container.decode(String.self, forKey: .visit_id),
                  let intValue = Int(stringValue) {
            visit_id = intValue
        } else {
            visit_id = nil
        }

        // offline_id
        if let intValue = try? container.decode(Int.self, forKey: .offline_id) {
            offline_id = intValue
        } else if let stringValue = try? container.decode(String.self, forKey: .offline_id),
                  let intValue = Int(stringValue) {
            offline_id = intValue
        } else {
            offline_id = nil
        }
    }
}
struct SavePlanData: Codable {
    let acccount : String?
    let doctor : String?
    let shift : AccountShift?
    let llAcccount : String?
    let lgAcccount : String?
    let account_dr_id : String?
    let account_id : String?
    let account_type_id : String?
    let div_id: String?
    let insertion_date: String?
    let line_id: String?
    let offline_id: Int?
    let visit_date: String?
    let visit_time: String?
}
struct SaveNewPlanModel: Codable {

    // MARK: - Identifiers
    let id: String
    var onlineID: Int
    var offlineID: Int?

    // MARK: - Account
    var accountID: String?
    var accountDoctorID: String?
    var accountTypeID: String?
    var divID: String?
    var lineID: String?

    // MARK: - Meta
    var insertionDate: String?
    var visitDate: String?
    var visitTime: String?

    // MARK: - Display
    var accountName: String?
    var doctorName: String?
    var shift: AccountShift?

    // MARK: - Location
    var latitude: String?
    var longitude: String?

    // MARK: - State
    var isUploaded: Bool
}
