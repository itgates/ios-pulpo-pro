//
//  AccountsDoctorsModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 03/02/2026.
//
import Foundation

struct AccountsDoctorsModel: Codable {
    let Status: Int?
    let Status_Message: String?
    let Data: AccountsDoctorsData?
}
struct AccountsDoctorsData: Codable {
    let Accounts: [Accounts]?
    let Doctors: [Doctors]?
}
struct Accounts: Codable {
    let id: String?
    let t_team_id: String?
    let t_div_id: String?
    let t_class_id: String?
    let team_ll: String?
    let team_lg: String?
    let ref_id: String?
    let name: String?
    let brick_id: String?
    let address: String?
    let tel: String?
    let mobile: String?
    let tbl: String?
}
struct Doctors: Codable {
    let id: String?
    let doc_acc_id: String?
    let d_account_id: String?
    let d_active_from: String?
    let d_inactive_from: String?
    let team_id: String?
    let name: String?
    let specialization_id: String?
    let class_id: String?
    let active_from: String?
    let inactive_from: String?
    let aactive: String?
    let tbl: String?
//    let target: Int?
}
