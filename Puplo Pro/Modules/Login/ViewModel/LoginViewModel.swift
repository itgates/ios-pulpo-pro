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
        
        let baseURL = LocalStorageManager.shared.getAPIPath() ?? ""
        let url = "\(baseURL + URLs.loginURL)&username=\(name)&password=\(password)"
        print("url >>\(url)")
        // MARK: - Headers
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "lang": "ar",
            "device-id": AppInfo.shared.deviceID,
            "timezone": "Africa/Cairo"
        ]
        print("headers >>\(headers)")
        loadingBehavior.accept(true)
        
        NetworkLayer.shared.fetchData(
            method: .post,
            url: url,
            parameters: [:],
            headers: headers
        ) { [weak self] (result: Result<LoginModel>) in
            guard let self = self else { return }
            self.loadingBehavior.accept(false)
            switch result {
            case .success(let model):
                
                if model.Status != 500 && model.Data?.count ?? 0 > 0 {
                    
                    LocalStorageManager.shared.clearUsers()
                    let now = Date()
                    let checkInDate = now.formattedDate
                    let checkInTime = now.formattedTime
                    
                    LocalStorageManager.shared.saveUser(
                        model: model,
                        checkInDate: checkInDate,
                        checkInTime: checkInTime,
                        companyName: companyName)
                    print("model >>\(model)")
                    completion(true)
                } else {
                    completion(false)
                }
            case .failure(let error):
                print("error >>\(error)")
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
        getPlannedVisits { success in
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
        let now = Date()
        
        let url = "\(baseURL + URLs.masterDataURL)&today=\(now.formattedDate)&userId=\(user?.user_id ?? "")&lineId=\(user?.lineIds ?? "")&divId=\(user?.divIds ?? "")"
        print("url >>\(url)")
        
        // MARK: - Headers
        let headers: HTTPHeaders = [
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
            self.loadingBehavior.accept(false)
            switch result {
            case .success(let model):
                // Save master data locally
                LocalStorageManager.shared.saveMasterData(model)
                if model.Data != nil {
                    completion(true)
                } else {
                    completion(false)
                }
                print("DEBUG: switch success with model: \(model)")
            case .failure(let error):
                print("DEBUG: switch failure with error: \(error)")
            }
        }
    }
    // MARK: - get Accounts Doctors
    func getAccountsDoctors(completion: @escaping (Bool) -> Void) {
        
        // MARK: - Validate Required Data
        guard let user = LocalStorageManager.shared.getLoggedUser(),
              let baseURL = LocalStorageManager.shared.getAPIPath() else {
            completion(false)
            return }
        
        let url = "\(baseURL + URLs.accountsDoctorsURL)&lineId=\(user.lineIds ?? "")&divId=\(user.divIds ?? "")"
        
        let headers: HTTPHeaders = [
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
                
                guard let data = model.Data else {
                    completion(false)
                    return
                }
                LocalStorageManager.shared.saveAccountsDoctors(model)
                
                var amDoctors: [PlanningVisitsData] = []
                var pmDoctors: [PlanningVisitsData] = []
                var otherDoctors: [PlanningVisitsData] = []
                
                //  Optimization: Cache account types once
                let accountTypes = LocalStorageManager.shared
                    .getMasterData()?
                    .Data?
                    .account_types
                
                data.Doctors?.forEach { doctor in
                    
                    guard let doctorId = doctor.id else { return }
                    
                    let account = data.Accounts?.first { $0.id == doctor.d_account_id }
                    let hospitalName = account?.name ?? ""
                    
                    // Resolve Shift
                    var shift: AccountShift = .other
                    var resolvedAccountType: String? = nil
                    var accountTypeID: String? = nil
                    
                    if let tbl = account?.tbl,
                       let accountType = accountTypes?.first(where: { $0.tbl == tbl }) {
                        
                        resolvedAccountType = accountType.name
                        accountTypeID = accountType.id
                        
                        switch accountType.cat_id {
                        case "1":
                            shift = .pm
                        case "2":
                            shift = .am
                        default:
                            shift = .other
                        }
                    }
                    let item = PlanningVisitsData(
                        id: doctorId,
                        account_id: account?.id,
                        name: doctor.name ?? "",
                        hosptal: hospitalName,
                        shift: shift,
                        div_id: account?.t_div_id,
                        brick_id: account?.brick_id,
                        class_id: account?.t_class_id,
                        account_type: resolvedAccountType,
                        type_id: accountTypeID,
                        line_id: "",
                        lat: account?.team_ll,
                        lng: account?.team_lg
                    )
                    
                    switch shift {
                    case .am:
                        amDoctors.append(item)
                    case .pm:
                        pmDoctors.append(item)
                    case .other:
                        otherDoctors.append(item)
                    }
                }
                
                print("amDoctors >>> \(amDoctors.count)")
                print("pmDoctors >>> \(pmDoctors.count)")
                print("otherDoctors >>> \(otherDoctors.count)")
                LocalStorageManager.shared.saveAccountsDoctorsAM(amDoctors)
                LocalStorageManager.shared.saveAccountsDoctorsPM(pmDoctors)
                LocalStorageManager.shared.saveAccountsDoctorsOther(otherDoctors)
                
                completion(true)
                
            case .failure(let error):
                print("Error fetching doctors: \(error)")
                completion(false)
            }
        }
    }
    
    // MARK: - get Planned Visits
    //(empty data please check the data entry)
    func getPlannedVisits(completion: @escaping (Bool) -> Void) {
        
        let user = LocalStorageManager.shared.getLoggedUser()
        let now = Date()
        let baseURL = LocalStorageManager.shared.getAPIPath() ?? ""
        let url = "\(baseURL + URLs.plannedVisitsURL)&today=\(now.formattedDate)&userId=\(user?.user_id ?? "")"
        print("url >>\(url)")
        
        // MARK: - Headers
        let headers: HTTPHeaders = [
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
        ) { [weak self] (result: Result<PlannedVisitsModel>) in
            guard let self = self else { return }
            self.loadingBehavior.accept(false)
            switch result {
            case .success(let model):
                // Save  Plan Visits Data locally
                LocalStorageManager.shared.savePlannedVisitsData(model.Data ?? [])
                if model.Data != nil {
                    completion(true)
                } else {
                    completion(false)
                }
                print("DEBUG: switch success with PlannedVisits: \(model)")
            case .failure(let error):
                print("DEBUG: switch failure with error: \(error)")
            }
        }
    }
    
    // MARK: - get app presentations
    func getAppPresentations(completion: @escaping (Bool) -> Void) {
        
        let user = LocalStorageManager.shared.getLoggedUser()
        let baseURL = LocalStorageManager.shared.getAPIPath() ?? ""
        let url = "\(baseURL + URLs.appPresentationsURL)&teamId=\(user?.lineIds ?? "")"
        
        let headers: HTTPHeaders = [
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
                LocalStorageManager.shared.saveAppPresentationsModel(model)
                if model.Data != nil {
                    completion(true)
                } else {
                    completion(false)
                }
                print("DEBUG: switch success with Presentations: \(model)")
            case .failure(let error):
                print("Error fetching doctors: \(error)")
                completion(false)
                
            }
        }
    }
}

