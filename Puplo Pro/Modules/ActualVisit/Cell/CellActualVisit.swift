//
//  CellActualVisit.swift
//  Gemstone Pro
//
//  Created by Ahmed on 22/12/2025.
//

import UIKit
import RxCocoa
import RxSwift
class CellActualVisit: UITableViewCell {
    
    // MARK: - out let
    @IBOutlet weak var viewContiner: UIView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var onlineIdLabel: UILabel!
    @IBOutlet weak var divisionLabel: UILabel!
    @IBOutlet weak var accountTypeLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var brickLabel: UILabel!
    @IBOutlet weak var doctorLabel: UILabel!
    @IBOutlet weak var visitDateLabel: UILabel!
    @IBOutlet weak var visitTypeLabel: UILabel!
    @IBOutlet weak var checkUpload: UIImageView!
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
    // MARK: - Configure
    func configure(with model: ActualVisitModel) {
        idLabel.rx.text.onNext(model.id)
        onlineIdLabel.rx.text.onNext(model.online_id)
        divisionLabel.rx.text.onNext(model.division_name)
        accountTypeLabel.rx.text.onNext(model.account_type)
        accountLabel.rx.text.onNext(model.account_name)
        brickLabel.rx.text.onNext(model.brick_name)
        doctorLabel.rx.text.onNext(model.doctor_name)
        visitDateLabel.rx.text.onNext(model.visit_date)
        visitTypeLabel.rx.text.onNext(model.visit_type)
        
        if model.isUploaded == true {
            checkUpload.isHidden = false
        } else {
            checkUpload.isHidden = true
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

