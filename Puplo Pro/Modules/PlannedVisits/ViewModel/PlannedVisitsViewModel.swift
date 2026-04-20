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
    var itemsObservable: Observable<[PlannedVisitItem]> {
        itemsRelay.asObservable()
    }
    
    let masterData = AppDataProvider.shared.masterData
    
    // MARK: - Private Properties
    private let itemsRelay = BehaviorRelay<[PlannedVisitItem]>(value: [])
    
    private let planVisits: [PlannedVisitsData]
    
    private(set) var allPlanOws: [PlanOwsData] = []
    
    private lazy var actualVisits: [ActualVisitModel] = {
        RealmStorageManager.shared.getActualVisitData() ?? []
    }()
    
    /// ✅ Mapping سريع: account_type_id → cat_id
    private lazy var accountTypeMap: [String: String] = {
        let list = masterData?.Data?.account_types ?? []
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
        
        self.planVisits = (RealmStorageManager.shared.getPlannedVisitsData() ?? [])
            .filter {
                $0.vdate?.trimmingCharacters(in: .whitespacesAndNewlines) == today
            }
    }
    
    // MARK: - Load Data
    func loadAccount(for type: AccountType) {
        let items = self.visits(for: type.categoryId)
        self.itemsRelay.accept(items)
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
