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
    var productsModelObservable: Observable<[IdNameModel]> {
        productsRelay.asObservable()
    }
    
    // MARK: - Private
    private let productsRelay = BehaviorRelay<[IdNameModel]>(value: [])
    let masterData = AppDataProvider.shared.masterData
    // MARK: - Public
    func loadProducts() {
        let items = masterData?.Data?.products ?? []
        self.productsRelay.accept(items)
    }
}
