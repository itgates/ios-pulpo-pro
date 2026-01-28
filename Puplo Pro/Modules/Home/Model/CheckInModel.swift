//
//  CheckInModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 19/11/2025.
//

import Foundation
struct CheckInModel : Codable {
    let success : Bool?
    let message : String?
    let data : [CheckInData]?
    let total_processed : Int?

    enum CodingKeys: String, CodingKey {

        case success = "success"
        case message = "message"
        case data = "data"
        case total_processed = "total_processed"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = try values.decodeIfPresent(Bool.self, forKey: .success)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        data = try values.decodeIfPresent([CheckInData].self, forKey: .data)
        total_processed = try values.decodeIfPresent(Int.self, forKey: .total_processed)
    }

}
struct CheckInData : Codable {
    let online_id : Int?
    let offline_id : Int?
    let action : String?
    let status : String?
    let checkin_date : String?
    let checkout_date : String?
    let sync_date : String?
    let sync_time : String?
    let sync_timestamp : String?

    enum CodingKeys: String, CodingKey {

        case online_id = "online_id"
        case offline_id = "offline_id"
        case action = "action"
        case status = "status"
        case checkin_date = "checkin_date"
        case checkout_date = "checkout_date"
        case sync_date = "sync_date"
        case sync_time = "sync_time"
        case sync_timestamp = "sync_timestamp"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        online_id = try values.decodeIfPresent(Int.self, forKey: .online_id)
        offline_id = try values.decodeIfPresent(Int.self, forKey: .offline_id)
        action = try values.decodeIfPresent(String.self, forKey: .action)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        checkin_date = try values.decodeIfPresent(String.self, forKey: .checkin_date)
        checkout_date = try values.decodeIfPresent(String.self, forKey: .checkout_date)
        sync_date = try values.decodeIfPresent(String.self, forKey: .sync_date)
        sync_time = try values.decodeIfPresent(String.self, forKey: .sync_time)
        sync_timestamp = try values.decodeIfPresent(String.self, forKey: .sync_timestamp)
    }

}
struct CheckInOutSend: Codable {
    var check_in_date: String
    var check_in_time: String
    var ll_check_in: String
    var lg_check_in: String
    var offline_id: Int
    var online_id: String
    var check_out_date: String
    var check_out_time: String
    var ll_check_out: String
    var lg_check_out: String
}
