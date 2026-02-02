//
//  CellUnPlannedVisit.swift
//  Puplo Pro
//
//  Created by Ahmed on 07/12/2025.
//

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

    private var currentItems: [Lines] = []
    private var currentField: ItemSelectionType?

    var model: VisitItem?
    var didSelectItem: ((Lines, ItemSelectionType) -> Void)?
    var didChangeComment: ((String?) -> Void)?

    let now = Date()
    
    // MARK: - Static Data
    private let shiftData: [Lines] = [
        Lines(id: "1", name: "AM"),
        Lines(id: "2", name: "PM"),
        Lines(id: "3", name: "Full Day")
    ]

    private let visitTypeData: [Lines] = [
        Lines(id: "1", name: "Single"),
        Lines(id: "2", name: "Double")
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
            print(" masterData?.Data?.bricks >>\(self?.masterData?.Data?.bricks ?? [])")
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
            guard let divisionID = model?.division?.id else {
                currentItems = []
                break
            }
            currentItems = brickData.filter { brick in
                print("team_id >>\(brick.team_id ?? "") divisionID >>\(divisionID)")        // for debugging
                return brick.team_id == String(divisionID)
            }
        case .accountType:
            currentItems = accountTypeData

        case .account:
            guard let brickID = model?.brick?.id else {
                currentItems = []
                break
            }
            currentItems = accountsForBrick(Int(brickID) ?? 0)

        case .doctor:
            guard let accountID = model?.account?.id else {
                currentItems = []
                break
            }
            currentItems = doctorsForAccount(Int(accountID) ?? 0)

        case .visitType:
            currentItems = visitTypeData

        case .shiftType:
            currentItems = shiftData
        }

        dropDown.dataSource = currentItems.compactMap { $0.name }
        dropDown.show()
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
    func updateUI(field: ItemSelectionType, item: Lines) {
      
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

    var divisionData: [Lines] {
        masterData?.Data?.divisions?
            .map {
                Lines(
                    id: $0.id,
                    name: $0.name,
                    team_id: $0.team_id,
                    line_id: $0.line_id,
                    line_division_id: $0.line_division_id
                )
            } ?? []
    }

    var brickData: [Lines] {
        masterData?.Data?.bricks?
            .map {
                Lines(
                    id: $0.id,
                    name: $0.name,
                    team_id: $0.team_id,
                    ter_id: $0.ter_id,
                )
            } ?? []
    }

    var accountTypeData: [Lines] {
        masterData?.Data?.account_types?
            .map { Lines(id: $0.id, name: $0.name) } ?? []
    }
    func accountsForBrick(_ brickID: Int) -> [Lines] {
        LocalStorageManager.shared
            .getAccountsDoctors()?
            .data?
            .accoutns?
            .filter {
                guard let idString = $0.brick_id,
                      let id = Int(idString) else { return false }
                return id == brickID
            }
            .map {
                Lines(
                    id: String($0.id ?? 0),
                    name: $0.name ?? "",
                    line_id: $0.line_id ?? 0,
                    ll: $0.ll ?? "",
                    lg: $0.lg ?? ""
                )
            } ?? []
    }

    func doctorsForAccount(_ accountID: Int) -> [Lines] {
        LocalStorageManager.shared.getAccountsDoctors()?
            .data?.doctors?
            .filter { $0.account_id == accountID }
            .map { Lines(id: String($0.id ?? 0), name: $0.name) } ?? []
    }
}

// MARK: - UITextFieldDelegate
extension CellUnPlannedVisit: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        didChangeComment?(textField.text)
        updateBorders()
    }
}
