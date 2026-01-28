//
//  ReportsViewModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 24/11/2025.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import Alamofire
class ReportsViewModel {
    
    // MARK: - Properties
   
    // Visibility states (kept private)
    private let isCollectionViewHidden = BehaviorRelay<Bool>(value: false)
    
    private let reportsModelSubject = BehaviorRelay<[HomeModel]>(value: [])
    var reportsModelObservable: Observable<[HomeModel]> {
        reportsModelSubject.asObservable()
    }
    
    // MARK: - Fetch Data
    func fetchData() {
        
        let reportsData: [(name: String, imageName: String, vc: UIViewController.Type?)] = [
            ("Statistics", "Statistics", StatisticsVC.self),
            ("Product", "Product", ProductListVC.self),
            ("Account", "Account", AccountsListVC.self),
            ("Actual Visit", "Visit", ActualVisitVC.self),
            ("Planned Visit", "Paln", PlannedVisitListVC.self),
            ("New Plan", "newPlan", NewPlanVC.self),
            ("Plan Approval", "PlanApproval", nil),
            //("Database tables", "databaseTable", nil)
        ]

        let items: [HomeModel] = reportsData.compactMap { data in
            guard let image = UIImage(named: data.imageName) else { return nil }
            return HomeModel(name: data.name, image: image,vc: data.vc)
        }
        reportsModelSubject.accept(items)
    }
    
   
}
