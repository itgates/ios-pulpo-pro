//
//  CellPlanningVisits.swift
//  Gemstone Pro
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
    let masterData = AppDataProvider.shared.masterData
    var accountName: String = ""
    var doctorName: String = ""
    var onLat: String = ""
    var onLong: String = ""
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
        bindActions()
    }
    // MARK: - Configuration
    func configureCell(model: PlanningVisitsData) {
        idLabel.rx.text.onNext("id: \(model.id ?? "")")
        iMDepartmentLabel.rx.text.onNext(model.name)
        hosptalLabel.rx.text.onNext(model.hosptal)
        AMAccountLabel.rx.text.onNext(" (\(model.account_type ?? ""))")
    }
    func configureCellPlanned(model: PlannedVisitsData) {

        viewCircel.rx.isHidden.onNext(true)
        AMAccountLabel.textColor = .orange
        checkImage.image = UIImage(named: "pin")
        idLabel.rx.text.onNext("id: \(model.id ?? "")")

        // ✅ Doctor Name
        let doctors = RealmStorageManager.shared.getAccountsDoctors()?.Data?.Doctors ?? []

        let doctor = doctors.first {
            $0.id?.trimmingCharacters(in: .whitespacesAndNewlines)
            ==
            model.item_doc_id?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let doctorName = doctor?.name ?? "Unknown"
        iMDepartmentLabel.rx.text.onNext("Doctor: \(doctorName)")
        self.doctorName =  doctorName
        
        // ✅ Account Type Name
        let accountTypes = masterData?.Data?.account_types ?? []

        let accountTypeName = accountTypes
            .first {
                $0.id?.trimmingCharacters(in: .whitespacesAndNewlines)
                ==
                model.account_type?.trimmingCharacters(in: .whitespacesAndNewlines)
            }?
            .name ?? "Unknown"

        hosptalLabel.rx.text.onNext("\(accountTypeName):")

        // ✅ Fetch Account Object (IMPORTANT)
        let accounts = RealmStorageManager.shared.getAccountsDoctors()?.Data?.Accounts ?? []

        let account = accounts.first {
            $0.id?.trimmingCharacters(in: .whitespacesAndNewlines)
            ==
            model.item_id?.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        let accountName = account?.name ?? "Unknown"
        AMAccountLabel.rx.text.onNext("(\(accountName))")

        // ✅ Save Lat & Lng inside cell properties
        self.onLat = account?.team_ll ?? ""
        self.onLong = account?.team_lg ?? ""
        self.accountName =  accountName
    }
    func configureCellOWS(model: PlanOwsData) {
        viewCircel.rx.isHidden.onNext(true)
        checkImage.rx.isHidden.onNext(true)

        idLabel.rx.text.onNext("id: \(model.id ?? "")")
        iMDepartmentLabel.rx.text.onNext("Date: \(model.date ?? "")")
       
        let name = masterData?.Data?.office_work_types?
            .first(where: { $0.id == model.ow_type_id })?
            .name ?? ""
        hosptalLabel.rx.text.onNext("\(name): ")
        
        if model.shift_id == "2" {
            AMAccountLabel.rx.text.onNext("(AM)")
        } else if model.shift_id == "1" {
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
