
//  SplashVC.swift
//  Puplo Pro
//
//  Created by Ahmed on 01/01/2026.
//

import UIKit
import LocalAuthentication

final class SplashVC: UIViewController {

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateIfNeeded()
    }
}

// MARK: - Authentication
private extension SplashVC {

    func authenticateIfNeeded() {
        let context = LAContext()
        var error: NSError?

        let policy: LAPolicy = .deviceOwnerAuthentication

        guard context.canEvaluatePolicy(policy, error: &error) else {
            navigateToNextScreen()
            return
        }

        let reason = "Please authenticate to securely access the application."

        context.evaluatePolicy(policy, localizedReason: reason) { [weak self] success, _ in
            DispatchQueue.main.async {
                success ? self?.navigateToNextScreen() : self?.handleAuthFailure()
            }
        }
    }

    func handleAuthFailure() {
        // Best practice: keep user on splash or show alert
        showAuthFailedAlert()
    }
}

// MARK: - Navigation
private extension SplashVC {

    func navigateToNextScreen() {
        let user = LocalStorageManager.shared.getLoggedUser()
        let destinationVC: UIViewController = (user?.user_id != nil)
            ? HomeVC()
            : PinVC()

        navigationController?.setViewControllers([destinationVC], animated: true)
    }
}

// MARK: - Alerts
private extension SplashVC {

    func showAuthFailedAlert() {
        let alert = UIAlertController(
            title: "Authentication Failed",
            message: "You need to authenticate to continue using the app.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
            self?.authenticateIfNeeded()
        })

        alert.addAction(UIAlertAction(title: "Exit", style: .destructive) { _ in
            exit(0)
        })

        present(alert, animated: true)
    }
}
