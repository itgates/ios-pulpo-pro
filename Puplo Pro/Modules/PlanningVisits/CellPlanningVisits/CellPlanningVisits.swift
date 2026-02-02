//
//  CellPlanningVisits.swift
//  Puplo Pro
//
//  Created by Ahmed on 25/11/2025.
//

import UIKit
import RxCocoa
import RxSwift
class CellPlanningVisits: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var iMDepartmentLabel: UILabel!
    @IBOutlet weak var hosptalLabel: UILabel!
    @IBOutlet weak var AMAccountLabel: UILabel!
    
    @IBOutlet weak var viewCircel: UIView!
    @IBOutlet weak var viewBorder: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    // Closure
    var onMapTapped: (() -> Void)?
    let officeWorkTypes = LocalStorageManager.shared.getMasterData()?.Data?.office_work_types
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
        bindActions()
    }
    // MARK: - Configuration
    func configureCell(model: PlanningVisitsData,AMAccount:String) {
        idLabel.rx.text.onNext("id: \(model.id ?? 0)")
        iMDepartmentLabel.rx.text.onNext(model.name)
        hosptalLabel.rx.text.onNext(model.hosptal)
        AMAccountLabel.rx.text.onNext(AMAccount)
    }
    func configureCellPlanned(model: PlanVisitsData) {
        viewCircel.rx.isHidden.onNext(true)
        AMAccountLabel.textColor = .orange
        checkImage.image = UIImage(named: "pin")
        idLabel.rx.text.onNext("id: \(model.id ?? 0)")
        
        iMDepartmentLabel.rx.text.onNext("Doctor: (\(model.doctor ?? ""))")
        AMAccountLabel.rx.text.onNext("(\(model.account ?? ""))")
       
        if model.shift_id == 1 {
            hosptalLabel.rx.text.onNext("\(model.account_type ?? ""):")
        } else if model.shift_id == 2 {
            hosptalLabel.rx.text.onNext("\(model.account_type ?? ""):")
        }else {
            hosptalLabel.rx.text.onNext("\(model.account_type ?? ""):")
        }
       
    }
    func configureCellOWS(model: PlanOwsData) {
        viewCircel.rx.isHidden.onNext(true)
        checkImage.rx.isHidden.onNext(true)

        idLabel.rx.text.onNext("id: \(model.id ?? 0)")
        iMDepartmentLabel.rx.text.onNext("Date: \(model.date ?? "")")
       
        let name = officeWorkTypes?
            .first(where: { Int($0.id ?? "") == model.ow_type_id })?
            .name ?? ""
        hosptalLabel.rx.text.onNext("\(name): ")
        
        if model.shift_id == 1 {
            AMAccountLabel.rx.text.onNext("(AM)")
        } else if model.shift_id == 2 {
            AMAccountLabel.rx.text.onNext("(PM)")
        } else {
            AMAccountLabel.rx.text.onNext("(Other)")
        }
    }

    
    func setupUI() {
        viewBackground.layer.rx.cornerRadius.onNext(10)
        viewCircel.layer.rx.cornerRadius.onNext(viewCircel.frame.height / 2)
    }
    // MARK: - selectedItem
    func selectedItem() {
        viewBackground.layer.rx.borderColor.onNext(baseColor.cgColor)
        viewBackground.layer.rx.borderWidth.onNext(2)
        checkImage.image = UIImage(systemName: "checkmark.circle.fill", compatibleWith: nil)
    }
    // MARK: - un selectedItem
    func unSelectedItem() {
        viewBackground.layer.rx.borderColor.onNext(UIColor.clear.cgColor)
        viewBackground.layer.rx.borderWidth.onNext(0)
        checkImage.image = UIImage(systemName: "", compatibleWith: nil)
    }
    // MARK: - Bind action
    func bindActions() {
        checkImage.onTap { [weak self] in
            self?.onMapTapped?()
        }
    }
}
