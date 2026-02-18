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
                ("Planned Visits", "Planned",nil),
                ("Unplanned Visit", "Unplanned",nil),
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
}
