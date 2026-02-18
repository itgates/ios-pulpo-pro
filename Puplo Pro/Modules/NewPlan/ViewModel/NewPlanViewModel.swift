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
    let loadingBehavior = BehaviorRelay<Bool>(value: false)
    var newPlanModelObservable: Observable<[SaveNewPlanModel]> {
        newPlanRelay.asObservable()
    }

    // MARK: - Private
    private let newPlanRelay = BehaviorRelay<[SaveNewPlanModel]>(value: [])

    // MARK: - Public
    func loadProducts() {
        loadingBehavior.accept(true)
        DispatchQueue.global(qos: .userInitiated).async {
            let items = LocalStorageManager.shared.getNewPlanData() ?? []
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.newPlanRelay.accept(items)
                self.loadingBehavior.accept(false)
            }
        }
    }
}
