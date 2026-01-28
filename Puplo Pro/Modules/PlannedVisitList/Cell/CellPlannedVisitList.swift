//
//  CellPlannedVisitList.swift
//  Puplo Pro
//
//  Created by Ahmed on 05/01/2026.
//

import UIKit
import RxCocoa
import RxSwift
class CellPlannedVisitList: UITableViewCell {
    
    // MARK: - out let
    @IBOutlet weak var viewContiner: UIView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var doctorLabel: UILabel!
    @IBOutlet weak var visitDateLabel: UILabel!
    @IBOutlet weak var mapButton: UIButton!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    // Closure
    var onMapTapped: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bindActions()
    }
    func configure(with model: PlanVisitsData) {
        idLabel.rx.text.onNext("\(model.id ?? 0)")
        accountLabel.rx.text.onNext(model.account)
        doctorLabel.rx.text.onNext(model.doctor)
        visitDateLabel.rx.text.onNext(model.date)
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
