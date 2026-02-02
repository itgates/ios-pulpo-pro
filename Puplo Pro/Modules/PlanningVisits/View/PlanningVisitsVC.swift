//
//  PlanningVisitsVC.swift
//  Puplo Pro
//
//  Created by Ahmed on 21/11/2025.
//
import UIKit
import RxSwift
import RxCocoa
import DropDown

final class PlanningVisitsVC: BaseView {

    // MARK: - Outlets
    @IBOutlet private weak var viewBackgroundHeader: UIView!
    @IBOutlet private weak var appVersionLabel: UILabel!
    @IBOutlet private weak var companyNameLabel: UILabel!
    @IBOutlet private weak var buttonBack: UIButton!

    @IBOutlet private weak var viewBackgroundButton: UIView!
    @IBOutlet private weak var amButton: UIButton!
    @IBOutlet private weak var pmButton: UIButton!
    @IBOutlet private weak var otherButton: UIButton!

    @IBOutlet private weak var viewBackgroundSearch: UIView!
    @IBOutlet private weak var searchTextField: UITextField!

    @IBOutlet private weak var viewShadowFilter: UIView!
    @IBOutlet private weak var stackColapseTapped: UIStackView!
    @IBOutlet private var viewCornerRadius: [UIView]!

    @IBOutlet private weak var stackTappedDivision: UIStackView!
    @IBOutlet private weak var selectDivisionTextField: UITextField!

    @IBOutlet private weak var stackTappedBrick: UIStackView!
    @IBOutlet private weak var selectBrickTextField: UITextField!

    @IBOutlet private weak var stackTappedAccountType: UIStackView!
    @IBOutlet private weak var selectAccountTypeTextField: UITextField!

    @IBOutlet private weak var stackTappedClass: UIStackView!
    @IBOutlet private weak var selectClassTextField: UITextField!

    @IBOutlet private weak var applyFilterButton: UIButton!
    @IBOutlet private weak var stackFilter: UIStackView!

    @IBOutlet private weak var amAccountLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var heightTableView: NSLayoutConstraint!
    @IBOutlet private weak var nextButton: UIButton!

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = PlanningVisitsViewModel()

    private let selectedPeriod = BehaviorRelay<Period>(value: .am)
    private let selectedModels = BehaviorRelay<[PlanningVisitsData]>(value: [])
    private let filteredDoctors = BehaviorRelay<[PlanningVisitsData]>(value: [])

    private var tableObservation: NSKeyValueObservation?
    private var hasShownInitialLoading = false

    private let dropDown = DropDown()
    private var currentSelection: SelectionFilterType?
    private var currentLines: [Lines] = []
    private var selectedFilter = SelectFilter()

    private let masterData = LocalStorageManager.shared.getMasterData()

    // MARK: - Period
    private enum Period {
        case am, pm, other

        var title: String {
            switch self {
            case .am: return "(AM Account)"
            case .pm: return "(PM Account)"
            case .other: return "(Other Account)"
            }
        }

        var shift: AccountShift {
            switch self {
            case .am: return .am
            case .pm: return .pm
            case .other: return .other
            }
        }

        var vmType: PlanningVisitsViewModel.AccountType {
            switch self {
            case .am: return .am
            case .pm: return .pm
            case .other: return .other
            }
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        setupTableView()
        setupDropDown()
        setupGestures()
        setupBindings()
        bindTableView()
        observeTableHeight()
        subscribeToLoading()

        viewModel.doctorsObservable
            .bind(to: filteredDoctors)
            .disposed(by: disposeBag)

        selectedPeriod.accept(.am)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupUI()
        viewBackgroundSearch.layer.cornerRadius = viewBackgroundSearch.frame.height / 2
    }
}

// MARK: - setupUI
private extension PlanningVisitsVC {

    func setupUI() {
        drawRoundedCorners(for: viewBackgroundHeader, cornerRadius: 20, direction: .bottom)
        shadowView(viewBackgroundHeader)

        style(view: viewShadowFilter, cornerRadius: 10)
        shadowView(viewShadowFilter, color: .gray, opacity: 0.13, offset: .zero, radius: 10)
        
        appVersionLabel.text = displayAppVersion()
        appVersionLabel.textColor = .green
        companyNameLabel.text = "I. \(user?.company_name ?? "")"

        style(view: viewBackgroundSearch, borderWidth: 2, borderColor: baseColor)

        [nextButton, applyFilterButton].forEach {
            style(view: $0!, cornerRadius: $0!.frame.height / 2, backgroundColor: baseColor)
        }

        viewCornerRadius.forEach {
            style(view: $0, cornerRadius: $0.frame.height / 2, borderWidth: 2, borderColor: baseColor)
        }

        [selectDivisionTextField,
         selectBrickTextField,
         selectAccountTypeTextField,
         selectClassTextField].forEach {
            $0?.isUserInteractionEnabled = false
            $0?.placeHolderColor = baseColor
        }

        nextButton.isEnabled = false
        nextButton.alpha = 0.5
    }

