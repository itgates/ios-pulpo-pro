//
//  navigation.swift
//  Puplo Pro
//
//  Created by Ahmed on 18/11/2025.
//

import Foundation
import Foundation
import UIKit
extension UIViewController {
    
    func navigationHomeVC() {
        let vc = HomeVC()
        let navController = UINavigationController(rootViewController: vc)
        navController.navigationBar.isHidden = true
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first {
            window.rootViewController = navController
            window.makeKeyAndVisible()
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
    
    func navigationLoginVC(companyName:String) {
        let loginVC = LoginVC()
        loginVC.companyName = companyName
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    func navigateIfPossible(for item: HomeModel) {
        guard let vcType = item.vc else { return }
        let viewController = vcType.init()
        navigationController?.pushViewController(viewController, animated: true)
    }
//    func navigationSavePalnsVC(model:[PlanningVisitsData]) {
//        let savePalnsVC = SavePlansVC()
//        savePalnsVC.planningVisits = model
//        self.navigationController?.pushViewController(savePalnsVC, animated: true)
//    }
//    func slidesWebViewVC(slides: [Slides]) {
//        let vc = SlidesWebViewVC()
//        vc.slidesArray = slides
//        let nav = OrientationNavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .fullScreen
//        present(nav, animated: true)
//
//    }
    func closePopUp() {
        // Animate disappearance
        UIView.animate(withDuration: 0.25,
                       animations: {
            self.view.alpha = 0
            self.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: { _ in
            // Remove from parent after animation
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
        })
    }
    func showPopUp(view: UIViewController) {
        self.addChild(view)
        view.view.frame = self.view.bounds

        // Initial state for animation
        view.view.alpha = 0
        view.view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        self.view.addSubview(view.view)
        view.didMove(toParent: self)

        // Animate popup
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseOut,
                       animations: {
            view.view.alpha = 1
            view.view.transform = .identity
                       }, completion: nil)
    }
}
