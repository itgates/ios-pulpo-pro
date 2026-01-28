//
//  StatisticsVC.swift
//  Puplo Pro
//
//  Created by Ahmed on 06/01/2026.
//

import UIKit
import RxCocoa
import RxSwift

final class StatisticsVC: BaseView {

    // MARK: - Outlets
    @IBOutlet private weak var viewBackgroundHeader: UIView!
    @IBOutlet private weak var appVersionLabel: UILabel!
    @IBOutlet private weak var companyNameLabel: UILabel!

    @IBOutlet private weak var buttonBack: UIButton!

    @IBOutlet private weak var productsCountLabel: UILabel!
    @IBOutlet private weak var accountsCountLabel: UILabel!
    @IBOutlet private weak var plannedVisitsCountLabel: UILabel!
    @IBOutlet private weak var actualVisitsCountLabel: UILabel!
    @IBOutlet private weak var settingsCountLabel: UILabel!

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = StatisticsViewModel()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindUI()
    }
}

// MARK: - UI Setup
private extension StatisticsVC {

    func setupUI() {
        drawRoundedCorners(for: viewBackgroundHeader,
                           cornerRadius: 20,
                           direction: .bottom)

        shadowView(viewBackgroundHeader)

        appVersionLabel.text = displayAppVersion()
        appVersionLabel.textColor = .green

        companyNameLabel.text = "I. \(user?.company_name ?? "")"
    }
}

// MARK: - Bindings
private extension StatisticsVC {

    func bindUI() {

        // Statistics bindings
        viewModel.productsCount
            .drive(productsCountLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.accountsCount
            .drive(accountsCountLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.plannedVisitsCount
            .drive(plannedVisitsCountLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.actualVisitsCount
            .drive(actualVisitsCountLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.settingsCount
            .drive(settingsCountLabel.rx.text)
            .disposed(by: disposeBag)

        // Back action
        buttonBack.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { vc, _ in
                vc.dismiss()
            }
            .disposed(by: disposeBag)
    }
}
