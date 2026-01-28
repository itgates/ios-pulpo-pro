//
//  AppPresentationsModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 02/12/2025.
//

import Foundation
struct AppPresentationsModel : Codable {
    let status : Int?
    let data : AppPresentationsData?
}
struct AppPresentationsData : Codable {
    let presentations : [Presentations]?
    let slides : [Slides]?
}
struct Presentations : Codable {
    let name : String?
    let product_id : Int?
    let presentation_id : Int?
    var ratings: [RatingPresentations]?
    var slides: [Slides]?
}
struct RatingPresentations : Codable {
    let rating : Int?
    let slide_id : Int?
}
struct Slides : Codable {
  
    let slide_path : String?
    let slide_type : String?
    let thumbnail_path : String?
    let thumbnail_id : Int?
    let presentation_id : Int?
    // pass
    var start_time : String?
    var end_time : String?
    let rating : Int?
    let slide_id : Int?
}
                                  
