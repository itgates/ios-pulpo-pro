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

// MARK: - Lightweight Codable Models
struct UserLocation: Codable { let latitude: Double; let longitude: Double; let timestamp: Date }
struct OfflinePlan: Codable { let plans: [SavePlanData] }

// MARK: - Keys Namespace
private enum Keys {
    static let offlineCheckActions = "offline_check_actions"
    static let lastLocation        = "last_user_location"
    static let masterData          = "master_data_model"
    static let accountsDoctors     = "accounts_doctors_model"
    static let accountsDoctorsAM   = "accounts_doctors_AM_model"
    static let accountsDoctorsPM   = "accounts_doctors_PM_model"
    static let accountsDoctorsOther = "accounts_doctors_Other_model"
    static let offlinePlansKey     = "offline_plans_model"
    static let planVisitsKey       = "plan_Visits_model"
    static let newPlanKey       = "new_plan_model"
    static let planOwsDataKey      = "plan_ows_model"
    static let appPresentationsModelKey = "app_presentations_model"
    static let oWActivitiesKey     = "oWActivities_model"
    static let giftsDataKey = "gifts_data_key"
    static let managerDataKey = "manager_data_key"
    static let visitItemKey = "visitItem_data_key"
    static let productsDataKey = "products_data_key"
    static let selectedImageVisitDataKey = "selectedImageVisit_data_key"
    static let applayUnPlannedVisitOffline = "applay_unplanned_visit_offline"
    static let visitStartLocation = "visit_start_location"
    static let actualVisitKey = "actual_visit_model"
    static let companyNameKey = "company_name_key"
}

// MARK: - LocalStorageManager
final class LocalStorageManager {

    // Singleton remains for compatibility
    static let shared = LocalStorageManager(persistentContainer: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)

    // MARK: Core Data
    private let persistentContainer: NSPersistentContainer
    var context: NSManagedObjectContext { persistentContainer.viewContext }

    private init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    // MARK: - Logging Helper
    @inline(__always) private func log(_ message: String) { print(message) }

    // MARK: - UserDefaults Generic Helpers
    private func setCodable<T: Codable>(_ object: T, forKey key: String) {
        do {
            let data = try JSONEncoder().encode(object)
            UserDefaults.standard.set(data, forKey: key)
            UserDefaults.standard.synchronize() // <- هذا يضمن الحفظ فورًا
        } catch {
            print("Error saving codable:", error)
        }
    }

