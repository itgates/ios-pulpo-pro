//
//  DataCenterVC.swift
//  Puplo Pro
//
//  Created by Ahmed on 12/02/2026.
//

import UIKit
import RxCocoa
import RxSwift

final class DataCenterVC: BaseView {

    // MARK: - Outlets
    @IBOutlet private weak var viewBackgroundHeader: UIView!
    @IBOutlet private weak var appVersionLabel: UILabel!
    @IBOutlet private weak var companyNameLabel: UILabel!
    
    @IBOutlet private weak var buttonBack: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var heightTableView: NSLayoutConstraint!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = DataCenterViewModel()
    private var tableObservation: NSKeyValueObservation?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTableView()
        observeTableHeight()
        bindUI()
        bindTableView()
        viewModel.fetchData()
    }
}

private extension DataCenterVC {
    
    func setupUI() {
        drawRoundedCorners(for: viewBackgroundHeader, cornerRadius: 20, direction: .bottom)
        shadowView(viewBackgroundHeader)
        appVersionLabel.text = displayAppVersion()
        appVersionLabel.textColor = .green
        companyNameLabel.rx.text.onNext("I. \(user?.company_name ?? "")")
    }
    
    func configureTableView() {
        tableView.register(UINib(nibName: "DataCenterCell", bundle: nil),
                           forCellReuseIdentifier: "DataCenterCell")
        tableView.tableFooterView = UIView()
    }
}

// MARK: - Bindings
private extension DataCenterVC {
    
    func bindUI() {
        buttonBack.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { vc, _ in vc.dismiss() }
            .disposed(by: disposeBag)
    }
    
    func bindTableView() {
        viewModel.dataCenterModelObservable
            .bind(to: tableView.rx.items(
                cellIdentifier: "DataCenterCell",
                cellType: DataCenterCell.self
            )) { index, model, cell in
                
                self.shadowView(cell.viewBackground,
                                color: .gray,
                                opacity: 0.13,
                                offset: .zero,
                                radius: 10)
                
                cell.configureCell(model: model)
                
                cell.onDownloadTapped = { [weak self] in
                    self?.handleDownload(at: index)
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Table Height Observer
private extension DataCenterVC {
    
    func observeTableHeight() {
        tableObservation = tableView.observe(\.contentSize) { [weak self] _, _ in
            self?.heightTableView.constant = self?.tableView.contentSize.height ?? 0
        }
    }
}

// MARK: - Loading Indicator
private extension DataCenterVC {
    
    private func subscribeToLoading(isAll: Bool = false) {
        viewModel.loadingBehavior
            .subscribe(onNext: { [weak self] isLoading in
                if isAll {
                    self?.startLoading()
                } else {
                    isLoading ? self?.startLoading() : self?.endLoading()
                }
                
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Download Handling
private extension DataCenterVC {
    
    enum DownloadType {
        case all
        case master
        case accounts
        case planVisits
//        case planOws
        case appPresentations
    }
    
    func handleDownload(at index: Int) {
        let type: DownloadType = {
            switch index {
            case 0: return .all
            case 1: return .master
            case 2: return .accounts
            case 3: return .planVisits
//            case 4: return .planOws
            case 4: return .appPresentations
            default: return .master
            }
        }()
        
        startDownload(type)
    }
    
    func startDownload(_ type: DownloadType) {
        
        switch type {
            
        case .all:
            downloadAllData()
        case .master:
            subscribeToLoading()
            viewModel.getMasterData { [weak self] done in
                guard let self else { return }
                if done {
                    self.showAlert(alertTitle: "Done",
                                   alertMessage: "Master Data has been downloaded successfully.")
                } else {
                    self.showAlert(alertTitle: "Error",
                                   alertMessage: "Failed to download Master Data. Please try again.")
                }
            }
        case .accounts:
            subscribeToLoading()
            viewModel.getAccountsDoctors { [weak self] done in
                guard let self else { return }
                if done {
                    self.showAlert(alertTitle: "Done",
                                   alertMessage: "Accounts Doctors data has been downloaded successfully.")
                } else {
                    self.showAlert(alertTitle: "Error",
                                   alertMessage: "Failed to download Accounts Doctors data. Please try again.")
                }
            }
        case .planVisits:
            subscribeToLoading()
            viewModel.getPlannedVisits { [weak self] done in
                guard let self else { return }
                if done {
                    self.showAlert(alertTitle: "Done",
                                   alertMessage: "Plan Visits data has been downloaded successfully.")
                } else {
                    self.showAlert(alertTitle: "Error",
                                   alertMessage: "Failed to download Plan Visits data. Please try again.")
                }
            }
        case .appPresentations:
            subscribeToLoading()
            viewModel.getAppPresentations { [weak self] done in
                guard let self else { return }
                if done {
                    self.showAlert(alertTitle: "Done",
                                   alertMessage: "App Presentations data has been downloaded successfully.")
                } else {
                    self.showAlert(alertTitle: "Error",
                                   alertMessage: "Failed to download App Presentations data. Please try again.")
                }
            }
        }
    }
}
private extension DataCenterVC {
    
    func downloadAllData() {
        let group = DispatchGroup()
        
        var results: [String: Bool] = [:]
        
        subscribeToLoading(isAll: true)
        
        let apis: [(name: String, call: (@escaping (Bool) -> Void) -> Void)] = [
            ("Master Data", viewModel.getMasterData),
            ("Accounts Doctors", viewModel.getAccountsDoctors),
            ("Plan Visits", viewModel.getPlannedVisits),
            ("App Presentations", viewModel.getAppPresentations)
        ]
        
        for api in apis {
            group.enter()
            api.call { success in
                results[api.name] = success
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            
            let message = apis.map { api in
                let success = results[api.name] ?? false
                return "\(api.name): " + (success ? "has been downloaded Success ✅" : "has been downloaded Failed ❌")
            }.joined(separator: "\n")
            
            let allSuccess = results.values.allSatisfy { $0 }
            
            self.showAlert(
                alertTitle: allSuccess ? "Done" : "Partial Error",
                alertMessage: message
            )
            
            self.endLoading()
        }
    }
}
