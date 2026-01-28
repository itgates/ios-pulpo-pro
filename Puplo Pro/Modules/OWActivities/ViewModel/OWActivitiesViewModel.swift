//
//  OWActivitiesViewModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 02/12/2025.
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
    
    private let oWActivitiesAMModelSubject = BehaviorRelay<[OWActivitiesData]>(value: [])
    var oWActivitiesAMModelObservable: Observable<[OWActivitiesData]> {
        oWActivitiesAMModelSubject.asObservable()
    }
    
    private let officeWorkTypesModelSubject = BehaviorRelay<[Lines]>(value: [])
    var officeWorkTypesModelObservable: Observable<[Lines]> {
        officeWorkTypesModelSubject.asObservable()
    }
        
    var officeWork = LocalStorageManager.shared.getMasterData()
    
   
    // MARK: - Fetch Data
    func fetchData() {
        
        let reportsData: [(name: String, id: Int)] = [
            ("AM", 1),
            ("PM", 2),
            ("Full Day", 4)
        ]

        let items: [OWActivitiesData] = reportsData.compactMap { data in
            return OWActivitiesData(name: data.name, id: data.id)
        }
        oWActivitiesAMModelSubject.accept(items)
        
        guard let data = officeWork?.data else { return }
        officeWorkTypesModelSubject.accept(data.officeWorkTypes ?? [])
    }
    // MARK: - Helpers (Lookup)
    func shiftName(for shiftId: Int) -> String? {
        return oWActivitiesAMModelSubject.value
            .first { $0.id == shiftId }?
            .name
    }

    func officeWorkName(for owTypeId: Int) -> String? {
        return officeWorkTypesModelSubject.value
            .first { $0.id == owTypeId }?
            .name
    }


    func applayWithNetworkCheck(OWS: [OWSModel], completion: @escaping (Bool, String) -> Void) {

        if Reachability.isConnectedToNetwork() {
            fetchDataApplay(OWS: OWS) { done, message in
                if done {
                    LocalStorageManager.shared.clearOWActivitiesModel()
                }
                completion(done, message)
            }
        } else {
            LocalStorageManager.shared.saveOWActivitiesModel(model: OWS)
            completion(true, "تم حفظ البيانات محليًا. سيتم رفعها عند الاتصال بالإنترنت.")
        }
    }

    // MARK: - fetch Data Applay
    func fetchDataApplay(OWS: [OWSModel], completion: @escaping (Bool,String) -> Void) {

        let user = LocalStorageManager.shared.getLoggedUser()
        let baseURL = LocalStorageManager.shared.getAPIPath() ?? ""
        let url = baseURL + URLs.saveOwURL
        
        //  Convert Visits to Dictionary Format
        let owsArray: [[String: Any]] = OWS.map { ows in
            return [
                "date": ows.date,
                "id": 0,
                "notes": ows.notes,
                "offline_id": ows.offline_id,
                "ow_plan_id": ows.ow_plan_id,
                "ow_type_id": ows.ow_type_id,
                "shift_id": ows.shift_id,
                "time": ows.time
            ]
        }
        // MARK: - Prepare Parameters
        let params: [String: Any] = [
            "os_type": "1",
            "ows": owsArray
        ]
        print("params >> \(params)")

        // MARK: - Headers
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(user?.access_token ?? "")",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "lang": "ar",
            "device-id": AppInfo.shared.deviceID,
            "timezone": "Africa/Cairo"
        ]

        loadingBehavior.accept(true)

        NetworkLayer.shared.fetchData(
            method: .post,
            url: url,
            parameters: params,
            headers: headers
        ) { [weak self] (result: Result<OWActivitiesResponse>) in
            guard let self = self else { return }
            self.loadingBehavior.accept(false)
            switch result {
            case .success(let model):
                let hasData = (model.Data?.isEmpty == false)
                completion(hasData,model.message ?? "")
                print("model >>>\(model)")
            case .failure:
                completion(false,"")
            }
        }
    }
}