    private func getCodable<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        do { return try JSONDecoder().decode(T.self, from: data) }
        catch { log("❌ Decode error for key (\(key)): \(error.localizedDescription)"); return nil }
    }

    private func clear(_ key: String) { UserDefaults.standard.removeObject(forKey: key) }

    // MARK: - User (Core Data)
    func saveUser(model: LoginModel, check_in_date: String, check_in_time: String,companyName: String) {
        let userEntity = UserEntity(context: context)
        userEntity.user_id = "\(model.data?.first?.userId ?? "")"
//        userEntity.access_token = "\(model.data?.first?.userId ?? "")"
//        userEntity.email = model.data?.first?.name
        userEntity.fullname = model.data?.first?.username
        userEntity.mobile = model.data?.first?.mobile
        userEntity.divIds = model.data?.first?.divIds
        userEntity.lineIds = model.data?.first?.lineIds
        userEntity.check_in_date = check_in_date
        userEntity.check_in_time = check_in_time
        userEntity.offline_id = "11"
        userEntity.company_name = companyName
        do { try context.save(); log("✔ User saved successfully") }
        catch { log("❌ Core Data Save Error: \(error.localizedDescription)") }
    }

    @discardableResult
    func getLoggedUser() -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.fetchLimit = 1
        do { return try context.fetch(request).first }
        catch { log("Fetching Data Error: \(error.localizedDescription)"); return nil }
    }

    func clearUsers() {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        do {
            try context.fetch(fetchRequest).forEach { context.delete($0) }
            try context.save()
        } catch { log("❌ Failed to clear users: \(error)") }
    }

    func deleteUser(byUserID id: String) {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "user_id == %@", id)
        do {
            try context.fetch(fetchRequest).forEach { context.delete($0) }
            try context.save(); log("✔ User(s) deleted successfully")
        } catch { log("❌ Failed to delete user(s): \(error)") }
    }

    // MARK: - User fields updates
    func saveOnlineID(_ onlineID: String) {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest(); request.fetchLimit = 1
        do { if let user = try context.fetch(request).first { user.online_id = onlineID; try context.save(); log("✔ Online ID updated successfully") } }
        catch { log("❌ Failed to update online id: \(error.localizedDescription)") }
    }

    func getOnlineID() -> String? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest(); request.fetchLimit = 1
        do { return try context.fetch(request).first?.online_id }
        catch { log("❌ Failed to Fetch Online ID: \(error.localizedDescription)"); return nil }
    }

    func saveCheckIn(_ check_in: String) {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest(); request.fetchLimit = 1
        do { if let user = try context.fetch(request).first { user.check_in = check_in; try context.save(); log("✔ Check-in updated successfully") } }
        catch { log("❌ Failed to update check-in: \(error.localizedDescription)") }
    }

    func getCheckIn() -> String? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest(); request.fetchLimit = 1
        do { return try context.fetch(request).first?.check_in }
        catch { log("❌ Failed to Fetch Check-in: \(error.localizedDescription)"); return nil }
    }

    // MARK: - API Path (Core Data AppSettingsEntity)
    func saveAPIPath(_ apiPath: String) {
        let request: NSFetchRequest<AppSettingsEntity> = AppSettingsEntity.fetchRequest(); request.fetchLimit = 1
        do {
            let settings = try context.fetch(request).first ?? AppSettingsEntity(context: context)
            settings.api_path = apiPath
            try context.save(); log("✔ API Path Saved Safely in AppSettingsEntity")
        } catch { log("❌ Failed to Save API Path: \(error.localizedDescription)") }
    }

    func getAPIPath() -> String? {
        let request: NSFetchRequest<AppSettingsEntity> = AppSettingsEntity.fetchRequest(); request.fetchLimit = 1
        do { return try context.fetch(request).first?.api_path }
        catch { log("❌ Failed to Fetch API Path: \(error.localizedDescription)"); return nil }
    }

    // MARK: - Offline Check Actions (UserDefaults)
    func saveOfflineCheckAction(_ body: [CheckInOutSend]) {
        var old = getOfflineCheckActions()
        old.append(body)
        setCodable(old, forKey: Keys.offlineCheckActions)
    }

    func getOfflineCheckActions() -> [[CheckInOutSend]] {
        getCodable([[CheckInOutSend]].self, forKey: Keys.offlineCheckActions) ?? []
    }

    func clearOfflineCheckActions() { clear(Keys.offlineCheckActions) }

    // MARK: - User Location (UserDefaults)
    func saveUserLocation(_ location: CLLocation) {
        let loc = UserLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, timestamp: Date())
        setCodable(loc, forKey: Keys.lastLocation)
        log("✔ User location saved")
    }

    func getUserLocation() -> CLLocation? {
        guard let loc = getCodable(UserLocation.self, forKey: Keys.lastLocation) else { return nil }
        return CLLocation(latitude: loc.latitude, longitude: loc.longitude)
    }

    func clearUserLocation() { clear(Keys.lastLocation) }

    // MARK: - Master Data (UserDefaults)
    func saveMasterData(model: MasterDataModel) { setCodable(model, forKey: Keys.masterData); log("✔ MasterData saved successfully") }
    func getMasterData() -> MasterDataModel? { getCodable(MasterDataModel.self, forKey: Keys.masterData) }
    func clearMasterData() { clear(Keys.masterData) }

    // MARK: - Accounts Doctors (UserDefaults)
    func saveAccountsDoctors(model: AccountsDoctorsModel) { setCodable(model, forKey: Keys.accountsDoctors); log("✔ AccountsDoctors saved successfully") }
    func getAccountsDoctors() -> AccountsDoctorsModel? { getCodable(AccountsDoctorsModel.self, forKey: Keys.accountsDoctors) }
    func clearAccountsDoctors() { clear(Keys.accountsDoctors) }

    // MARK: - Accounts Doctors AM/PM/Other (UserDefaults)
    func saveAccountsDoctorsAM(model: [PlanningVisitsData]) { setCodable(model, forKey: Keys.accountsDoctorsAM); log("✔ AccountsDoctors AM saved successfully") }
    func getAccountsDoctorsAM() -> [PlanningVisitsData]? { getCodable([PlanningVisitsData].self, forKey: Keys.accountsDoctorsAM) }
    func clearAccountsDoctorsAM() { clear(Keys.accountsDoctorsAM) }

    func saveAccountsDoctorsPM(model: [PlanningVisitsData]) { setCodable(model, forKey: Keys.accountsDoctorsPM); log("✔ AccountsDoctors PM saved successfully") }
    func getAccountsDoctorsPM() -> [PlanningVisitsData]? { getCodable([PlanningVisitsData].self, forKey: Keys.accountsDoctorsPM) }
    func clearAccountsDoctorsPM() { clear(Keys.accountsDoctorsPM) }

    func saveAccountsDoctorsOther(model: [PlanningVisitsData]) { setCodable(model, forKey: Keys.accountsDoctorsOther); log("✔ AccountsDoctors Other saved successfully") }
    func getAccountsDoctorsOther() -> [PlanningVisitsData]? { getCodable([PlanningVisitsData].self, forKey: Keys.accountsDoctorsOther) }
    func clearAccountsDoctorsOther() { clear(Keys.accountsDoctorsOther) }

    // MARK: - Plans (UserDefaults)
    func saveOfflinePlans(model: [SavePlanData]) {
        var oldData = getOfflinePlans() ?? []
        oldData.append(contentsOf: model)
        setCodable(oldData, forKey: Keys.offlinePlansKey)
        log("✔ Plans Data appended & saved successfully")
    }

    func getOfflinePlans() -> [SavePlanData]? { getCodable([SavePlanData].self, forKey: Keys.offlinePlansKey) }
    func clearOfflinePlans() { clear(Keys.offlinePlansKey) }

    // MARK: - Plan Visits (UserDefaults)
    func savePlanVisitsData(model: [PlanVisitsData]) { setCodable(model, forKey: Keys.planVisitsKey); log("✔ Plan Visits saved successfully") }
    func getPlanVisitsData() -> [PlanVisitsData]? { getCodable([PlanVisitsData].self, forKey: Keys.planVisitsKey) }
    func clearPlanVisitsData() { clear(Keys.planVisitsKey) }

    // MARK: - Plan OWS Data (UserDefaults)
    func savePlanOwsData(model: [PlanOwsData]) { setCodable(model, forKey: Keys.planOwsDataKey); log("✔ Plan Ows Data saved successfully") }
    func getPlanOwsData() -> [PlanOwsData]? { getCodable([PlanOwsData].self, forKey: Keys.planOwsDataKey) }
    func clearPlanOwsData() { clear(Keys.planOwsDataKey) }

    // MARK: - App Presentations (UserDefaults)
    func saveAppPresentationsModel(model: AppPresentationsModel) { setCodable(model, forKey: Keys.appPresentationsModelKey); log("✔ App Presentations Model saved successfully") }
    func getAppPresentationsModel() -> AppPresentationsModel? { getCodable(AppPresentationsModel.self, forKey: Keys.appPresentationsModelKey) }
    func clearAppPresentationsModel() { clear(Keys.appPresentationsModelKey) }

    // MARK: - OW Activities (UserDefaults)
    func saveOWActivitiesModel(model: [OWSModel]) {
        var oldData = getOWActivitiesData() ?? []
        oldData.append(contentsOf: model)
        setCodable(oldData, forKey: Keys.oWActivitiesKey)
        log("✔ OWActivities Data appended & saved successfully")
    }

    func getOWActivitiesData() -> [OWSModel]? { getCodable([OWSModel].self, forKey: Keys.oWActivitiesKey) }
    func clearOWActivitiesModel() { clear(Keys.oWActivitiesKey) }

    
    
    // MARK: - Gifts Data (UserDefaults)
    func saveGiftsData(model: [Lines]) { setCodable(model, forKey: Keys.giftsDataKey); log("✔ App giftsData Model saved successfully") }
    func getGiftsData() -> [Lines]? { getCodable([Lines].self, forKey: Keys.giftsDataKey) }
    func clearGiftsData() { clear(Keys.giftsDataKey) }
    
    func saveManagerData(model: [Lines]) { setCodable(model, forKey: Keys.managerDataKey); log("✔ App ManagerData Model saved successfully") }
    func getManagerData() -> [Lines]? { getCodable([Lines].self, forKey: Keys.managerDataKey) }
    func clearManagerData() { clear(Keys.managerDataKey) }
    
    func saveVisitItemData(model: [VisitItem]) { setCodable(model, forKey: Keys.visitItemKey); log("✔ App VisitItemData Model saved successfully") }
    func getVisitItemData() -> [VisitItem]? { getCodable([VisitItem].self, forKey: Keys.visitItemKey) }
    func clearVisitItemData() { clear(Keys.visitItemKey) }
    
    func saveProductsData(model: [ProductItem]) { setCodable(model, forKey: Keys.productsDataKey); log("✔ App productsData Model saved successfully") }
    func getProductsData() -> [ProductItem]? { getCodable([ProductItem].self, forKey: Keys.productsDataKey) }
    func clearProductsData() { clear(Keys.productsDataKey) }
    
    func saveSelectedImageVisitData(model: [SelectedImage]) { setCodable(model, forKey: Keys.selectedImageVisitDataKey); log("✔ App SelectedImageVisit Model saved successfully") }
    
    func getSelectedImageVisitData() -> [SelectedImage]? { getCodable([SelectedImage].self, forKey: Keys.selectedImageVisitDataKey) }
    func clearSelectedImageVisitData() { clear(Keys.selectedImageVisitDataKey) }
    
    // MARK: - UnPlanned Visit Offline Flag
    func setUnPlannedVisitOffline(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: Keys.applayUnPlannedVisitOffline)
        log("✔ UnPlannedVisitOffline flag set to \(value)")
    }

    func isUnPlannedVisitOffline() -> Bool {
        return UserDefaults.standard.bool(forKey: Keys.applayUnPlannedVisitOffline)
    }

    func clearUnPlannedVisitOffline() {
        UserDefaults.standard.removeObject(forKey: Keys.applayUnPlannedVisitOffline)
        log("✔ UnPlannedVisitOffline flag cleared")
    }

    func saveVisitStartLocation(lat: Double, lng: Double) {
        let location = VisitStartLocation(
            latitude: lat,
            longitude: lng,
            timestamp: Date()
        )
        setCodable(location, forKey: Keys.visitStartLocation)
        log("✔ Visit start location saved")
    }
    func getVisitStartLocation() -> CLLocation? {
        guard let loc = getCodable(VisitStartLocation.self,
                                   forKey: Keys.visitStartLocation) else {
            return nil
        }
        return CLLocation(latitude: loc.latitude, longitude: loc.longitude)
    }
    func clearVisitStartLocation() {
        clear(Keys.visitStartLocation)
        log("✔ Visit start location cleared")
    }

    
    func saveActualVisitData(model: [ActualVisitModel]) { setCodable(model, forKey: Keys.actualVisitKey); log("✔ App actualVisit Model saved successfully") }
    func getActualVisitData() -> [ActualVisitModel]? { getCodable([ActualVisitModel].self, forKey: Keys.actualVisitKey) }
    func clearActualVisitData() { clear(Keys.actualVisitKey) }
    
    
    // MARK: - new Plan (UserDefaults)
    func saveNewPlanData(model: [SaveNewPlanModel]) { setCodable(model, forKey: Keys.newPlanKey); log("✔ New Plan saved successfully") }
    func getNewPlanData() -> [SaveNewPlanModel]? { getCodable([SaveNewPlanModel].self, forKey: Keys.newPlanKey) }
    func clearNewPlanData() { clear(Keys.newPlanKey) }

}
