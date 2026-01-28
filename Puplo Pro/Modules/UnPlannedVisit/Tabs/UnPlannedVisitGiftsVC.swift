//
//  UnPlannedVisitGiftsVC.swift
//  Puplo Pro
//
//  Created by Ahmed on 09/12/2025.
//

import UIKit
import RxCocoa
import RxSwift

class UnPlannedVisitGiftsVC: BaseView {
    
    // MARK: - Outlets
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var heightCollectionView: NSLayoutConstraint!
    @IBOutlet private weak var addGiveawayButton: UIButton!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = UnPlannedVisitGiftsViewModel()
    private var expandedIndex: Int?
    private var collectionViewObservation: NSKeyValueObservation?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
        registerCollectionCells()
        observeCollectionHeights()
        bindAddGiveawayCollectionView()
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addGiveawayButton.layer.cornerRadius = addGiveawayButton.frame.height / 2
        addGiveawayButton.layer.masksToBounds = true
    }
}
// MARK: - CollectionView Setup
private extension UnPlannedVisitGiftsVC {
    func registerCollectionCells() {
        collectionView.registerCell(cellClass: CellGifts.self)
    }
}

// MARK: - Rx Bindings
private extension UnPlannedVisitGiftsVC {
    
    func bindUI() {
        
        viewModel.allGiftsSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] allSelected in
                self?.addGiveawayButton.isHidden = allSelected
            })
            .disposed(by: disposeBag)
        
        addGiveawayButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { vc, _ in
                vc.viewModel.addGift(name: "Select Giveaway")
            }
            .disposed(by: disposeBag)
    }
    
    func bindAddGiveawayCollectionView() {
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
        viewModel.gifts
            .bind(to: collectionView.rx.items(
                cellIdentifier: String(describing: CellGifts.self),
                cellType: CellGifts.self
            )) { [weak self] index, model, cell in
                guard let self = self else { return }
                
                self.style(view: cell.stackSelect, cornerRadius: cell.stackSelect.frame.height / 2, borderWidth: 1.5, borderColor: baseColor)
                self.style(view: cell.stackButtons, cornerRadius: cell.stackButtons.frame.height / 2, borderWidth: 1.5, borderColor: baseColor)
                
                cell.deleteIndex = { [weak self] in
                    self?.viewModel.deleteGift(at: index)
                }
                cell.tag = index
                cell.configure(with: model, index: index)
                
                cell.didSelectItem = { [weak self] item in
                    guard let self = self else { return }
                    
                    var items = self.viewModel.gifts.value
                    
                    if items.enumerated().contains(where: { $0.offset != index && $0.element.id == item.id }) {
                        self.showAlert(alertTitle: "Warning", alertMessage: "This item was added by")
                        return
                    }
                    items[index] = item
                    self.viewModel.gifts.accept(items)
                    cell.nameLabel.text = item.name
                    LocalStorageManager.shared.saveGiftsData(model: items)
                }
                cell.onCountChanged = { [weak self] newCount in
                    self?.viewModel.updateGiftCount(at: index, count: "\(newCount)")
                }
                
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Collection Height Observation
private extension UnPlannedVisitGiftsVC {
    func observeCollectionHeights() {
        collectionViewObservation = collectionView.observe(\.contentSize) { [weak self] cv, _ in
            self?.heightCollectionView.constant = cv.contentSize.height
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension UnPlannedVisitGiftsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let spacing: CGFloat = 10
        return CGSize(width: (collectionView.bounds.width - spacing * 3) / 1, height: 50)
    }
}

