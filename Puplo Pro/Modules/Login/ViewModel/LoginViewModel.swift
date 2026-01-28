//
//  LoginViewModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 17/11/2025.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

class LoginViewModel {
    
    // MARK: - Properties
    let loadingBehavior = BehaviorRelay<Bool>(value: false)
    let alertBehavior = PublishSubject<String>()
    
    // MARK: - API Call: Login
    func loginUser(name: String, password: String,companyName:String, completion: @escaping (Bool) -> Void) {
        
        let user = LocalStorageManager.shared.getLoggedUser()
        
        let baseURL = LocalStorageManager.shared.getAPIPath() ?? ""
        let url = baseURL + URLs.loginURL
        print("url >>\(url)")
        // MARK: - Prepare Parameters
        let params: [String: Any] = [
            "name": name,
            "password": password,
            "isRealLogin": true,
            "appVersion": AppInfo.shared.appVersion,
            "osVersion": AppInfo.shared.osVersion,
            "deviceBrand": AppInfo.shared.deviceModel,
            "osType": "iOS",
            "OsID": AppInfo.shared.deviceID
        ]
        
        // MARK: - Headers
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(user?.access_token ?? "")",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "lang": "ar",
            "device-id": AppInfo.shared.deviceID,
            "timezone": "Africa/Cairo"
        ]
        print("headers >>\(headers)")
        print("params >>\(params)")
        loadingBehavior.accept(true)
        
