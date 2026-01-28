//
//  PlannedVisitsViewModel.swift
//  Puplo Pro
//

import Foundation
import RxSwift
import RxCocoa

final class PlannedVisitsViewModel {

    // MARK: - Item Type
    enum PlannedVisitItem {
        case visit(PlanVisitsData)
        case office(PlanOwsData)
    }

    // MARK: - Account Type
    enum AccountType {
        case am, pm, other, officeWork

        var shiftId: Int {
            switch self {
            case .am: return 1
            case .pm: return 2
            case .other: return 3
            case .officeWork: return 4
            }
        }
    }

    // MARK: - Outputs
    let loadingBehavior = BehaviorRelay<Bool>(value: false)

    var itemsObservable: Observable<[PlannedVisitItem]> {
        itemsRelay.asObservable()
    }

    // MARK: - Private Properties
    private let itemsRelay = BehaviorRelay<[PlannedVisitItem]>(value: [])

    private let planVisits: [PlanVisitsData]
    private let planOws: [PlanOwsData]

    private(set) var allPlanOws: [PlanOwsData] = []

    // MARK: - Init
    init() {
        let today = Self.dateFormatter.string(from: Date())

        self.planVisits = (LocalStorageManager.shared.getPlanVisitsData() ?? [])
            .filter {
                $0.date?.trimmingCharacters(in: .whitespacesAndNewlines) == today
            }

        self.planOws = (LocalStorageManager.shared.getPlanOwsData() ?? [])
            .filter {
                $0.date?.trimmingCharacters(in: .whitespacesAndNewlines) == today
            }
    }


    // MARK: - Load Data
    func loadAccount(for type: AccountType) {
        loadingBehavior.accept(true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self else { return }

            let items: [PlannedVisitItem]

            switch type {
            case .am, .pm:
                self.debugPrintPlanVisitsDates()
                items = self.visits(for: type.shiftId)
            case .other:
                items = self.otherVisits()

            case .officeWork:
                self.allPlanOws = self.planOws.filter { self.isToday($0.date) }
                items = self.allPlanOws.map { .office($0) }
            }

            self.itemsRelay.accept(items)
            self.loadingBehavior.accept(false)
        }
    }
    func debugPrintPlanVisitsDates() {
        print("==== PLAN VISITS DATES ====")
        planVisits.enumerated().forEach { index, visit in
            print("[\(index)] date -> \(visit.date ?? "nil") | shift_id -> \(visit.shift_id ?? 0)")
        }
    }

    // MARK: - Filtering (Date Range)
    func filterVisits(from fromDate: Date, to toDate: Date) -> [PlanOwsData] {
        let formatter = Self.dateFormatter
        return allPlanOws.filter {
            guard let dateString = $0.date,
                  let date = formatter.date(from: dateString) else { return false }
            return date >= fromDate && date <= toDate
        }
    }

    // MARK: - Update Table
    func updateVisits(_ visits: [PlanOwsData]) {
        itemsRelay.accept(visits.map { .office($0) })
    }
}

// MARK: - Date Helpers
private extension PlannedVisitsViewModel {

    static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    /// ✅ Strict comparison — TODAY ONLY
    func isToday(_ dateString: String?) -> Bool {
        guard let dateString else { return false }

        let cleanDate = dateString.trimmingCharacters(in: .whitespacesAndNewlines)

        let formatter = Self.dateFormatter
        let today = formatter.string(from: Date())

        return cleanDate == today
    }

    func visits(for shiftId: Int) -> [PlannedVisitItem] {
      
        planVisits
            .filter {
                $0.shift_id == shiftId &&
                isToday($0.date)
            }
            .map { .visit($0) }
        
       
    }

    func otherVisits() -> [PlannedVisitItem] {
        planVisits
            .filter {
                $0.shift_id != AccountType.am.shiftId &&
                $0.shift_id != AccountType.pm.shiftId &&
                isToday($0.date)
            }
            .map { .visit($0) }
    }
}
