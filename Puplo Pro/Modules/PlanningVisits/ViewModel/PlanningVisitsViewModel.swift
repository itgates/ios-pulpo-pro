//
//  PlanningVisitsViewModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 25/11/2025.
//
import Foundation
import RxSwift
import RxCocoa

final class PlanningVisitsViewModel {

    enum AccountType {
        case am, pm, other
    }

    let loadingBehavior = BehaviorRelay<Bool>(value: false)

    private let allDoctorsRelay = BehaviorRelay<[PlanningVisitsData]>(value: [])
    private let doctorsRelay = BehaviorRelay<[PlanningVisitsData]>(value: [])

    var doctorsObservable: Observable<[PlanningVisitsData]> {
        doctorsRelay.asObservable()
    }

    func loadDoctors(for type: AccountType) {
        loadingBehavior.accept(true)

        DispatchQueue.global(qos: .userInitiated).async {

            let data: [PlanningVisitsData]
            switch type {
            case .am:
                data = LocalStorageManager.shared.getAccountsDoctorsAM() ?? []
            case .pm:
                data = LocalStorageManager.shared.getAccountsDoctorsPM() ?? []
            case .other:
                data = LocalStorageManager.shared.getAccountsDoctorsOther() ?? []
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.allDoctorsRelay.accept(data)
                self.doctorsRelay.accept(data)
                self.loadingBehavior.accept(false)
            }
        }
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
        if let id = filter.brick?.id, Int(account.brick_id ?? "") != id { return false }
        if let id = filter.accountType?.id, account.type_id != id { return false }
        if let id = filter.classType?.id, account.class_id != id { return false }

        return true
    }
}
