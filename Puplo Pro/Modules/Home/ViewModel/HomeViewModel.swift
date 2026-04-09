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
    let isUnplannedEnabled = BehaviorRelay<Bool>(value: true)
    
    // Visibility states (kept private)
    private let isCollectionViewHidden = BehaviorRelay<Bool>(value: false)
    private let isTableViewHidden = BehaviorRelay<Bool>(value: false)
    
    private let homeModelSubject = BehaviorRelay<[HomeModel]>(value: [])
    var homeModelObservable: Observable<[HomeModel]> { homeModelSubject.asObservable() }
    
    var newVersionAvailable: Bool?
    var appStoreVersion: String?
    
    // MARK: - Fetch Data
    func fetchData() {
        loadingBehavior.accept(true)
        DispatchQueue.global(qos: .userInitiated).async {
            let schedulData: [(dayName: String, imageName: String,vc: UIViewController.Type?)] = [
                ("Planning visits", "Planning",PlanningVisitsVC.self),
                ("Planned Visits", "Planned",PlannedVisitsVC.self),
                ("Unplanned Visit", "Unplanned",UnPlannedVisitVC.self),
                ("OW & Activities", "OW",OWActivitiesVC.self),
                ("My Location", "Location",MapVC.self),
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
    func canOpenUnplanned() -> Bool {
        
        guard let lines = LocalStorageManager.shared
            .getMasterData()?
            .Data?
            .lines,
              let limitString = lines.first?.unplanned_limit,
              let limit = Int(limitString) else {
            print("⚠️ limit not found")
            return true
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())
        
        print("📅 Today: \(todayString)")
        print("🎯 Limit: \(limit)")
        
        let allVisits = LocalStorageManager.shared.getActualVisitData() ?? []
        
        print("📦 All Visits Count: \(allVisits.count)")
        
        allVisits.forEach {
            print("Visit date: \($0.visit_date ?? "nil")")
        }
        
        let visitsCountToday = allVisits
            .filter { $0.visit_date == todayString }
            .count
        
        print("🔥 Visits Today: \(visitsCountToday)")
        
        let canOpen = visitsCountToday < limit
        print("✅ Can Open: \(canOpen)")
        
        return canOpen
    }
    
    // MARK: - check App Store
    func checkAppStore(callback: ((_ versionAvailable: Bool?, _ version: String?)->Void)? = nil) {
        let ourBundleId = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
        let url = "https://itunes.apple.com/lookup?bundleId=\(ourBundleId)&timestamp=\(Date().timeIntervalSince1970)"
        AF.request(url).responseJSON { response in
            var isNew: Bool?
            var versionStr: String?
            switch response.result {
            case .success(let value):
                if let json = value as? NSDictionary,
                   let results = json["results"] as? NSArray,
                   let entry = results.firstObject as? NSDictionary,
                   let appVersion = entry["version"] as? String,
                   let ourVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    
                    isNew = self.isVersion(appVersion, greaterThan: ourVersion)
                    versionStr = appVersion
                    print("ourVersion >>\(ourVersion)")
                    print("appVersion >>\(appVersion)")
                }
            case .failure(let error):
                print("Error: \(error)")
            }
            
            self.appStoreVersion = versionStr
            self.newVersionAvailable = isNew
            callback?(isNew, versionStr)
        }
    }
    private func isVersion(_ v1: String, greaterThan v2: String) -> Bool {
        let v1Components = v1.split(separator: ".").map { Int($0) ?? 0 }
        let v2Components = v2.split(separator: ".").map { Int($0) ?? 0 }
        let maxCount = max(v1Components.count, v2Components.count)

        for i in 0..<maxCount {
            let v1Part = i < v1Components.count ? v1Components[i] : 0
            let v2Part = i < v2Components.count ? v2Components[i] : 0

            if v1Part > v2Part { return true }
            if v1Part < v2Part { return false }
        }

        return false
    }
}

