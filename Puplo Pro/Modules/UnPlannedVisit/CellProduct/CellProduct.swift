//
//  CellProduct.swift
//  Gemstone Pro
//
//  Created by Ahmed on 16/12/2025.
//

import UIKit
import RxCocoa
import RxSwift
import DropDown

final class CellProduct: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var shadowView: UIView!
    
    @IBOutlet weak var stackSelectProduct: UIStackView!
    @IBOutlet weak var productNameTextField: UITextField!
    
    @IBOutlet weak var stackButtons: UIStackView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var countProductLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    
    @IBOutlet weak var stackFeedBack: UIStackView!
    @IBOutlet weak var feedbackTextField: UITextField!
//    
    @IBOutlet weak var stackMarket: UIStackView!
    @IBOutlet weak var marketTextField: UITextField!
//    
    @IBOutlet weak var stackFollowUps: UIStackView!
    @IBOutlet weak var followUpsTextField: UITextField!
    
    @IBOutlet weak var stackComment: UIStackView!
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var stackPayment: UIStackView!
    @IBOutlet weak var paymentTextField: UITextField!
    
    @IBOutlet weak var stackStock: UIStackView!
    @IBOutlet weak var stockTextField: UITextField!
    
    @IBOutlet weak var stackOrder: UIStackView!
    @IBOutlet weak var orderTextField: UITextField!
    
    @IBOutlet weak var collectionViewPresentations: UICollectionView!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let dropDown = DropDown()
    
    var didSelectItem: ((IdNameModel, ProductSelectionType,[Presentations]) -> String?)?
    
    var onCountChanged: ((Int) -> Void)?
    var deleteIndex: (() -> Void)?
    
    var onFeedBackChanged: ((String?) -> Void)?
    var onMarketChanged: ((String?) -> Void)?
    var onFollowUpsChanged: ((String?) -> Void)?
    
    var onCommentChanged: ((String?) -> Void)?
    var onPaymentChanged: ((String?) -> Void)?
    var onStockChanged: ((String?) -> Void)?
    var onOrderChanged: ((String?) -> Void)?
    var onPresentations: (([Slides]) -> Void)?
    
    private var count = 1 {
        didSet { countProductLabel.text = "\(count)" }
    }
    
    private var productsData: [IdNameModel]? {
        LocalStorageManager.shared.getMasterData()?.Data?.products
    }
    private var presentationsData: [Presentations] {
        LocalStorageManager.shared.getAppPresentationsModel()?.Data?.Presentations ?? []
    }
    private let presentationsRelay = BehaviorRelay<[Presentations]>(value: [])
    
    private var slidesData: [Slides] {
        LocalStorageManager.shared.getAppPresentationsModel()?.Data?.Slides ?? []
    }
