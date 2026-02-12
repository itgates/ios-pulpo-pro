//
//  LoginVC.swift
//  Puplo Pro
//
//  Created by Ahmed on 17/11/2025.
//

import UIKit
import RxCocoa
import RxSwift

class LoginVC: BaseView {

    // MARK: - Outlets
    @IBOutlet weak var viewBackgroundHeader: UIView!
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var buttonBack: UIButton!

    @IBOutlet weak var viewBackgroundUserName: UIView!
    @IBOutlet weak var userNameTextField: UITextField!

    @IBOutlet weak var viewBackgroundPassword: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var showPasswordButton: UIButton!

    @IBOutlet weak var loginButton: UIButton!

    // MARK: - Variables
    private let disposeBag = DisposeBag()
    private let viewModel = LoginViewModel()
    var companyName: String = ""

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStyles()
        setupBindings()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
        loginButton.layer.masksToBounds = true
    }

    // MARK: - UI Setup
    private func setupUI() {
        drawRoundedCorners(for: viewBackgroundHeader, cornerRadius: 20, direction: .bottom)
        shadowView(viewBackgroundHeader)

        passwordTextField.isSecureTextEntry = true

        appVersionLabel.text = displayAppVersion()
        appVersionLabel.textColor = .green

        userNameTextField.placeholder = "User Name"
        passwordTextField.placeholder = "Password"

        userNameTextField.placeHolderColor = .lightGray
        passwordTextField.placeHolderColor = .lightGray

        userNameTextField.textAlignment = .left
        passwordTextField.textAlignment = .left

        companyNameLabel.text = "I. \(companyName)"

        // Initial state
        setApplyButton(button: loginButton, enabled: false)
    }

    // MARK: - Styles
    private func setupStyles() {
        loginButton.backgroundColor = baseColor
        style(view: viewBackgroundUserName, cornerRadius: 15, borderWidth: 2, borderColor: baseColor)
        style(view: viewBackgroundPassword, cornerRadius: 15, borderWidth: 2, borderColor: baseColor)
    }

    // MARK: - Bindings
    private func setupBindings() {

        // Show / Hide password
        showPasswordButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                passwordTextField.isSecureTextEntry.toggle()
                let icon = passwordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
                showPasswordButton.setImage(UIImage(systemName: icon), for: .normal)
            })
            .disposed(by: disposeBag)

        // Validate form
        let isFormValid = Observable
            .combineLatest(
                userNameTextField.rx.text.orEmpty,
                passwordTextField.rx.text.orEmpty
            )
            .map { !$0.0.isEmpty && !$0.1.isEmpty }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)

        // Apply button state
        isFormValid
            .drive(onNext: { [weak self] isEnabled in
                guard let self else { return }
                self.setApplyButton(button: self.loginButton, enabled: isEnabled)
            })
            .disposed(by: disposeBag)

        // Login action
        loginButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.login()
            })
            .disposed(by: disposeBag)

        // Back
        buttonBack.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.dismiss()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Loading
    private func subscribeToLoading() {
        viewModel.loadingBehavior
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                isLoading ? self?.startLoading() : self?.endLoading()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Actions
    private func login() {
        let username = userNameTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        setApplyButton(button: loginButton, enabled: false)
        subscribeToLoading()

        viewModel.loginUser(
            name: username,
            password: password,
            companyName: companyName
        ) { [weak self] success in
            guard let self else { return }
            success ? self.loadMasterData() : self.handleLoginFailure()
        }
    }
    private func handleLoginFailure() {
        showAlert( alertTitle: "Error", alertMessage: "Invalid username or password")
        setApplyButton(button: loginButton, enabled: true)
    }
    private func loadMasterData() {
        viewModel.fetchAllData { [weak self] success in
            guard let self, success else { return }
            if success {
                self.showTopAlert(message: "Successfully login") {
                    self.navigationHomeVC()
                }
            } else {
                showAlert( alertTitle: "Error", alertMessage: "Data not found")
            }
           
        }
    }
}
