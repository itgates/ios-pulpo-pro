//
//  ActualVisitViewModel.swift
//  Gemstone Pro
//
//  Created by Ahmed on 21/12/2025.
//
import Foundation
import RxSwift
import RxCocoa

final class ActualVisitViewModel {

    // MARK: - Properties
    let loadingBehavior = BehaviorRelay<Bool>(value: false)
    
    var allVisits: [ActualVisitModel] = []
    private var visitSubject = BehaviorRelay<[ActualVisitModel]>(value: [])
    var visitObservable: Observable<[ActualVisitModel]> {
        return visitSubject.asObservable()
    }

    // MARK: - Fetch Data
    func fetchData() {
        loadingBehavior.accept(true)
        DispatchQueue.global(qos: .userInitiated).async {
            let items = LocalStorageManager.shared.getActualVisitData() ?? []
            self.allVisits = items
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.visitSubject.accept(items)
                self.loadingBehavior.accept(false)
            }
        }
    }

    // MARK: - Filter by Date
    func filterVisits(from fromDate: Date, to toDate: Date) -> [ActualVisitModel] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return allVisits.filter { product in
            guard let productDate = formatter.date(from: product.visit_date ?? "") else { return false }
            return productDate >= fromDate && productDate <= toDate
        }
    }

    // MARK: - Update Table
    func updateVisits(_ visits: [ActualVisitModel]) {
        visitSubject.accept(visits)
    }
}
