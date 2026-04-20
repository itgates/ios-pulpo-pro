//
//  AppDataProvider.swift
//  Puplo Pro
//
//  Created by Ahmed on 19/04/2026.
//

import Foundation
final class AppDataProvider {

    static let shared = AppDataProvider()
    
    private init() {}

    // MARK: - Master Data
    var masterData: MasterDataModel? {
        return RealmStorageManager.shared.getMasterData()
    }

    // MARK: - Doctors
    var doctors: [Doctors] {
        return RealmStorageManager.shared.getAccountsDoctors()?.Data?.Doctors ?? []
    }
}
