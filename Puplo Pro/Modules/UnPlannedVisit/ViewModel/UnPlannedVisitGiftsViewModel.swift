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
                guard let masterGifts = LocalStorageManager.shared.getMasterData()?.Data?.giveaways,
                      !masterGifts.isEmpty else {
                    return false
                }
                return currentGifts.count >= masterGifts.count
            }
       }
    // MARK: - Init
    init() {
        // Load saved gifts
        if let savedGifts = LocalStorageManager.shared.getGiftsData() {
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
        LocalStorageManager.shared.saveGiftsData(list)
    }

    func deleteGift(at index: Int) {
        var list = gifts.value
        guard index < list.count else { return }
        list.remove(at: index)
        gifts.accept(list)
        LocalStorageManager.shared.saveGiftsData(list)
    }
    
    func updateGiftCount(at index: Int, count: String) {
        var list = gifts.value
        guard index < list.count else { return }
        var item = list[index]
        item.count = count
        list[index] = item
        gifts.accept(list)
        LocalStorageManager.shared.saveGiftsData(list)
    }
}
