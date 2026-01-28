//
//  AccountsDoctorsModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 25/11/2025.
//

import Foundation
struct AccountsDoctorsModel : Codable {
    let status : Int?
    let data : AccountsDoctorsData?
}
struct AccountsDoctorsData : Codable {
    let accoutns : [Accoutns]?
    let doctors : [Doctors]?
}
struct Accoutns : Codable {
    let id : Int?
    let name : String?
    let line_id : Int?
    let div_id : Int?
    let brick_id : String?
    let class_id : Int?
    let code : String?
    let type_id : Int?
    let address : String?
    let tel : String?
    let mobile : String?
    let email : String?
    let ll : String?
    let lg : String?
}

struct Doctors : Codable {
    let id : Int?
    let name : String?
    let line_id : Int?
    let account_id : Int?
    let type_id : Int?
    let active_date : String?
    let inactive_date : String?
    let speciality_id : Int?
    let class_id : Int?
    let email : String?
    let tel : String?
    let mobile : String?
    let gender : String?
}

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
