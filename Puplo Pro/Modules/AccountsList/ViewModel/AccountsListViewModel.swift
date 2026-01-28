//
//  AccountsListViewModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 06/01/2026.
//
import RxSwift
import RxCocoa

final class AccountsListViewModel {
    
    // MARK: - Properties
    private let allAccounts: [Accoutns] =
        LocalStorageManager.shared.getAccountsDoctors()?.data?.accoutns ?? []
    
    let loadingBehavior = BehaviorRelay<Bool>(value: false)
    
    private let accountsRelay = BehaviorRelay<[Accoutns]>(value: [])
    var accountsObservable: Observable<[Accoutns]> {
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
    func applyFilter(_ filter: SelectFilter) {
        
        let filtered = allAccounts.filter { account in
            
            if let id = filter.division?.id, account.div_id != id { return false }
            if let id = filter.brick?.id, Int(account.brick_id ?? "") != id { return false }
            if let id = filter.accountType?.id, account.type_id != id { return false }
            if let id = filter.classType?.id, account.class_id != id { return false }
            
            return true
        }
        
        accountsRelay.accept(filtered)
    }
    
    func clearFilter() {
        accountsRelay.accept(allAccounts)
    }
}
