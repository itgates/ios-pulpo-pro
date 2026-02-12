//
//  PlannedVisitsModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 10/02/2026.
//

import Foundation
struct PlannedVisitsModel : Codable {
    let Status : Int?
    let Status_Message : String?
    let Data : [PlannedVisitsData]?
}
struct PlannedVisitsData : Codable {
    let id : String?
    let div_id : String?
    let account_type : String?
    let item_id : String?
    let item_doc_id : String?
    let members : String?
    let vdate : String?
    let vtime : String?
    let shift : String?
    let comments : String?
    let insertion_date : String?
    let user_id : String?
    let team_id : String?
    let related_id : String?
    let approved : String?
    let approved_userid : String?
    let approved_date : String?
}
