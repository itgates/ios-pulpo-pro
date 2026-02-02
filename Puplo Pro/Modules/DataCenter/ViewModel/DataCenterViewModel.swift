//
//  DataCenterViewModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 24/11/2025.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import Alamofire
class DataCenterViewModel {
    
    // MARK: - Properties
    let loadingBehavior = BehaviorRelay<Bool>(value: false)
    // Visibility states (kept private)
    private let isCollectionViewHidden = BehaviorRelay<Bool>(value: false)
    
    private let dataCenterModelSubject = BehaviorRelay<[HomeModel]>(value: [])
    var dataCenterModelObservable: Observable<[HomeModel]> {
        dataCenterModelSubject.asObservable()
    }
    
    // MARK: - Fetch Data
    func fetchData() {
        
        let reportsData: [(name: String, imageName: String, vc: UIViewController.Type?)] = [
            ("GET ALL DATA", "ALLDATA", nil),
            ("GET MASTER DATA", "MASTERDATA", nil),
            ("GET ACCOUNTS DATA", "ACCOUNTSDATA", nil),
            ("GET PLANNED VISITS DATA", "Paln", nil),
//            ("GET PLANNED OW DATA", "PLANNEDOW", nil),
            ("GET PRESENTATIONS DATA", "PRESENTATIONS", nil)
        ]

        let items: [HomeModel] = reportsData.compactMap { data in
            guard let image = UIImage(named: data.imageName) else { return nil }
            return HomeModel(name: data.name, image: image, vc: data.vc)
        }
        
        dataCenterModelSubject.accept(items)
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
            print("DEBUG: entered fetchData completion for getMasterData")
            self.loadingBehavior.accept(false)
            print("DEBUG: about to switch on result")
            switch result {
            case .success(let model):
                print("DEBUG: switch success with model: \(model)")
                // Save master data locally
                LocalStorageManager.shared.saveMasterData(model: model)
                if model.Data != nil {
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
        let user = LocalStorageManager.shared.getLoggedUser()
        let baseURL = LocalStorageManager.shared.getAPIPath() ?? ""
        let url = "\(baseURL + URLs.accountsDoctorsURL)&lineId=\(user?.lineIds ?? "")&divId=\(user?.divIds ?? "")"
        
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
    //(empty data please check the data entry)
    func getPlanVisitsData(completion: @escaping (Bool) -> Void) {
        
        let user = LocalStorageManager.shared.getLoggedUser()
        let now = Date()
        let baseURL = LocalStorageManager.shared.getAPIPath() ?? ""
        let url = "\(baseURL + URLs.planVisitsURL)&today=\(now.formattedDate)&userId=\(user?.user_id ?? "")"
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

