//
//  OWActivitiesModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 12/02/2026.
//

import Foundation
import UIKit
struct OWSModel : Codable {
    let date: String
    let id: Int
    let notes: String
    let offline_id: Int
    let ow_plan_id: String
    let ow_type_id: String
    let shift_id: String?
    let time: String
}
struct OWActivitiesResponse : Codable {
    let Status : Int?
    let Status_Message : String?
    let Data : [OWActivitiesResponseData]?
}
struct OWActivitiesResponseData: Codable {
    
    let visit_id: Int?
    let offline_id: String?
    let is_synced: Int?
    let sync_date: String?
    let sync_time: String?
    
    enum CodingKeys: String, CodingKey {
        case visit_id
        case offline_id
        case is_synced
        case sync_date
        case sync_time
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let intValue = try? container.decode(Int.self, forKey: .visit_id) {
            visit_id = intValue
        } else if let stringValue = try? container.decode(String.self, forKey: .visit_id),
                  let intFromString = Int(stringValue) {
            visit_id = intFromString
        } else {
            visit_id = nil
        }
        
        offline_id = try? container.decode(String.self, forKey: .offline_id)
        is_synced = try? container.decode(Int.self, forKey: .is_synced)
        sync_date = try? container.decode(String.self, forKey: .sync_date)
        sync_time = try? container.decode(String.self, forKey: .sync_time)
    }
}

import Foundation
struct PlanOwsDataModel : Codable {
    let status : Int?
    let data : [PlanOwsData]?
}
struct PlanOwsData : Codable {
    let id : String?
    let ow_type_id : String?
    let shift_id : String?
    let date : String?
    let time : String?
}
