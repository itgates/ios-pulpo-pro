//
//  PlannedVisitsVC.swift
//  Gemstone Pro
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
//    @IBOutlet private weak var heightTableView: NSLayoutConstraint!
    
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
       // case officeWork
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupButtons()
        setupBindings()
//        observeTableHeight()
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
                        print("modelMap >>\(modelMap)")
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
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
        }
    }
    private func handleVisit(_ model: PlannedVisitsData) {
        guard let masterData = LocalStorageManager.shared.getMasterData()?.Data,
              let user = LocalStorageManager.shared.getLoggedUser()
        else { return }

        let divisionName = masterData.divisions?
            .first(where: { $0.id == model.div_id })?
            .name ?? ""

        let brick = masterData.bricks?.first(where: {
            $0.ter_id == model.div_id &&
            $0.team_id == user.lineIds
        })

        let brickName = brick?.name ?? ""
        
        let accountTypeName = masterData.account_types?
            .first(where: { $0.id == model.account_type })?
            .name ?? ""

        let accountsData = LocalStorageManager.shared.getAccountsDoctors()?.Data
        let selectedAccount = accountsData?.Accounts?
            .first(where: { $0.id == model.item_id })
        let accountId = selectedAccount?.id ?? ""
        let accountName = selectedAccount?.name ?? ""
        let accountll = selectedAccount?.team_ll ?? ""
        let accountlg = selectedAccount?.team_lg ?? ""
        
        let doctorData = LocalStorageManager.shared.getAccountsDoctors()?.Data
        let selectedDoctor = doctorData?.Doctors?
            .first(where: { $0.id == model.item_doc_id })
        let doctorName = selectedDoctor?.name ?? ""
        
//        let visitName = model.members == "0" ? "Single" : "Double"
//        let visitID = model.members == "0" ? "1" : "2"
        
        
        let shiftType = IdNameModel(
            id: (model.shift == "0") ? "" : model.shift,
            name: {
                switch model.shift {
                case "2": return "AM"
                case "1": return "PM"
                default: return ""
                }
            }(),
            ll: accountll,
            lg: accountlg
        )

        let visitItem = VisitItem(
            date: model.vdate,
            time: model.vtime,
            planID: model.id,
            division: IdNameModel(id: model.div_id, name: divisionName,ll: accountll,lg: accountlg),
            brick: IdNameModel(id: brick?.id ?? "", name: brickName,ll: accountll,lg: accountlg),
            accountType: IdNameModel(id: model.account_type, name: accountTypeName,ll: accountll,lg: accountlg),
            account: IdNameModel(id: accountId, name: accountName,ll: accountll,lg: accountlg),
            doctor: IdNameModel(id: model.item_doc_id, name: doctorName,ll: accountll,lg: accountlg),
//            visitType: IdNameModel(id: visitID, name: visitName,ll: accountll,lg: accountlg),
            shiftType: shiftType
        )
        print("visitItem >>> \(visitItem)")
        LocalStorageManager.shared.saveVisitItemData([visitItem])
        LocalStorageManager.shared.clearManagerData()
        LocalStorageManager.shared.clearProductsData()
        LocalStorageManager.shared.clearGiftsData()
        let vc = UnPlannedVisitVC()
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
//private extension PlannedVisitsVC {
//    
//    func observeTableHeight() {
//        tableObservation = tableView.observe(\.contentSize) { [weak self] tableView, _ in
//            self?.heightTableView.constant = tableView.contentSize.height
//        }
//    }
//}
//
