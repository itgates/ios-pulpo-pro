//
//  DataCenterViewModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 12/02/2026.
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
                LocalStorageManager.shared.saveAccountsDoctors(model)
                if model.Data != nil {
                    completion(true)
                } else {
                    completion(false)
                }
                print("DEBUG: switch success with model: \(model)")
            case .failure(let error):
                print("Error fetching doctors: \(error)")
                completion(false)
            }
        }
    }
    
    // MARK: - get Planned Visits
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
                LocalStorageManager.shared.savePlanVisits(model)
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
