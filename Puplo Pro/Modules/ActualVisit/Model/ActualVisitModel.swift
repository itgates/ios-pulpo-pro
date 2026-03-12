//
//  ActualVisitModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 16/02/2026.
//
import Foundation

struct ActualVisitModel: Codable {
    let id: String                 // UUID local
    var accountID: String? = nil
    var palnID: String? = "0"
    var doctorID: String? = nil
    var accountTypeID: String? = nil
    var divisionID: String? = nil
    var brickID: String? = nil
    var lineId: String? = nil
    var comment: String? = nil
    var visitTypeId: String? = nil
    var ampm: String? = "1"
    var shiftTypeId: String? = "2"
    var shiftId: String? = nil
    var offline_id: String? = nil
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
    let productId: String
    let name: String
    let count: String
    let comment: String
//    let stock: String
//    let payment: String
//    let order: String
    let feedback_id: String?
    let follow_ups: String?
    let market_feedback: String?
    var presentations: [Presentations]?
}

struct GiftVisitModel: Codable {
    let giftId: String?
    let name: String?
    var count: Int? = 1
}

struct ManagerVisitModel: Codable {
    let empId: String
    let name: String
}

struct ImageVisitModel: Codable {
    let path: String
}
