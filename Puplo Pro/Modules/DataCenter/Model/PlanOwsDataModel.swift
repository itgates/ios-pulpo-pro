//
//  PlanOwsDataModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 02/12/2025.
//

import Foundation
struct PlanOwsDataModel : Codable {
    let status : Int?
    let data : [PlanOwsData]?
}
struct PlanOwsData : Codable {
    let id : Int?
    let ow_type_id : Int?
    let shift_id : Int?
    let date : String?
    let time : String?
}
