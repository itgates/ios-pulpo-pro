//
//  UserEntity+CoreDataGemstone.swift
//  Puplo Pro
//
//  Created by Ahmed on 18/11/2025.
//

import Foundation
import CoreData

@objc(UserEntity)
public class UserEntity: NSManagedObject {

}
extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }
//    @NSManaged public var access_token: String?
//    @NSManaged public var api_path: String?
//    @NSManaged public var email: String?
    @NSManaged public var fullname: String?
    @NSManaged public var password: String?
    @NSManaged public var mobile: String?
    @NSManaged public var user_id: String?
    @NSManaged public var divIds: String?
    @NSManaged public var lineIds: String?
    @NSManaged public var check_in_date: String?
    @NSManaged public var check_in_time: String?
    @NSManaged public var check_in: String?
    @NSManaged public var offline_id: String?
    @NSManaged public var online_id: String?
    @NSManaged public var company_name: String?
}

