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
struct ResponseData : Codable {
    let planned_id : String?
    let offline_id : Int?
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
    var onlineID: String
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
