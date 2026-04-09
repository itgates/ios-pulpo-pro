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
        case visit(PlannedVisitsData)
    }

    // MARK: - Account Type (UI Tabs)
    enum AccountType {
        case am, pm, other

        var categoryId: String {
            switch self {
            case .am: return "2"
            case .pm: return "1"
            case .other: return "3"
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

    /// ✅ Mapping سريع: account_type_id → cat_id
    private lazy var accountTypeMap: [String: String] = {
        let list = LocalStorageManager.shared.getMasterData()?.Data?.account_types ?? []
        var dict: [String: String] = [:]

        list.forEach {
            if let id = $0.id, let cat = $0.cat_id {
                dict["\(id)"] = "\(cat)"
            }
        }

        return dict
    }()

    // MARK: - Init
    init() {
        let today = Self.dateFormatter.string(from: Date())

        self.planVisits = (LocalStorageManager.shared.getPlannedVisitsData() ?? [])
            .filter {
                $0.vdate?.trimmingCharacters(in: .whitespacesAndNewlines) == today
            }
    }

    // MARK: - Load Data
    func loadAccount(for type: AccountType) {
        loadingBehavior.accept(true)
        debugPrintPlanVisitsDates()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self else { return }

            let items = self.visits(for: type.categoryId)

            self.itemsRelay.accept(items)
            self.loadingBehavior.accept(false)
        }
    }

    // MARK: - Debug
    func debugPrintPlanVisitsDates() {
        print("==== PLAN VISITS DATES ====")

        let accountTypes = LocalStorageManager.shared.getMasterData()?.Data?.account_types ?? []
        print("account_types -> \(accountTypes)")

        planVisits.enumerated().forEach { index, visit in
            print("[\(index)] id -> \(visit.id ?? "nil") | account_type -> \(visit.account_type ?? "")")
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

    /// ✅ تأكد إنه النهاردة
    func isToday(_ dateString: String?) -> Bool {
        guard let dateString else { return false }

        let cleanDate = dateString.trimmingCharacters(in: .whitespacesAndNewlines)
        let today = Self.dateFormatter.string(from: Date())

        return cleanDate == today
    }

    // MARK: - Core Filtering 🔥
    func visits(for categoryId: String) -> [PlannedVisitItem] {

        let actualVisits = LocalStorageManager.shared.getActualVisitData() ?? []

        return planVisits
            .filter { planned in

                guard isToday(planned.vdate) else { return false }

                /// ✅ نجيب الـ cat_id من الماب
                let catId = accountTypeMap[planned.account_type ?? ""]

                /// ✅ نقارن بالـ tab (AM / PM / Other)
                if catId != categoryId {
                    return false
                }

                /// ✅ نشيل اللي اتعملها visit
                let isVisited = actualVisits.contains {
                    $0.palnID == planned.id
                }

                return !isVisited
            }
            .map { .visit($0) }
    }
}
