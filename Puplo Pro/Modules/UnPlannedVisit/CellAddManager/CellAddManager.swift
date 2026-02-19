//  CellAddManager.swift
//  Gemstone Pro
//
import UIKit
import RxCocoa
import RxSwift
import DropDown

class CellAddManager: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var stackSelect: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let dropDown = DropDown()
    private var currentDropDownItems: [IdNameModel] = []
    private let managerDataRelay = BehaviorRelay<[IdNameModel]>(value: [])
    var deleteIndex: (() -> Void)?
    var didSelectItem: ((IdNameModel) -> Void)?

    private var managerData: [IdNameModel]? {
        LocalStorageManager.shared.getMasterData()?.Data?.managers
    }

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        bindDeleteButton()
        setupStackGestures()
        setupDropDown()
    }
}

// MARK: - Configuration
extension CellAddManager {
    func configure(with model: IdNameModel, index: Int) {
        nameLabel.text = model.name
        guard let data = managerData else { return }
        managerDataRelay.accept(data)
        updateDropDown(data)
    }
}

// MARK: - UI Setup & DropDown
private extension CellAddManager {
    func bindDeleteButton() {
        deleteButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind { [weak self] in self?.deleteIndex?() }
            .disposed(by: disposeBag)
    }

    func setupStackGestures() {
        stackSelect.onTap { [weak self] in
            self?.dropDown.show()
        }
    }

    func updateDropDown(_ items: [IdNameModel]) {
        currentDropDownItems = items
        dropDown.dataSource = items.compactMap { $0.name }
    }

    func setupDropDown() {
        DropDown.startListeningToKeyboard()
        let appearance = DropDown.appearance()
        appearance.cellHeight = 40
        appearance.backgroundColor = .white
        appearance.selectionBackgroundColor = UIColor(red: 0.65, green: 0.82, blue: 1, alpha: 0.2)
        appearance.setupCornerRadius(10)
        appearance.shadowColor = UIColor(white: 0.6, alpha: 1)
        appearance.animationduration = 0.25
        appearance.textColor = mainColor

        dropDown.anchorView = stackSelect
        dropDown.direction = .bottom
        dropDown.semanticContentAttribute = .forceLeftToRight
        dropDown.bottomOffset = CGPoint(x: 0, y: stackSelect.bounds.height)
        dropDown.width = stackSelect.bounds.width
        
        dropDown.selectionAction = { [weak self] index, itemName in
            guard let self = self, index < self.currentDropDownItems.count else { return }
            let selectedLine = self.currentDropDownItems[index]
            self.didSelectItem?(selectedLine)
        }

    }
}
