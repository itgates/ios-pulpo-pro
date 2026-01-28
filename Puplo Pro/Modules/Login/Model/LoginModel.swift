//
//  LoginModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 17/11/2025.
//

import Foundation
struct LoginModel : Codable {
    let code: Int?
    let user : User?
    let userDetails : UserDetails?
    let access_token : String?

    enum CodingKeys: String, CodingKey {
        
        case code = "code"
        case user = "user"
        case userDetails = "userDetails"
        case access_token = "access_token"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decodeIfPresent(Int.self, forKey: .code)
        user = try values.decodeIfPresent(User.self, forKey: .user)
        userDetails = try values.decodeIfPresent(UserDetails.self, forKey: .userDetails)
        access_token = try values.decodeIfPresent(String.self, forKey: .access_token)
    }
}
struct User : Codable {
    let id : Int?
    let fullname : String?
    let menuroles: String?
    let email : String?
    let url : String?
    enum CodingKeys: String, CodingKey {

        case id = "id"
        case fullname = "fullname"
        case menuroles = "menuroles"
        case email = "email"
        case url = "url"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        fullname = try values.decodeIfPresent(String.self, forKey: .fullname)
        menuroles = try values.decodeIfPresent(String.self, forKey: .menuroles)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        url = try values.decodeIfPresent(String.self, forKey: .url)
    }

}
struct UserDetails : Codable {
    let user_id : Int?
    let mobile : String?

    enum CodingKeys: String, CodingKey {

        case user_id = "user_id"
        case mobile = "mobile"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        user_id = try values.decodeIfPresent(Int.self, forKey: .user_id)
        mobile = try values.decodeIfPresent(String.self, forKey: .mobile)
    }

}
