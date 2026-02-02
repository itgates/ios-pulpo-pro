//
//  LoginModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 17/11/2025.
//

import Foundation
//struct LoginModel : Codable {
//    let code: Int?
//    let user : User?
//    let userDetails : UserDetails?
//    let access_token : String?
//
//    enum CodingKeys: String, CodingKey {
//        
//        case code = "code"
//        case user = "user"
//        case userDetails = "userDetails"
//        case access_token = "access_token"
//    }
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        code = try values.decodeIfPresent(Int.self, forKey: .code)
//        user = try values.decodeIfPresent(User.self, forKey: .user)
//        userDetails = try values.decodeIfPresent(UserDetails.self, forKey: .userDetails)
//        access_token = try values.decodeIfPresent(String.self, forKey: .access_token)
//    }
//}
//struct User : Codable {
//    let id : Int?
//    let fullname : String?
//    let menuroles: String?
//    let email : String?
//    let url : String?
//    enum CodingKeys: String, CodingKey {
//
//        case id = "id"
//        case fullname = "fullname"
//        case menuroles = "menuroles"
//        case email = "email"
//        case url = "url"
//    }
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        id = try values.decodeIfPresent(Int.self, forKey: .id)
//        fullname = try values.decodeIfPresent(String.self, forKey: .fullname)
//        menuroles = try values.decodeIfPresent(String.self, forKey: .menuroles)
//        email = try values.decodeIfPresent(String.self, forKey: .email)
//        url = try values.decodeIfPresent(String.self, forKey: .url)
//    }
//
//}
//struct UserDetails : Codable {
//    let user_id : Int?
//    let mobile : String?
//
//    enum CodingKeys: String, CodingKey {
//
//        case user_id = "user_id"
//        case mobile = "mobile"
//    }
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        user_id = try values.decodeIfPresent(Int.self, forKey: .user_id)
//        mobile = try values.decodeIfPresent(String.self, forKey: .mobile)
//    }
//
//}

struct LoginModel : Codable {
    let status : Int?
    let status_Message : String?
    let data : [LoginData]?

    enum CodingKeys: String, CodingKey {

        case status = "Status"
        case status_Message = "Status_Message"
        case data = "Data"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        status_Message = try values.decodeIfPresent(String.self, forKey: .status_Message)
        data = try values.decodeIfPresent([LoginData].self, forKey: .data)
    }

}
struct LoginData : Codable {
    let userId : String?
    let code : String?
    let name : String?
    let nameAr : String?
    let nameEn : String?
    let mobile : String?
    let username : String?
    let password : String?
    let pic : String?
    let picCrm : String?
    let active : String?
    let typeId : String?
    let divisionName : String?
    let hireDate : String?
    let productId : String?
    let isManager : String?
    let lineIds : String?
    let divIds : String?
    let positionId : String?
    let defaultLineId : String?
    let levelId : String?
    let defaultLineName : String?
    let kOLList : String?

    enum CodingKeys: String, CodingKey {

        case userId = "UserId"
        case code = "Code"
        case name = "Name"
        case nameAr = "NameAr"
        case nameEn = "NameEn"
        case mobile = "Mobile"
        case username = "Username"
        case password = "Password"
        case pic = "Pic"
        case picCrm = "PicCrm"
        case active = "Active"
        case typeId = "TypeId"
        case divisionName = "DivisionName"
        case hireDate = "HireDate"
        case productId = "ProductId"
        case isManager = "IsManager"
        case lineIds = "LineIds"
        case divIds = "DivIds"
        case positionId = "PositionId"
        case defaultLineId = "DefaultLineId"
        case levelId = "LevelId"
        case defaultLineName = "DefaultLineName"
        case kOLList = "KOLList"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        userId = try values.decodeIfPresent(String.self, forKey: .userId)
        code = try values.decodeIfPresent(String.self, forKey: .code)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        nameAr = try values.decodeIfPresent(String.self, forKey: .nameAr)
        nameEn = try values.decodeIfPresent(String.self, forKey: .nameEn)
        mobile = try values.decodeIfPresent(String.self, forKey: .mobile)
        username = try values.decodeIfPresent(String.self, forKey: .username)
        password = try values.decodeIfPresent(String.self, forKey: .password)
        pic = try values.decodeIfPresent(String.self, forKey: .pic)
        picCrm = try values.decodeIfPresent(String.self, forKey: .picCrm)
        active = try values.decodeIfPresent(String.self, forKey: .active)
        typeId = try values.decodeIfPresent(String.self, forKey: .typeId)
        divisionName = try values.decodeIfPresent(String.self, forKey: .divisionName)
        hireDate = try values.decodeIfPresent(String.self, forKey: .hireDate)
        productId = try values.decodeIfPresent(String.self, forKey: .productId)
        isManager = try values.decodeIfPresent(String.self, forKey: .isManager)
        lineIds = try values.decodeIfPresent(String.self, forKey: .lineIds)
        divIds = try values.decodeIfPresent(String.self, forKey: .divIds)
        positionId = try values.decodeIfPresent(String.self, forKey: .positionId)
        defaultLineId = try values.decodeIfPresent(String.self, forKey: .defaultLineId)
        levelId = try values.decodeIfPresent(String.self, forKey: .levelId)
        defaultLineName = try values.decodeIfPresent(String.self, forKey: .defaultLineName)
        kOLList = try values.decodeIfPresent(String.self, forKey: .kOLList)
    }

}
