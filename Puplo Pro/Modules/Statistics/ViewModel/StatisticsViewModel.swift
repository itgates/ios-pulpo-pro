//
//  StatisticsViewModel.swift
//  Gemstone Pro
//
//  Created by Ahmed on 06/01/2026.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
final class StatisticsViewModel {

    // MARK: - Outputs
    let productsCount: Driver<String>
    let accountsCount: Driver<String>
    let plannedVisitsCount: Driver<String>
    let actualVisitsCount: Driver<String>
    let settingsCount: Driver<String>
    let masterData = AppDataProvider.shared.masterData
    
    init() {
        productsCount = Observable
            .just(masterData?.Data?.products?.count ?? 0)
            .map { "\($0)" }
            .asDriver(onErrorJustReturn: "0")

        accountsCount = Observable
            .just(RealmStorageManager.shared.getAccountsDoctors()?.Data?.Accounts?.count ?? 0)
            .map { "\($0)" }
            .asDriver(onErrorJustReturn: "0")

        plannedVisitsCount = Observable
            .just(RealmStorageManager.shared.getPlannedVisitsData()?.count ?? 0)
            .map { "\($0)" }
            .asDriver(onErrorJustReturn: "0")

        actualVisitsCount = Observable
            .just(RealmStorageManager.shared.getActualVisitData()?.count ?? 0)
            .map { "\($0)" }
            .asDriver(onErrorJustReturn: "0")

        settingsCount = Observable
            .just(masterData?.Data?.settings?.count ?? 0)
            .map { "\($0)" }
            .asDriver(onErrorJustReturn: "0")
    }
}
