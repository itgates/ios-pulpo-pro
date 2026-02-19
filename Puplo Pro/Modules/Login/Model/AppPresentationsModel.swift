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
    let presentation_id : String?
    var ratings: [RatingPresentations]?
    var slides: [Slides]?
}
struct Slides : Codable {
    let id : String?
    let title : String?
    let description : String?
    let contents : String?
    let presentation_id : String?
    let product_id : String?
    let brand_id : String?
    let slide_path : String?
    let slide_type : String?
    let file_path : String?
    let structure : String?
    
    var start_time : String?
    var end_time : String?
    let rating : Int?
    let slide_id : String?
}
struct RatingPresentations : Codable {
    let rating : String?
    let slide_id : String?
}
