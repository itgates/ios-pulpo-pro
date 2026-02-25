//
//  AccountsListVC.swift
//  Gemstone Pro
//
//  Created by Ahmed on 06/01/2026.
//
import UIKit
import RxSwift
import RxCocoa
import DropDown

// MARK: - ViewController
final class AccountsListVC: BaseView {
    
    // MARK: - Outlets
    @IBOutlet private weak var viewBackgroundHeader: UIView!
    @IBOutlet private weak var appVersionLabel: UILabel!
    @IBOutlet private weak var companyNameLabel: UILabel!
    @IBOutlet private weak var buttonBack: UIButton!
    
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
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var heightTableView: NSLayoutConstraint!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = AccountsListViewModel()
    private let dropDown = DropDown()
    
    private var tableObservation: NSKeyValueObservation?
    private var currentSelection: SelectionFilterType?
    private var currentLines: [IdNameModel] = []
    private var selectedFilter = SelectFilter()
    
    private let masterData = LocalStorageManager.shared.getMasterData()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        observeTableHeight()
        setupDropDown()
        setupGestures()
        bindActions()
        bindTableView()
        bindLoading()
        viewModel.fetchData()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyFilterButton.layer.cornerRadius = applyFilterButton.frame.height / 2
        applyFilterButton.layer.masksToBounds = true
        
        viewCornerRadius.forEach {
            style(view: $0,
                  cornerRadius: $0.frame.height / 2,
                  borderWidth: 2,
                  borderColor: baseColor)}
    }
}

// MARK: - UI Setup
private extension AccountsListVC {
    
    func setupUI() {
        drawRoundedCorners(for: viewBackgroundHeader, cornerRadius: 20, direction: .bottom)
        shadowView(viewBackgroundHeader)
        
        appVersionLabel.text = displayAppVersion()
        appVersionLabel.textColor = .green
        companyNameLabel.text = "I. \(user?.company_name ?? "")"
        
        style(view: viewShadowFilter, cornerRadius: 10)
        shadowView(viewShadowFilter, color: .gray, opacity: 0.13, offset: .zero, radius: 10)
        
           [selectDivisionTextField,
            selectBrickTextField,
            selectAccountTypeTextField,
            selectClassTextField
        ].forEach {
            $0?.isUserInteractionEnabled = false
            $0?.placeHolderColor = baseColor
        }
    }
}

// MARK: - TableView
private extension AccountsListVC {
    
    func setupTableView() {
        tableView.register(
            UINib(nibName: "CellAccountsList", bundle: nil),
            forCellReuseIdentifier: "CellAccountsList"
        )
        tableView.rowHeight = 100
        tableView.tableFooterView = UIView()
    }
    
