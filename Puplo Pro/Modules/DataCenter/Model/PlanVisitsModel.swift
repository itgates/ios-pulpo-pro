//
//  PlanVisitsModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 02/12/2025.
//

import Foundation
struct PlanVisitsModel : Codable {
    let status : Int?
    let data : [PlanVisitsData]?
}
struct PlanVisitsData : Codable {
    let id : Int?
    let line_id : Int?
    let division_id : Int?
    let brick_id : String?
    let account_id : Int?
    let account : String?
    let type_id : Int?
    let account_type : String?
    let doctor_id : Int?
    let doctor : String?
    let doc_class : String?
    let speciality_id : Int?
    let ll : String?
    let lg : String?
    let shift_id : Int?
    let acc_class : String?
    let type : String?
    let visit_type_id : Int?
    let date : String?
    let time : String?
}
