//
//  OfflineRequestManagerVC.swift
//  Puplo Pro
//
//  Created by Ahmed on 27/11/2025.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import CoreLocation

class OfflineRequestManager {
    
    // MARK: - Properties
    let loadingBehavior = BehaviorRelay<Bool>(value: false)
    let alertBehavior = PublishSubject<String>()
    
    
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
    
    // MARK: - save Plans
    func savePlans(completion: @escaping (Bool, String,[(offlineID: Int, onlineID: Int)]) -> Void) {
        guard
            let user = LocalStorageManager.shared.getLoggedUser(),
            let baseURL = LocalStorageManager.shared.getAPIPath()
        else {
            completion(false, "Unauthorized", [])
            return
        }
        let plans = LocalStorageManager.shared.getNewPlanData() ?? []
        let url = baseURL + URLs.planURL
        let paramsArray = buildParams(from: plans, user_id: user.user_id ?? "")
        let headers = buildHeaders()
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: paramsArray, options: [])
            loadingBehavior.accept(true)
            NetworkLayer.shared.fetchData(
                method: .post,
                url: url,
                parameters: [:],
                body: jsonData,
                headers: headers
            ) { [weak self] (result: Result<SavePlanResponse>) in
                self?.loadingBehavior.accept(false)
                switch result {
                case .success(let model):
                    let idsMap: [(offlineID: Int, onlineID: Int)] =
                        model.Data?.compactMap {
                            guard
                                let offlineID = $0.offline_id,
                                let onlineID = Int($0.planned_id ?? "")
                            else { return nil }
                            
                            return (offlineID, onlineID)
                        } ?? []
                    print("model >>\(model)")
                    completion(true, model.Status_Message ?? "", idsMap)
                case .failure:
                    completion(false, "Something went wrong", [])
                }
            }
        } catch {
            completion(false, "Invalid JSON body", [])
        }
    }
    // MARK: - Helpers
    private func buildParams(from plans: [SaveNewPlanModel],user_id: String) -> [[String: Any]] {
        
        return plans.map {
            [
                "div_id": $0.divID ?? 0,
                "id": 0,
                "insertion_date": $0.insertionDate ?? "",
                "item_doc_id": $0.accountDoctorID ?? 0,
                "item_id": $0.accountID ?? 0,
                "offline_id": $0.offlineID ?? 0,
                "team_id": 1,
                "type_id": $0.accountTypeID ?? 0,
                "user_id": user_id,
                "vdate": $0.visitDate ?? "",
                "vtime": $0.visitTime ?? ""
            ]
        }
    }
    private func buildHeaders() -> HTTPHeaders {
        [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "lang": "ar",
            "device-id": AppInfo.shared.deviceID,
            "timezone": "Africa/Cairo"
        ]
    }
}
