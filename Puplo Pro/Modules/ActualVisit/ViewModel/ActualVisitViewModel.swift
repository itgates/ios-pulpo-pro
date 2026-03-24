//
//  ActualVisitViewModel.swift
//  Gemstone Pro
//
//  Created by Ahmed on 21/12/2025.

import Foundation
import RxSwift
import RxCocoa

struct VisitSection {
    let header: String
    var items: [Any]
}

final class ActualVisitViewModel {

    // MARK: - Properties
    let loadingBehavior = BehaviorRelay<Bool>(value: false)

    var allVisits: [ActualVisitModel] = []
    var allOfficeWorks: [OWSModel] = []

    private let sectionsSubject = BehaviorRelay<[VisitSection]>(value: [])
    var sectionsObservable: Observable<[VisitSection]> {
        sectionsSubject.asObservable()
    }

    // MARK: - Fetch Data
    func fetchData() {

        loadingBehavior.accept(true)

        DispatchQueue.global(qos: .userInitiated).async {

            let visits = LocalStorageManager.shared.getActualVisitData() ?? []
            let officeWorks = LocalStorageManager.shared.getOfficeWorkData() ?? []

            self.allVisits = visits
            self.allOfficeWorks = officeWorks
            print("officeWorks >>\(officeWorks)")
            let sections: [VisitSection] = [
                VisitSection(header: "Actual Visit", items: visits),
                VisitSection(header: "Office Work", items: officeWorks)
            ]

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.sectionsSubject.accept(sections)
                self.loadingBehavior.accept(false)
            }
        }
    }

    // MARK: - Filter by Date
    func filterVisits(from fromDate: Date, to toDate: Date) {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        // Filter Actual Visits
        let filteredVisits = allVisits.filter { item in
            guard let dateString = item.visit_date,
                  let visitDate = formatter.date(from: dateString) else { return false }

            return visitDate >= fromDate && visitDate <= toDate
        }

        // Filter Office Works
        let filteredOfficeWorks = allOfficeWorks.filter { item in
            let dateString = item.date
            
            guard let workDate = formatter.date(from: dateString) else { return false }

            return workDate >= fromDate && workDate <= toDate
        }

        let sections: [VisitSection] = [
            VisitSection(header: "Actual Visit", items: filteredVisits),
            VisitSection(header: "Office Work", items: filteredOfficeWorks)
        ]

        sectionsSubject.accept(sections)
    }
}