    func setupButtons() {
        [amButton, pmButton, otherButton, viewBackgroundButton]
            .forEach { $0?.layer.cornerRadius = 10 }
    }
}
// MARK: - Bindings
private extension PlanningVisitsVC {

    func setupBindings() {

        // Period buttons
        [(amButton, Period.am),
         (pmButton, Period.pm),
         (otherButton, Period.other)].forEach { button, period in
            button?.rx.tap
                .map { period }
                .bind(to: selectedPeriod)
                .disposed(by: disposeBag)
        }

        selectedPeriod
            .subscribe(onNext: { [weak self] period in
                self?.updatePeriodUI(period)
            })
            .disposed(by: disposeBag)

        applyFilterButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }

                // 1️⃣ Apply filter
                self.viewModel.applyFilter(self.selectedFilter)

                // 2️⃣ Clear selected models
                self.selectedModels.accept([])

                // 3️⃣ Deselect all selected rows
                if let indexPaths = self.tableView.indexPathsForSelectedRows {
                    indexPaths.forEach {
                        self.tableView.deselectRow(at: $0, animated: false)
                    }
                }

                // 4️⃣ Reload table to reset UI
                self.tableView.reloadData()

                // 5️⃣ Close filter view
                self.toggleFilterStack()
            }
            .disposed(by: disposeBag)

        buttonBack.rx.tap
            .bind { [weak self] in self?.dismiss() }
            .disposed(by: disposeBag)

        selectedModels
            .map { !$0.isEmpty }
            .subscribe(onNext: { [weak self] enabled in
                self?.nextButton.isEnabled = enabled
                self?.nextButton.alpha = enabled ? 1 : 0.5
            })
            .disposed(by: disposeBag)

        nextButton.rx.tap
            .withLatestFrom(Observable.combineLatest(selectedModels, selectedPeriod))
            .subscribe(onNext: { [weak self] models, period in
                let final = models.map {
                    var item = $0
                    item.shift = period.shift
                    return item
                }
                self?.navigationSavePalnsVC(model: final)
            })
            .disposed(by: disposeBag)
    }
}
// MARK: - TableView + Search
private extension PlanningVisitsVC {

    func setupTableView() {
        tableView.register(
            UINib(nibName: "CellPlanningVisits", bundle: nil),
            forCellReuseIdentifier: "CellPlanningVisits"
        )
        tableView.rowHeight = 140
    }

    func bindTableView() {

        let search = searchTextField.rx.text.orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()

        let dataSource = Observable.combineLatest(filteredDoctors, search)
            .map { items, text in
                guard !text.isEmpty else { return items }
                return items.filter {
                    $0.name.localizedCaseInsensitiveContains(text)
                    || $0.hosptal.localizedCaseInsensitiveContains(text)
                }
            }

        dataSource
            .bind(to: tableView.rx.items(
                cellIdentifier: "CellPlanningVisits",
                cellType: CellPlanningVisits.self
            )) { [weak self] _, model, cell in
                guard let self else { return }
                cell.configureCell(model: model, AMAccount: self.amAccountLabel.text ?? "")
                self.shadowView(cell.viewBackground,
                                color: .gray,
                                opacity: 0.15,
                                offset: .zero,
                                radius: 10)
                
                self.shadowView(cell.viewCircel,
                                color: .gray,
                                opacity: 0.15,
                                offset: .zero,
                                radius: 10)
                
                self.style(view: cell.viewBorder,
                           cornerRadius: cell.viewBorder.frame.height / 2,
                           borderWidth: 1.5,
                           borderColor: .lightGray)
                
                cell.configureCell(model: model,
                                   AMAccount: self.amAccountLabel.text ?? "")
                self.selectedModels.value.contains(where: { $0.id == model.id })
                    ? cell.selectedItem()
                    : cell.unSelectedItem()
            }
            .disposed(by: disposeBag)

        Observable.zip(tableView.rx.itemSelected,
                       tableView.rx.modelSelected(PlanningVisitsData.self))
            .subscribe(onNext: { [weak self] indexPath, model in
                guard let self else { return }
                var list = self.selectedModels.value
                if let id = model.id,
                   let index = list.firstIndex(where: { $0.id == id }) {
                    list.remove(at: index)
                } else {
                    list.append(model)
                }
                self.selectedModels.accept(list)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            })
            .disposed(by: disposeBag)
    }
}
// MARK: - DropDown + Filter
private extension PlanningVisitsVC {

