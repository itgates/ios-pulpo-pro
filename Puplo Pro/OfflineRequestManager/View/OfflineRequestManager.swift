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
}
