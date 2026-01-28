//
//  SavePlansModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 27/11/2025.
//

import Foundation

struct SavePlanResponse: Codable {
    let message: String
    let data: [ResponseData]?
    
    enum CodingKeys: String, CodingKey {
        case message
        case data = "Data"
    }
}

struct ResponseData: Codable {
    let visitID: Int?
    let offlineID: Int?
    let syncDate: String?
    let syncTime: String?
    
    enum CodingKeys: String, CodingKey {
        case visitID = "visit_id"
        case offlineID = "offline_id"
        case syncDate = "sync_date"
        case syncTime = "sync_time"
    }
}
struct SavePlanData: Codable {
    let acccount : String?
    let doctor : String?
    let shift : AccountShift?
    let llAcccount : String?
    let lgAcccount : String?
    let account_dr_id : Int?
    let account_id : Int?
    let account_type_id : Int?
    let div_id: Int?
    let insertion_date: String?
    let line_id: Int?
    let offline_id: Int?
    let visit_date: String?
    let visit_time: String?
}
struct SaveNewPlanModel: Codable {

    // MARK: - Identifiers
    let id: String
    var onlineID: String
    var offlineID: Int?

    // MARK: - Account
    var accountID: Int?
    var accountDoctorID: Int?
    var accountTypeID: Int?
    var divID: Int?
    var lineID: Int?

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

enum AccountShift: Int, Codable {
    case am = 17
    case pm = 1
    case other = 0

    var title: String {
        switch self {
        case .am: return "AM Account"
        case .pm: return "PM Account"
        case .other: return "Other Account"
        }
    }
}
