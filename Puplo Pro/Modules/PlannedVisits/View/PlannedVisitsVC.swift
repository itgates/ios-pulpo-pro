//
//  PlannedVisitsVC.swift
//  Puplo Pro
//
//  Created by Ahmed on 30/12/2025.
//

import UIKit
import RxSwift
import RxCocoa

final class PlannedVisitsVC: BaseView {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var viewBackgroundHeader: UIView!
    @IBOutlet private weak var appVersionLabel: UILabel!
    @IBOutlet private weak var companyNameLabel: UILabel!
    @IBOutlet private weak var buttonBack: UIButton!
    
    @IBOutlet private weak var viewBackgroundButton: UIView!
    @IBOutlet private weak var amButton: UIButton!
    @IBOutlet private weak var pmButton: UIButton!
    @IBOutlet private weak var otherButton: UIButton!
    @IBOutlet private weak var officeWorkButton: UIButton!
    
    // filter
    @IBOutlet weak var stackShowFilter: UIStackView!
    @IBOutlet weak var viewShadowFilter: UIView!
    @IBOutlet weak var stackColapseTapped: UIStackView!
    @IBOutlet weak var viewTappedDateFrom: UIView!
    @IBOutlet weak var dateFromLabel: UILabel!
    @IBOutlet weak var viewTappedDateTo: UIView!
    @IBOutlet weak var dateToLabel: UILabel!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var stackFilter: UIStackView!
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var heightTableView: NSLayoutConstraint!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = PlannedVisitsViewModel()
    
    /// Holds the currently selected visit period
    private let selectedPeriod = BehaviorRelay<Period?>(value: nil)
    private var tableObservation: NSKeyValueObservation?
    private var selectedFilterType: FilterType?
    
    // MARK: - Enums
    private enum Period {
        case am
        case pm
        case other
        case officeWork
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupButtons()
        setupBindings()
        observeTableHeight()
        setupTableView()
        bindTableView()
        subscribeToLoading()
        viewModel.loadAccount(for: .am)
    }
}

// MARK: - UI Setup
private extension PlannedVisitsVC {
    
