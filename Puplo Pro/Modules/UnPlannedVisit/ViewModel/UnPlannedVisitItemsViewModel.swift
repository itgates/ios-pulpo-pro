

//
//  UnPlannedVisitItemsViewModel.swift
//  Gemstone Pro
//
//  Created by Ahmed on 18/12/2025.
//
import Foundation
import RxSwift
import RxCocoa
import UIKit

enum ProductSelectionType {
    case product
    case feedback
    //    case market
    //    case followUp
}
final class UnPlannedVisitItemsViewModel {
    
    // MARK: - Properties
    let products = BehaviorRelay<[ProductItem]>(value: [])
    let showWarning = PublishRelay<String>()
    
    var isAddEnabled: BehaviorRelay<Bool> = BehaviorRelay(value: false)
       
    // MARK: - Init
    init() {
        if let savedProducts = RealmStorageManager.shared.getProductsData() {
            products.accept(savedProducts)
        }
        checkAddEnabled()
    }
    func checkAddEnabled() {
        let visitItem = RealmStorageManager.shared.getVisitItemData()?.first
        let enabled = visitItem?.accountType?.id?.isEmpty == false
        isAddEnabled.accept(enabled)
    }
    
    // MARK: - Products
    func addProducts() {
        var list = products.value
        
        let requiredCount = Int(
            RealmStorageManager.shared
                .getMasterData()?
                .Data?
                .settings?
                .first(where: { $0.attribute_name == "no_of_products" })?
                .attribute_value ?? ""
        ) ?? 0
        
        let currentCount = list.count
        
        if requiredCount > 0, currentCount < requiredCount {
            let difference = requiredCount - currentCount
            for _ in 0..<difference {
                list.append(
                    ProductItem(
                        product: nil,
                        feedback: nil,
                        market: nil,
                        followUp: nil,
                        count: "1",
                        comment: nil
                    )
                )
            }
            products.accept(list)
            RealmStorageManager.shared.saveProductsData(list)
            return
        }
        
        if requiredCount > 0, currentCount == requiredCount {
            guard let last = list.last else { return }
            if let error = last.validationError() {
                showWarning.accept(error)
                return
            }
        }
        
        if !list.isEmpty {
            guard let last = list.last else { return }
            
            if last.product == nil {
                list.removeLast()
                products.accept(list)
                RealmStorageManager.shared.saveProductsData(list)
                return
            }
            if let error = last.validationError() {
                showWarning.accept(error)
                return
            }
        }
        
        list.append(
            ProductItem(
                product: nil,
                feedback: nil,
                market: nil,
                followUp: nil,
                count: "1",
                comment: nil
            )
        )
        products.accept(list)
        RealmStorageManager.shared.saveProductsData(list)
    }
    // MARK: - Helpers
    func deleteProducts(at index: Int) {
        var list = products.value
        guard index < list.count else { return }
        list.remove(at: index)
        products.accept(list)
        RealmStorageManager.shared.saveProductsData(list)
    }
    
    func updateProductsCount(at index: Int, count: String) {
        var list = products.value
        guard index < list.count else { return }
        list[index].count = count
        products.accept(list)
        RealmStorageManager.shared.saveProductsData(list)
    }

    func updateSelection(
        at index: Int,
        item: IdNameModel,
        type: ProductSelectionType
    ) -> String? {
        var list = products.value
        guard index < list.count else { return nil }
        
        // ✅ Apply duplicate check ONLY for product
        if type == .product {
            let isDuplicate = list.enumerated().contains { (offset, element) in
                guard offset != index else { return false }
                return element.product?.id == item.id
            }
            
            if isDuplicate {
                return "Warning: This product is already selected in another row"
            }
        }
        
        // 🔽 normal assignment
        switch type {
        case .product:
            list[index].product = item
            
        case .feedback:
            list[index].feedback = item
        }
        
        products.accept(list)
        RealmStorageManager.shared.saveProductsData(list)
        
        return nil
    }
    
    func updatePresentations(at index: Int, presentation: [Presentations]) {
        var list = products.value
        guard index < list.count else { return }
        
        list[index].presentations = presentation.isEmpty ? [] : presentation
        
        print("list >>\(list)")
        products.accept(list)
        RealmStorageManager.shared.saveProductsData(list)
    }
    
    // MARK: - TextFields Handling
    func updateComment(at index: Int, text: String?) {
        var list = products.value
        guard index < list.count else { return }
        list[index].comment = text
        products.accept(list)
        RealmStorageManager.shared.saveProductsData(list)
    }
    func updateMarket(at index: Int, text: String?) {
        var list = products.value
        guard index < list.count else { return }
        list[index].market = text
        products.accept(list)
        RealmStorageManager.shared.saveProductsData(list)
    }
    func updateFollowUps(at index: Int, text: String?) {
        var list = products.value
        guard index < list.count else { return }
        list[index].followUp = text
        products.accept(list)
        RealmStorageManager.shared.saveProductsData(list)
    }
}
