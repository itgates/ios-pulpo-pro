//
//  StatisticsViewModel.swift
//  Puplo Pro
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

    init() {
        productsCount = Observable
            .just(LocalStorageManager.shared.getMasterData()?.data?.products?.count ?? 0)
            .map { "\($0)" }
            .asDriver(onErrorJustReturn: "0")

        accountsCount = Observable
            .just(LocalStorageManager.shared.getAccountsDoctors()?.data?.accoutns?.count ?? 0)
            .map { "\($0)" }
            .asDriver(onErrorJustReturn: "0")

        plannedVisitsCount = Observable
            .just(LocalStorageManager.shared.getPlanVisitsData()?.count ?? 0)
            .map { "\($0)" }
            .asDriver(onErrorJustReturn: "0")

        actualVisitsCount = Observable
            .just(LocalStorageManager.shared.getActualVisitData()?.count ?? 0)
            .map { "\($0)" }
            .asDriver(onErrorJustReturn: "0")

        settingsCount = Observable
            .just(LocalStorageManager.shared.getMasterData()?.data?.settings?.count ?? 0)
            .map { "\($0)" }
            .asDriver(onErrorJustReturn: "0")
    }
}
