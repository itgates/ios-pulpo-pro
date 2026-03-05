//
//  CellUnPlannedVisit.swift
//  Gemstone Pro
//
//  Created by Ahmed on 07/12/2025.
//
// LocalStorageManager.shared.getMasterData()?.Data?.settings,

        
import UIKit
import DropDown

private enum BorderStyle {
    case required
    case optional
}
final class CellUnPlannedVisit: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet var drows: [UIImageView]!
    
    @IBOutlet weak var stackDate: UIStackView!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var stackTime: UIStackView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var stackTappedDivision: UIStackView!
    @IBOutlet weak var divisionTextField: UITextField!
    
    @IBOutlet weak var stackTappedBrick: UIStackView!
    @IBOutlet weak var brickTextField: UITextField!
    
    @IBOutlet weak var stackTappedAccountType: UIStackView!
    @IBOutlet weak var accountTypeTextField: UITextField!
    
    @IBOutlet weak var stackTappedAccount: UIStackView!
    @IBOutlet weak var accountTextField: UITextField!
    
    @IBOutlet weak var stackTappedDoctor: UIStackView!
    @IBOutlet weak var doctorTextField: UITextField!
    
    @IBOutlet weak var stackTappedVisitType: UIStackView!
    @IBOutlet weak var visitTypeTextField: UITextField!
    
    @IBOutlet weak var stackTappedShiftType: UIStackView!
    @IBOutlet weak var shiftTypeTextField: UITextField!
    
    @IBOutlet weak var stackComment: UIStackView!
    @IBOutlet private weak var commentTextField: UITextField!

    // MARK: - Properties
    private let dropDown = DropDown()
    private let masterData = LocalStorageManager.shared.getMasterData()

    private var currentItems: [IdNameModel] = []
    private var currentField: ItemSelectionType?

    var model: VisitItem?
    var didSelectItem: ((IdNameModel, ItemSelectionType) -> Void)?
    var didChangeComment: ((String?) -> Void)?
    var showWarning: ((String) -> Void)?
    let now = Date()
    
    private var isShiftEnabled: Bool {
        masterData?
            .Data?
            .settings?
            .first(where: { $0.attribute_name == "add_shift" })?
            .attribute_value == "1"
    }
    // MARK: - Static Data
    private let shiftData: [IdNameModel] = [
        IdNameModel(id: "2", name: "AM"),
        IdNameModel(id: "1", name: "PM"),
        IdNameModel(id: "4", name: "Full Day")
    ]

    private let visitTypeData: [IdNameModel] = [
        IdNameModel(id: "1", name: "Single"),
        IdNameModel(id: "2", name: "Double")
    ]

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupDropDown()
        setupGestures()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        model = nil
    }

    func configure(with model: VisitItem) {
        self.model = model
        bindModelToUI()
        updateBorders()
    }
}

// MARK: - Setup UI
private extension CellUnPlannedVisit {

    func setupUI() {

        [
            divisionTextField,
            brickTextField,
            accountTypeTextField,
            accountTextField,
            doctorTextField,
            visitTypeTextField,
            shiftTypeTextField
        ].forEach { $0?.isUserInteractionEnabled = false }

        commentTextField.delegate = self
        commentTextField.placeholder = "Comment"
        
        dateLabel.text = now.formattedDate.to24HourFormat
        timeLabel.text = now.formattedTime
        
        update(stackDate, nil, style: .required)
        update(stackTime, nil, style: .required)
        update(stackTappedDivision, nil, style: .required)
        stackTappedShiftType.isHidden = !isShiftEnabled
    }

    func setupDropDown() {

        DropDown.startListeningToKeyboard()

        let appearance = DropDown.appearance()
        appearance.cellHeight = 40
        appearance.backgroundColor = .white
        appearance.selectionBackgroundColor = UIColor(
            red: 0.65,
            green: 0.82,
            blue: 1,
            alpha: 0.2
        )
        appearance.setupCornerRadius(10)
        appearance.shadowColor = UIColor(white: 0.6, alpha: 1)
        appearance.textColor = mainColor

        dropDown.direction = .bottom
        dropDown.semanticContentAttribute = .forceLeftToRight

        dropDown.selectionAction = { [weak self] index, title in
            guard
                let self,
                let field = self.currentField,
                index < self.currentItems.count
            else { return }

            let selected = self.currentItems[index]
            self.updateUI(field: field, item: selected)
            self.didSelectItem?(selected, field)
            self.updateBorders()
            print("✅ Selected \(field): \(selected.name ?? "")")
        }
    }
}

