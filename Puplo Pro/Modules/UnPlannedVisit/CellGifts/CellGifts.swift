//
//  CellGifts.swift
//  Puplo Pro
//
//  Created by Ahmed on 09/12/2025.

import UIKit
import RxCocoa
import RxSwift
import DropDown

class CellGifts: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet weak var stackSelect: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stackButtons: UIStackView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!

    // MARK: - Properties
    private let disposeBag = DisposeBag()

    var deleteIndex: (() -> Void)?
    var didSelectItem: ((Lines) -> Void)?
    var onCountChanged: ((Int) -> Void)?

    private let dropDown = DropDown()
    private var currentDropDownItems: [Lines] = []
    private let giftsDataRelay = BehaviorRelay<[Lines]>(value: [])
    
    private var giftsData: [Lines]? {
        LocalStorageManager.shared.getMasterData()?.data?.giveways
    }
    
    private var count: Int = 1 {
        didSet { countLabel.text = "\(count)" }
    }
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        bindButtons()
        setupStackGestures()
        setupDropDown()
    }

    // MARK: - Binding Buttons
    private func bindButtons() {
        plusButton.rx.tap
            .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
            .bind(with: self) { cell, _ in
                cell.count += 1
                cell.onCountChanged?(cell.count)
            }
            .disposed(by: disposeBag)

        minusButton.rx.tap
            .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
            .bind(with: self) { cell, _ in
                if cell.count > 1 {
                    cell.count -= 1
                    cell.onCountChanged?(cell.count)
                } else {
                    cell.deleteIndex?()
                }
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Configure
    func configure(with model: Lines, index: Int) {
        nameLabel.text = model.name
        count = Int(model.count ?? "1") ?? 1

        guard let data = giftsData else { return }
        giftsDataRelay.accept(data)
        updateDropDown(data)
    }
}
private extension CellGifts {
   
    func setupStackGestures() {
        stackSelect.onTap { [weak self] in
            self?.dropDown.show()
        }
    }

    func updateDropDown(_ items: [Lines]) {
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