    /// Initial UI configuration
    func setupUI() {
        
        drawRoundedCorners(
            for: viewBackgroundHeader,
            cornerRadius: 20,
            direction: .bottom
        )
        shadowView(viewBackgroundHeader)
        appVersionLabel.text = displayAppVersion()
        appVersionLabel.textColor = .green
        companyNameLabel.text = "I. \(user?.company_name ?? "")"
        stackShowFilter.rx.isHidden.onNext(true)
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

// MARK: - Buttons UI Handling
private extension PlannedVisitsVC {
    
    /// Applies corner radius to buttons and background views
    func setupButtons() {
        let roundedViews: [UIView?] = [
            amButton,
            pmButton,
            otherButton,
            officeWorkButton,
            viewBackgroundButton
        ]
        
        roundedViews.forEach {
            $0?.layer.cornerRadius = 10
        }
    }
    
    /// Updates UI based on selected period
    private func updateButtonsUI(selected period: Period) {
        resetButtonsUI()
        
        switch period {
        case .am:
            stackShowFilter.rx.isHidden.onNext(true)
            highlightButton(amButton)
            viewModel.loadAccount(for: .am)
        case .pm:
            stackShowFilter.rx.isHidden.onNext(true)
            highlightButton(pmButton)
            viewModel.loadAccount(for: .pm)
        case .other:
            stackShowFilter.rx.isHidden.onNext(true)
            highlightButton(otherButton)
            viewModel.loadAccount(for: .other)
        case .officeWork:
            stackShowFilter.rx.isHidden.onNext(false)
            highlightButton(officeWorkButton)
            viewModel.loadAccount(for: .officeWork)
        }
    }
    
    /// Highlights selected button
    func highlightButton(_ button: UIButton) {
        button.backgroundColor = baseColor
        button.setTitleColor(.white, for: .normal)
    }
    
    /// Resets all buttons to default state
    func resetButtonsUI() {
        let buttons = [
            amButton,
            pmButton,
            otherButton,
            officeWorkButton
        ]
        
        buttons.forEach {
            $0?.backgroundColor = .clear
            $0?.setTitleColor(baseColor, for: .normal)
        }
    }
}
// MARK: - setup Table View
private extension PlannedVisitsVC {
    
    func setupTableView() {
        tableView.register(
            UINib(nibName: "CellPlanningVisits", bundle: nil),
            forCellReuseIdentifier: "CellPlanningVisits"
        )
        tableView.rowHeight = 150
    }
    
    func bindTableView() {
        viewModel.itemsObservable
            .bind(to: tableView.rx.items(
                cellIdentifier: "CellPlanningVisits",
                cellType: CellPlanningVisits.self
            )) { [weak self] index, item, cell in
                guard let self = self else { return }
                
                self.shadowView(cell.viewBackground,
                                color: .gray,
                                opacity: 0.15,
                                offset: .zero,
                                radius: 10)
                
                switch item {
                    
                case .visit(let model):
                    cell.configureCellPlanned(model: model)
                    
                    let modelMap = ActualVisitModel(
                        id: "\(model.id ?? 0)",
                        account_type: model.account_type ?? "",
                        account_name: model.account ?? "",
                        doctor_name: model.doctor ?? "",
                        shift_type: "\(model.shift_id ?? 0)",
                        visit_date: model.date ?? "",
                        llAcccount: model.ll ?? "",
                        lgAcccount: model.lg ?? "",
                        isUploaded: false
                    )
                    
                    cell.onMapTapped = {
                        let vc = MyLocationVC()
                        vc.delegateType = .plannedVisit
                        vc.itemModel = modelMap
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    
                case .office(let model):
                    cell.configureCellOWS(model: model)
                }
            }
            .disposed(by: disposeBag)
        
        Observable
            .zip(
                tableView.rx.itemSelected,
                tableView.rx.modelSelected(PlannedVisitsViewModel.PlannedVisitItem.self)
            )
            .subscribe(onNext: { [weak self] indexPath, item in
                guard let self = self else { return }
                self.tableView.deselectRow(at: indexPath, animated: true)
                print("item >>\(item)")
                self.handleSelection(item)
            })
            .disposed(by: disposeBag)

    }
    
    private func handleSelection(_ item: PlannedVisitsViewModel.PlannedVisitItem) {
        switch item {
        case .visit(let model):
            handleVisit(model)
        case .office(let model):
            handleOffice(model)
        }
    }
    private func handleVisit(_ model: PlanVisitsData) {
        guard let masterData = LocalStorageManager.shared.getMasterData()?.data else { return }

        let divisionName = masterData.divisions?.first(where: { $0.id == model.division_id })?.name ?? ""

        let brickName = masterData.bricks?.first(where: { $0.id == Int(model.brick_id ?? "") })?.name ?? ""

        let accountTypeID = masterData.accountTypes?.first(where: { $0.name == model.account_type })?.id ?? 0

        let visitName = model.visit_type_id == 1 ? "Single" : "Double"

        let shiftName: String = {
            switch model.shift_id {
            case 1: return "AM"
            case 2: return "PM"
            default: return "Full Day"
            }
        }()
        print("model.id >>\(model.id ?? 0)")
        let visitItem = VisitItem(
            date: model.date,
            time: model.time,
            planID: model.id,
            division: Lines(id: model.division_id, name: divisionName,line_id: model.line_id, ll: model.ll, lg: model.lg),
            brick: Lines(id: Int(model.brick_id ?? "") ?? 0, name: brickName,line_id: model.line_id, ll: model.ll, lg: model.lg),
            accountType: Lines(id: accountTypeID, name: model.account_type,line_id: model.line_id, ll: model.ll, lg: model.lg),
            account: Lines(id: model.account_id, name: model.account,line_id: model.line_id, ll: model.ll, lg: model.lg),
            doctor: Lines(id: model.doctor_id, name: model.doctor,line_id: model.line_id, ll: model.ll, lg: model.lg),
            visitType: Lines(id: model.visit_type_id, name: visitName,line_id: model.line_id, ll: model.ll, lg: model.lg),
            shiftType: Lines(id: model.shift_id, name: shiftName,line_id: model.line_id, ll: model.ll, lg: model.lg),
        )

        LocalStorageManager.shared.saveVisitItemData(model: [visitItem])

        let vc = UnPlannedVisitVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    private func handleOffice(_ model: PlanOwsData) {
        let vc = OWActivitiesVC()
        vc.delegateType = .PlannedVisit
        vc.plannedOfficeModel = model
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Loading
private extension PlannedVisitsVC {
    func subscribeToLoading() {
        viewModel.loadingBehavior.subscribe(onNext: { [weak self] isLoading in
            isLoading ? self?.startLoading() : self?.endLoading()
        }).disposed(by: disposeBag)
    }
}

// MARK: - Rx Bindings
private extension PlannedVisitsVC {
    
    
    /// Sets up RxSwift bindings
    func setupBindings() {
        
        // Period selection bindings
        amButton.rx.tap
            .map { Period.am }
            .bind(to: selectedPeriod)
            .disposed(by: disposeBag)
        
        pmButton.rx.tap
            .map { Period.pm }
            .bind(to: selectedPeriod)
            .disposed(by: disposeBag)
        
        otherButton.rx.tap
            .map { Period.other }
            .bind(to: selectedPeriod)
            .disposed(by: disposeBag)
        
        officeWorkButton.rx.tap
            .map { Period.officeWork }
            .bind(to: selectedPeriod)
            .disposed(by: disposeBag)
        
        // Update UI when period changes
        selectedPeriod
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] period in
                self?.updateButtonsUI(selected: period)
            })
            .disposed(by: disposeBag)
        
        // Back button action
        buttonBack.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { vc, _ in
                vc.dismiss()
            }
            .disposed(by: disposeBag)
        
        stackColapseTapped.onTap { [weak self] in self?.toggleFilterStack() }
//        viewTappedDateFrom.onTap { [weak self] in self?.openCalendar(for: .dateFrom) }
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
private extension PlannedVisitsVC {
    func toggleFilterStack() { stackFilter.isHidden ? showFilterStack() : hideFilterStack() }
    func showFilterStack() { stackFilter.isHidden = false; UIView.animate(withDuration: 0.3) { self.stackFilter.alpha = 1 } }
    func hideFilterStack(animated: Bool = true) { stackFilter.alpha = 0; stackFilter.isHidden = true }
}
// MARK: - Calendar
private extension PlannedVisitsVC {
    func openCalendar(for type: FilterType) {
        selectedFilterType = type
        let calendarVC = CalenderVC()
        calendarVC.delegateDate = self
        calendarVC.selectAllDates = true
        showPopUp(view: calendarVC)
    }
}
// MARK: - Calendar Delegate
extension PlannedVisitsVC: BackSelectDate {
    func selectDate(date: String) {
        switch selectedFilterType {
        case .dateFrom: dateFromLabel.text = date
        case .dateTo: dateToLabel.text = date
        case .none: break
        }
    }
}

private extension PlannedVisitsVC {
    
    func observeTableHeight() {
        tableObservation = tableView.observe(\.contentSize) { [weak self] tableView, _ in
            self?.heightTableView.constant = tableView.contentSize.height
        }
    }
}