// MARK: - Gestures
private extension CellUnPlannedVisit {

    func setupGestures() {

        stackTappedDivision.onTap { [weak self] in
            self?.show(.division, anchor: self?.stackTappedDivision)
        }

        stackTappedBrick.onTap { [weak self] in
            self?.show(.brick, anchor: self?.stackTappedBrick)
        }

        stackTappedAccountType.onTap { [weak self] in
            self?.show(.accountType, anchor: self?.stackTappedAccountType)
        }

        stackTappedAccount.onTap { [weak self] in
            self?.show(.account, anchor: self?.stackTappedAccount)
        }

        stackTappedDoctor.onTap { [weak self] in
            self?.show(.doctor, anchor: self?.stackTappedDoctor)
        }

        stackTappedVisitType.onTap { [weak self] in
            self?.show(.visitType, anchor: self?.stackTappedVisitType)
        }

        stackTappedShiftType.onTap { [weak self] in
            self?.show(.shiftType, anchor: self?.stackTappedShiftType)
        }
    }
}

// MARK: - DropDown Logic
private extension CellUnPlannedVisit {

    func show(_ field: ItemSelectionType, anchor: UIView?) {

        // 🔴 Validation Order
        if let warning = validationWarning(for: field) {
            showWarning?(warning)
            return
        }
        currentField = field
        dropDown.anchorView = anchor
        dropDown.bottomOffset = CGPoint(
            x: 0,
            y: anchor?.bounds.height ?? 0
        )

        switch field {

        case .division:
            currentItems = divisionData

        case .brick:
            currentItems = brickData.filter {
                $0.ter_id == model?.division?.id
            }

        case .accountType:
            currentItems = accountTypeData

        case .account:
            currentItems = accountsForBrick(model?.brick?.id ?? "")

        case .doctor:
            currentItems = doctorsForAccount(model?.account?.id ?? "")

        case .visitType:
            currentItems = visitTypeData

        case .shiftType:
            guard isShiftEnabled else { return }
            currentItems = shiftData
//
//        case .shiftType:
//            currentItems = shiftData
        }

        dropDown.dataSource = currentItems.compactMap { $0.name }
        dropDown.show()
    }
    private func validationWarning(for field: ItemSelectionType) -> String? {

        switch field {

        case .brick:
            if model?.division == nil {
                return "Please select Division first"
            }

        case .accountType:
            if model?.brick == nil {
                return "Please select Brick first"
            }

        case .account:
            if model?.accountType == nil {
                return "Please select Account Type first"
            }

        case .doctor:
            if model?.account == nil {
                return "Please select Account first"
            }

        default:
            break
        }

        return nil
    }
}

// MARK: - Bind UI
private extension CellUnPlannedVisit {

    func bindModelToUI() {
        divisionTextField.text = model?.division?.name
        brickTextField.text = model?.brick?.name
        accountTypeTextField.text = model?.accountType?.name
        accountTextField.text = model?.account?.name
        doctorTextField.text = model?.doctor?.name
        visitTypeTextField.text = model?.visitType?.name
        shiftTypeTextField.text = model?.shiftType?.name
        commentTextField.text = model?.comment
    }
    
    func updateUI(field: ItemSelectionType, item: IdNameModel) {

        switch field {

        case .division:
            model?.division = item
            divisionTextField.text = item.name

            // reset dependent fields
            model?.brick = nil
            model?.account = nil
            model?.doctor = nil

        case .brick:
            model?.brick = item
            brickTextField.text = item.name

            model?.account = nil
            model?.doctor = nil

        case .accountType:
            model?.accountType = item
            accountTypeTextField.text = item.name

        case .account:
            model?.account = item
            accountTextField.text = item.name

            model?.doctor = nil

        case .doctor:
            model?.doctor = item
            doctorTextField.text = item.name

        case .visitType:
            model?.visitType = item          // ✅ ID محفوظ
            visitTypeTextField.text = item.name

        case .shiftType:
            model?.shiftType = item          // ✅ ID محفوظ
            shiftTypeTextField.text = item.name
            
        }
    }

}