    func bindTableView() {
        viewModel.accountsObservable
            .bind(to: tableView.rx.items(
                cellIdentifier: "CellAccountsList",
                cellType: CellAccountsList.self)
            ) { [weak self] _, model, cell in
                guard let self else { return }
                cell.viewContiner.layer.cornerRadius = 8
                self.shadowView(cell.viewContiner,
                                color: .gray,
                                opacity: 0.13,
                                offset: .zero,
                                radius: 10)
                cell.configure(with: model)
                
                cell.onMapTapped = {
                    let vc = MapVC()
                    vc.delegateType = .plannedVisit
                    vc.itemModel = ActualVisitModel(
                        id: "\(model.id ?? "")",
                        account_name: model.name ?? "",
                        llAcccount: model.team_ll ?? "",
                        lgAcccount: model.team_lg ?? "",
                        isUploaded: false
                    )
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Gestures & Actions
private extension AccountsListVC {
    
    func setupGestures() {
        stackTappedDivision.onTap { [weak self] in self?.show(.division, anchor: self?.stackTappedDivision) }
        stackTappedBrick.onTap { [weak self] in self?.show(.brick, anchor: self?.stackTappedBrick) }
        stackTappedAccountType.onTap { [weak self] in self?.show(.accountType, anchor: self?.stackTappedAccountType) }
        stackTappedClass.onTap { [weak self] in self?.show(.classes, anchor: self?.stackTappedClass) }
    }
    
    func bindActions() {
        stackColapseTapped.onTap { [weak self] in self?.toggleFilterStack() }
        
        buttonBack.rx.tap
            .bind { [weak self] in self?.dismiss() }
            .disposed(by: disposeBag)
        
        applyFilterButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.viewModel.applyFilter(self.selectedFilter)
                self.toggleFilterStack()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Filter Stack
private extension AccountsListVC {
    
    func toggleFilterStack() {
        stackFilter.isHidden ? showFilter() : hideFilter()
    }
    
    func showFilter() {
        stackFilter.isHidden = false
        UIView.animate(withDuration: 0.3) { self.stackFilter.alpha = 1 }
    }
    
    func hideFilter() {
        UIView.animate(withDuration: 0.2) {
            self.stackFilter.alpha = 0
        } completion: { _ in
            self.stackFilter.isHidden = true
        }
    }
}

// MARK: - DropDown
private extension AccountsListVC {
    
    func setupDropDown() {
        DropDown.startListeningToKeyboard()
        let appearance = DropDown.appearance()
        appearance.cellHeight = 40
        appearance.backgroundColor = .white
        appearance.textColor = mainColor
        appearance.selectionBackgroundColor = UIColor(red: 0.65, green: 0.82, blue: 1, alpha: 0.2)
        appearance.setupCornerRadius(10)
        
        dropDown.direction = .bottom
        dropDown.selectionAction = { [weak self] index, _ in
            guard
                let self,
                let type = self.currentSelection,
                index < self.currentLines.count
            else { return }
            
            let line = self.currentLines[index]
            self.saveSelection(type, line)
            self.updateUI(type, line)
        }
    }
    
    func show(_ type: SelectionFilterType, anchor: UIView?) {
        currentSelection = type
        dropDown.anchorView = anchor
        dropDown.bottomOffset = CGPoint(x: 0, y: anchor?.bounds.height ?? 0)

        switch type {
        case .division:
            guard let user = LocalStorageManager.shared.getLoggedUser(),
                  let userDivIdsString = user.divIds else {
                currentLines = []
                break }
            //  Convert "1,2,5" -> ["1","2","5"]
            let userDivIds = userDivIdsString
                .split(separator: ",")
                .map { String($0.trimmingCharacters(in: .whitespaces)) }
            
            currentLines = (masterData?.Data?.divisions ?? [])
                .filter { division in
                    guard let id = division.id else { return false }
                    return userDivIds.contains(id)
                }
                .map { IdNameModel(id: $0.id, name: $0.name) }
        case .brick:
            guard let id = selectedFilter.division?.id else { currentLines = []; break }
            currentLines = (masterData?.Data?.bricks ?? []).filter { $0.ter_id == id }.map { IdNameModel(id: $0.id, name: $0.name) }
        case .accountType:
            currentLines = (masterData?.Data?.account_types ?? []).map { IdNameModel(id: $0.id, name: $0.name) }
        case .classes:
            currentLines = (masterData?.Data?.classes ?? []).map { IdNameModel(id: $0.id, name: $0.name) }
        }

        dropDown.dataSource = currentLines.compactMap { $0.name }
        dropDown.show()
    }

    func saveSelection(_ type: SelectionFilterType, _ line: IdNameModel) {
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
    
    func updateUI(_ type: SelectionFilterType, _ line: IdNameModel) {
        switch type {
        case .division: selectDivisionTextField.text = line.name
        case .brick: selectBrickTextField.text = line.name
        case .accountType: selectAccountTypeTextField.text = line.name
        case .classes: selectClassTextField.text = line.name
        }
    }
}

// MARK: - Helpers
private extension AccountsListVC {
    
    func observeTableHeight() {
        tableObservation = tableView.observe(\.contentSize) { [weak self] table, _ in
            self?.heightTableView.constant = table.contentSize.height
        }
    }
    
    func bindLoading() {
        viewModel.loadingBehavior.subscribe(onNext: { [weak self] isLoading in
            isLoading ? self?.startLoading() : self?.endLoading()
        }).disposed(by: disposeBag)
    }
    
}
