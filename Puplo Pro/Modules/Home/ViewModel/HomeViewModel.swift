//
//  HomeViewModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 18/11/2025.
//
import Foundation
import RxSwift
import RxCocoa
import UIKit
import Alamofire
class HomeViewModel {
    
    // MARK: - Properties
    let loadingBehavior = BehaviorRelay<Bool>(value: false)
    let alert = PublishSubject<String>()
    var isCheckIn: Bool = true
    
    // Visibility states (kept private)
    private let isCollectionViewHidden = BehaviorRelay<Bool>(value: false)
    private let isTableViewHidden = BehaviorRelay<Bool>(value: false)
    
    private let homeModelSubject = BehaviorRelay<[HomeModel]>(value: [])
    var homeModelObservable: Observable<[HomeModel]> { homeModelSubject.asObservable() }
    
    // MARK: - Fetch Data
    func fetchData() {
        loadingBehavior.accept(true)
        DispatchQueue.global(qos: .userInitiated).async {
            let schedulData: [(dayName: String, imageName: String,vc: UIViewController.Type?)] = [
                ("Planning visits", "Planning",PlanningVisitsVC.self),
                ("Planned Visits", "Planned",PlannedVisitsVC.self),
                ("Unplanned Visit", "Unplanned",UnPlannedVisitVC.self),
                ("OW & Activities", "OW",OWActivitiesVC.self),
                ("My Location", "Location",MyLocationVC.self),
                ("Data Center", "Data",DataCenterVC.self),
                ("Reports", "Reports",ReportsVC.self),
            ]
            
            let items: [HomeModel] = schedulData.compactMap { data in
                guard let image = UIImage(named: data.imageName) else { return nil }
                return HomeModel(name: data.dayName, image: image,vc: data.vc)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.homeModelSubject.accept(items)
                self.loadingBehavior.accept(false)
            }
        }
    }
    // MARK: - Check In/Out (Public)
    func checkInOut(completion: @escaping (Bool, String) -> Void) {

        let currentStatus = LocalStorageManager.shared.getCheckIn()

        // OFFLINE
        if Reachability.isConnectedToNetwork() == false {

            LocationManager.shared.getCurrentLocation { lat, long in

                let body = self.buildCheckInBody(
                    lat: "\(lat)",
                    long: "\(long)"
                )

                LocalStorageManager.shared.saveOfflineCheckAction(body)

                let newStatus = (currentStatus == "checked_in")
                    ? "checked_out"
                    : "checked_in"

                LocalStorageManager.shared.saveCheckIn(newStatus)

                completion(true, "Saved offline")
            }

            return
        }

        // ONLINE
        apiCheckInOut(completion: completion)
    }

    func syncOfflineActionsIfNeeded(completion: @escaping () -> Void) {
        guard Reachability.isConnectedToNetwork() == true else {
            completion(); return
        }
        
        let actions = LocalStorageManager.shared.getOfflineCheckActions()
        guard !actions.isEmpty else { completion(); return }
        
        let group = DispatchGroup()
        for body in actions {
            group.enter()
            sendOfflineActionToAPI(body) { group.leave() }
        }
        
        group.notify(queue: .main) {
            LocalStorageManager.shared.clearOfflineCheckActions()
            completion()
        }
    }
    
    // MARK: - Networking helpers
    private func sendOfflineActionToAPI(_ body: [CheckInOutSend], completion: @escaping () -> Void) {
        guard let user = LocalStorageManager.shared.getLoggedUser() else { completion(); return }
        let baseURL = LocalStorageManager.shared.getAPIPath() ?? ""
        let url = baseURL + URLs.checkInOutsURL
        
        guard let jsonData = try? JSONEncoder().encode(body) else { completion(); return }
        print("body >>>\(body)")
        let headers = makeDefaultHeaders(accessToken: user.access_token)
        
        NetworkLayer.shared.fetchData(
            method: .post,
            url: url,
            body: jsonData,
            headers: headers
        ) { (result: Result<CheckInModel>) in
            if case let .success(model) = result {
                LocalStorageManager.shared.saveCheckIn(model.data?.first?.status ?? "")
                if let onlineID = model.data?.first?.online_id {
                    LocalStorageManager.shared.saveOnlineID(String(onlineID))
                }
            }
            completion()
        }
    }
    
    // MARK: - Check In/Out (Online)
    func apiCheckInOut(completion: @escaping (Bool, String) -> Void) {
        guard let user = LocalStorageManager.shared.getLoggedUser() else {
            completion(false, ""); return
        }
        
        let baseURL = LocalStorageManager.shared.getAPIPath() ?? ""
        let url = baseURL + URLs.checkInOutsURL
        
        // Obtain location first
        LocationManager.shared.getCurrentLocation { [weak self] lat, long in
            guard let self = self else { return }
            
            let body = self.buildCheckInBody(lat: "\(lat)", long: "\(long)")
            print("body >>\(body)")
            guard let jsonData = try? JSONEncoder().encode(body) else {
                completion(false, "Encoding error"); return
            }
            
            let headers = self.makeDefaultHeaders(accessToken: user.access_token)
            
            self.loadingBehavior.accept(true)
            
            NetworkLayer.shared.fetchData(
                method: .post,
                url: url,
                body: jsonData,
                headers: headers
            ) { [weak self] (result: Result<CheckInModel>) in
                guard let self = self else { return }
                self.loadingBehavior.accept(false)
                
                switch result {
                case .success(let model):
                    if model.success == true {
                        LocalStorageManager.shared.saveCheckIn(model.data?.first?.status ?? "")
                        if let onlineID = model.data?.first?.online_id {
                            LocalStorageManager.shared.saveOnlineID(String(onlineID))
                        }
                        completion(true, "")
                    } else {
                        completion(false, model.message ?? "")
                    }
                    print("model >>\(model)")
                case .failure(let error):
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Body Builder
    private func buildCheckInBody(lat: String, long: String) -> [CheckInOutSend] {
        guard let user = LocalStorageManager.shared.getLoggedUser() else { return [] }
        
        let now = Date()
        let currentDate = now.formattedDate
        let currentTime = now.formattedTime
        let online_id = LocalStorageManager.shared.getOnlineID() ?? ""
        let checkStatus = LocalStorageManager.shared.getCheckIn() ?? ""
        
        switch checkStatus {
        case "checked_in":
            return [
                CheckInOutSend(
                    check_in_date: user.check_in_date ?? "",
                    check_in_time: (user.check_in_time ?? "").to24HourFormat,
                    ll_check_in: lat,
                    lg_check_in: long,
                    offline_id: 11,
                    online_id: online_id,
                    check_out_date: currentDate,
                    check_out_time: currentTime.to24HourFormat,
                    ll_check_out: lat,
                    lg_check_out: long
                )
            ]
        default:
            return [
                CheckInOutSend(
                    check_in_date: currentDate,
                    check_in_time: currentTime.to24HourFormat,
                    ll_check_in: lat,
                    lg_check_in: long,
                    offline_id: 11,
                    online_id: "",
                    check_out_date: "",
                    check_out_time: "",
                    ll_check_out: "",
                    lg_check_out: ""
                )
            ]
        }
    }
    
    // MARK: - Headers Helper
    private func makeDefaultHeaders(accessToken: String?) -> HTTPHeaders {
        return [
            "Authorization": "Bearer \(accessToken ?? "")",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "lang": "ar",
            "device-id": AppInfo.shared.deviceID,
            "timezone": "Africa/Cairo"
        ]
    }
}
