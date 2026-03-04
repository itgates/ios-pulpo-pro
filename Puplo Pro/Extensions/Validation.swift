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
  
    func validate(tab: TabIndex) -> NavigationResult {
        
        let visitItems = LocalStorageManager.shared.getVisitItemData() ?? []
        let managers = LocalStorageManager.shared.getManagerData()
        let products = LocalStorageManager.shared.getProductsData() ?? []

        switch tab {
            
        case .first:
            guard let firstVisit = visitItems.first else {
                return .blocked(message: "Visit section incomplete.")
            }
            guard firstVisit.isValid else {
                return .blocked(message: "Visit section incomplete.")
            }
            if firstVisit.visitType?.name == "Double" && managers?.count ?? 0 < 1 {
                return .blocked(message: "Please select a Manager for Double visit.")
            }
            return .allowed
            
        case .second:
            return .allowed
            
        case .third:
            if products.contains(where: { !$0.isValid }) {
                return .blocked(message: "Please complete all products before proceeding.")
            }
            return .allowed
            
        case .fourth:
            for tab in [TabIndex.first, .second, .third] {
                if case .blocked(let msg) = validate(tab: tab) {
                    showAlert(alertTitle: "Incomplete Data", alertMessage: msg)
                    return .blocked(message: msg)
                }
            }
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
