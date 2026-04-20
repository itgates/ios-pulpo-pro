
//
//  RealmStorageManager.swift
//  Puplo Pro
//
//  Created by Ahmed on 18/11/2025.
//

import Foundation
import RealmSwift
import CoreLocation
import UIKit

// MARK: - Realm Objects
class AppConfigRealm: Object {
    @Persisted(primaryKey: true) var id: String = "app_config"
    @Persisted var apiPath: String = ""
}

class UserLocationRealm: Object {
    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var latitude: Double = 0
    @Persisted var longitude: Double = 0
    @Persisted var timestamp: Date = Date()
}

class CacheObject: Object {
    @Persisted(primaryKey: true) var key: String = ""
    @Persisted var data: Data = Data()
}

// MARK: - Realm Storage Manager (FULL)
final class RealmStorageManager {

    // MARK: - Singleton
    static let shared = RealmStorageManager()
    private let realm = try! Realm()
    private init() {}

    // MARK: - Safe Write
    private func write(_ block: () -> Void) {
        try! realm.write { block() }
    }

    // MARK: - Generic Cache (replaces UserDefaults)
    private func setCodable<T: Codable>(_ object: T, forKey key: String) {
        do {
            let data = try JSONEncoder().encode(object)
            let cache = CacheObject()
            cache.key = key
            cache.data = data
            write { realm.add(cache, update: .modified) }
        } catch {
            print("❌ Encode error for key (\(key)):", error)
        }
    }

