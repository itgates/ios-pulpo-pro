//
//  OWActivitiesVC.swift
//  Puplo Pro
//
//  Created by Ahmed on 02/12/2025.
//

import UIKit
import RxCocoa
import RxSwift

enum OWActivitiesType {
    case PlannedVisit
    case OWActivities
}
final class OWActivitiesVC: BaseView {

    // MARK: - Outlets
    @IBOutlet private weak var viewBackgroundHeader: UIView!
    @IBOutlet private weak var appVersionLabel: UILabel!
    @IBOutlet private weak var companyNameLabel: UILabel!
    
    @IBOutlet private weak var buttonBack: UIButton!

    @IBOutlet private weak var tableViewAM: UITableView!
    @IBOutlet private weak var heightTableViewAM: NSLayoutConstraint!

    @IBOutlet private weak var tableViewOfficeWork: UITableView!
    @IBOutlet private weak var heightTableViewOfficeWork: NSLayoutConstraint!

    @IBOutlet private weak var viewBackgroundDate: UIView!
    @IBOutlet private weak var stackDateTapped: UIStackView!
    @IBOutlet private weak var dateLabel: UILabel!

    @IBOutlet private weak var viewBackgroundAM: UIView!
    @IBOutlet private weak var stackAMTapped: UIStackView!
    @IBOutlet private weak var AMLabel: UILabel!

    @IBOutlet private weak var viewBackgroundOfficeWork: UIView!
    @IBOutlet private weak var stackOfficeWorkTapped: UIStackView!
    @IBOutlet private weak var officeWorkLabel: UILabel!

    @IBOutlet private weak var viewBackgroundComment: UIView!
    @IBOutlet private weak var stackCommentTapped: UIStackView!
    @IBOutlet private weak var commentTextField: UITextField!

    @IBOutlet private weak var applyButton: UIButton!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = OWActivitiesViewModel()

    private var tableObservationAM: NSKeyValueObservation?
    private var tableObservationOfficeWork: NSKeyValueObservation?

    private var isAMExpanded = false
    private var isOfficeExpanded = false
    private var appendedOWSData = [OWSModel]()
    private var ow_type_id: Int = 0
    private var shift_id: Int = 1
    private var ow_plan_id: Int = 0
    var delegateType: OWActivitiesType = .OWActivities
    var plannedOfficeModel: PlanOwsData?


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        configureTables()
        observeTables()
        bindUI()
        bindTableView()

        viewModel.fetchData()

        if delegateType == .PlannedVisit {
            setupPlannedVisitData()
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupUI()
    }
}
// MARK: - UI Setup
private extension OWActivitiesVC {

    func setupUI() {
        configureHeaderUI()
        configureFormUI()
        configureInitialStates()
        setupBindings()
    }

    func configureHeaderUI() {
        drawRoundedCorners(for: viewBackgroundHeader, cornerRadius: 20, direction: .bottom)
        shadowView(viewBackgroundHeader)
        appVersionLabel.text = displayAppVersion()
        appVersionLabel.textColor = .green
        companyNameLabel.rx.text.onNext("I. \(user?.company_name ?? "")")
    }

    func configureFormUI() {
        [viewBackgroundDate, viewBackgroundAM, viewBackgroundOfficeWork, viewBackgroundComment].forEach {
            style(view: $0, cornerRadius: 15, borderWidth: 2, borderColor: baseColor)
        }

        commentTextField.placeholder = "Comment"
        commentTextField.placeHolderColor = .lightGray
        commentTextField.textAlignment = .left

        style(view: applyButton, cornerRadius: applyButton.frame.height / 2)
        dateLabel.text = Date().formattedDate
    }

    func configureInitialStates() {
        heightTableViewAM.constant = 0
        tableViewAM.alpha = 0
        
        heightTableViewOfficeWork.constant = 0
        tableViewOfficeWork.alpha = 0
    }
}
// MARK: - Bindings
private extension OWActivitiesVC {
    
    private func setupPlannedVisitData() {
        guard let model = plannedOfficeModel else { return }
        print("model >>\(model)")
        // Date
        dateLabel.text = model.date ?? ""

        // Shift
        shift_id = model.shift_id ?? 0
        AMLabel.text = viewModel.shiftName(for: shift_id) ?? ""
        // Office Work
        ow_type_id = model.ow_type_id ?? 0
        officeWorkLabel.text = viewModel.officeWorkName(for: ow_type_id) ?? ""
        
        // ow plan
        ow_plan_id = model.id ?? 0
        // Disable interaction
        stackAMTapped.isUserInteractionEnabled = false
        stackOfficeWorkTapped.isUserInteractionEnabled = false

        stackAMTapped.alpha = 0.6
        stackOfficeWorkTapped.alpha = 0.6
    }

