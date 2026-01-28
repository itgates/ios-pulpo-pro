//
//  AppSettingsEntity.swift
//  Puplo Pro
//
//  Created by Ahmed on 19/11/2025.
//

import Foundation
import CoreData

@objc(AppSettingsEntity)
public class AppSettingsEntity: NSManagedObject {

}
extension AppSettingsEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AppSettingsEntity> {
        return NSFetchRequest<AppSettingsEntity>(entityName: "AppSettingsEntity")
    }
    @NSManaged public var api_path: String?
    
}
