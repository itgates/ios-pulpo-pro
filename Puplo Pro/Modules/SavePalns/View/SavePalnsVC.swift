//
//  SavePalnsVC.swift
//  Gemstone Pro
//
//  Created by Ahmed on 27/11/2025.
//

import UIKit
import RxCocoa
import RxSwift

final class SavePlansVC: BaseView {

    // MARK: - Outlets
    @IBOutlet private weak var viewBackgroundHeader: UIView!
    @IBOutlet private weak var appVersionLabel: UILabel!
    @IBOutlet private weak var companyNameLabel: UILabel!
    
    @IBOutlet private weak var buttonBack: UIButton!
    
    @IBOutlet private weak var viewBackgroundDate: UIView!
    @IBOutlet private weak var dateStackTapped: UIStackView!
    @IBOutlet private weak var dateLabel: UILabel!

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var heightTableView: NSLayoutConstraint!
    
    @IBOutlet private weak var buttonSavePlans: UIButton!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = SavePlansViewModel()
    /// incoming data
    var planningVisits = [PlanningVisitsData]()
    
    /// list data relay
    private let doctorsRelay = BehaviorRelay<[PlanningVisitsData]>(value: [])
    var doctorsObservable: Observable<[PlanningVisitsData]> {
        doctorsRelay.asObservable()
    }
        
    private var tableObservation: NSKeyValueObservation?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureBindings()
        configureTable()
        observeTableHeight()
        doctorsRelay.accept(planningVisits)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewBackgroundDate.layer.cornerRadius = viewBackgroundDate.frame.height / 2
        viewBackgroundDate.layer.masksToBounds = true
        
        buttonSavePlans.layer.cornerRadius = buttonSavePlans.frame.height / 2
        // Date container
        shadowView(viewBackgroundDate,
                   color: .gray,
                   opacity: 0.15,
                   offset: .zero,
                   radius: 10)
    }
    
}

// MARK: - UI Setup
private extension SavePlansVC {

    func configureUI() {

        // Header
        drawRoundedCorners(for: viewBackgroundHeader,
                           cornerRadius: 20,
                           direction: .bottom)
        shadowView(viewBackgroundHeader)

      

        // Version
        appVersionLabel.text = displayAppVersion()
        appVersionLabel.textColor = .green
        companyNameLabel.rx.text.onNext("I. \(user?.company_name ?? "")")
        
        // Default Date
        dateLabel.text = Date().formattedDate

        // Open calendar popup
        dateStackTapped.onTap { [weak self] in
            guard let self = self else { return }
            let calendarVC = CalenderVC()
            calendarVC.delegateDate = self
            self.showPopUp(view: calendarVC)
        }
    }
}

// MARK: - Calendar Delegate
extension SavePlansVC: BackSelectDate {
    func selectDate(date: String) {
        dateLabel.rx.text.onNext(date) 
    }
}

// MARK: - Bindings
private extension SavePlansVC {

    func configureBindings() {

        // Back Button
        buttonBack.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind { [weak self] in
                self?.dismiss()
            }
            .disposed(by: disposeBag)

        buttonSavePlans.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind { [weak self] in
                guard let self = self else { return }
                self.setApplyButton(button: buttonSavePlans, enabled: false)
                self.subscribeToLoading()
                
                let now = Date()
                let insertionDate = now.formattedDate
                let visitDate = self.dateLabel.text ?? ""
                let plans: [SavePlanData] = self.planningVisits.enumerated().map { index, doc in
                    SavePlanData(
                        acccount: doc.hosptal,
                        doctor: doc.name,
                        shift: doc.shift,
                        llAcccount: doc.lat,
                        lgAcccount: doc.lng,
                        account_dr_id: doc.id,
                        account_id: doc.account_id,
                        account_type_id: doc.type_id,
                        div_id: doc.div_id,
                        insertion_date: insertionDate,
                        line_id: doc.line_id,
                        offline_id: Int(Date().timeIntervalSince1970 * 1000) + index,
                        visit_date: visitDate,
                        visit_time: now.formattedTime.to24HourFormat
                    )
                }
                self.viewModel.savePlansWithNetworkCheck(plans: plans) { done, message in
                    if done {
                        self.showTopAlert(message: "The visit was successfully completed") {
                            self.navigationHomeVC()
                        }
                    } else {
                        self.setApplyButton(button: self.buttonSavePlans, enabled: true)
                        self.showAlert(alertTitle: "Error", alertMessage: message)
                    }
                }
            }
            .disposed(by: disposeBag)

    }
  
    // MARK: - Loading Indicator
    private func subscribeToLoading() {
        viewModel.loadingBehavior
            .bind { [weak self] isLoading in
                isLoading ? self?.startLoading() : self?.endLoading()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - TableView
private extension SavePlansVC {

    func configureTable() {

        tableView.register(
            UINib(nibName: "CellPlanningVisits", bundle: nil),
            forCellReuseIdentifier: "CellPlanningVisits"
        )
        tableView.rowHeight = 140

        doctorsObservable
            .bind(to: tableView.rx.items(
                cellIdentifier: "CellPlanningVisits",
                cellType: CellPlanningVisits.self
            )) { [weak self] index, model, cell in

                guard let self = self else { return }

                self.shadowView(cell.viewBackground,
                                color: .gray,
                                opacity: 0.15,
                                offset: .zero,
                                radius: 10)

                cell.viewCircel.isHidden = true

                self.style(view: cell.viewBorder,
                           cornerRadius: cell.viewBorder.frame.height / 2,
                           borderWidth: 1.5,
                           borderColor: .lightGray)

                cell.configureCell(model: model)
                cell.selectedItem()
            }
            .disposed(by: disposeBag)
    }

    func observeTableHeight() {
        tableObservation = tableView.observe(\.contentSize) { [weak self] tableView, _ in
            self?.heightTableView.constant = tableView.contentSize.height
        }
    }
}
