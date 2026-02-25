//
//  CellAccountsList.swift
//  Gemstone Pro
//
//  Created by Ahmed on 06/01/2026.
//

import UIKit
import RxCocoa
import RxSwift
class CellAccountsList: UITableViewCell {
    
    // MARK: - out let
    @IBOutlet weak var viewContiner: UIView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var lngLabel: UILabel!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    // Closure
    var onMapTapped: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bindActions()
    }
    func configure(with model: Accounts) {
        idLabel.rx.text.onNext("\(model.id ?? "")")
        
        latLabel.rx.text.onNext(model.team_ll)
        lngLabel.rx.text.onNext(model.team_lg)
        
        //  Optimization: Cache account types once
        let accountTypes = LocalStorageManager.shared
            .getMasterData()?
            .Data?
            .account_types
        
        if let tbl = model.tbl,
           let accountType = accountTypes?.first(where: { $0.tbl == tbl }) {
            accountLabel.rx.text.onNext("(\(accountType.name ?? ""))")
            accountNameLabel.rx.text.onNext("\(model.name ?? "")")
        }
    }
    // MARK: - Bind Button
    func bindActions() {
        mapButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { vc, _ in
                vc.onMapTapped?()
            }
            .disposed(by: disposeBag)
    }
}
