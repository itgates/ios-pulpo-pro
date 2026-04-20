
//
//  OWActivitiesViewModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 12/02/2026.
//
import Foundation
import RxSwift
import RxCocoa
import UIKit
import Alamofire
class OWActivitiesViewModel {
    
    // MARK: - Properties
    let loadingBehavior = BehaviorRelay<Bool>(value: false)
    // Visibility states (kept private)
    private let isCollectionViewHidden = BehaviorRelay<Bool>(value: false)
    
    private let oWActivitiesAMModelSubject = BehaviorRelay<[IdNameModel]>(value: [])
    var oWActivitiesAMModelObservable: Observable<[IdNameModel]> {
        oWActivitiesAMModelSubject.asObservable()
    }
    
    private let officeWorkTypesModelSubject = BehaviorRelay<[IdNameModel]>(value: [])
    var officeWorkTypesModelObservable: Observable<[IdNameModel]> {
        officeWorkTypesModelSubject.asObservable()
    }
    
    let officeWork = AppDataProvider.shared.masterData
        
    // MARK: - Fetch Data
    func fetchData() {
        
        let reportsData: [(name: String, id: String)] = [
            ("AM", "2"),
            ("PM", "1"),
            ("Full Day", "4")
        ]
        
        let items: [IdNameModel] = reportsData.compactMap { data in
            return IdNameModel(id: data.id, name: data.name)
        }
        oWActivitiesAMModelSubject.accept(items)
        
        guard let data = officeWork?.Data else { return }
        officeWorkTypesModelSubject.accept(data.office_work_types ?? [])
    }
    // MARK: - Helpers (Lookup)
    func shiftName(for shiftId: String) -> String? {
        return oWActivitiesAMModelSubject.value
            .first { $0.id == shiftId }?
            .name
    }
    func officeWorkName(for owTypeId: String) -> String? {
        return officeWorkTypesModelSubject.value
            .first { $0.id == owTypeId }?
            .name
    }
    func validateOfficeWorkShift(newShiftId: String, date: String) -> String? {
        
        let todayWorks = RealmStorageManager.shared.getOfficeWorkData() ?? []
        
        print("🗓 Selected Date:", date)
        print("📦 All Office Works:", todayWorks)
        
        let sameDayWorks = todayWorks.filter {
            $0.date == date
        }
        
        print("📆 Same Day Works:", sameDayWorks)
        
        let hasAM = sameDayWorks.contains { $0.shift_id == "2" }
        let hasPM = sameDayWorks.contains { $0.shift_id == "1" }
        let hasFullDay = sameDayWorks.contains { $0.shift_id == "4" }
        
        print("🔍 hasAM:", hasAM, "| hasPM:", hasPM, "| hasFullDay:", hasFullDay)
        print("🆕 Selected Shift:", newShiftId)
        
        if hasFullDay {
            print("❌ Blocked: Full Day already exists")
            return "You cannot add any additional office work today after selecting Full Day."
        }
        
        if newShiftId == "4" && !sameDayWorks.isEmpty {
            print("❌ Blocked: Trying to add Full Day with existing shifts")
            return "You cannot select Full Day together with any other shift on the same day."
        }
        
        if newShiftId == "2" && hasAM {
            print("❌ Blocked: Duplicate AM")
            return "You cannot add AM more than once on the same day."
        }
        
        if newShiftId == "1" && hasPM {
            print("❌ Blocked: Duplicate PM")
            return "You cannot add PM more than once on the same day."
        }
        
        print("✅ Office Work validation passed")
        return nil
    }
    func applayWithNetworkCheck(OWS: [OWSModel], completion: @escaping (Bool, String) -> Void) {
        print("OWS.count >>>\(OWS.count)")
        if Reachability.isConnectedToNetwork() {
            fetchDataApplay(OWS: OWS) { done, message in
                if done {
                    RealmStorageManager.shared.saveOfficeWorkModel(OWS)
                    print("OWS >>>>\(OWS)")
                    print("getOfficeWorkData >>>>\(RealmStorageManager.shared.getOfficeWorkData() ?? [])")
//                    RealmStorageManager.shared.clearOWActivitiesModel()
                }
                completion(done, message)
            }
        } else {
            RealmStorageManager.shared.saveOWActivitiesModel(OWS)
            RealmStorageManager.shared.saveOfficeWorkModel(OWS)
            completion(true, "The data has been saved locally. It will be uploaded once an internet connection is available.")
        }
    }
    
    // MARK: - fetch Data Applay
    func fetchDataApplay(OWS: [OWSModel],completion: @escaping (Bool,String) -> Void) {
        
        let user = RealmStorageManager.shared.getLoggedUser()
        let baseURL = RealmStorageManager.shared.getAPIPath() ?? ""
        let url = baseURL + URLs.saveOwURL
        
        let visitArray: [[String: Any]] = OWS.map { model in
            return [
                "ampm": model.shift_id ?? "2",
                "comments": model.notes,
                "date_added": model.date,
                "appVersion": AppInfo.shared.appVersion,
                "osVersion": AppInfo.shared.osVersion,
                "deviceBrand": AppInfo.shared.deviceModel,
                "osType": "iOS",
                "div_id": -1,
                "giveaway_info": [],
                "id": 0,
                "insertion_date": "",
                "insertion_time": "",
                "is_fake_end_location": false,
                "is_fake_start_location": false,
                "is_sync": 0,
                "item_doc_id": 0,
                "item_id": 0,
                "member_info": [],
                "members": "0",
                "no_of_doctors": 0,
                "offline_id": "11",
                "product_info": [],
                "selected_shift": model.shift_id ?? "1",
                "sync_date": "",
                "sync_time": "",
                "team_id": 0,
                "type_id": model.ow_type_id,
                "user_id": user?.user_id ?? "",
                "vdate": model.date,
                "visit_address": "",
                "visit_deviation": 0,
                "visit_duration": "00:00:08",
                "vplanned_id": 0,
                "vtime": model.time,
            ]
        }
        print("visitArray >>>\(visitArray)")
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: visitArray, options: [])
            print("bodyData >>>\(bodyData)")
            NetworkLayer.shared.fetchData(
                method: .post,
                url: url,
                parameters: [:],
                body: bodyData,
                headers: [
                    "Content-Type": "application/json",
                    "Accept": "application/json",
                    "lang": "ar",
                    "device-id": AppInfo.shared.deviceID,
                    "timezone": "Africa/Cairo"
                ]
            ) { [weak self] (result: Result<OWActivitiesResponse>) in
                self?.loadingBehavior.accept(false)
                switch result {
                case .success(let model):
                    completion(true, model.Status_Message ?? "")
                    print("model >>>\(model)")
                case .failure(let error):
                    completion(false, error.localizedDescription)
                }
            }
        } catch {
            completion(false, "JSON Encoding Error")
        }
    }
}


