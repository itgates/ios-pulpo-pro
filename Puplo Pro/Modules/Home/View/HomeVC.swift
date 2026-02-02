//
//  HomeVC.swift
//  Puplo Pro
//
//  Created by Ahmed on 18/11/2025.
//

import UIKit
import RxCocoa
import RxSwift
import Kingfisher

// MARK: - Constants
private enum Constants {
    static let headerCornerRadius: CGFloat = 20
    static let userDataCornerRadius: CGFloat = 10
    static let userTypePrefix = "Type: "
    static let collectionItemHeight: CGFloat = 120
    static let collectionSpacing: CGFloat = 50
}

final class HomeVC: BaseView {

    // MARK: - Outlets
    @IBOutlet private weak var viewBackgroundHeader: UIView!
    @IBOutlet private weak var appVersionLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    
    @IBOutlet private weak var viewContentUserData: UIView!
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var userTypeLabel: UILabel!
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var heightCollectionView: NSLayoutConstraint!

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = HomeViewModel()
    private var collectionObservation: NSKeyValueObservation?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        setupUI()
        setupBindings()
        observeCollectionHeight()
        subscribeToLoading()
        viewModel.fetchData()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userImageView.layoutIfNeeded()
        userImageView.layer.cornerRadius = userImageView.bounds.height / 2
        userImageView.clipsToBounds = true
    }
}

// MARK: - Setup UI
private extension HomeVC {
    
    // MARK: - Loading Indicator
    private func subscribeToLoading() {
        viewModel.loadingBehavior
            .subscribe(onNext: { [weak self] isLoading in
                isLoading ? self?.startLoading() : self?.endLoading()
            })
            .disposed(by: disposeBag)
    }
    
    func setupUI() {
        setupHeader()
        setupUserDataView()
        registerCollectionCells()
        loadUserData()
    }
    
    func setupHeader() {
        drawRoundedCorners(for: viewBackgroundHeader, cornerRadius: Constants.headerCornerRadius, direction: .bottom)
        shadowView(viewBackgroundHeader)
        appVersionLabel.text = displayAppVersion()
        appVersionLabel.textColor = .green
        companyNameLabel.rx.text.onNext("I. \(user?.company_name ?? "")")
    }
    
    func setupUserDataView() {
        viewContentUserData.backgroundColor = baseColor
        viewContentUserData.layer.cornerRadius = Constants.userDataCornerRadius
        viewContentUserData.clipsToBounds = true
        
        makeCircular(userImageView)
    }
    func registerCollectionCells() {
        collectionView.registerCell(cellClass: CellCollectionViewHome.self)
    }
    
    func makeCircular(_ view: UIView) {
        view.layer.cornerRadius = view.frame.height / 2
        view.clipsToBounds = true
    }
}

// MARK: - Bindings
private extension HomeVC {
    
    func setupBindings() {
        setupCollectionBinding()
    }
    
    func setupCollectionBinding() {
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.homeModelObservable
            .bind(to: collectionView.rx.items(
                cellIdentifier: String(describing: CellCollectionViewHome.self),
                cellType: CellCollectionViewHome.self
            )) { _, model, cell in
                cell.configureCell(model: model)
            }
            .disposed(by: disposeBag)
        Observable
            .zip(collectionView.rx.itemSelected, collectionView.rx.modelSelected(HomeModel.self))
            .bind { [weak self] _, model in
                self?.navigateIfPossible(for: model)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Load User Data
private extension HomeVC {
    
    func loadUserData() {
        guard let user = LocalStorageManager.shared.getLoggedUser() else { return }
        
        userNameLabel.text = user.fullname
        userTypeLabel.text = Constants.userTypePrefix + (user.mobile ?? "")
        dateLabel.text = "Date \(user.check_in_date ?? "")"
        timeLabel.text = "Time \(user.check_in_time ?? "")"
        
//        if let urlString = user.url, let url = URL(string: urlString) {
//            userImageView.kf.setImage(with: url)
//        }
    }
}

// MARK: - Observe Collection Height
private extension HomeVC {
    
    func observeCollectionHeight() {
        collectionObservation = collectionView.observe(\.contentSize) { [weak self] _, _ in
            guard let self else { return }
            heightCollectionView.constant = collectionView.contentSize.height
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let width = (collectionView.frame.width - Constants.collectionSpacing) / 4
        let height = view.bounds.height * 0.15   // 18% من الشاشة

        return CGSize(width: width, height: height)
    }

}
