//
//  CellFilter.swift
//  Puplo Pro
//
//  Created by Ahmed on 30/11/2025.
//

import UIKit
import RxCocoa
import RxSwift
class CellFilter: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var selectNameLabel: UILabel!
    @IBOutlet weak var stackSelect: UIStackView!
    @IBOutlet weak var tableViewSelectFilter: UITableView!
    @IBOutlet weak var heightTableViewSelectFilter: NSLayoutConstraint!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    var didTapStackIndex: (() -> Void)?
    
    let masterDataRelay = BehaviorRelay<[Lines]>(value: [])
    var masterDataObservable: Observable<[Lines]> {
        masterDataRelay.asObservable()
    }
    
    var masterData = LocalStorageManager.shared.getMasterData()
    var didSelectItem: ((String,String) -> Void)?
    private var tableObservation: NSKeyValueObservation?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStackGestures()
        setupTableView()
        bindTableViewFilter()
        observeTableHeight()
    }
    
    func configureCell(model: FilterModel) {
        nameLabel.text = model.name
        selectNameLabel.text = model.selectedValue ?? "Select \(model.name)"

        guard let data = masterData?.Data else { return }
        
        switch model.name {
        case "Division":
            masterDataRelay.accept(data.divisions ?? [])
            
        case "Brick":
            masterDataRelay.accept(data.bricks ?? [])
            
        case "Account Type":
            masterDataRelay.accept(data.account_types ?? [])
            
        case "Class":
            masterDataRelay.accept(data.classes ?? [])
            
        default:
            masterDataRelay.accept([])
        }
    }
    
    private func setupStackGestures() {
        stackSelect.onTap { [weak self] in
            guard let self = self else { return }
            self.didTapStackIndex?()
        }
    }
}
private extension CellFilter {
    
    func bindTableViewFilter() {
        
        masterDataObservable
            .bind(to: tableViewSelectFilter.rx.items(
                cellIdentifier: "CellSelectFilter",
                cellType: CellSelectFilter.self
            )) { index, model, cell in
                cell.nameLabel?.text = model.name
            }
            .disposed(by: disposeBag)
        tableViewSelectFilter.rx.modelSelected(Lines.self)
            .subscribe(onNext: { [weak self] item in
                guard let self = self else { return }
                
                let name = item.name ?? ""
                let id = item.id ?? ""
                self.selectNameLabel.text = name
                self.didSelectItem?(name,id)
            })
            .disposed(by: disposeBag)
        
    }
    
    func setupTableView() {
        tableViewSelectFilter.register(
            UINib(nibName: "CellSelectFilter", bundle: nil),
            forCellReuseIdentifier: "CellSelectFilter"
        )
        tableViewSelectFilter.rowHeight = 40
    }
    func observeTableHeight() {
        tableObservation = tableViewSelectFilter.observe(\.contentSize) { [weak self] tableView, _ in
            self?.heightTableViewSelectFilter.constant = tableView.contentSize.height
        }
    }
}

