//
//  ProductListVC.swift
//  Gemstone Pro
//
//  Created by Ahmed on 05/01/2026.
//

import UIKit
import RxCocoa
import RxSwift
class ProductListVC: BaseView {
    
    // MARK: - Outlets
    @IBOutlet private weak var viewBackgroundHeader: UIView!
    @IBOutlet private weak var appVersionLabel: UILabel!
    @IBOutlet private weak var companyNameLabel: UILabel!
    
    @IBOutlet private weak var buttonBack: UIButton!
    @IBOutlet private weak var tableView: UITableView!
//    @IBOutlet private weak var heightTableView: NSLayoutConstraint!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = ProductListViewModel()
    private var tableObservation: NSKeyValueObservation?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTableView()
//        observeTableHeight()
        bindUI()
        bindTableView()
        subscribeToLoading()
        viewModel.loadProducts()
    }
}

private extension ProductListVC {
    
    // MARK: - Loading Indicator
    private func subscribeToLoading() {
        viewModel.loadingBehavior
            .subscribe(onNext: { [weak self] isLoading in
                isLoading ? self?.startLoading() : self?.endLoading()
            })
            .disposed(by: disposeBag)
    }
    func setupUI() {
        drawRoundedCorners(for: viewBackgroundHeader, cornerRadius: 20, direction: .bottom)
        shadowView(viewBackgroundHeader)
        appVersionLabel.text = displayAppVersion()
        appVersionLabel.textColor = .green
        companyNameLabel.rx.text.onNext("I. \(user?.company_name ?? "")")
    }
}
private extension ProductListVC {
    
    func configureTableView() {
        tableView.register(UINib(nibName: "CellProductList", bundle: nil),
                           forCellReuseIdentifier: "CellProductList")
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
    }
}
private extension ProductListVC {
    
    func bindUI() {
        buttonBack.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { vc, _ in vc.dismiss() }
            .disposed(by: disposeBag)
    }
    
    func bindTableView() {
        viewModel.productsModelObservable
            .bind(to: tableView.rx.items(
                cellIdentifier: "CellProductList",
                cellType: CellProductList.self
            )) { _, model, cell in
                cell.configureCell(model: model)
            }
            .disposed(by: disposeBag)
        
//            Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Lines.self))
//                .bind { [unowned self] indexPath, model in
//
//                }.disposed(by: disposeBag)
    }
}

//private extension ProductListVC {
//    
//    func observeTableHeight() {
//        tableObservation = tableView.observe(\.contentSize) { [weak self] _, _ in
//            guard let self else { return }
//            heightTableView.constant = tableView.contentSize.height
//        }
//    }
//}
