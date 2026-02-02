//
//  AccountsDoctorsModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 25/11/2025.
//

import Foundation
struct AccountsDoctorsModel : Codable {
    let status : Int?
    let status_Message : String?
    let data : AccountsDoctorsData?
}
struct AccountsDoctorsData : Codable {
    let accoutns : [Accounts]?
    let doctors : [Doctors]?
}
struct Accounts : Codable {
    let id : String?
    let t_team_id : String?
    let t_div_id : String?
    let t_class_id : String?
    let team_ll : String?
    let team_lg : String?
    let ref_id : String?
    let name : String?
    let brick_id : String?
    let address : String?
    let tel : String?
    let mobile : String?
    let tbl : String?
}
struct Doctors : Codable {
    let id : String?
    let doc_acc_id : String?
    let d_account_id : String?
    let d_active_from : String?
    let d_inactive_from : String?
    let team_id : String?
    let name : String?
    let specialization_id : String?
    let class_id : String?
    let active_from : String?
    let inactive_from : String?
    let aactive : String?
    let tbl : String?
    let target : Int?
}
//struct Accoutns : Codable {
//    let id : Int?
//    let name : String?
//    let line_id : Int?
//    let div_id : Int?
//    let brick_id : String?
//    let class_id : Int?
//    let code : String?
//    let type_id : Int?
//    let address : String?
//    let tel : String?
//    let mobile : String?
//    let email : String?
//    let ll : String?
//    let lg : String?
//}
//
//struct Doctors : Codable {
//    let id : Int?
//    let name : String?
//    let line_id : Int?
//    let account_id : Int?
//    let type_id : Int?
//    let active_date : String?
//    let inactive_date : String?
//    let speciality_id : Int?
//    let class_id : Int?
//    let email : String?
//    let tel : String?
//    let mobile : String?
//    let gender : String?
//}

struct PlanningVisitsData : Codable {
    let id : Int?
    let account_id: Int?
    let name : String
    let hosptal : String
    var shift: AccountShift? = .other
    let div_id : Int?
    let brick_id : String?
    let class_id : Int?
    let type_id : Int?
    let line_id : Int?
    let lat : String?
    let lng : String?
}
