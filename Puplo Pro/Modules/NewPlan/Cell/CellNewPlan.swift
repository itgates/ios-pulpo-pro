//
//  CellNewPlan.swift
//  Gemstone Pro
//
//  Created by Ahmed on 05/01/2026.

import UIKit
import RxCocoa
import RxSwift
class CellNewPlan: UITableViewCell {
    
    // MARK: - out let
    @IBOutlet weak var viewContiner: UIView!
    @IBOutlet weak var onlineIdLabel: UILabel!
    @IBOutlet weak var checkUpload: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var hospitsalLabel: UILabel!
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
    func configure(with model: SaveNewPlanModel) {
        idLabel.rx.text.onNext("\(model.id)")
        visitDateLabel.rx.text.onNext(model.visitDate)
        onlineIdLabel.rx.text.onNext("\(model.onlineID)")
        
        let accountName = model.accountName?.isEmpty == false ? model.accountName! : "Unknown"
        hospitsalLabel.rx.text.onNext("(\(accountName))")
        doctorLabel.rx.text.onNext("(\(model.doctorName ?? ""))")
       
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
