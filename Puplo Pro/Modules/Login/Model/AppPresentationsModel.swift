//
//  AppPresentationsModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 12/02/2026.
//

import Foundation
struct AppPresentationsModel : Codable {
    let Status : Int?
    let Status_Message : String?
    let Data : AppPresentationsData?
}
struct AppPresentationsData : Codable {
    let Presentations : [Presentations]?
    let Slides : [Slides]?
}
struct Presentations : Codable {
    let id : String?
    let name : String?
    let description : String?
    let insert_date : String?
    let insert_time : String?
    let active : String?
    let product_id : String?
    let brand_id : String?
    let team_id : String?
    let product : String?
    let structure : String?
}
struct Slides : Codable {
    let id : String?
    let title : String?
    let description : String?
    let contents : String?
    let presentation_id : String?
    let product_id : String?
    let brand_id : String?
    let slide_type : String?
    let file_path : String?
    let structure : String?
}
