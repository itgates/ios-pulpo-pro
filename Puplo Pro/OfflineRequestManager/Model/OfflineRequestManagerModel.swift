//
//  OfflineRequestManagerModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 23/02/2026.
//

import Foundation
struct PlannedVisitResponse : Codable {
    let Status : Int?
    let Status_Message : String?
    let Data : [PlannedVisitData]?
}
struct PlannedVisitData: Codable {
    let visit_id: String?
    let offline_id: String?
}
