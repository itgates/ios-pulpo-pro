//
//  ActualVisitVC.swift
//  Puplo Pro
//
//  Created by Ahmed on 21/12/2025.
//

import UIKit
import RxSwift
import RxCocoa

enum FilterType {
    case dateFrom, dateTo
}

final class ActualVisitVC: BaseView {

    // MARK: - Outlets
    @IBOutlet private weak var viewBackgroundHeader: UIView!
    @IBOutlet private weak var appVersionLabel: UILabel!
    @IBOutlet private weak var companyNameLabel: UILabel!
    @IBOutlet private weak var buttonBack: UIButton!
    
    @IBOutlet weak var viewShadowFilter: UIView!
    @IBOutlet weak var stackColapseTapped: UIStackView!
    @IBOutlet weak var viewTappedDateFrom: UIView!
    @IBOutlet weak var dateFromLabel: UILabel!
    @IBOutlet weak var viewTappedDateTo: UIView!
    @IBOutlet weak var dateToLabel: UILabel!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var stackFilter: UIStackView!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightTableView: NSLayoutConstraint!

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = ActualVisitViewModel()
    private var selectedFilterType: FilterType?
    private var tableObservation: NSKeyValueObservation?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTableView()
        observeTableHeight()
        bindActions()
        bindTableView()
        subscribeToLoading()
        viewModel.fetchData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideFilterStack(animated: false)
    }
}

// MARK: - UI Setup
private extension ActualVisitVC {
    
    func setupUI() {
        drawRoundedCorners(for: viewBackgroundHeader, cornerRadius: 20, direction: .bottom)
        shadowView(viewBackgroundHeader)
        appVersionLabel.text = displayAppVersion()
        appVersionLabel.textColor = .green
        companyNameLabel.rx.text.onNext("I. \(user?.company_name ?? "")")
        
        style(view: viewShadowFilter, cornerRadius: 10)
        style(view: applyButton, cornerRadius: applyButton.frame.height / 2)
        styleDateView(viewTappedDateFrom)
        styleDateView(viewTappedDateTo)
        shadowView(viewShadowFilter, color: .gray, opacity: 0.13, offset: .zero, radius: 10)
        dateFromLabel.text = Date().formattedDate
        dateToLabel.text = Date().formattedDate
    }
    
    func styleDateView(_ view: UIView) {
        style(view: view, cornerRadius: view.frame.height / 2, borderWidth: 2, borderColor: baseColor, backgroundColor: .white)
    }
}

// MARK: - TableView
private extension ActualVisitVC {
    
    func configureTableView() {
        tableView.register(UINib(nibName: "CellActualVisit", bundle: nil), forCellReuseIdentifier: "CellActualVisit")
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 330
    }
    
    func bindTableView() {
        viewModel.visitObservable
            .bind(to: tableView.rx.items(cellIdentifier: "CellActualVisit", cellType: CellActualVisit.self)) { [weak self] _, model, cell in
                guard let self = self else { return }
                cell.viewContiner.layer.cornerRadius = 8
                self.shadowView(cell.viewContiner, color: .gray, opacity: 0.13, offset: .zero, radius: 10)
                cell.configure(with: model)
                cell.onMapTapped = {
                    let vc = MyLocationVC()
                    vc.delegateType = .actual
                    vc.itemModel = model
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Actions & Filter
private extension ActualVisitVC {
    
    func bindActions() {
        buttonBack.rx.tap.throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind { [weak self] in self?.dismiss() }
            .disposed(by: disposeBag)
        
        stackColapseTapped.onTap { [weak self] in self?.toggleFilterStack() }
        viewTappedDateFrom.onTap { [weak self] in self?.openCalendar(for: .dateFrom) }
        viewTappedDateTo.onTap { [weak self] in self?.openCalendar(for: .dateTo) }
        applyButton.rx.tap.bind { [weak self] in self?.applyDateFilter() }.disposed(by: disposeBag)
    }
    
    func applyDateFilter() {
        guard let fromText = dateFromLabel.text, !fromText.isEmpty,
              let toText = dateToLabel.text, !toText.isEmpty else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let fromDate = formatter.date(from: fromText),
              let toDate = formatter.date(from: toText) else { return }
        
        let filtered = viewModel.filterVisits(from: fromDate, to: toDate)
        print("Filtered Products: \(filtered)")
        viewModel.updateVisits(filtered)
        hideFilterStack()
    }
}

// MARK: - Filter Animation
private extension ActualVisitVC {
    func toggleFilterStack() { stackFilter.isHidden ? showFilterStack() : hideFilterStack() }
    func showFilterStack() { stackFilter.isHidden = false; UIView.animate(withDuration: 0.3) { self.stackFilter.alpha = 1 } }
    func hideFilterStack(animated: Bool = true) { stackFilter.alpha = 0; stackFilter.isHidden = true }
}

// MARK: - Calendar
private extension ActualVisitVC {
    func openCalendar(for type: FilterType) {
        selectedFilterType = type
        let calendarVC = CalenderVC()
        calendarVC.delegateDate = self
        calendarVC.selectAllDates = true
        showPopUp(view: calendarVC)
    }
}

// MARK: - Table Height
private extension ActualVisitVC {
    func observeTableHeight() {
        tableObservation = tableView.observe(\.contentSize) { [weak self] _, _ in
            self?.heightTableView.constant = self?.tableView.contentSize.height ?? 0
        }
    }
}

// MARK: - Loading
private extension ActualVisitVC {
    func subscribeToLoading() {
        viewModel.loadingBehavior.subscribe(onNext: { [weak self] isLoading in
            isLoading ? self?.startLoading() : self?.endLoading()
        }).disposed(by: disposeBag)
    }
}

// MARK: - Calendar Delegate
extension ActualVisitVC: BackSelectDate {
    func selectDate(date: String) {
        switch selectedFilterType {
        case .dateFrom: dateFromLabel.text = date
        case .dateTo: dateToLabel.text = date
        case .none: break
        }
    }
}
