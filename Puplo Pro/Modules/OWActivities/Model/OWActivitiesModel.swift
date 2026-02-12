//
//  OWActivitiesModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 12/02/2026.
//

import Foundation
import UIKit
struct OWActivitiesData {
    let name: String
    let id: Int
}
struct OWSModel : Codable {
    let date: String
    let id: Int
    let notes: String
    let offline_id: Int
    let ow_plan_id: Int
    let ow_type_id: Int
    let shift_id: Int
    let time: String
}
struct OWActivitiesResponse: Codable {
    let message: String?
    let Data: [OWActivitiesResponseData]?
}
struct OWActivitiesResponseData: Codable {
    let ow_id: Int?
    let offline_id: Int?
    let sync_date: String?
    let sync_time: String?
}