// MARK: - Borders
private extension CellUnPlannedVisit {

    private func updateArrow(
        _ imageView: UIImageView,
        hasValue: Bool
    ) {
        imageView.tintColor = hasValue ? baseColor : .lightGray
    }

    func updateBorders() {

        update(stackTappedBrick, model?.brick)
        updateArrow(drows[1], hasValue: model?.brick != nil)

        update(stackTappedAccountType, model?.accountType)
        updateArrow(drows[2], hasValue: model?.accountType != nil)

        update(stackTappedAccount, model?.account)
        updateArrow(drows[3], hasValue: model?.account != nil)

        update(stackTappedDoctor, model?.doctor)
        updateArrow(drows[4], hasValue: model?.doctor != nil)

        update(stackTappedVisitType, model?.visitType)
        updateArrow(drows[5], hasValue: model?.visitType != nil)

        update(stackTappedShiftType, model?.shiftType)
        updateArrow(drows[6], hasValue: model?.shiftType != nil)
        update(stackComment, model?.comment)
    }

    func update(
        _ stack: UIStackView,
        _ value: Any?,
        style: BorderStyle = .optional
    ) {
        stack.layer.cornerRadius = stack.frame.height / 2
        stack.layer.borderWidth = 1.5

        switch style {
        case .required:
            stack.layer.borderColor = baseColor.cgColor
        case .optional:
            stack.layer.borderColor =
                (value == nil ? UIColor.lightGray : baseColor).cgColor
        }
    }
}

// MARK: - Data Helpers
private extension CellUnPlannedVisit {

    var divisionData: [IdNameModel] {
        
        guard
            let user = LocalStorageManager.shared.getLoggedUser(),
            let userDivIdsString = user.divIds,
            let divisions = masterData?.Data?.divisions
        else {
            return []
        }

        // "1,2,5" -> ["1","2","5"]
        let userDivIds = Set(
            userDivIdsString
                .split(separator: ",")
                .map { String($0.trimmingCharacters(in: .whitespaces)) }
        )

        return divisions
            .filter { division in
                guard let id = division.id else { return false }
                return userDivIds.contains(id)
            }
            .map {
                IdNameModel(
                    id: $0.id,
                    name: $0.name,
                    line_id: "",
                    line_division_id: ""
                )
            }
    }

    var brickData: [IdNameModel] {
        masterData?.Data?.bricks?
            .map {
                IdNameModel(
                    id: $0.id,
                    name: $0.name,
                    ter_id: $0.ter_id
                )
            } ?? []
    }

    var accountTypeData: [IdNameModel] {
        masterData?.Data?.account_types?
            .map { IdNameModel(id: $0.id, name: $0.name) } ?? []
    }
    func accountsForBrick(_ brickID: String) -> [IdNameModel] {
        LocalStorageManager.shared
            .getAccountsDoctors()?
            .Data?
            .Accounts?
            .filter {
                guard let idString = $0.brick_id,
                      let id = Int(idString) else { return false }
                return id == Int(brickID)
            }
            .map {
                IdNameModel(
                    id: $0.id,
                    name: $0.name ?? "",
                    line_id: "",//$0.line_id ?? 0,
                    ll: $0.team_ll ?? "",
                    lg: $0.team_lg ?? ""
                )
            } ?? []
    }

    func doctorsForAccount(_ accountID: String) -> [IdNameModel] {
        LocalStorageManager.shared.getAccountsDoctors()?
            .Data?.Doctors?
            .filter { $0.d_account_id ?? "" == accountID }
            .map { IdNameModel(id: $0.id, name: $0.name) } ?? []
    }
}

// MARK: - UITextFieldDelegate
extension CellUnPlannedVisit: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        didChangeComment?(textField.text)
        updateBorders()
    }
}
