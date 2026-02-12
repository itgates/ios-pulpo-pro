//
//  PinVC.swift
//  Puplo Pro
//
//  Created by Ahmed on 17/11/2025.
//

import UIKit
import RxCocoa
import RxSwift
import Lottie

class PinVC: BaseView {
    
    // MARK: - Outlets
    @IBOutlet weak var viewBackgroundHeader: UIView!
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var lockIcon: LottieAnimationView!
    
    @IBOutlet weak var viewBackgroundCompanyPin: UIView!
    @IBOutlet weak var companyPinTextField: UITextField!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    // MARK: - Variables
    private let disposeBag = DisposeBag()
    private let animationView = LottieAnimationView(name: "pin_lottie")
    private let pinViewModel = PinViewModel()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStyles()
        setupBindings()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if companyPinTextField.text?.isEmpty == false {
            self.setApplyButton(button: self.confirmButton, enabled: true)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        confirmButton.layer.cornerRadius = confirmButton.frame.height / 2
        confirmButton.layer.masksToBounds = true
    }

    // MARK: - UI Setup
    private func setupUI() {
        drawRoundedCorners(for: viewBackgroundHeader, cornerRadius: 20, direction: .bottom)
        shadowView(viewBackgroundHeader)
        setupLottie()
        appVersionLabel.text = displayAppVersion()
        appVersionLabel.textColor = .green
        companyPinTextField.placeholder = "Pin"
        companyPinTextField.placeHolderColor = UIColor.lightGray
        companyPinTextField.textAlignment = .left
    }
    
    private func setupLottie() {
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        
        lockIcon.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: lockIcon.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: lockIcon.centerYAnchor),
            animationView.widthAnchor.constraint(equalTo: lockIcon.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: lockIcon.heightAnchor)
        ])
        
        animationView.play()
    }
    
    // MARK: - Styles
    private func setupStyles() {
        confirmButton.backgroundColor = baseColor
        style(view: viewBackgroundCompanyPin,cornerRadius: 15, borderWidth: 2,borderColor: baseColor)
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        
        // Stream: is text empty?
        let isPinValid = companyPinTextField.rx.text.orEmpty
            .map { !$0.isEmpty }
            .asDriver(onErrorJustReturn: false)
        
        // Enable / Disable button
        isPinValid
            .drive(confirmButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // Button alpha
        isPinValid
            .drive(onNext: { [weak self] isEnabled in
                self?.confirmButton.alpha = isEnabled ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)
        
        // Confirm click
        confirmButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .withLatestFrom(companyPinTextField.rx.text.orEmpty)
            .subscribe(onNext: { [weak self] pin in
                 self?.fetchData(pin: pin)
            })
            .disposed(by: disposeBag)
    }
    // MARK: - Loading Indicator
    private func subscribeToLoading() {
        pinViewModel.loadingBehavior
            .subscribe(onNext: { [weak self] isLoading in
                isLoading ? self?.startLoading() : self?.endLoading()
            })
            .disposed(by: disposeBag)
    }
    // MARK: - Fetch Data
    private func fetchData(pin: String) {
        setApplyButton(button: self.confirmButton, enabled: false)
        subscribeToLoading()
        pinViewModel.loginUser(pin: pin) { done,companyName, message in
            if done {
                self.navigationLoginVC(companyName: companyName)
            } else {
                self.showAlert(alertTitle: "Error", alertMessage: message)
                self.setApplyButton(button: self.confirmButton, enabled: true)
            }
        }
    }
}