//    private var feedBackData: [IdNameModel]? {
//        LocalStorageManager.shared.getMasterData()?.Data?.visitFeedBack
//    }
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupGestures()
        setupButtons()
        bindTextFields()
        registerCollectionCells()
        bindCollectionView()
    }
    // MARK: - UI
    private func setupUI() {
        // DropDown fields → read only
        [
            productNameTextField
        ].forEach { $0?.isUserInteractionEnabled = false }
    }
    // MARK: - Bind TextFields
    private func bindTextFields() {
        feedbackTextField.delegate = self
        marketTextField.delegate = self
        followUpsTextField.delegate = self
        
        commentTextField.delegate = self
        paymentTextField.delegate = self
        stockTextField.delegate = self
        orderTextField.delegate = self
    }
    // MARK: - Gestures
    private func setupGestures() {
        bind(stackSelectProduct, productsData, .product, productNameTextField)
    }
    
    private func bind(
        _ stack: UIStackView,
        _ data: [IdNameModel]?,
        _ type: ProductSelectionType,
        _ field: UITextField
    ) {
        stack.onTap { [weak self] in
            self?.showDropDown(items: data, anchor: stack, type: type, field: field)
        }
    }
    
    private func showDropDown(
        items: [IdNameModel]?,
        anchor: UIView,
        type: ProductSelectionType,
        field: UITextField
    ) {
        guard let items else { return }
        
        dropDown.hide()
        dropDown.dataSource = items.compactMap { $0.name }
        dropDown.anchorView = anchor
        dropDown.bottomOffset = CGPoint(x: 0, y: anchor.bounds.height)
 
        dropDown.selectionAction = { [weak self] index, title in
            guard let self = self else { return }
            let selectedItem = items[index]
            
            field.text = title

            if field == productNameTextField {
                let filteredPresentations = self.presentationsData.filter {
                    $0.product_id == selectedItem.id
                }
                self.didSelectItem?(selectedItem, .product, filteredPresentations)
                self.collectionViewPresentations.isHidden = filteredPresentations.isEmpty
                self.presentationsRelay.accept(filteredPresentations)
            }
        }
        dropDown.show()
    }
    
    // MARK: - Buttons
    private func setupButtons() {
        plusButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.count += 1
                self.onCountChanged?(self.count)
            }
            .disposed(by: disposeBag)
        
        minusButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.count > 1 ? (self.count -= 1) : self.deleteIndex?()
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Configure
    func configure(with model: ProductItem) {
        productNameTextField.text = model.product?.name
        feedbackTextField.text = model.feedback
        marketTextField.text = model.market
        followUpsTextField.text = model.followUp
        
        commentTextField.text = model.comment
        paymentTextField.text = model.payment
        stockTextField.text = model.stock
        orderTextField.text = model.order
        
        count = Int(model.count) ?? 1
//        if model.presentations?.count ?? 0 > 0  {
//            presentationsRelay.accept(model.presentations ?? [])
//        }
        let hasData = !(model.presentations?.isEmpty ?? true)
        collectionViewPresentations.isHidden = !hasData
        presentationsRelay.accept(model.presentations ?? [])
       
    }
}
// MARK: - UITextFieldDelegate
extension CellProduct: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        
        if text == feedbackTextField.text {
            self.onFeedBackChanged?(text)
        } else if text == marketTextField.text {
            self.onMarketChanged?(text)
        } else if text == followUpsTextField.text {
            self.onFollowUpsChanged?(text)
        } else if text == commentTextField.text {
            self.onCommentChanged?(text)
        } else if text == paymentTextField.text {
            self.onPaymentChanged?(text)
        } else if text == stockTextField.text{
            self.onStockChanged?(text)
        } else {
            self.onOrderChanged?(text)
        }
    }
}
// MARK: - CollectionView Setup
private extension CellProduct {
    func registerCollectionCells() {
        collectionViewPresentations.registerCell(cellClass: CellPresentations.self)
    }
}
// MARK: - Rx Bindings
private extension CellProduct {
    
    func bindCollectionView() {
        collectionViewPresentations.rx.setDelegate(self)
            .disposed(by: disposeBag)

        presentationsRelay
            .bind(to: collectionViewPresentations.rx.items(
                cellIdentifier: String(describing: CellPresentations.self),
                cellType: CellPresentations.self
            )) { index, model, cell in
                cell.configure(name: model.name)
            }
            .disposed(by: disposeBag)

        // didSelect
        Observable
            .zip(collectionViewPresentations.rx.itemSelected, collectionViewPresentations.rx.modelSelected(Presentations.self))
            .bind { [weak self] _, model in
                guard let self else { return }
                
                let relatedSlides = self.slidesData.filter {
                    $0.presentation_id == model.id
                   //check presentation_id for Presentations  $0.presentation_id == model.presentation_id
                }
                
//                print("Selected presentation id:", model.presentation_id ?? 0)
//                print("Slides count:", relatedSlides.count)
                onPresentations?(relatedSlides)
            }
            .disposed(by: disposeBag)
    }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension CellProduct: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let spacing: CGFloat = 10
        return CGSize(width: (collectionView.bounds.width - spacing * 3) / 3, height: 50)
    }
}
