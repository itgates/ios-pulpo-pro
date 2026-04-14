//
//  PlannedVisitListVC.swift
//  Gemstone Pro
//
//  Created by Ahmed on 05/01/2026.
//
import UIKit
import RxSwift
import RxCocoa

final class PlannedVisitListVC: BaseView {

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
//    @IBOutlet weak var heightTableView: NSLayoutConstraint!

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = PlannedVisitListViewModel()
    private var selectedFilterType: FilterType?
    private var tableObservation: NSKeyValueObservation?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTableView()
//        observeTableHeight()
        bindActions()
        bindTableView()
        subscribeToLoading()
        viewModel.fetchData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideFilterStack(animated: false)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyButton.layer.cornerRadius = applyButton.frame.height / 2
        applyButton.layer.masksToBounds = true
        styleDateView(viewTappedDateFrom)
        styleDateView(viewTappedDateTo)
    }
}

// MARK: - UI Setup
private extension PlannedVisitListVC {
    
    func setupUI() {
        drawRoundedCorners(for: viewBackgroundHeader, cornerRadius: 20, direction: .bottom)
        shadowView(viewBackgroundHeader)
        appVersionLabel.text = displayAppVersion()
        appVersionLabel.textColor = .green
        companyNameLabel.rx.text.onNext("I. \(user?.company_name ?? "")")
        
        style(view: viewShadowFilter, cornerRadius: 10)
        shadowView(viewShadowFilter, color: .gray, opacity: 0.13, offset: .zero, radius: 10)
        dateFromLabel.text = Date().formattedDate
        dateToLabel.text = Date().formattedDate
    }
    
    func styleDateView(_ view: UIView) {
        style(view: view, cornerRadius: view.frame.height / 2, borderWidth: 2, borderColor: baseColor, backgroundColor: .white)
    }
}

// MARK: - TableView
private extension PlannedVisitListVC {
    
    func configureTableView() {
        tableView.register(UINib(nibName: "CellPlannedVisitList", bundle: nil),
                           forCellReuseIdentifier: "CellPlannedVisitList")
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 122
    }
    
    func bindTableView() {
        viewModel.visitObservable
            .bind(to: tableView.rx.items(cellIdentifier: "CellPlannedVisitList", cellType: CellPlannedVisitList.self)) { [weak self] _, model, cell in
                guard let self = self else { return }
                cell.viewContiner.layer.cornerRadius = 8
                self.shadowView(cell.viewContiner, color: .gray, opacity: 0.13, offset: .zero, radius: 10)
                cell.configure(with: model)
                
                let modelMap = ActualVisitModel(
                    id: "\(model.id ?? "")",
                    account_type: model.account_type ?? "",
                    account_name: cell.accountName,
                    doctor_name: cell.doctorName,
                    shift_type: "\(model.shift ?? "")",
                    visit_date: model.insertion_date ?? "",
                    llAcccount: cell.onLat,
                    lgAcccount: cell.onLong,
                    isUploaded: false
                )
                cell.onMapTapped = {
                    if modelMap.lgAcccount.isEmpty || modelMap.llAcccount.isEmpty {
                        self.showAlert( alertTitle: "Error", alertMessage: "No location available")
                        return
                    }
                    let vc = MapVC()
                    vc.delegateType = .plannedVisit
                    vc.itemModel = modelMap
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Actions & Filter
private extension PlannedVisitListVC {
    
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
private extension PlannedVisitListVC {
    func toggleFilterStack() { stackFilter.isHidden ? showFilterStack() : hideFilterStack() }
    func showFilterStack() { stackFilter.isHidden = false; UIView.animate(withDuration: 0.3) { self.stackFilter.alpha = 1 } }
    func hideFilterStack(animated: Bool = true) { stackFilter.alpha = 0; stackFilter.isHidden = true }
}

// MARK: - Calendar
private extension PlannedVisitListVC {
    func openCalendar(for type: FilterType) {
        selectedFilterType = type
        let calendarVC = CalenderVC()
        calendarVC.delegateDate = self
        calendarVC.selectAllDates = true
        showPopUp(view: calendarVC)
    }
}

// MARK: - Table Height
//private extension PlannedVisitListVC {
//    func observeTableHeight() {
//        tableObservation = tableView.observe(\.contentSize) { [weak self] _, _ in
//            self?.heightTableView.constant = self?.tableView.contentSize.height ?? 0
//        }
//    }
//}

// MARK: - Loading
private extension PlannedVisitListVC {
    func subscribeToLoading() {
        viewModel.loadingBehavior.subscribe(onNext: { [weak self] isLoading in
            isLoading ? self?.startLoading() : self?.endLoading()
        }).disposed(by: disposeBag)
    }
}

// MARK: - Calendar Delegate
extension PlannedVisitListVC: BackSelectDate {
    func selectDate(date: String) {
        switch selectedFilterType {
        case .dateFrom: dateFromLabel.text = date
        case .dateTo: dateToLabel.text = date
        case .none: break
        }
    }
}
