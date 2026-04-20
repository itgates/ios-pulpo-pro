//
//  PlannedVisitListViewModel.swift
//  Gemstone Pro
//
//  Created by Ahmed on 05/01/2026.
//

import Foundation
import RxSwift
import RxCocoa

final class PlannedVisitListViewModel {

    // MARK: - Properties
    var allVisits: [PlannedVisitsData] = []
    private var visitSubject = BehaviorRelay<[PlannedVisitsData]>(value: [])
    var visitObservable: Observable<[PlannedVisitsData]> {
        return visitSubject.asObservable()
    }

    // MARK: - Fetch Data
    func fetchData() {
            let items = RealmStorageManager.shared.getPlannedVisitsData() ?? []
            self.allVisits = items
            self.visitSubject.accept(items)
    }

    // MARK: - Filter by Date
    func filterVisits(from fromDate: Date, to toDate: Date) -> [PlannedVisitsData] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return allVisits.filter { product in
            guard let productDate = formatter.date(from: product.insertion_date ?? "") else { return false }
            return productDate >= fromDate && productDate <= toDate
        }
    }

    // MARK: - Update Table
    func updateVisits(_ visits: [PlannedVisitsData]) {
        visitSubject.accept(visits)
    }
}
