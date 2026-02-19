//
//  Validation.swift
//  Puplo Pro
//
//  Created by Ahmed on 28/12/2025.
//


import Foundation
import UIKit
enum Period {
   case firstTap
   case secondTap
   case thirdTap
   case fourthTap
}
extension UIViewController {
//    func validate(tab: TabIndex) -> NavigationResult {
//
//        let visitItems = LocalStorageManager.shared.getVisitItemData() ?? []
//        let gifts = LocalStorageManager.shared.getGiftsData() ?? []
//        let products = LocalStorageManager.shared.getProductsData() ?? []
//
//        switch tab {
//
//        case .first:
//            return visitItems.contains(where: { $0.isValid })
//            ? .allowed
//            : .blocked(message: "Visit section incomplete.")
//
//        case .second:
//            return hasValidSelection(gifts)
//            ? .allowed
//            : .blocked(message: "Gifts section incomplete.")
//
//        case .third:
//            return products.contains(where: { $0.isValid })
//            ? .allowed
//            : .blocked(message: "Products section incomplete.")

//        case .fourth:
//            return .allowed
//        }
//    }
    func validate(tab: TabIndex) -> NavigationResult {

        let visitItems = LocalStorageManager.shared.getVisitItemData() ?? []

        switch tab {

        case .first:
            return visitItems.contains(where: { $0.isValid })
            ? .allowed
            : .blocked(message: "Visit section incomplete.")

        case .second:
            return .allowed   // ✅ validation removed

        case .third:
            return .allowed   // ✅ validation removed

        case .fourth:
            return .allowed
        }
    }

    // ✅ Generic validation
    func hasValidSelection<T: SelectableItem>(_ items: [T]) -> Bool {
        items.contains { $0.idValue != "" }
    }
     func periodToTabIndex(_ period: Period) -> TabIndex {
        switch period {
        case .firstTap: return .first
        case .secondTap: return .second
        case .thirdTap: return .third
        case .fourthTap: return .fourth
        }
    }
}
