//
//  AccountsListViewModel.swift
//  Gemstone Pro
//
//  Created by Ahmed on 06/01/2026.
//
import RxSwift
import RxCocoa

final class AccountsListViewModel {
    
    // MARK: - Properties
    private let allAccounts: [Accounts] =
        RealmStorageManager.shared.getAccountsDoctors()?.Data?.Accounts ?? []
        
    private let accountsRelay = BehaviorRelay<[Accounts]>(value: [])
    var accountsObservable: Observable<[Accounts]> {
        accountsRelay.asObservable()
    }
    
    let masterData = AppDataProvider.shared.masterData
    
    // MARK: - Fetch
    func fetchData() {
            self.accountsRelay.accept(self.allAccounts)
    }
    
    // MARK: - Filter
    func applyFilter(_ filter: SelectFilter) {
        
        // Cache account types once
        let accountTypes = masterData?.Data?.account_types
        
            let filtered = self.allAccounts.filter { account in
                
                if let id = filter.division?.id, account.t_div_id != id { return false }
                if let id = filter.brick?.id, account.brick_id ?? "" != id { return false }
                
                if let tbl = account.tbl,
                   let accountType = accountTypes?.first(where: { $0.tbl == tbl }) {
                    if let id = filter.accountType?.id, accountType.id != id { return false }
                }
                
                if let id = filter.classType?.id, account.t_class_id != id { return false }
                
                return true
            }
            self.accountsRelay.accept(filtered)
    }
    
    func clearFilter() {
        accountsRelay.accept(allAccounts)
    }
}
