//
//  PlannedVisitListViewModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 05/01/2026.
//

import Foundation
import RxSwift
import RxCocoa

final class PlannedVisitListViewModel {

    // MARK: - Properties
    let loadingBehavior = BehaviorRelay<Bool>(value: false)
    
    var allVisits: [PlanVisitsData] = []
    private var visitSubject = BehaviorRelay<[PlanVisitsData]>(value: [])
    var visitObservable: Observable<[PlanVisitsData]> {
        return visitSubject.asObservable()
    }

    // MARK: - Fetch Data
    func fetchData() {
        loadingBehavior.accept(true)
        DispatchQueue.global(qos: .userInitiated).async {
            let items = LocalStorageManager.shared.getPlanVisitsData() ?? []
            self.allVisits = items
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.visitSubject.accept(items)
                self.loadingBehavior.accept(false)
            }
        }
    }

    // MARK: - Filter by Date
    func filterVisits(from fromDate: Date, to toDate: Date) -> [PlanVisitsData] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return allVisits.filter { product in
            guard let productDate = formatter.date(from: product.date ?? "") else { return false }
            return productDate >= fromDate && productDate <= toDate
        }
    }

    // MARK: - Update Table
    func updateVisits(_ visits: [PlanVisitsData]) {
        visitSubject.accept(visits)
    }
}
