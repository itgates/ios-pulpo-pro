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
        LocalStorageManager.shared.getAccountsDoctors()?.Data?.Accounts ?? []
    
    let loadingBehavior = BehaviorRelay<Bool>(value: false)
    
    private let accountsRelay = BehaviorRelay<[Accounts]>(value: [])
    var accountsObservable: Observable<[Accounts]> {
        accountsRelay.asObservable()
    }
    
    // MARK: - Fetch
    func fetchData() {
        loadingBehavior.accept(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.accountsRelay.accept(self.allAccounts)
            self.loadingBehavior.accept(false)
        }
    }
    
    // MARK: - Filter
//    func applyFilter(_ filter: SelectFilter) {
//        
//        let filtered = allAccounts.filter { account in
//            
//            if let id = filter.division?.id, account.t_div_id != id { return false }
//            if let id = filter.brick?.id, account.brick_id ?? "" != id { return false }
//            
//            //  Optimization: Cache account types once
//            let accountTypes = LocalStorageManager.shared
//                .getMasterData()?
//                .Data?
//                .account_types
//            
//            if let tbl = account.tbl,
//               let accountType = accountTypes?.first(where: { $0.tbl == tbl }) {
//                if let id = filter.accountType?.id, accountType.id != id { return false }
//            }
//            
//            if let id = filter.classType?.id, account.t_class_id != id { return false }
//            
//            return true
//        }
//        
//        accountsRelay.accept(filtered)
//    }
    func applyFilter(_ filter: SelectFilter) {
        loadingBehavior.accept(true)
        
        // Cache account types once
        let accountTypes = LocalStorageManager.shared.getMasterData()?.Data?.account_types
        
        DispatchQueue.global(qos: .userInitiated).async {
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
            
            DispatchQueue.main.async {
                self.accountsRelay.accept(filtered)
                self.loadingBehavior.accept(false)
            }
        }
    }
    
    func clearFilter() {
        accountsRelay.accept(allAccounts)
    }
}
