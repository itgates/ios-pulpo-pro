//
//  CellPlannedVisitList.swift
//  Gemstone Pro
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
    var accountName: String = ""
    var doctorName: String = ""
    var onLat: String = ""
    var onLong: String = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bindActions()
    }
    func configure(with model: PlannedVisitsData) {
        idLabel.rx.text.onNext("\(model.id ?? "")")
        accountLabel.rx.text.onNext(model.account_type)
//        doctorLabel.rx.text.onNext(model.doctor)
        visitDateLabel.rx.text.onNext(model.insertion_date)
        
        // ✅ Fetch Account Object (IMPORTANT)
        let accounts = LocalStorageManager.shared.getAccountsDoctors()?.Data?.Accounts ?? []
        let account = accounts.first {
            $0.id?.trimmingCharacters(in: .whitespacesAndNewlines)
            ==
            model.item_id?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let accountName = account?.name ?? "Unknown"
        accountLabel.rx.text.onNext("(\(accountName))")
        self.accountName = accountName
        self.onLat = account?.team_ll ?? ""
        self.onLong = account?.team_lg ?? ""
        
        let doctorData = LocalStorageManager.shared.getAccountsDoctors()?.Data
        let selectedDoctor = doctorData?.Doctors?
            .first(where: { $0.id == model.item_doc_id })
        let doctorName = selectedDoctor?.name ?? ""
        self.doctorName = doctorName
        doctorLabel.rx.text.onNext("(\(doctorName))")
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