    func setupDropDown() {
        DropDown.startListeningToKeyboard()
        dropDown.direction = .bottom
        dropDown.selectionAction = { [weak self] index, _ in
            guard let self,
                  let type = self.currentSelection,
                  index < self.currentLines.count else { return }
            let line = self.currentLines[index]
            self.saveSelection(type, line)
            self.updateUI(type, line)
        }
    }

    func setupGestures() {
        stackColapseTapped.onTap { [weak self] in self?.toggleFilterStack() }
        stackTappedDivision.onTap { [weak self] in self?.show(.division, anchor: self?.stackTappedDivision) }
        stackTappedBrick.onTap { [weak self] in self?.show(.brick, anchor: self?.stackTappedBrick) }
        stackTappedAccountType.onTap { [weak self] in self?.show(.accountType, anchor: self?.stackTappedAccountType) }
        stackTappedClass.onTap { [weak self] in self?.show(.classes, anchor: self?.stackTappedClass) }
    }

    func show(_ type: SelectionFilterType, anchor: UIView?) {
        currentSelection = type
        dropDown.anchorView = anchor
        dropDown.bottomOffset = CGPoint(x: 0, y: anchor?.bounds.height ?? 0)

        switch type {
        case .division:
            currentLines = masterData?.Data?.divisions ?? []
        case .brick:
            guard let id = selectedFilter.division?.id else { currentLines = []; break }
            currentLines = masterData?.Data?.bricks?.filter { $0.line_division_id == Int(id) } ?? []
        case .accountType:
            currentLines = masterData?.Data?.account_types ?? []
        case .classes:
            currentLines = masterData?.Data?.classes ?? []
        }

        dropDown.dataSource = currentLines.compactMap { $0.name }
        dropDown.show()
    }

    func saveSelection(_ type: SelectionFilterType, _ line: Lines) {
        switch type {
        case .division:
            selectedFilter.division = line
            selectedFilter.brick = nil
            selectBrickTextField.text = nil
        case .brick:
            selectedFilter.brick = line
        case .accountType:
            selectedFilter.accountType = line
        case .classes:
            selectedFilter.classType = line
        }
    }

    func updateUI(_ type: SelectionFilterType, _ line: Lines) {
        switch type {
        case .division: selectDivisionTextField.text = line.name
        case .brick: selectBrickTextField.text = line.name
        case .accountType: selectAccountTypeTextField.text = line.name
        case .classes: selectClassTextField.text = line.name
        }
    }
}
// MARK: - Helpers
private extension PlanningVisitsVC {

    private func updatePeriodUI(_ period: Period) {
        resetButtonsUI()
        highlightButton(for: period)
        amAccountLabel.text = period.title
        selectedFilter = SelectFilter()
        viewModel.loadDoctors(for: period.vmType)
    }

    private func highlightButton(for period: Period) {
        let button = period == .am ? amButton : period == .pm ? pmButton : otherButton
        button?.backgroundColor = baseColor
        button?.setTitleColor(.white, for: .normal)
    }

    func resetButtonsUI() {
        [amButton, pmButton, otherButton].forEach {
            $0?.backgroundColor = .clear
            $0?.setTitleColor(baseColor, for: .normal)
        }
    }

    func toggleFilterStack() {
        stackFilter.isHidden.toggle()
        UIView.animate(withDuration: 0.3) {
            self.stackFilter.alpha = self.stackFilter.isHidden ? 0 : 1
        }
    }

    func observeTableHeight() {
        tableObservation = tableView.observe(\.contentSize) { [weak self] tableView, _ in
            self?.heightTableView.constant = tableView.contentSize.height
        }
    }

    func subscribeToLoading() {
        viewModel.loadingBehavior
            .subscribe(onNext: { [weak self] loading in
                loading ? self?.startLoading() : self?.endLoading()
            })
            .disposed(by: disposeBag)
    }
}
