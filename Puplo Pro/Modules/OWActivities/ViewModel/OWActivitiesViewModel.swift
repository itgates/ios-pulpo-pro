
//
//  OWActivitiesViewModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 12/02/2026.
//
//import Foundation
//import RxSwift
//import RxCocoa
//import UIKit
//import Alamofire
//class OWActivitiesViewModel {
//
//    // MARK: - Properties
//    let loadingBehavior = BehaviorRelay<Bool>(value: false)
//    // Visibility states (kept private)
//    private let isCollectionViewHidden = BehaviorRelay<Bool>(value: false)
//
//    private let oWActivitiesAMModelSubject = BehaviorRelay<[IdNameModel]>(value: [])
//    var oWActivitiesAMModelObservable: Observable<[IdNameModel]> {
//        oWActivitiesAMModelSubject.asObservable()
//    }
//
//    private let officeWorkTypesModelSubject = BehaviorRelay<[IdNameModel]>(value: [])
//    var officeWorkTypesModelObservable: Observable<[IdNameModel]> {
//        officeWorkTypesModelSubject.asObservable()
//    }
//
//    var officeWork = LocalStorageManager.shared.getMasterData()
//
//
//    // MARK: - Fetch Data
//    func fetchData() {
//
//        let reportsData: [(name: String, id: String)] = [
//            ("AM", "1"),
//            ("PM", "2"),
//            ("Full Day", "4")
//        ]
//
//        let items: [IdNameModel] = reportsData.compactMap { data in
//            return IdNameModel(id: data.id, name: data.name)
//        }
//        oWActivitiesAMModelSubject.accept(items)
//
//        guard let data = officeWork?.Data else { return }
//        officeWorkTypesModelSubject.accept(data.office_work_types ?? [])
//    }
//    // MARK: - Helpers (Lookup)
//    func shiftName(for shiftId: String) -> String? {
//        return oWActivitiesAMModelSubject.value
//            .first { $0.id == shiftId }?
//            .name
//    }
//    func officeWorkName(for owTypeId: String) -> String? {
//        return officeWorkTypesModelSubject.value
//            .first { $0.id == owTypeId }?
//            .name
//    }
//    func applayWithNetworkCheck(OWS: [OWSModel], completion: @escaping (Bool, String) -> Void) {
//        print("OWS.count >>>\(OWS.count)")
//        if Reachability.isConnectedToNetwork() {
//            fetchDataApplay(OWS: OWS) { done, message in
//                if done {
//                    LocalStorageManager.shared.clearOWActivitiesModel()
//                }
//                completion(done, message)
//            }
//        } else {
//            LocalStorageManager.shared.saveOWActivitiesModel(OWS)
//            completion(true, "تم حفظ البيانات محليًا. سيتم رفعها عند الاتصال بالإنترنت.")
//        }
//    }
//
//    // MARK: - fetch Data Applay
//    func fetchDataApplay(OWS: [OWSModel],
//                         completion: @escaping (Bool,String) -> Void) {
//
//        let user = LocalStorageManager.shared.getLoggedUser()
//        let baseURL = LocalStorageManager.shared.getAPIPath() ?? ""
//        let url = baseURL + URLs.saveOwURL
//
//
//
//        let visitArray: [[String: Any]] = OWS.map { model in
//            return [
////                "androidId": "7026570c4eaa5789",
////                "androidVersion": "12",
////                "appVersion": AppInfo.shared.appVersion,
////                "deviceBrand": AppInfo.shared.deviceModel,
////                "deviceModel": "Redmi Note 9S",
//                "appVersion": AppInfo.shared.appVersion,
//                "osVersion": AppInfo.shared.osVersion,
//                "deviceBrand": AppInfo.shared.deviceModel,
//                "osType": "iOS",
//                "type_id": model.ow_type_id,
//                "vdate": model.date,
//                "date_added": model.date,
//                "vtime": model.time,
//                "ampm": model.shift_id,
//                "comments": model.notes,
//                "user_id": user?.user_id ?? "",
//                "visit_duration": "00:00:08",
//                "visit_deviation": 0,
//                "lg": "",
//                "lg_start": "",
//                "ll": "",
//                "ll_start": "",
//            ]
//        }
//        print("visitArray >>>\(visitArray)")
//        do {
//            let bodyData = try JSONSerialization.data(withJSONObject: visitArray, options: [])
//            print("bodyData >>>\(bodyData)")
//            NetworkLayer.shared.fetchData(
//                method: .post,
//                url: url,
//                parameters: [:],
//                body: bodyData,
//                headers: [
//                    "Content-Type": "application/json",
//                    "Accept": "application/json",
//                    "lang": "ar",
//                    "device-id": AppInfo.shared.deviceID,
//                    "timezone": "Africa/Cairo"
//                ]
//            ) { [weak self] (result: Result<OWActivitiesResponse>) in
//                self?.loadingBehavior.accept(false)
//                switch result {
//                case .success(let model):
//                    completion(true, model.Status_Message ?? "")
//                    print("model >>>\(model)")
//                case .failure(let error):
//                    completion(false, error.localizedDescription)
//                }
//            }
//        } catch {
//            completion(false, "JSON Encoding Error")
//        }
//    }
//}
//



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
    
    var officeWork = LocalStorageManager.shared.getMasterData()
    
    
    // MARK: - Fetch Data
    func fetchData() {
        
        let reportsData: [(name: String, id: String)] = [
            ("AM", "1"),
            ("PM", "2"),
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
    func applayWithNetworkCheck(OWS: [OWSModel], completion: @escaping (Bool, String) -> Void) {
        print("OWS.count >>>\(OWS.count)")
        if Reachability.isConnectedToNetwork() {
            fetchDataApplay(OWS: OWS) { done, message in
                if done {
                    LocalStorageManager.shared.clearOWActivitiesModel()
                }
                completion(done, message)
            }
        } else {
            LocalStorageManager.shared.saveOWActivitiesModel(OWS)
            completion(true, "تم حفظ البيانات محليًا. سيتم رفعها عند الاتصال بالإنترنت.")
        }
    }
    
    // MARK: - fetch Data Applay
    func fetchDataApplay(OWS: [OWSModel],completion: @escaping (Bool,String) -> Void) {
        
        let user = LocalStorageManager.shared.getLoggedUser()
        let baseURL = LocalStorageManager.shared.getAPIPath() ?? ""
        let url = baseURL + URLs.saveOwURL
        
        let visitArray: [[String: Any]] = OWS.map { model in
            return [
                "ampm": model.shift_id ?? "1",
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