    func setupBindings() {
        applyButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(with: self) { vc, _ in
                vc.handleApplyTap()
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Actions
    func handleApplyTap() {
        setApplyButton(button: applyButton, enabled: false)

        guard validateOfficeWork() else {
            setApplyButton(button: applyButton, enabled: true)
            return
        }

        submitOfficeWork()
    }

    // MARK: - Validation
    func validateOfficeWork() -> Bool {
        guard ow_type_id != 0 else {
            showAlert(
                alertTitle: "Error",
                alertMessage: "Select office work"
            )
            return false
        }
        return true
    }

    // MARK: - Submission
    func submitOfficeWork() {
        let model = makeOWSModel()
        appendedOWSData.append(model)

        subscribeToLoading()

        viewModel.applayWithNetworkCheck(OWS: appendedOWSData) { [weak self] done, _ in
            guard let self else { return }

            if done {
                self.handleSuccess()
            } else {
                self.handleFailure()
            }
        }
    }

    // MARK: - Helpers
    func makeOWSModel() -> OWSModel {
        let now = Date()
        return OWSModel(
            date: dateLabel.text ?? "",
            id: 0,
            notes: commentTextField.text ?? "",
            offline_id: 11,
            ow_plan_id: ow_plan_id,
            ow_type_id: ow_type_id,
            shift_id: shift_id,
            time: (now.formattedTime).to24HourFormat
        )
    }

    func handleSuccess() {
        showTopAlert(
            message: "Office work was successfully completed"
        ) {
            self.navigationHomeVC()
        }
    }

    func handleFailure() {
        showAlert(
            alertTitle: "Error",
            alertMessage: "Saved Failed"
        )
        self.setApplyButton(button: applyButton, enabled: true)
    }
}

// MARK: - Loading Indicator
private extension OWActivitiesVC {
    
    private func subscribeToLoading() {
        viewModel.loadingBehavior
            .subscribe(onNext: { [weak self] isLoading in
                isLoading ? self?.startLoading() : self?.endLoading()
            })
            .disposed(by: disposeBag)
    }
}
// MARK: - Configure Tables
private extension OWActivitiesVC {

    func configureTables() {
        tableViewAM.register(
            UINib(nibName: "CellSelectFilter", bundle: nil),
            forCellReuseIdentifier: "CellSelectFilter"
        )
        tableViewAM.rowHeight = 40
        
        tableViewOfficeWork.register(
            UINib(nibName: "CellSelectFilter", bundle: nil),
            forCellReuseIdentifier: "CellSelectFilter"
        )
        tableViewOfficeWork.rowHeight = 40
    }
}

// MARK: - Observe contentSize (KVO)
private extension OWActivitiesVC {

    func observeTables() {
        observeTableHeightAM()
        observeTableHeightOfficeWork()
    }

    func observeTableHeightAM() {
        tableObservationAM = tableViewAM.observe(\.contentSize) { [weak self] tableView, _ in
            guard let self else { return }
            if self.isAMExpanded {
                self.heightTableViewAM.constant = tableView.contentSize.height
            }
        }
    }
    func observeTableHeightOfficeWork() {
        tableObservationOfficeWork = tableViewOfficeWork.observe(\.contentSize) { [weak self] tableView, _ in
            guard let self else { return }
            if self.isOfficeExpanded {
                self.heightTableViewOfficeWork.constant = tableView.contentSize.height
            }
        }
    }
}

// MARK: - Bind UI
private extension OWActivitiesVC {

    func bindUI() {
        bindBackButton()
        bindAMTap()
        bindOfficeTap()
    }

    func bindBackButton() {
        buttonBack.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { vc, _ in vc.dismiss() }
            .disposed(by: disposeBag)
    }

    func bindAMTap() {
        stackAMTapped.onTap { [weak self] in
            guard let self, self.delegateType != .PlannedVisit else { return }
            self.toggleAMTable()
        }
    }

    func bindOfficeTap() {
        stackOfficeWorkTapped.onTap { [weak self] in
            guard let self, self.delegateType != .PlannedVisit else { return }
            self.toggleOfficeTable()
        }
    }


    func toggleAMTable() {
        isAMExpanded.toggle()

        UIView.animate(withDuration: 0.25) {
            self.heightTableViewAM.constant = self.isAMExpanded
                ? self.tableViewAM.contentSize.height
                : 0

            self.tableViewAM.alpha = self.isAMExpanded ? 1 : 0
            self.view.layoutIfNeeded()
        }
    }
    func toggleOfficeTable() {
        isOfficeExpanded.toggle()

        UIView.animate(withDuration: 0.25) {
            self.heightTableViewOfficeWork.constant = self.isOfficeExpanded
                ? self.tableViewOfficeWork.contentSize.height
                : 0

            self.tableViewOfficeWork.alpha = self.isOfficeExpanded ? 1 : 0
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Bind TableView
private extension OWActivitiesVC {

    func bindTableView() {

        viewModel.oWActivitiesAMModelObservable
            .bind(to: tableViewAM.rx.items(
                cellIdentifier: "CellSelectFilter",
                cellType: CellSelectFilter.self
            )) { _, model, cell in
                cell.nameLabel?.text = model.name
            }
            .disposed(by: disposeBag)

        tableViewAM.rx.modelSelected(OWActivitiesData.self)
            .subscribe(onNext: { [weak self] item in
                guard let self else { return }
                self.AMLabel.text = item.name
                self.shift_id = item.id
                print("AM.id >>\(item.id)")
                self.collapseAMTable()
            })
            .disposed(by: disposeBag)
        
        
        viewModel.officeWorkTypesModelObservable
            .bind(to: tableViewOfficeWork.rx.items(
                cellIdentifier: "CellSelectFilter",
                cellType: CellSelectFilter.self
            )) { _, model, cell in
                cell.nameLabel?.text = model.name
            }
            .disposed(by: disposeBag)

        tableViewOfficeWork.rx.modelSelected(Lines.self)
            .subscribe(onNext: { [weak self] item in
                guard let self else { return }
                self.officeWorkLabel.text = item.name
                self.ow_type_id = Int(item.id ?? "") ?? 0
                print("officeWork.id >>\(item.id ?? "")")
                self.collapseOfficeWork()
            })
            .disposed(by: disposeBag)
    }
    func collapseOfficeWork() {
        isOfficeExpanded = false

        UIView.animate(withDuration: 0.25) {
            self.heightTableViewOfficeWork.constant = 0
            self.tableViewOfficeWork.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    func collapseAMTable() {
        isAMExpanded = false

        UIView.animate(withDuration: 0.25) {
            self.heightTableViewAM.constant = 0
            self.tableViewAM.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
}

