//
//  UnPlannedVisitDetailsViewModel.swift
//  Gemstone Pro
//
//  Created by Ahmed on 18/12/2025.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
enum ItemSelectionType {
    case division
    case brick
    case accountType
    case account
    case doctor
    case visitType
    case shiftType
}
final class UnPlannedVisitDetailsViewModel {
    
    // MARK: - Properties
    let visitItems = BehaviorRelay<[VisitItem]>(value: [])
    let managers = BehaviorRelay<[IdNameModel]>(value: [])
    
    var shouldShowAddManager: Observable<Bool> {
        visitItems
            .map { items in
                items.contains { $0.visitType?.name == "Double" }
            }
            .distinctUntilChanged()
            .do(onNext: { [weak self] shouldShow in
                guard let self else { return }
                
                if !shouldShow {
                    self.managers.accept([])
                    RealmStorageManager.shared.saveManagerData([])
                }
            })
    }
    // MARK: - Computed Observables
    var allManagersSelected: Observable<Bool> {
        managers
            .map { currentManagers in
                guard let masterManagers = RealmStorageManager.shared.getMasterData()?.Data?.managers,
                      !masterManagers.isEmpty else {
                    return false
                }
                return currentManagers.count >= masterManagers.count
            }
    }
    
    // MARK: - Init
    init() {
        if let savedVisitItems = RealmStorageManager.shared.getVisitItemData() {
            visitItems.accept(savedVisitItems)
        }
        // Load saved managers
        if let savedManagers = RealmStorageManager.shared.getManagerData() {
            managers.accept(savedManagers)
        }
    }
    
    // MARK: - Fetch Data
    func fetchData() {
        var list = visitItems.value

        guard list.isEmpty else {
            visitItems.accept(list)
            return
        }
        let newItem = VisitItem(
            date: nil,
            time: nil,
            division: nil,
            brick: nil,
            accountType: nil,
            account: nil,
            doctor: nil,
            visitType: nil,
            shiftType: nil,
            comment: nil
        )

        list.append(newItem)
        visitItems.accept(list)
    }

    func updateSelection(
        at index: Int,
        item: IdNameModel,
        type: ItemSelectionType
    ) -> String? {
        var list = visitItems.value
        guard index < list.count else { return nil }
        
        let isDuplicate = list.enumerated().contains { (offset, element) in
            guard offset != index else { return false }
            switch type {
            case .division: return element.division?.id == item.id
            case .brick: return element.brick?.id == item.id
            case .accountType: return element.accountType?.id == item.id
            case .account: return element.account?.id == item.id
            case .doctor: return element.doctor?.id == item.id
            case .visitType: return element.visitType?.id == item.id
            case .shiftType: return element.shiftType?.id == item.id
            }
        }
        
        if isDuplicate {
            return "Warning: This item is already selected in another row"
        }
        switch type {
        case .division: list[index].division = item
        case .brick: list[index].brick = item
        case .accountType: list[index].accountType = item
        case .account: list[index].account = item
        case .doctor: list[index].doctor = item
        case .visitType: list[index].visitType = item
        case .shiftType: list[index].shiftType = item
        }
        
        visitItems.accept(list)
        RealmStorageManager.shared.saveVisitItemData(list)
        return nil
    }
    func updateComment(at index: Int, text: String?) {
        var list = visitItems.value
        guard index < list.count else { return }
        list[index].comment = text
        visitItems.accept(list)
        RealmStorageManager.shared.saveVisitItemData(list)
    }
    
    // MARK: - Managers
    func addManager() -> String? {
        var list = managers.value
        
        if list.contains(where: { $0.name?.isEmpty ?? true }) {
            return "Please select the current manager first"
        }
        
        let lastIdInt = Int(list.last?.id ?? "0") ?? 0
        let newId = String(lastIdInt + 1)
        
        let newManager = IdNameModel(id: newId, name: "")
        list.append(newManager)
        
        managers.accept(list)
        RealmStorageManager.shared.saveManagerData(list)
        
        return nil
    }

    
    func deleteManager(at index: Int) {
        var list = managers.value
        guard index < list.count else { return }
        list.remove(at: index)
        managers.accept(list)
        RealmStorageManager.shared.saveManagerData(list)
    }
}
