//
//  NewPlanViewModel.swift
//  Gemstone Pro
//
//  Created by Ahmed on 05/01/2026.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
final class NewPlanViewModel {
    
    // MARK: - Outputs
    var newPlanModelObservable: Observable<[SaveNewPlanModel]> {
        newPlanRelay.asObservable()
    }
    
    // MARK: - Private
    private let newPlanRelay = BehaviorRelay<[SaveNewPlanModel]>(value: [])
    
    // MARK: - Public
    func loadProducts() {
        let items = RealmStorageManager.shared.getNewPlanData() ?? []
        self.newPlanRelay.accept(items)
    }
}
