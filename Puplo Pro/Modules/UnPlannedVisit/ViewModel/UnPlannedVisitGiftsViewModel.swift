//
//  UnPlannedVisitGiftsViewModel.swift
//  Gemstone Pro
//
//  Created by Ahmed on 18/12/2025.
//
import Foundation
import RxSwift
import RxCocoa
import UIKit

final class UnPlannedVisitGiftsViewModel {
    
    // MARK: - Properties
    let gifts = BehaviorRelay<[IdNameModel]>(value: [])
    
    // MARK: - Computed Observables
    var allGiftsSelected: Observable<Bool> {
        gifts
            .map { currentGifts in
                guard let masterGifts = RealmStorageManager.shared.getMasterData()?.Data?.giveaways,
                      !masterGifts.isEmpty else {
                    return false
                }
                return currentGifts.count >= masterGifts.count
            }
       }
    // MARK: - Init
    init() {
        // Load saved gifts
        if let savedGifts = RealmStorageManager.shared.getGiftsData() {
            gifts.accept(savedGifts)
        }
    }
    
    // MARK: - Gifts
    func addGift(name: String, count: String = "1") {
        var list = gifts.value

        let newGift = IdNameModel(
            id: "",
            name: name,
            count: count
        )
        list.append(newGift)
        gifts.accept(list)
        RealmStorageManager.shared.saveGiftsData(list)
    }

    func deleteGift(at index: Int) {
        var list = gifts.value
        guard index < list.count else { return }
        list.remove(at: index)
        gifts.accept(list)
        RealmStorageManager.shared.saveGiftsData(list)
    }
    
    func updateGiftCount(at index: Int, count: String) {
        var list = gifts.value
        guard index < list.count else { return }
        var item = list[index]
        item.count = count
        list[index] = item
        gifts.accept(list)
        RealmStorageManager.shared.saveGiftsData(list)
    }
    
    func validateGiveaways() -> String? {
        
        print("🔍 Start validateGiveaways()")
        
        let settings = RealmStorageManager.shared
            .getMasterData()?
            .Data?
            .settings
        
        guard
            let requiredValue = settings?
                .first(where: { $0.attribute_name == "no_of_giveaways" })?
                .attribute_value,
            let requiredCount = Int(requiredValue)
        else {
            print("ℹ️ no_of_giveaways setting not found")
            return nil
        }
        
        print("📌 Required Giveaways:", requiredCount)
        
        let currentGifts = gifts.value
        print("📦 Current Gifts Count:", currentGifts.count)
        print("📦 Current Gifts:", currentGifts)
        
        if currentGifts.count < requiredCount {
            print("❌ Not enough giveaways")
            return "You must add \(requiredCount) giveaways"
        }
        
        if currentGifts.count == requiredCount {
            if let last = currentGifts.last {
                print("🧾 Last Gift -> id:", last.id ?? "nil", "name:", last.name ?? "nil")
                
                if last.id == nil || last.name == "Select Giveaway" {
                    print("❌ Last giveaway not selected")
                    return "Please select the last giveaway"
                }
            }
        }
        
        print("✅ Giveaways validation passed")
        return nil
    }
}
