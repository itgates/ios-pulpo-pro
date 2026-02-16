//
//  ReportsVC.swift
//  Puplo Pro
//
//  Created by Ahmed on 13/02/2026.

import UIKit
import RxCocoa
import RxSwift

final class ReportsVC: BaseView {

    // MARK: - Outlets
    @IBOutlet private weak var viewBackgroundHeader: UIView!
    @IBOutlet private weak var appVersionLabel: UILabel!
    @IBOutlet private weak var companyNameLabel: UILabel!
    
    @IBOutlet private weak var buttonBack: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var heightTableView: NSLayoutConstraint!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = ReportsViewModel()
    private var tableObservation: NSKeyValueObservation?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTableView()
        observeTableHeight()
        bindUI()
        bindTableView()
        viewModel.fetchData()
    }
}
private extension ReportsVC {
    
    func setupUI() {
        drawRoundedCorners(for: viewBackgroundHeader, cornerRadius: 20, direction: .bottom)
        shadowView(viewBackgroundHeader)
        appVersionLabel.text = displayAppVersion()
        appVersionLabel.textColor = .green
        companyNameLabel.rx.text.onNext("I. \(user?.company_name ?? "")")
    }
}
private extension ReportsVC {
    
    func configureTableView() {
        tableView.register(UINib(nibName: "ReportsCell", bundle: nil),
                           forCellReuseIdentifier: "ReportsCell")
        tableView.tableFooterView = UIView()
    }
}
private extension ReportsVC {
    
    func bindUI() {
        buttonBack.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { vc, _ in vc.dismiss() }
            .disposed(by: disposeBag)
    }
    
    func bindTableView() {
        viewModel.reportsModelObservable
            .bind(to: tableView.rx.items(
                cellIdentifier: "ReportsCell",
                cellType: ReportsCell.self
            )) { _, model, cell in
                self.shadowView(cell.viewBackground,color: .gray,opacity: 0.13,offset: .zero, radius: 10)
                cell.configureCell(model: model)
            }
            .disposed(by: disposeBag)
        
            Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(HomeModel.self))
                .bind { [unowned self] indexPath, model in
                    self.navigateIfPossible(for: model)
                }.disposed(by: disposeBag)
    }
}
private extension ReportsVC {
    
    func observeTableHeight() {
        tableObservation = tableView.observe(\.contentSize) { [weak self] _, _ in
            guard let self else { return }
            heightTableView.constant = tableView.contentSize.height
        }
    }
}
