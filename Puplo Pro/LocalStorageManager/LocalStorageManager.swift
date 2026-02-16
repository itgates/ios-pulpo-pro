//
//  LocalStorageManager.swift
//  Puplo Pro
//
//  Created by Ahmed on 18/11/2025.
//
import Foundation
import UIKit
import CoreData
import CoreLocation

// MARK: - UserDefaults Keys
private enum UserDefaultsKeys {
    static let masterDataKey = "master_data_model"
    static let accountsDoctorsKey = "accounts_doctors_model"
    static let planVisitsKey = "plan_visits_model"
    static let appPresentationsKey = "app_Presentations_model"
    static let oWActivitiesKey = "oW_activities_model"
    static let visitStartLocation = "visit_start_location"
}

// MARK: - LocalStorageManager
final class LocalStorageManager {

    // MARK: Singleton
    static let shared = LocalStorageManager(
        persistentContainer: (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    )

    // MARK: - Core Data
    private let persistentContainer: NSPersistentContainer
    var context: NSManagedObjectContext { persistentContainer.viewContext }

    private init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    // MARK: - Logger
    @inline(__always)
    private func log(_ message: String) {
        print(message)
    }

    // MARK: - UserDefaults (Codable Helpers)
    private func saveCodable<T: Codable>(_ object: T, key: String) {
        do {
            let data = try JSONEncoder().encode(object)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            log("❌ Failed to save codable for key (\(key)): \(error)")
        }
    }

    private func loadCodable<T: Codable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            log("❌ Failed to decode codable for key (\(key)): \(error)")
            return nil
        }
    }

    private func removeValue(for key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }

    // MARK: - User (Core Data)
    func saveUser(
        model: LoginModel,
        checkInDate: String,
        checkInTime: String,
        companyName: String
    ) {
        let user = UserEntity(context: context)
        let userData = model.Data?.first

        user.user_id = userData?.UserId
        user.fullname = userData?.Username
        user.mobile = userData?.Mobile
        user.divIds = userData?.DivIds
        user.lineIds = userData?.LineIds
        user.check_in_date = checkInDate
        user.check_in_time = checkInTime
        user.offline_id = "11"
        user.company_name = companyName

        do {
            try context.save()
            log("✔ User saved successfully")
        } catch {
            log("❌ Failed to save user: \(error.localizedDescription)")
        }
    }

    @discardableResult
    func getLoggedUser() -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.fetchLimit = 1
        do {
            return try context.fetch(request).first
        } catch {
            log("❌ Failed to fetch logged user: \(error.localizedDescription)")
            return nil
        }
    }

    func clearUsers() {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        do {
            try context.fetch(request).forEach { context.delete($0) }
            try context.save()
            log("✔ All users cleared")
        } catch {
            log("❌ Failed to clear users: \(error.localizedDescription)")
        }
    }

    func deleteUser(userId: String) {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "user_id == %@", userId)
        do {
            try context.fetch(request).forEach { context.delete($0) }
            try context.save()
            log("✔ User deleted successfully")
        } catch {
            log("❌ Failed to delete user: \(error.localizedDescription)")
        }
    }

    // MARK: - API Path (Core Data)
    func saveAPIPath(_ path: String) {
        let request: NSFetchRequest<AppSettingsEntity> = AppSettingsEntity.fetchRequest()
        request.fetchLimit = 1

        do {
            let settings = try context.fetch(request).first ?? AppSettingsEntity(context: context)
            settings.api_path = path
            try context.save()
            log("✔ API path saved")
        } catch {
            log("❌ Failed to save API path: \(error.localizedDescription)")
        }
    }

    func getAPIPath() -> String? {
        let request: NSFetchRequest<AppSettingsEntity> = AppSettingsEntity.fetchRequest()
        request.fetchLimit = 1
        do {
            return try context.fetch(request).first?.api_path
        } catch {
            log("❌ Failed to fetch API path: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Master Data (UserDefaults)
    func saveMasterData(_ model: MasterDataModel) {
        saveCodable(model, key: UserDefaultsKeys.masterDataKey)
        log("✔ Master data saved")
    }

    func getMasterData() -> MasterDataModel? {
        loadCodable(MasterDataModel.self, key: UserDefaultsKeys.masterDataKey)
    }

    func clearMasterData() {
        removeValue(for: UserDefaultsKeys.masterDataKey)
        log("✔ Master data cleared")
    }
    
    // MARK: - Accounts Doctors (UserDefaults)
    func saveAccountsDoctors(_ model: AccountsDoctorsModel) {
        saveCodable(model, key: UserDefaultsKeys.accountsDoctorsKey)
        log("✔ AccountsDoctors data saved")
    }

    func getAccountsDoctors() -> AccountsDoctorsModel? {
        loadCodable(AccountsDoctorsModel.self, key: UserDefaultsKeys.accountsDoctorsKey)
    }

    func clearAccountsDoctors() {
        removeValue(for: UserDefaultsKeys.accountsDoctorsKey)
        log("✔ AccountsDoctors data cleared")
    }

    // MARK: - plan Visits (UserDefaults)
    func savePlanVisits(_ model: PlannedVisitsModel) {
        saveCodable(model, key: UserDefaultsKeys.planVisitsKey)
        log("✔ plan Visits data saved")
    }

    func getPlanVisits() -> PlannedVisitsModel? {
        loadCodable(PlannedVisitsModel.self, key: UserDefaultsKeys.planVisitsKey)
    }

    func clearPlanVisits() {
        removeValue(for: UserDefaultsKeys.planVisitsKey)
        log("✔ Plan Visits data cleared")
    }
    
    // MARK: - App PresentationsModel (UserDefaults)
    func saveAppPresentationsModel(_ model: AppPresentationsModel) {
        saveCodable(model, key: UserDefaultsKeys.appPresentationsKey)
        log("✔ App Presentations data saved")
    }

    func getAppPresentationsModel() -> AppPresentationsModel? {
        loadCodable(AppPresentationsModel.self, key: UserDefaultsKeys.appPresentationsKey)
    }

    func clearAppPresentationsModel() {
        removeValue(for: UserDefaultsKeys.appPresentationsKey)
        log("✔ App Presentations data cleared")
    }
    
    // MARK: - OW Activities (UserDefaults)
//    func saveOWActivitiesModel(_ model: [OWSModel]) {
//        saveCodable(model, key: UserDefaultsKeys.oWActivitiesKey)
//        log("✔ OW Activities data saved")
//    }
//
//    func getOWActivitiesData() -> [OWSModel]? {
//        loadCodable([OWSModel].self, key: UserDefaultsKeys.oWActivitiesKey)
//    }
//
//    func clearOWActivitiesModel() {
//        removeValue(for: UserDefaultsKeys.oWActivitiesKey)
//        log("✔ OW Activities data cleared")
//    }
//    
//
    // MARK: - OW Activities (UserDefaults)
    func saveOWActivitiesModel(_ model: [OWSModel]) {
        var oldData = getOWActivitiesData() ?? []
        oldData.append(contentsOf: model)
        saveCodable(oldData, key: UserDefaultsKeys.oWActivitiesKey)
        log("✔ OW Activities data appended & saved successfully")
    }

    func getOWActivitiesData() -> [OWSModel]? {
        loadCodable([OWSModel].self, key: UserDefaultsKeys.oWActivitiesKey)
    }

    func clearOWActivitiesModel() {
        removeValue(for: UserDefaultsKeys.oWActivitiesKey)
        log("✔ OW Activities data cleared")
    }
    // MARK: - Visit Start Location (UserDefaults)
    func saveVisitStartLocation(lat: Double, lng: Double) {
        let location = VisitStartLocation(
            latitude: lat,
            longitude: lng,
            timestamp: Date())

        saveCodable(location, key: UserDefaultsKeys.visitStartLocation)
        log("✔ Visit start location saved")
    }

    func getVisitStartLocation() -> CLLocation? {
        guard let loc = loadCodable(VisitStartLocation.self,
                                    key: UserDefaultsKeys.visitStartLocation) else {
            return nil
        }
        
        return CLLocation(latitude: loc.latitude, longitude: loc.longitude)
    }

    func clearVisitStartLocation() {
        removeValue(for: UserDefaultsKeys.visitStartLocation)
        log("✔ Visit start location cleared")
    }
}

