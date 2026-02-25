//
//  PlannedVisitsViewModel.swift
//  Gemstone Pro
//

import Foundation
import RxSwift
import RxCocoa

final class PlannedVisitsViewModel {

    // MARK: - Item Type
    enum PlannedVisitItem {
        case visit(PlannedVisitsData)
    }

    // MARK: - Account Type
    enum AccountType {
        case am, pm, other

        var shiftId: String {
            switch self {
            case .am: return "2"
            case .pm: return "1"
            case .other: return "0"
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

    private let planVisits: [PlannedVisitsData]

    private(set) var allPlanOws: [PlanOwsData] = []

    // MARK: - Init
    init() {
        let today = Self.dateFormatter.string(from: Date())

        self.planVisits = (LocalStorageManager.shared.getPlannedVisitsData() ?? [])
            .filter {
                $0.insertion_date?.trimmingCharacters(in: .whitespacesAndNewlines) == today
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
            }

            self.itemsRelay.accept(items)
            self.loadingBehavior.accept(false)
        }
    }
    func debugPrintPlanVisitsDates() {
        print("==== PLAN VISITS DATES ====")
        planVisits.enumerated().forEach { index, visit in
            print("[\(index)] date -> \(visit.insertion_date ?? "nil") | shift_id -> \(visit.shift ?? "")")
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

    func visits(for shiftId: String) -> [PlannedVisitItem] {
      
        planVisits
            .filter {
                $0.shift == shiftId &&
                isToday($0.insertion_date)
            }
            .map { .visit($0) }
    }

    func otherVisits() -> [PlannedVisitItem] {
        planVisits
            .filter {
//                $0.shift != AccountType.am.shiftId &&
//                $0.shift != AccountType.pm.shiftId &&
                $0.shift == AccountType.other.shiftId &&
                isToday($0.insertion_date)
            }
            .map { .visit($0) }
    }
}



