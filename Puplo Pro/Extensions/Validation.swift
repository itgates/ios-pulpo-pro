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
            
            if let message = validateVisitItem(firstVisit) {
                return .blocked(message: message)
            }
            
            if firstVisit.visitType?.name == "Double",
               (managers?.count ?? 0) < 1 {
                return .blocked(message: "Please select a Manager for Double visit.")
            }
            return .allowed
        case .second:
            return .allowed
        case .third:
            
            // ✅ check if no products at all (optional حسب business)
            if products.isEmpty {
                return .blocked(message: "Please add at least one product.")
            }
            
            // ✅ get first validation error dynamically
            if let error = products.compactMap({ $0.validationError() }).first {
                return .blocked(message: error)
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
    private func validateVisitItem(_ item: VisitItem) -> String? {
        
        
        let masterData = LocalStorageManager.shared.getMasterData()
        let isShiftEnabled =
            masterData?
                .Data?
                .settings?
                .first(where: { $0.attribute_name == "add_shift" })?
                .attribute_value == "1"
        
        if !item.division.isSelected {
            return "Please select division"
        }
        
        if !item.brick.isSelected {
            return "Please select brick"
        }
        
        if !item.accountType.isSelected {
            return "Please select account type"
        }
        
        if !item.account.isSelected {
            return "Please select account"
        }
        
        if !item.doctor.isSelected {
            return "Please select doctor"
        }
        
        if !item.visitType.isSelected {
            return "Please select visit type"
        }
        // ✅ أهم سطر
        if isShiftEnabled && !item.shiftType.isSelected {
            return "Please select shift type"
        }
        return nil
    }
}
extension ProductItem {
    
    func validationError() -> String? {
        if !product.isSelected {
            return "Please select a product."
        }
        
        if !feedback.isSelected {
            return "Please select feedback."
        }
        
        if count.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Please enter count."
        }
        
        return nil
    }
    
    var isValid: Bool {
        return validationError() == nil
    }
}
