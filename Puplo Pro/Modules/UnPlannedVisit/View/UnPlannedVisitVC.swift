//
//  UnPlannedVisitVC.swift
//  Puplo Pro
//

import UIKit
import RxCocoa
import RxSwift

enum TabIndex: Int {
    case first = 0
    case second = 1
    case third = 2
    case fourth = 3
}
enum NavigationResult {
    case allowed
    case blocked(message: String)
}
final class UnPlannedVisitVC: BaseView {

    // MARK: - Outlets
    @IBOutlet weak var childViewFrame: UIView!
    @IBOutlet private weak var viewBackgroundHeader: UIView!
    @IBOutlet private weak var appVersionLabel: UILabel!
    @IBOutlet private weak var companyNameLabel: UILabel!
    @IBOutlet private weak var buttonBack: UIButton!

    @IBOutlet private weak var viewBackgroundButtonTappes: UIView!
    @IBOutlet private weak var firstTapButton: UIButton!
    @IBOutlet private weak var secondTapButton: UIButton!
    @IBOutlet private weak var thirdTapButton: UIButton!
    @IBOutlet private weak var fourthTapButton: UIButton!

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private var currentViewController: UIViewController?
    private var defaultHomeVC: UnPlannedVisitDetailsVC?

    private let selectedPeriod = BehaviorRelay<Period>(value: .firstTap)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupButtons()
        bindUI()
    }
}

// MARK: - UI Setup
private extension UnPlannedVisitVC {

    func setupUI() {
        displayCurrentTab(TabIndex.first.rawValue)

        drawRoundedCorners(for: viewBackgroundHeader, cornerRadius: 20, direction: .bottom)
        shadowView(viewBackgroundHeader)

        appVersionLabel.text = displayAppVersion()
        appVersionLabel.textColor = .green
        companyNameLabel.text = "I. \(user?.company_name ?? "")"

        viewBackgroundButtonTappes.layer.cornerRadius = 10
        highlightButton(firstTapButton)
    }

    func setupButtons() {
        [firstTapButton, secondTapButton, thirdTapButton, fourthTapButton].forEach {
            $0.layer.cornerRadius = 10
        }
    }

    func highlightButton(_ button: UIButton) {
        button.backgroundColor = baseColor
        button.tintColor = .white
    }

    func resetButtonsUI() {
        [firstTapButton, secondTapButton, thirdTapButton, fourthTapButton].forEach {
            $0.backgroundColor = .clear
            $0.tintColor = baseColor
        }
    }

    private func updateButtonsUI(selected: Period) {
        resetButtonsUI()

        switch selected {
        case .firstTap:
            highlightButton(firstTapButton)
            displayCurrentTab(TabIndex.first.rawValue)

        case .secondTap:
            highlightButton(secondTapButton)
            displayCurrentTab(TabIndex.second.rawValue)

        case .thirdTap:
            highlightButton(thirdTapButton)
            displayCurrentTab(TabIndex.third.rawValue)

        case .fourthTap:
            highlightButton(fourthTapButton)
            displayCurrentTab(TabIndex.fourth.rawValue)
        }
    }
}

// MARK: - Child VC Handling
private extension UnPlannedVisitVC {

    func displayCurrentTab(_ tabIndex: Int) {
        if let current = currentViewController {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }

        guard let vc = viewControllerForSelectedSegmentIndex(tabIndex) else { return }

        addChild(vc)
        vc.view.frame = childViewFrame.bounds
        childViewFrame.addSubview(vc.view)
        vc.didMove(toParent: self)

        currentViewController = vc
    }

    func viewControllerForSelectedSegmentIndex(_ index: Int) -> UIViewController? {
        switch index {
        case TabIndex.first.rawValue:
            if let defaultVC = defaultHomeVC {
                return defaultVC
            } else {
                let vc = UnPlannedVisitDetailsVC()
                defaultHomeVC = vc
                return vc
            }

        case TabIndex.second.rawValue:
            return UnPlannedVisitGiftsVC()

        case TabIndex.third.rawValue:
            return UnPlannedVisitItemsVC()

        case TabIndex.fourth.rawValue:
            return UnPlannedVisitNotesVC()

        default:
            return nil
        }
    }
}

// MARK: - Validation Logic
private extension UnPlannedVisitVC {
    func canNavigate(from current: TabIndex, to target: TabIndex) -> Bool {

        guard current != target else { return true }
        let currentValidation = validate(tab: current)

        if target == .fourth {
            if case .blocked(let msg) = validate(tab: .first) {
                showAlert(alertTitle: "Incomplete Data", alertMessage: msg)
                return false
            }

            if case .blocked(let msg) = validate(tab: .second) {
                showAlert(alertTitle: "Incomplete Data", alertMessage: msg)
                return false
            }

            if case .blocked(let msg) = validate(tab: .third) {
                showAlert(alertTitle: "Incomplete Data", alertMessage: msg)
                return false
            }

            return true
        }

        if case .blocked(let msg) = currentValidation,
           case .blocked = validate(tab: target) {

            showAlert(alertTitle: "Incomplete Data", alertMessage: msg)
            return false
        }
        return true
    }
}

// MARK: - Rx Bindings
private extension UnPlannedVisitVC {

    func bindUI() {

        let buttons: [(UIButton, Period)] = [
            (firstTapButton, .firstTap),
            (secondTapButton, .secondTap),
            (thirdTapButton, .thirdTap),
            (fourthTapButton, .fourthTap)
        ]

        buttons.forEach { button, period in
            button.rx.tap
                .bind(with: self) { vc, _ in
                    let currentTab = vc.periodToTabIndex(vc.selectedPeriod.value)
                    let targetTab = vc.periodToTabIndex(period)

                    guard vc.canNavigate(from: currentTab, to: targetTab) else { return }

                    vc.selectedPeriod.accept(period)
                    vc.updateButtonsUI(selected: period)
                }
                .disposed(by: disposeBag)
        }

        buttonBack.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { vc, _ in
                vc.dismiss()
            }
            .disposed(by: disposeBag)
    }
}
