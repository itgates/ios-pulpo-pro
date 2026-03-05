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
    @IBOutlet private weak var addProductButton: UIButton!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = UnPlannedVisitItemsViewModel()
    private var expandedIndex: Int?
    private var cellHeights: [Int: CGFloat] = [:]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
        registerCollectionCells()
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
        
        viewModel.isAddEnabled
               .asObservable()
               .subscribe(onNext: { [weak self] enabled in
                   guard let self = self else { return }
                   self.setApplyButton(button: self.addProductButton, enabled: enabled)
               })
               .disposed(by: disposeBag)
        
        viewModel.showWarning
            .bind(with: self) { vc, message in
                vc.showAlert(alertTitle: "Warning", alertMessage: message)
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
                cell.didSelectItem = { [weak self] item, type, presentations -> String? in
                    guard let self = self else { return nil }
                    let warning = self.viewModel.updateSelection(at: index, item: item, type: type)
                    
                    if let warning = warning {
                        self.showAlert(alertTitle: "Warning", alertMessage: warning)
                        if type == .product {
                            cell.productNameTextField.text = ""
                            self.viewModel.updateSelection(at: index, item: IdNameModel(id: nil, name: nil), type: .product)
                            self.viewModel.updatePresentations(at: index, presentation: [])
                        }
                    } else {
                        if type == .product {
                            cell.productNameTextField.text = item.name
                            viewModel.updatePresentations(at: index, presentation: presentations)
                        }
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
                cell.onPresentations = { [weak self] slides in
                    guard let self = self else { return }
                    slidesWebViewVC(slides: slides)
                }
                
            }
            .disposed(by: disposeBag)
    }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension UnPlannedVisitItemsVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let height: CGFloat
        if let customHeight = cellHeights[indexPath.item] {
            height = customHeight
        } else {
            let model = viewModel.products.value[indexPath.item]
            height = (model.presentations?.isEmpty == false) ? 270 : 210
        }

        let spacing: CGFloat = 10
        return CGSize(
            width: (collectionView.bounds.width - spacing * 3),
            height: height
        )
    }
}