        NetworkLayer.shared.fetchData(
            method: .post,
            url: url,
            parameters: params,
            headers: headers
        ) { [weak self] (result: Result<LoginModel>) in
            guard let self = self else { return }
            self.loadingBehavior.accept(false)
            switch result {
            case .success(let model):
               
                if model.code != 500 {
                    
                    LocalStorageManager.shared.clearUsers()
                    let now = Date()
                    let checkInDate = now.formattedDate
                    let checkInTime = now.formattedTime

                    LocalStorageManager.shared.saveUser(
                        model: model,
                        check_in_date: checkInDate,
                        check_in_time: checkInTime,
                        companyName: companyName,
                    )
                    
                    completion(true)
                } else {
                    completion(false)
                }
            case .failure(let error):
                self.alertBehavior.onNext(error.localizedDescription)
                completion(false)
            }
        }
    }
    // MARK: - fetchAllData
    func fetchAllData(completion: @escaping (Bool) -> Void) {

        let group = DispatchGroup()
        var isAllSuccess = true

        group.enter()
        getMasterData { success in
            isAllSuccess = isAllSuccess && success
            group.leave()
        }

        group.enter()
        getAccountsDoctors { success in
            isAllSuccess = isAllSuccess && success
            group.leave()
        }

        group.enter()
        getPlanVisitsData { success in
            isAllSuccess = isAllSuccess && success
            group.leave()
        }

        group.enter()
        getPlanOwsData { success in
            isAllSuccess = isAllSuccess && success
            group.leave()
        }

        group.enter()
        getAppPresentations { success in
            isAllSuccess = isAllSuccess && success
            group.leave()
        }

        group.notify(queue: .main) {
            completion(isAllSuccess)
        }
    }

    // MARK: - get Master Data
    func getMasterData(completion: @escaping (Bool) -> Void) {
        
        let user = LocalStorageManager.shared.getLoggedUser()
        
        let baseURL = LocalStorageManager.shared.getAPIPath() ?? ""
        let url = baseURL + URLs.masterDataURL
        print("url >>\(url)")
        
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
        print("headers >>\(headers)")
        NetworkLayer.shared.fetchData(
            method: .get,
            url: url,
            parameters: [:],
            headers: headers
        ) { [weak self] (result: Result<MasterDataModel>) in
            guard let self = self else { return }
            print("DEBUG: entered fetchData completion for getMasterData")
            self.loadingBehavior.accept(false)
            print("DEBUG: about to switch on result")
            switch result {
            case .success(let model):
                print("DEBUG: switch success with model: \(model)")
                // Save master data locally
                LocalStorageManager.shared.saveMasterData(model: model)
                if model.data != nil {
                    completion(true)
                } else {
                    completion(false)
                }
            case .failure(let error):
                print("DEBUG: switch failure with error: \(error)")
            }
        }
    }
    // MARK: - get Accounts Doctors
    func getAccountsDoctors(completion: @escaping (Bool) -> Void) {
        
        guard let user = LocalStorageManager.shared.getLoggedUser() else {
            completion(false)
            return
        }
        
        let baseURL = LocalStorageManager.shared.getAPIPath() ?? ""
        let url = baseURL + URLs.accountsDoctorsURL
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(user.access_token ?? "")",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "lang": "ar",
            "device-id": AppInfo.shared.deviceID,
            "timezone": "Africa/Cairo"
        ]
        
        loadingBehavior.accept(true)
        
        NetworkLayer.shared.fetchData(
            method: .get,
            url: url,
            parameters: [:],
            headers: headers
        ) { [weak self] (result: Result<AccountsDoctorsModel>) in
            
            guard let self = self else { return }
            self.loadingBehavior.accept(false)
            
            switch result {
            case .success(let model):

                LocalStorageManager.shared.saveAccountsDoctors(model: model)
                
                var amDoctors = [PlanningVisitsData]()
                var pmDoctors = [PlanningVisitsData]()
                var otherDoctors = [PlanningVisitsData]()
                
                model.data?.doctors?.forEach { doc in
                    guard let id = doc.id else { return }

                    let account = model.data?.accoutns?.first { $0.id == doc.account_id }
                    let hospital = account?.name ?? ""

                    let shift = AccountShift(rawValue: account?.type_id ?? 0)

                    let item = PlanningVisitsData(
                        id: id,
                        account_id: account?.id,
                        name: doc.name ?? "",
                        hosptal: hospital,
                        shift: shift,
                        div_id: account?.div_id,
                        brick_id: account?.brick_id,
                        class_id: account?.class_id,
                        type_id: account?.type_id,
                        line_id: account?.line_id,
                        lat: account?.ll,
                        lng: account?.lg
                    )

                    switch shift {
                    case .am:
                        amDoctors.append(item)
                    case .pm:
                        pmDoctors.append(item)
                    default:
                        otherDoctors.append(item)
                    }
                }
                
                LocalStorageManager.shared.saveAccountsDoctorsAM(model: amDoctors)
                LocalStorageManager.shared.saveAccountsDoctorsPM(model: pmDoctors)
                LocalStorageManager.shared.saveAccountsDoctorsOther(model: otherDoctors)
                
                completion(model.data != nil)
                
            case .failure(let error):
                print("Error fetching doctors: \(error)")
                completion(false)
            }
        }
    }
    // MARK: - get plan Visits data
    func getPlanVisitsData(completion: @escaping (Bool) -> Void) {
        
        let user = LocalStorageManager.shared.getLoggedUser()
        
        let baseURL = LocalStorageManager.shared.getAPIPath() ?? ""
        let url = baseURL + URLs.planVisitsURL
        print("url >>\(url)")
        
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
        print("headers >>\(headers)")
        NetworkLayer.shared.fetchData(
            method: .get,
            url: url,
            parameters: [:],
            headers: headers
        ) { [weak self] (result: Result<PlanVisitsModel>) in
            guard let self = self else { return }
            print("DEBUG: entered fetchData completion for getMasterData")
            self.loadingBehavior.accept(false)
            print("DEBUG: about to switch on result")
            switch result {
            case .success(let model):
                print("DEBUG: switch success with model: \(model)")
                // Save  Plan Visits Data locally
                LocalStorageManager.shared.savePlanVisitsData(model: model.data ?? [])
                if model.data != nil {
                    completion(true)
                } else {
                    completion(false)
                }
            case .failure(let error):
                print("DEBUG: switch failure with error: \(error)")
            }
        }
    }
    
    // MARK: - get Plan Ows Data
    func getPlanOwsData(completion: @escaping (Bool) -> Void) {
        
        guard let user = LocalStorageManager.shared.getLoggedUser() else {
            completion(false)
            return
        }
        let baseURL = LocalStorageManager.shared.getAPIPath() ?? ""
        let url = baseURL + URLs.planOwsURL
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(user.access_token ?? "")",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "lang": "ar",
            "device-id": AppInfo.shared.deviceID,
            "timezone": "Africa/Cairo"
        ]
        
        loadingBehavior.accept(true)
        
        NetworkLayer.shared.fetchData(
            method: .get,
            url: url,
            parameters: [:],
            headers: headers
        ) { [weak self] (result: Result<PlanOwsDataModel>) in
            guard let self = self else { return }
            self.loadingBehavior.accept(false)
            switch result {
            case .success(let model):
                // Save  Plan Ows Data locally
                LocalStorageManager.shared.savePlanOwsData(model: model.data ?? [])
                if model.data != nil {
                    completion(true)
                } else {
                    completion(false)
                }
            case .failure(let error):
                print("Error fetching doctors: \(error)")
                completion(false)
            }
        }
    }
    
    // MARK: - get app presentations
    func getAppPresentations(completion: @escaping (Bool) -> Void) {
        
        guard let user = LocalStorageManager.shared.getLoggedUser() else {
            completion(false)
            return
        }
        let baseURL = LocalStorageManager.shared.getAPIPath() ?? ""
        let url = baseURL + URLs.appPresentationsURL
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(user.access_token ?? "")",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "lang": "ar",
            "device-id": AppInfo.shared.deviceID,
            "timezone": "Africa/Cairo"
        ]
        
        loadingBehavior.accept(true)
        
        NetworkLayer.shared.fetchData(
            method: .get,
            url: url,
            parameters: [:],
            headers: headers
        ) { [weak self] (result: Result<AppPresentationsModel>) in
            guard let self = self else { return }
            self.loadingBehavior.accept(false)
            switch result {
            case .success(let model):
                // Save  Plan Ows Data locally
                LocalStorageManager.shared.saveAppPresentationsModel(model: model)
                if model.data != nil {
                    completion(true)
                } else {
                    completion(false)
                }
            case .failure(let error):
                print("Error fetching doctors: \(error)")
                completion(false)
                
            }
        }
    }
}

