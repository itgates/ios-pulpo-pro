//
//  ActualVisitModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 16/02/2026.
//
import Foundation

struct ActualVisitModel: Codable {
    let id: String                 // UUID local
    var accountID: Int? = nil
    var palnID: Int? = nil
    var doctorID: Int? = nil
    var accountTypeID: Int? = nil
    var divisionID: Int? = nil
    var brickID: Int? = nil
    var lineId: Int? = nil
    var comment: String? = nil
    var visitTypeId: Int? = nil
    var shiftTypeId: Int? = 1
    var shiftId: Int? = nil
    var offline_id: Int? = nil             // مهم جدًا
    var online_id: String? = nil

    var division_name: String? = nil
    var account_type: String? = nil
    var account_name: String? = nil
    var brick_name: String? = nil
    var doctor_name: String? = nil
    var shift_type: String? = nil
    var visit_type: String? = nil

    var visit_date: String? = nil
    var llAcccount: String
    var lgAcccount: String
    var endLat: String? = nil
    var endLong: String? = nil

    var isUploaded: Bool

    var productVisit: [ProductVisitModel]? = []
    var giftVisit: [GiftVisitModel]? = []
    var managerVisit: [ManagerVisitModel]? = []
    var imageVisit: [ImageVisitModel]? = []
}
struct ProductVisitModel: Codable {
    let productId: Int
    let name: String
    let count: String
    let comment: String
    let stock: String
    let payment: String
    let order: String
    let followup_id: Int?
    let market_feedback_id: Int?
    let vFeedback_id: Int?
    var presentations: [Presentations]?
}

struct GiftVisitModel: Codable {
    let giftId: Int?
    let name: String?
    var count: Int? = 1
}

struct ManagerVisitModel: Codable {
    let empId: Int
    let name: String
}

struct ImageVisitModel: Codable {
    let path: String
}
