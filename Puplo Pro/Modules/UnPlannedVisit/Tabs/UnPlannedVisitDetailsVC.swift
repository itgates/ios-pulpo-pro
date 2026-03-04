//
//  UnPlannedVisitDetailsVC.swift
//  Gemstone Pro
//
//  Created by Ahmed on 09/12/2025.
//

import UIKit
import RxCocoa
import RxSwift
enum UnPlannedItem {
    case normal(IdNameModel)
    case manager(String)
}
final class UnPlannedVisitDetailsVC: BaseView, UIScrollViewDelegate {

    // MARK: - Outlets
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var heightCollectionView: NSLayoutConstraint!

    @IBOutlet private weak var collectionViewAddManager: UICollectionView!
    @IBOutlet private weak var heightCollectionViewAddManager: NSLayoutConstraint!

    @IBOutlet private weak var addManagerButton: UIButton!

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = UnPlannedVisitDetailsViewModel()

    private var collectionViewObservation: NSKeyValueObservation?
    private var collectionViewAddManagerObservation: NSKeyValueObservation?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        registerCollectionCells()
        observeCollectionHeights()
        bindUI()
        bindCollectionView()
        bindAddManagerCollectionView()
        viewModel.fetchData()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addManagerButton.layer.cornerRadius = addManagerButton.frame.height / 2
        addManagerButton.layer.masksToBounds = true
    }
}
private extension UnPlannedVisitDetailsVC {

    
    func setupUI() {
        LocationManager.shared.getCurrentLocation { lat, lng in
            LocalStorageManager.shared.saveVisitStartLocation(lat: lat, lng: lng)
        }
    }
}
private extension UnPlannedVisitDetailsVC {

    func registerCollectionCells() {
        collectionView.registerCell(cellClass: CellUnPlannedVisit.self)
        collectionViewAddManager.registerCell(cellClass: CellAddManager.self)
        setupFlowLayout(for: collectionView)
    }

    func setupFlowLayout(for collectionView: UICollectionView) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        let spacing: CGFloat = 10
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }
}
private extension UnPlannedVisitDetailsVC {

    func bindUI() {

        addManagerButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { vc, _ in
                vc.viewModel.addManager(name: "Manager")
            }
            .disposed(by: disposeBag)

        viewModel.shouldShowAddManager
            .observe(on: MainScheduler.instance)
            .bind { [weak self] shouldShow in
                self?.addManagerButton.isHidden = !shouldShow
            }
            .disposed(by: disposeBag)
    }

    func bindCollectionView() {
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)

        viewModel.visitItems
            .bind(to: collectionView.rx.items(
                cellIdentifier: String(describing: CellUnPlannedVisit.self),
                cellType: CellUnPlannedVisit.self
            )) { [weak self] index, model, cell in
                self?.configureCell(cell, with: model, at: index)
            }
            .disposed(by: disposeBag)
    }

    func bindAddManagerCollectionView() {
        collectionViewAddManager.rx.setDelegate(self).disposed(by: disposeBag)

        viewModel.managers
            .bind(to: collectionViewAddManager.rx.items(
                cellIdentifier: String(describing: CellAddManager.self),
                cellType: CellAddManager.self
            )) { [weak self] index, model, cell in
                self?.configureManagerCell(cell, with: model, at: index)
            }
            .disposed(by: disposeBag)
    }
}
private extension UnPlannedVisitDetailsVC {

    func configureCell(
        _ cell: CellUnPlannedVisit,
        with model: VisitItem,
        at index: Int
    ) {
        cell.tag = index
        cell.configure(with: model)

        // Shadow
        style(view: cell.shadowView, cornerRadius: 10)
        shadowView(
            cell.shadowView,
            color: .gray,
            opacity: 0.15,
            offset: .zero,
            radius: 12
        )
        cell.showWarning = { [weak self] message in
            self?.showAlert(
                alertTitle: "Warning",
                alertMessage: message
            )
        }
        // Selection callback (Model only)
        cell.didSelectItem = { [weak self] item, type in
            guard let self else { return }

            let warning = self.viewModel.updateSelection(
                at: index,
                item: item,
                type: type
            )

            if let warning {
                self.showAlert(
                    alertTitle: "Warning",
                    alertMessage: warning
                )
            }
            
            if type == .visitType {
                   let shouldShow =
                       self.viewModel.visitItems.value.contains {
                           $0.visitType?.name == "Double"
                       }

                   self.addManagerButton.isHidden = !shouldShow
               }
        }
        cell.didChangeComment = { [weak self] comment in
            guard let self else { return }
            viewModel.updateComment(at: index, text: comment)
        }
    }

    func configureManagerCell(
        _ cell: CellAddManager,
        with model: IdNameModel,
        at index: Int
    ) {
        cell.tag = index
        cell.configure(with: model, index: index)

        style(
            view: cell.stackSelect,
            cornerRadius: 25,
            borderWidth: 1.5,
            borderColor: baseColor
        )

        cell.didSelectItem = { [weak self] item in
            guard let self else { return }

            var managers = self.viewModel.managers.value

            if managers.enumerated().contains(
                where: { $0.offset != index && $0.element.id == item.id }
            ) {
                self.showAlert(
                    alertTitle: "Warning",
                    alertMessage: "This manager already exists"
                )
                return
            }

            managers[index] = item
            self.viewModel.managers.accept(managers)
            LocalStorageManager.shared.saveManagerData(managers)
        }

        cell.deleteIndex = { [weak self] in
            self?.viewModel.deleteManager(at: index)
        }
    }
}
private extension UnPlannedVisitDetailsVC {

    func observeCollectionHeights() {
        collectionViewObservation = collectionView.observe(
            \.contentSize
        ) { [weak self] cv, _ in
            self?.heightCollectionView.constant = cv.contentSize.height
        }

        collectionViewAddManagerObservation = collectionViewAddManager.observe(
            \.contentSize
        ) { [weak self] cv, _ in
            self?.heightCollectionViewAddManager.constant = cv.contentSize.height
        }
    }
}
extension UnPlannedVisitDetailsVC: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let spacing: CGFloat = 10

        if collectionView == collectionViewAddManager {
            return CGSize(
                width: collectionView.bounds.width - spacing * 2,
                height: 50
            )
        } else {
            return CGSize(
                width: collectionView.bounds.width - spacing * 2,
                height: 325
            )
        }
    }
}
