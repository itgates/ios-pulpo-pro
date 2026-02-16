//
//  BaseView.swift
//  Puplo Pro
//
//  Created by Ahmed on 17/11/2025.
//

import UIKit
import RxSwift
import RxCocoa

// MARK: - Enums
enum CornerDirection {
    case top, bottom, right, left
    case rightBottom, leftBottom, rightTop, leftTop
}

// MARK: - BaseView
class BaseView: UIViewController, UITextFieldDelegate{
    
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = OfflineRequestManager()
    
    let user = LocalStorageManager.shared.getLoggedUser()
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNeedsStatusBarAppearanceUpdate()
        LocationPermissionManager.shared.checkLocationPermission(from: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        executeOfflineRequestsIfNeeded()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc private func appDidBecomeActive() {
        LocationPermissionManager.shared.checkLocationPermission(from: self)
    }
   
    private func executeOfflineRequestsIfNeeded() {
        guard Reachability.isConnectedToNetwork() else { return }
        let offlineOWS = LocalStorageManager.shared.getOWActivitiesData() ?? []
        print("offlineOWS.count >>>\(offlineOWS.count)")
        guard !offlineOWS.isEmpty else {
            return
        }

        let dispatchGroup = DispatchGroup()
        var requestStatuses: [String] = []
        
        // MARK: - Offline OW & Activities
        if !offlineOWS.isEmpty {
            dispatchGroup.enter()
            viewModel.fetchDataApplay(OWS: offlineOWS) { done, message in
                if done {
                    LocalStorageManager.shared.clearOWActivitiesModel()
                    requestStatuses.append("OW & Activities: Success ✅")
                } else {
                    requestStatuses.append("OW & Activities: Error - \(message) ❌")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            let finalMessage = requestStatuses.joined(separator: "\n")
            self.showAlert(
                alertTitle: "Offline Sync Status",
                alertMessage: finalMessage
            )
        }
    }
    
    
    
    func setApplyButton(button: UIButton ,enabled: Bool) {
        button.isEnabled = enabled
        button.alpha = enabled ? 1.0 : 0.6
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    func style(
        view: UIView,
        cornerRadius: CGFloat? = nil,
        borderWidth: CGFloat? = nil,
        borderColor: UIColor? = nil,
        backgroundColor: UIColor? = nil
    ) {
        if let radius = cornerRadius {
            view.layer.rx.cornerRadius.onNext(radius)
        }
        
        if let width = borderWidth {
            view.layer.rx.borderWidth.onNext(width)
        }
        
        if let color = borderColor {
            view.layer.rx.borderColor.onNext(color.cgColor)
        }
        
        if let bg = backgroundColor {
            view.rx.backgroundColor.onNext(bg)
        }
    }
    
    // MARK: - Rounded Corners
    func drawRoundedCorners(for view: UIView, cornerRadius: CGFloat, direction: CornerDirection) {
        view.layer.cornerRadius = cornerRadius
        view.layer.masksToBounds = true
        
        switch direction {
        case .top:
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .bottom:
            view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .right:
            view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        case .left:
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        case .rightBottom:
            view.layer.maskedCorners = [.layerMaxXMaxYCorner]
        case .leftBottom:
            view.layer.maskedCorners = [.layerMinXMaxYCorner]
        case .rightTop:
            view.layer.maskedCorners = [.layerMaxXMinYCorner]
        case .leftTop:
            view.layer.maskedCorners = [.layerMinXMinYCorner]
        }
    }
    
    // MARK: - Shadow
    
    /// Adds shadow to any UIView (UILabel, UIButton, or UIView)
    func shadowView(
        _ view: UIView,
        color: UIColor = .black,
        opacity: Float = 0.25,
        offset: CGSize = CGSize(width: 0, height: 4),
        radius: CGFloat = 8
    ) {
        view.layer.shadowColor = color.cgColor
        view.layer.shadowOpacity = opacity
        view.layer.shadowOffset = offset
        view.layer.shadowRadius = radius
        view.layer.masksToBounds = false
    }
    // MARK: - App Version
    func displayAppVersion()->String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return "v\(version)"
        } else {
            return "v1.0"
        }
    }
}
class BaseNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
class AppInfo {
    static let shared = AppInfo()
    
    var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    var osVersion: String {
        return UIDevice.current.systemVersion
    }
    
    var deviceModel: String {
        return UIDevice.current.model + " " + UIDevice.current.name
    }
    
    var deviceID: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
}
extension BaseView {

    @discardableResult
    func addGemstoneNavigation(
        title: String,
        showBack: Bool = true
    ) -> GemstoneNavigationView {

        let navView = GemstoneNavigationView()
        navView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(navView)

        NSLayoutConstraint.activate([
            navView.topAnchor.constraint(equalTo: view.topAnchor),
            navView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navView.heightAnchor.constraint(equalToConstant: 110) // يشمل status bar
        ])

        navView.configure(
            title: title,
            version: displayAppVersion(),
            showBack: showBack
        )

        navView.onBackTapped = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        return navView
    }

}
