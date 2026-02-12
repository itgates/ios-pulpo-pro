//
//  PinModel.swift
//  Gemstone Pro
//
//  Created by Ahmed on 17/11/2025.
//

import Foundation
struct PinModel: Codable {
    let status: Int?
    let statusMessage: String?
    let data: [PinData]?
    
    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case statusMessage = "Status_Message"
        case data = "Data"
    }
}
struct PinData: Codable {
    let id: String?
    let pin: String?
    let name: String?
    let system: String?
    let apiPath: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case pin = "pin"
        case name = "name"
        case system = "system"
        case apiPath = "api_path"
    }
}