    private func getCodable<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let cache = realm.object(ofType: CacheObject.self, forPrimaryKey: key) else {
            return nil
        }
        do {
            return try JSONDecoder().decode(T.self, from: cache.data)
        } catch {
            print("❌ Decode error for key (\(key)):", error)
            return nil
        }
    }

    private func clear(_ key: String) {
        if let obj = realm.object(ofType: CacheObject.self, forPrimaryKey: key) {
            write { realm.delete(obj) }
        }
    }

    // MARK: - USER
    func saveUser(model: LoginModel, checkInDate: String, checkInTime: String, companyName: String) {
        let userData = model.Data?.first
        let user = UserLoginRealm()
        user.user_id = userData?.UserId ?? ""
        user.fullname = userData?.Username ?? ""
        user.mobile = userData?.Mobile ?? ""
        user.divIds = userData?.DivIds ?? ""
        user.lineIds = userData?.LineIds ?? ""
        user.check_in_date = checkInDate
        user.check_in_time = checkInTime
        user.company_name = companyName 
        user.isLoggedIn = true
        write { realm.add(user, update: .modified) }
        print("✔ User saved successfully")
    }

    @discardableResult
    func getLoggedUser() -> UserLoginRealm? {
        realm.objects(UserLoginRealm.self)
            .filter("isLoggedIn == true")
            .first
    }

    func clearUsers() {
        write { realm.delete(realm.objects(UserLoginRealm.self)) }
        print("✔ All users cleared")
    }

    func deleteUser(userId: String) {
        let users = realm.objects(UserLoginRealm.self).filter("id == %@", userId)
        write { realm.delete(users) }
        print("✔ User deleted successfully")
    }

    // MARK: - API PATH (replaces AppSettingsEntity CoreData)
    func saveAPIPath(_ path: String) {
        let config = AppConfigRealm()
        config.id = "app_config"
        config.apiPath = path
        write { realm.add(config, update: .modified) }
        print("✔ API path saved")
    }

    func getAPIPath() -> String? {
        realm.object(ofType: AppConfigRealm.self, forPrimaryKey: "app_config")?.apiPath
    }

    // MARK: - MASTER DATA
    func saveMasterData(_ model: MasterDataModel) {
        setCodable(model, forKey: "master_data_model")
        print("✔ Master data saved")
    }

    func getMasterData() -> MasterDataModel? {
        getCodable(MasterDataModel.self, forKey: "master_data_model")
    }

    func clearMasterData() {
        clear("master_data_model")
        print("✔ Master data cleared")
    }

    // MARK: - ACCOUNTS DOCTORS
    func saveAccountsDoctors(_ model: AccountsDoctorsModel) {
        setCodable(model, forKey: "accounts_doctors_model")
        print("✔ AccountsDoctors data saved")
    }

    func getAccountsDoctors() -> AccountsDoctorsModel? {
        getCodable(AccountsDoctorsModel.self, forKey: "accounts_doctors_model")
    }

    func clearAccountsDoctors() {
        clear("accounts_doctors_model")
        print("✔ AccountsDoctors data cleared")
    }

    // MARK: - ACCOUNTS DOCTORS AM
    func saveAccountsDoctorsAM(_ model: [PlanningVisitsData]) {
        setCodable(model, forKey: "accounts_doctors_am")
        print("✔ AccountsDoctors AM saved")
    }

    func getAccountsDoctorsAM() -> [PlanningVisitsData]? {
        getCodable([PlanningVisitsData].self, forKey: "accounts_doctors_am")
    }

    func clearAccountsDoctorsAM() {
        clear("accounts_doctors_am")
        print("✔ AccountsDoctors AM cleared")
    }

    // MARK: - ACCOUNTS DOCTORS PM
    func saveAccountsDoctorsPM(_ model: [PlanningVisitsData]) {
        setCodable(model, forKey: "accounts_doctors_pm")
        print("✔ AccountsDoctors PM saved")
    }

    func getAccountsDoctorsPM() -> [PlanningVisitsData]? {
        getCodable([PlanningVisitsData].self, forKey: "accounts_doctors_pm")
    }

    func clearAccountsDoctorsPM() {
        clear("accounts_doctors_pm")
        print("✔ AccountsDoctors PM cleared")
    }

    // MARK: - ACCOUNTS DOCTORS OTHER
    func saveAccountsDoctorsOther(_ model: [PlanningVisitsData]) {
        setCodable(model, forKey: "accounts_doctors_other")
        print("✔ AccountsDoctors Other saved")
    }

    func getAccountsDoctorsOther() -> [PlanningVisitsData]? {
        getCodable([PlanningVisitsData].self, forKey: "accounts_doctors_other")
    }

    func clearAccountsDoctorsOther() {
        clear("accounts_doctors_other")
        print("✔ AccountsDoctors Other cleared")
    }

    // MARK: - NEW PLAN
    func saveNewPlanData(_ model: [SaveNewPlanModel]) {
        setCodable(model, forKey: "new_plan_model")
        print("✔ NewPlan saved")
    }

    func getNewPlanData() -> [SaveNewPlanModel]? {
        getCodable([SaveNewPlanModel].self, forKey: "new_plan_model")
    }

    func clearNewPlanData() {
        clear("new_plan_model")
        print("✔ NewPlan cleared")
    }

    // MARK: - APP PRESENTATIONS
    func saveAppPresentationsModel(_ model: AppPresentationsModel) {
        setCodable(model, forKey: "app_Presentations_model")
        print("✔ App Presentations data saved")
    }

    func getAppPresentationsModel() -> AppPresentationsModel? {
        getCodable(AppPresentationsModel.self, forKey: "app_Presentations_model")
    }

    func clearAppPresentationsModel() {
        clear("app_Presentations_model")
        print("✔ App Presentations data cleared")
    }

    // MARK: - OW ACTIVITIES (append)
    func saveOWActivitiesModel(_ model: [OWSModel]) {
        var oldData = getOWActivitiesData() ?? []
        oldData.append(contentsOf: model)
        setCodable(oldData, forKey: "oWActivitiesKey")
        print("✔ OW Activities data appended & saved successfully")
    }

    func getOWActivitiesData() -> [OWSModel]? {
        getCodable([OWSModel].self, forKey: "oWActivitiesKey")
    }

    func clearOWActivitiesModel() {
        clear("oWActivitiesKey")
        print("✔ OW Activities data cleared")
    }

    // MARK: - OFFICE WORK (append)
    func saveOfficeWorkModel(_ model: [OWSModel]) {
        var oldData = getOfficeWorkData() ?? []
        oldData.append(contentsOf: model)
        setCodable(oldData, forKey: "officeWorkKey")
        print("✔ Office Work data appended & saved successfully")
    }

    func getOfficeWorkData() -> [OWSModel]? {
        getCodable([OWSModel].self, forKey: "officeWorkKey")
    }

    func clearOfficeWorkModel() {
        clear("officeWorkKey")
        print("✔ Office Work data cleared")
    }

    // MARK: - OFFLINE PLANS (append)
    func saveOfflinePlans(_ model: [SavePlanData]) {
        var oldData = getOfflinePlans() ?? []
        oldData.append(contentsOf: model)
        setCodable(oldData, forKey: "offline_plans_model")
        print("✔ Offline Plans data appended & saved successfully")
    }

    func getOfflinePlans() -> [SavePlanData]? {
        getCodable([SavePlanData].self, forKey: "offline_plans_model")
    }

    func clearOfflinePlans() {
        clear("offline_plans_model")
        print("✔ Offline Plans data cleared")
    }

    // MARK: - VISIT ITEMS
    func saveVisitItemData(_ model: [VisitItem]) {
        setCodable(model, forKey: "visitItem_data_key")
        print("✔ VisitItemData saved")
    }

    func getVisitItemData() -> [VisitItem]? {
        getCodable([VisitItem].self, forKey: "visitItem_data_key")
    }

    func clearVisitItemData() {
        clear("visitItem_data_key")
        print("✔ VisitItemData cleared")
    }

    // MARK: - MANAGER DATA
    func saveManagerData(_ model: [IdNameModel]) {
        setCodable(model, forKey: "manager_data_key")
        print("✔ App ManagerData Model saved successfully")
    }

    func getManagerData() -> [IdNameModel]? {
        getCodable([IdNameModel].self, forKey: "manager_data_key")
    }

    func clearManagerData() {
        clear("manager_data_key")
        print("✔ ManagerData cleared")
    }

    // MARK: - GIFTS DATA
    func saveGiftsData(_ model: [IdNameModel]) {
        setCodable(model, forKey: "gifts_data_key")
        print("✔ App giftsData Model saved successfully")
    }

    func getGiftsData() -> [IdNameModel]? {
        getCodable([IdNameModel].self, forKey: "gifts_data_key")
    }

    func clearGiftsData() {
        clear("gifts_data_key")
        print("✔ giftsData cleared")
    }

    // MARK: - PRODUCTS DATA
    func saveProductsData(_ model: [ProductItem]) {
        setCodable(model, forKey: "products_data_key")
        print("✔ App productsData Model saved successfully")
    }

    func getProductsData() -> [ProductItem]? {
        getCodable([ProductItem].self, forKey: "products_data_key")
    }

    func clearProductsData() {
        clear("products_data_key")
        print("✔ productsData cleared")
    }

    // MARK: - SELECTED IMAGE VISIT
    func saveSelectedImageVisitData(_ model: [SelectedImage]) {
        setCodable(model, forKey: "selectedImageVisit_data_key")
        print("✔ App SelectedImageVisit Model saved successfully")
    }

    func getSelectedImageVisitData() -> [SelectedImage]? {
        getCodable([SelectedImage].self, forKey: "selectedImageVisit_data_key")
    }

    func clearSelectedImageVisitData() {
        clear("selectedImageVisit_data_key")
        print("✔ SelectedImageVisit cleared")
    }

    // MARK: - ACTUAL VISIT
    func saveActualVisitData(_ model: [ActualVisitModel]) {
        setCodable(model, forKey: "actual_visit_model")
        print("✔ App actualVisit Model saved successfully")
    }

    func getActualVisitData() -> [ActualVisitModel]? {
        getCodable([ActualVisitModel].self, forKey: "actual_visit_model")
    }

    func clearActualVisitData() {
        clear("actual_visit_model")
        print("✔ actualVisit cleared")
    }

    // MARK: - PLANNED VISITS
    func savePlannedVisitsData(_ model: [PlannedVisitsData]) {
        setCodable(model, forKey: "planned_visits_model")
        print("✔ App Planned Visits Model saved successfully")
    }

    func getPlannedVisitsData() -> [PlannedVisitsData]? {
        getCodable([PlannedVisitsData].self, forKey: "planned_visits_model")
    }

    func clearPlannedVisitsData() {
        clear("planned_visits_model")
        print("✔ Planned Visits cleared")
    }

    // MARK: - VISIT START LOCATION
    func saveVisitStartLocation(lat: Double, lng: Double) {
        let loc = UserLocationRealm()
        loc.id = "visit_start_location"
        loc.latitude = lat
        loc.longitude = lng
        loc.timestamp = Date()
        write { realm.add(loc, update: .modified) }
        print("✔ Visit start location saved")
    }

    func getVisitStartLocation() -> CLLocation? {
        guard let loc = realm.object(ofType: UserLocationRealm.self, forPrimaryKey: "visit_start_location")
        else { return nil }
        return CLLocation(latitude: loc.latitude, longitude: loc.longitude)
    }

    func clearVisitStartLocation() {
        if let obj = realm.object(ofType: UserLocationRealm.self, forPrimaryKey: "visit_start_location") {
            write { realm.delete(obj) }
        }
        print("✔ Visit start location cleared")
    }

    // MARK: - VISIT END LOCATION
    func saveVisitEndLocation(lat: Double, lng: Double) {
        let loc = UserLocationRealm()
        loc.id = "visit_end_location"
        loc.latitude = lat
        loc.longitude = lng
        loc.timestamp = Date()
        write { realm.add(loc, update: .modified) }
        print("✔ Visit end location saved")
    }

    func getVisitEndLocation() -> CLLocation? {
        guard let loc = realm.object(ofType: UserLocationRealm.self, forPrimaryKey: "visit_end_location")
        else { return nil }
        return CLLocation(latitude: loc.latitude, longitude: loc.longitude)
    }

    func clearVisitEndLocation() {
        if let obj = realm.object(ofType: UserLocationRealm.self, forPrimaryKey: "visit_end_location") {
            write { realm.delete(obj) }
        }
        print("✔ Visit end location cleared")
    }

    // MARK: - USER LOCATION
    func saveUserLocation(_ location: CLLocation) {
        let loc = UserLocationRealm()
        loc.id = "last_location"
        loc.latitude = location.coordinate.latitude
        loc.longitude = location.coordinate.longitude
        loc.timestamp = Date()
        write { realm.add(loc, update: .modified) }
        print("✔ User location saved")
    }

    func getUserLocation() -> CLLocation? {
        guard let loc = realm.object(ofType: UserLocationRealm.self, forPrimaryKey: "last_location")
        else { return nil }
        return CLLocation(latitude: loc.latitude, longitude: loc.longitude)
    }

    // MARK: - UNPLANNED VISIT FLAG
    func setUnPlannedVisitOffline(_ value: Bool) {
        setCodable(value, forKey: "applay_unplanned_visit_offline")
        print("✔ UnPlannedVisitOffline flag set to \(value)")
    }

    func isUnPlannedVisitOffline() -> Bool {
        getCodable(Bool.self, forKey: "applay_unplanned_visit_offline") ?? false
    }

    func clearUnPlannedVisitOffline() {
        clear("applay_unplanned_visit_offline")
        print("✔ UnPlannedVisitOffline flag cleared")
    }
}
