//
//  RealmLoginModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 19/04/2026.
//

import Foundation
import RealmSwift

class UserLoginRealm: Object {
    @Persisted(primaryKey: true) var user_id: String
    @Persisted var fullname: String = ""
    @Persisted var menuroles: String = ""
    @Persisted var email: String = ""
    @Persisted var url: String = ""
    @Persisted var is_manager: String = ""
    @Persisted var check_in_date: String = ""
    @Persisted var check_in_time: String = ""
    @Persisted var company_name: String = ""
    @Persisted var access_token: String = ""
    @Persisted var check_in: String = ""
    @Persisted var online_id: String = ""
    @Persisted var mobile: String = ""
    @Persisted var divIds: String = ""
    @Persisted var lineIds: String = ""
    @Persisted var isLoggedIn: Bool = false
}
