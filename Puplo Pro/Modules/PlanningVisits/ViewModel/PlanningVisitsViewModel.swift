//
//  PlanningVisitsViewModel.swift
//  Gemstone Pro
//
//  Created by Ahmed on 25/11/2025.
//
import Foundation
import RxSwift
import RxCocoa
// MARK: - Enums & Filter
struct SelectFilter {
    var division: IdNameModel?
    var brick: IdNameModel?
    var accountType: IdNameModel?
    var classType: IdNameModel?
}
// MARK: - Enums & Models
enum SelectionFilterType {
    case division
    case brick
    case accountType
    case classes
}

final class PlanningVisitsViewModel {
    
    enum AccountType {
        case am, pm, other
    }
    
    private let allDoctorsRelay = BehaviorRelay<[PlanningVisitsData]>(value: [])
    private let doctorsRelay = BehaviorRelay<[PlanningVisitsData]>(value: [])
    
    var doctorsObservable: Observable<[PlanningVisitsData]> {
        doctorsRelay.asObservable()
    }
    
    func loadDoctors(for type: AccountType) {
        
        let data: [PlanningVisitsData]
        switch type {
        case .am:
            data = RealmStorageManager.shared.getAccountsDoctorsAM() ?? []
        case .pm:
            data = RealmStorageManager.shared.getAccountsDoctorsPM() ?? []
        case .other:
            data = RealmStorageManager.shared.getAccountsDoctorsOther() ?? []
        }
        print("data.count >>\(data.count)")
        self.allDoctorsRelay.accept(data)
        self.doctorsRelay.accept(data)
   }

   func applyFilter(_ filter: SelectFilter) {
    let filtered = allDoctorsRelay.value.filter {
        self.matchesFilter($0, filter: filter)
    }
    doctorsRelay.accept(filtered)
   }

   func clearFilter() {
    doctorsRelay.accept(allDoctorsRelay.value)
   }

   private func matchesFilter(
    _ account: PlanningVisitsData,
    filter: SelectFilter
   ) -> Bool {
    
    if let id = filter.division?.id, account.div_id != id { return false }
    if let id = filter.brick?.id, account.brick_id ?? "" != id { return false }
    if let id = filter.accountType?.id, account.type_id != id { return false }
    if let id = filter.classType?.id, account.class_id != id { return false }
    
    return true
  }
}
