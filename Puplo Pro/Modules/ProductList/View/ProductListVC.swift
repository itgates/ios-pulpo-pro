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
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = ProductListViewModel()
    private var tableObservation: NSKeyValueObservation?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTableView()
        bindUI()
        bindTableView()
        viewModel.loadProducts()
    }
}

private extension ProductListVC {
    
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
