//
//  UnPlannedVisitItemsVC.swift
//  Gemstone Pro
//
//  Created by Ahmed on 09/12/2025.
//

import UIKit
import RxCocoa
import RxSwift

class UnPlannedVisitItemsVC: BaseView {
    
    // MARK: - Outlets
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var heightCollectionView: NSLayoutConstraint!
    @IBOutlet private weak var addProductButton: UIButton!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = UnPlannedVisitItemsViewModel()
    private var expandedIndex: Int?
    private var cellHeights: [Int: CGFloat] = [:]
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
        addProductButton.layer.cornerRadius = addProductButton.frame.height / 2
        addProductButton.layer.masksToBounds = true
    }
}
// MARK: - CollectionView Setup
private extension UnPlannedVisitItemsVC {
    func registerCollectionCells() {
        collectionView.registerCell(cellClass: CellProduct.self)
    }
}

// MARK: - Rx Bindings
private extension UnPlannedVisitItemsVC {
    
    func bindUI() {
        
        addProductButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { vc, _ in
                vc.viewModel.addProducts()
            }
            .disposed(by: disposeBag)
    }
    
    func bindAddGiveawayCollectionView() {
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
        viewModel.products
            .bind(to: collectionView.rx.items(
                cellIdentifier: String(describing: CellProduct.self),
                cellType: CellProduct.self
            )) { [weak self] index, model, cell in
                guard let self = self else { return }
                style(view: cell.shadowView,cornerRadius: 10)
                self.shadowView(cell.shadowView,
                                color: .gray,
                                opacity: 0.15,
                                offset: .zero,
                                radius: 12)
                
                let stacks: [UIStackView?] = [
                    cell.stackSelectProduct,
                    cell.stackButtons,
                    cell.stackFeedBack,
                    cell.stackComment,
                    cell.stackMarket,
                    cell.stackFollowUps,
                    cell.stackPayment,
                    cell.stackStock,
                    cell.stackOrder
                ]
                stacks.compactMap { $0 }.forEach { stack in
                    self.style(view: stack, cornerRadius: stack.frame.height / 2, borderWidth: 1.5, borderColor: baseColor)
                }
            
                cell.configure(with: model)
                cell.didSelectItem = { [weak self] item, type -> String? in
                    guard let self = self else { return nil }
                    let warning = self.viewModel.updateSelection(at: index, item: item, type: type)
                    if let warning = warning {
                        self.showAlert(alertTitle: "Warning", alertMessage: warning)
                    } else {
                        // تحديث الـ textField
                        if type == .product { cell.productNameTextField.text = item.name }
//                        else if type == .feedback { cell.feedbackTextField.text = item.name }
//                        else if type == .market { cell.marketTextField.text = item.name }
//                        else if type == .followUp { cell.followUpsTextField.text = item.name }
                    }
                    return warning
                }

                cell.onCountChanged = { [weak self] newCount in
                    self?.viewModel.updateProductsCount(at: index, count: "\(newCount)")
                }

                cell.deleteIndex = { [weak self] in
                    self?.viewModel.deleteProducts(at: index)
                }

                // text filed
                cell.onFeedBackChanged = { [weak self] text in
                    self?.viewModel.updateFeedBack(at: index, text: text)
                }
                cell.onMarketChanged = { [weak self] text in
                    self?.viewModel.updateMarket(at: index, text: text)
                }
                cell.onFollowUpsChanged = { [weak self] text in
                    self?.viewModel.updateFollowUps(at: index, text: text)
                }
                //
                cell.onCommentChanged = { [weak self] text in
                    self?.viewModel.updateComment(at: index, text: text)
                }

                cell.onPaymentChanged = { [weak self] text in
                    self?.viewModel.updatePayment(at: index, text: text)
                }

                cell.onStockChanged = { [weak self] text in
                    self?.viewModel.updateStock(at: index, text: text)
                }
                cell.onOrderChanged = { [weak self] text in
                    self?.viewModel.updateOrder(at: index, text: text)
                }
                
                cell.showPresentations = { [weak self] show in
                    guard let self = self else { return }

                    let isShown = show ?? false
                    self.cellHeights[index] = isShown ? 384 : 330

                    UIView.performWithoutAnimation {
                        self.collectionView.collectionViewLayout.invalidateLayout()
                        self.collectionView.layoutIfNeeded()
                    }
                }
                cell.passPresentations = { [weak self] presentations in
                    guard let self = self else { return }
                    print("presentations >>>\(presentations)")
                    viewModel.updatePresentations(at: index, presentation: presentations)
                }
                cell.onPresentations = { [weak self] slides in
                    guard let self = self else { return }
                    slidesWebViewVC(slides: slides)
                }
                
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Collection Height Observation
private extension UnPlannedVisitItemsVC {
    func observeCollectionHeights() {
        collectionViewObservation = collectionView.observe(\.contentSize) { [weak self] cv, _ in
            self?.heightCollectionView.constant = cv.contentSize.height
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension UnPlannedVisitItemsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let model = viewModel.products.value[indexPath.item]
        let height: CGFloat = (model.presentations?.isEmpty == false) ? 270 : 230

        let spacing: CGFloat = 10
        return CGSize(
            width: (collectionView.bounds.width - spacing * 3),
            height: height
        )
    }
}
