//
//  NewPlanVC.swift
//  Puplo Pro
//
//  Created by Ahmed on 05/01/2026.
//

import UIKit
import RxCocoa
import RxSwift
class NewPlanVC: BaseView {

    // MARK: - Outlets
    @IBOutlet private weak var viewBackgroundHeader: UIView!
    @IBOutlet private weak var appVersionLabel: UILabel!
    @IBOutlet private weak var companyNameLabel: UILabel!
    
    @IBOutlet private weak var buttonBack: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var heightTableView: NSLayoutConstraint!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = NewPlanViewModel()
    private var tableObservation: NSKeyValueObservation?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTableView()
        observeTableHeight()
        bindUI()
        bindTableView()
        subscribeToLoading()
        viewModel.loadProducts()
    }
}

private extension NewPlanVC {
    
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
private extension NewPlanVC {
    
    func configureTableView() {
        tableView.register(UINib(nibName: "CellNewPlan", bundle: nil),
                           forCellReuseIdentifier: "CellNewPlan")
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 150
    }
}
private extension NewPlanVC {
    
    func bindUI() {
        buttonBack.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { vc, _ in vc.dismiss() }
            .disposed(by: disposeBag)
    }
    
    func bindTableView() {
        viewModel.newPlanModelObservable
            .bind(to: tableView.rx.items(
                cellIdentifier: "CellNewPlan",
                cellType: CellNewPlan.self
            )) { _, model, cell in
                cell.viewContiner.layer.cornerRadius = 8
                self.shadowView(cell.viewContiner, color: .gray, opacity: 0.13, offset: .zero, radius: 10)
                cell.configure(with: model)
                
                let modelMap = ActualVisitModel(
                    id: "\(model.id)",
                    account_name: model.accountName ?? "",
                    doctor_name: model.doctorName ?? "",
                    visit_date: model.visitDate ?? "",
                    llAcccount: model.latitude ?? "",
                    lgAcccount: model.longitude ?? "",
                    isUploaded: false
                )
                cell.onMapTapped = {
                    let vc = MyLocationVC()
                    vc.delegateType = .plannedVisit
                    vc.itemModel = modelMap
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
}

private extension NewPlanVC {
    
    func observeTableHeight() {
        tableObservation = tableView.observe(\.contentSize) { [weak self] _, _ in
            guard let self else { return }
            heightTableView.constant = tableView.contentSize.height
        }
    }
}
