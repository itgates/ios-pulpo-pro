
//
//  CellAccountsList.swift
//  Gemstone Pro
//
//  Created by Ahmed on 06/01/2026.
//

import UIKit
import RxCocoa
import RxSwift

final class CellAccountsList: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var viewContiner: UIView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var stackLocation: UIStackView!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var lngLabel: UILabel!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    var onMapTapped: (() -> Void)?
    private var isMapEnabled: Bool = false
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        bindActions()
    }
    
    // MARK: - Configuration
    func configure(with model: Accounts) {
        idLabel.rx.text.onNext(model.id ?? "")
        latLabel.rx.text.onNext(model.team_ll)
        lngLabel.rx.text.onNext(model.team_lg)
        
//        isMapEnabled = !(model.team_ll?.isEmpty ?? true) && !(model.team_lg?.isEmpty ?? true)
//        mapButton.isEnabled = isMapEnabled
//        mapButton.alpha = isMapEnabled ? 1.0 : 0.6
        mapButton.isHidden = (model.team_ll?.isEmpty ?? true)
        stackLocation.rx.isHidden.onNext(model.team_ll?.isEmpty ?? true)
        
        // Account Type
        if let accountTypes = LocalStorageManager.shared.getMasterData()?.Data?.account_types,
           let tbl = model.tbl,
           let accountType = accountTypes.first(where: { $0.tbl == tbl }) {
            accountLabel.rx.text.onNext("(\(accountType.name ?? ""))")
        }
        
        accountNameLabel.rx.text.onNext(model.name ?? "")
    }
    
    // MARK: - Actions
    private func bindActions() {
        mapButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind { [weak self] in self?.onMapTapped?() }
            .disposed(by: disposeBag)
    }
}
