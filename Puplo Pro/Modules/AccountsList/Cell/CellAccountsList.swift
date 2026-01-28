//
//  CellAccountsList.swift
//  Puplo Pro
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
    func configure(with model: Accoutns) {
        idLabel.rx.text.onNext("\(model.id ?? 0)")
        
        latLabel.rx.text.onNext(model.ll)
        lngLabel.rx.text.onNext(model.lg)
        
        let shift = AccountShift(rawValue: model.type_id ?? 0)
        
        switch shift {
        case .am:
            accountLabel.rx.text.onNext("\(model.name ?? "") (AM Account)")
        case .pm:
            accountLabel.rx.text.onNext("\(model.name ?? "") (PM Account)")
        default:
            accountLabel.rx.text.onNext("\(model.name ?? "") (Other Account)")
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
