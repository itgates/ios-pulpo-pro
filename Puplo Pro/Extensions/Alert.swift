//
//  Alert.swift
//  Puplo Pro
//
//  Created by Ahmed on 17/11/2025.
//

import Foundation
import UIKit
extension UIViewController {
    
    //MARK: - push viewController Using
    func goVC<viewController: UIViewController>(vc: viewController.Type,storyboard: storyboards) {
        let storyboard = UIStoryboard(name: storyboard.rawValue, bundle: nil)
        let vc  = storyboard.instantiateViewController(withIdentifier: String(describing: viewController.self))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - dismiss viewController Using navigation
    func dismiss()  {
        navigationController?.popViewController(animated: true)
    }
    // MARK: - validation UIAlert
    func showAlert(alertTitle: String, alertMessage: String) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let okAlertButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        // Change background color based on the user interface style
        if #available(iOS 12.0, *) {
            switch traitCollection.userInterfaceStyle {
            case .dark:
                alert.view.tintColor = .white // Dark mode background color
            default:
                alert.view.tintColor = mainColor // Light mode background color
            }
        } else {
            // Fallback for earlier iOS versions
            alert.view.tintColor = mainColor
        }
        alert.addAction(okAlertButton)
        present(alert, animated: true, completion: nil)
        
    }
    
}
extension UIViewController {

    func showTopAlert(message: String, duration: TimeInterval = 1.0, completion: (() -> Void)? = nil) {
        guard let parentView = self.view.window ?? self.view else { return } // superview أو window
        
        let alertHeight: CGFloat = 120
        let alertView = UIView(frame: CGRect(x: 0, y: -alertHeight, width: parentView.frame.width, height: alertHeight))
        alertView.backgroundColor = baseColor
        alertView.layer.cornerRadius = 10
        parentView.addSubview(alertView)
        
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: alertHeight - 20 - 20, width: alertView.frame.width, height: 20) // 20 نقطة من الأسفل
        alertView.addSubview(label)
        
        alertView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {
            alertView.frame.origin.y = 0
            alertView.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseIn) {
                alertView.frame.origin.y = -alertHeight
                alertView.alpha = 0
            } completion: { _ in
                alertView.removeFromSuperview()
                completion?()
            }
        }
    }
}
