
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
    static let userPhonePrefix = "Phone: "
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
    @IBOutlet private weak var userPhoneLabel: UILabel!
    
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
        checkUpdateVersion()
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
            .zip(collectionView.rx.itemSelected,
                 collectionView.rx.modelSelected(HomeModel.self))
            .bind { [weak self] _, model in
                
                guard let self = self else { return }
                
                if model.name == "Unplanned Visit" {
                    if !self.viewModel.canOpenUnplanned() {
                        self.showAlert( alertTitle: "Error", alertMessage: "You exceeded the allowed unplanned visits limit.")
                        return
                    }
                }
                self.navigateIfPossible(for: model)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Load User Data
private extension HomeVC {
    
    func loadUserData() {
        guard let user = RealmStorageManager.shared.getLoggedUser() else { return }
        
        userNameLabel.rx.text.onNext(user.fullname)
        guard !user.mobile.isEmpty else {
            userPhoneLabel.rx.isHidden.onNext(true)
            return
        }
        let mobile = user.mobile
        userPhoneLabel.rx.text.onNext(Constants.userPhonePrefix + mobile)
        
        dateLabel.rx.text.onNext("Date \(user.check_in_date)")
        timeLabel.rx.text.onNext("Time \(user.check_in_time)")
        
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
        let height = view.bounds.height * 0.15

        return CGSize(width: width, height: height)
    }

}

// MARK: - check Update Version
extension HomeVC {
    
    func checkUpdateVersion() {
        viewModel.checkAppStore { [weak self] isNew, version in
            guard let self else { return }
            if isNew == true{
                let vc = ForceUpdateVC()
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
}
