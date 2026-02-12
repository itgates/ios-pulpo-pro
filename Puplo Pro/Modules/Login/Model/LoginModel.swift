//
//  LoginModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 17/11/2025.
//

import Foundation
struct LoginModel: Codable {
    let Status: Int?
    let Status_Message: String?
    let Data: [LoginData]?
}
struct LoginData: Codable {
    let UserId: String?
    let Code: String?
    let Name: String?
    let NameAr: String?
    let NameEn: String?
    let Mobile: String?
    let Username: String?
    let Password: String?
    let Pic: String?
    let PicCrm: String?
    let Active: String?
    let TypeId: String?
    let DivisionName: String?
    let HireDate: String?
    let ProductId: String?
    let IsManager: String?
    let LineIds: String?
    let DivIds: String?
    let PositionId: String?
    let DefaultLineId: String?
    let LevelId: String?
    let DefaultLineName: String?
    let KOLList: String?
}
