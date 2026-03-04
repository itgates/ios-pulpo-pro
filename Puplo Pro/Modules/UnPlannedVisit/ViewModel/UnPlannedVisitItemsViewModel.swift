

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
    //    case feedback
    //    case market
    //    case followUp
}
final class UnPlannedVisitItemsViewModel {
    
    // MARK: - Properties
    let products = BehaviorRelay<[ProductItem]>(value: [])
    let showWarning = PublishRelay<String>()
    
    // MARK: - Init
    init() {
        if let savedProducts = LocalStorageManager.shared.getProductsData() {
            
            print("savedProducts>>>\(savedProducts)")
            products.accept(savedProducts)
        }
    }
    
    // MARK: - Products
    //    func addProducts() {
    //        var list = products.value
    //        list.append(
    //            ProductItem(
    //                product: nil,
    //                feedback: nil,
    //                market: nil,
    //                followUp: nil,
    //                count: "1",
    //                comment: nil,
    //                payment: nil,
    //                stock: nil,
    //                order: nil
    //            )
    //        )
    //        products.accept(list)
    //        LocalStorageManager.shared.saveProductsData(list)
    //    }
    // MARK: - Products
    func addProducts() {
        var list = products.value
        
        let requiredCount = Int(
            LocalStorageManager.shared
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
                        comment: nil,
                        payment: nil,
                        stock: nil,
                        order: nil
                    )
                )
            }
            products.accept(list)
            LocalStorageManager.shared.saveProductsData(list)
            return
        }
        
        if requiredCount > 0, currentCount == requiredCount {
            guard let last = list.last else { return }
            if !isProductCompleted(last) {
                showWarning.accept("Please complete the last product first.")
                return
            }
        }
        
        if !list.isEmpty {
            guard let last = list.last else { return }
            
            if last.product == nil {
                list.removeLast()
                products.accept(list)
                LocalStorageManager.shared.saveProductsData(list)
                return
            }
            
            if !isProductCompleted(last) {
                showWarning.accept("Please complete the last product first.")
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
                comment: nil,
                payment: nil,
                stock: nil,
                order: nil
            )
        )
        products.accept(list)
        LocalStorageManager.shared.saveProductsData(list)
    }
    // MARK: - Helpers
    private func isProductCompleted(_ item: ProductItem) -> Bool {
        return item.product != nil &&
        !(item.count.isEmpty) &&
        !(item.feedback?.isEmpty ?? true) &&
        !(item.market?.isEmpty ?? true) &&
        !(item.followUp?.isEmpty ?? true)
    }
    
    func deleteProducts(at index: Int) {
        var list = products.value
        guard index < list.count else { return }
        list.remove(at: index)
        products.accept(list)
        LocalStorageManager.shared.saveProductsData(list)
    }
    
    func updateProductsCount(at index: Int, count: String) {
        var list = products.value
        guard index < list.count else { return }
        list[index].count = count
        products.accept(list)
        LocalStorageManager.shared.saveProductsData(list)
    }
    
    func updateSelection(
        at index: Int,
        item: IdNameModel,
        type: ProductSelectionType
    ) -> String? {
        var list = products.value
        guard index < list.count else { return nil }
        
        let isDuplicate = list.enumerated().contains { (offset, element) in
            guard offset != index else { return false }
            switch type {
            case .product: return element.product?.id == item.id
                //            case .feedback: return element.feedback?.id == item.id
                //            case .market: return element.market?.id == item.id
                //            case .followUp: return element.followUp?.id == item.id
            }
        }
        
        if isDuplicate {
            return "Warning: This item is already selected in another row"
        }
        switch type {
        case .product: list[index].product = item
            //        case .feedback: list[index].feedback = item
            //        case .market: list[index].market = item
            //        case .followUp: list[index].followUp = item
        }
        
        products.accept(list)
        LocalStorageManager.shared.saveProductsData(list)
        return nil
    }
    
    func updatePresentations(at index: Int, presentation: [Presentations]) {
        var list = products.value
        guard index < list.count else { return }
        
        list[index].presentations = presentation.isEmpty ? [] : presentation
        
        print("list >>\(list)")
        products.accept(list)
        LocalStorageManager.shared.saveProductsData(list)
    }
    
    // MARK: - TextFields Handling
    func updateComment(at index: Int, text: String?) {
        var list = products.value
        guard index < list.count else { return }
        list[index].comment = text
        products.accept(list)
        LocalStorageManager.shared.saveProductsData(list)
    }
    func updateFeedBack(at index: Int, text: String?) {
        var list = products.value
        guard index < list.count else { return }
        list[index].feedback = text
        products.accept(list)
        LocalStorageManager.shared.saveProductsData(list)
    }
    func updateMarket(at index: Int, text: String?) {
        var list = products.value
        guard index < list.count else { return }
        list[index].market = text
        products.accept(list)
        LocalStorageManager.shared.saveProductsData(list)
    }
    func updateFollowUps(at index: Int, text: String?) {
        var list = products.value
        guard index < list.count else { return }
        list[index].followUp = text
        products.accept(list)
        LocalStorageManager.shared.saveProductsData(list)
    }
    
    func updatePayment(at index: Int, text: String?) {
        var list = products.value
        guard index < list.count else { return }
        list[index].payment = text
        products.accept(list)
        LocalStorageManager.shared.saveProductsData(list)
    }
    
    func updateStock(at index: Int, text: String?) {
        var list = products.value
        guard index < list.count else { return }
        list[index].stock = text
        products.accept(list)
        LocalStorageManager.shared.saveProductsData(list)
    }
    func updateOrder(at index: Int, text: String?) {
        var list = products.value
        guard index < list.count else { return }
        list[index].order = text
        products.accept(list)
        LocalStorageManager.shared.saveProductsData(list)
    }
    
}
