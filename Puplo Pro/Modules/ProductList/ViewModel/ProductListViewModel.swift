//
//  ProductListViewModel.swift
//  Gemstone Pro
//
//  Created by Ahmed on 05/01/2026.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
final class ProductListViewModel {

    // MARK: - Outputs
    let loadingBehavior = BehaviorRelay<Bool>(value: false)
    var productsModelObservable: Observable<[IdNameModel]> {
        productsRelay.asObservable()
    }

    // MARK: - Private
    private let productsRelay = BehaviorRelay<[IdNameModel]>(value: [])

    // MARK: - Public
    func loadProducts() {
        loadingBehavior.accept(true)
      //  DispatchQueue.global(qos: .userInitiated).async {
            let items = LocalStorageManager.shared.getMasterData()?.Data?.products ?? []
           // DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.productsRelay.accept(items)
                self.loadingBehavior.accept(false)
//            }
//        }
    }
}
