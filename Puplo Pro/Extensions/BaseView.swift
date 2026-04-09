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
        let offlinePlans = LocalStorageManager.shared.getOfflinePlans() ?? []
     
        
        let visitItem = LocalStorageManager.shared.getVisitItemData() ?? []
        let managerData = LocalStorageManager.shared.getManagerData() ?? []
        let giftsData = LocalStorageManager.shared.getGiftsData() ?? []
        let productsData = LocalStorageManager.shared.getProductsData() ?? []
        let issetUnPlannedVisitOffline = LocalStorageManager.shared.isUnPlannedVisitOffline()

        let actualVisits = LocalStorageManager.shared.getActualVisitData() ?? []
        let hasPendingUnplannedVisits = actualVisits.contains { !$0.isUploaded }
        
        print("offlineOWS.count >>>\(offlineOWS.count)")

        let hasUnplannedVisitData =
            !visitItem.isEmpty ||
            !managerData.isEmpty ||
            !giftsData.isEmpty ||
            !productsData.isEmpty

        let shouldSendUnPlannedVisit =
            issetUnPlannedVisitOffline &&
            hasUnplannedVisitData &&
            hasPendingUnplannedVisits

        guard
            !offlinePlans.isEmpty ||
            !offlineOWS.isEmpty ||
            shouldSendUnPlannedVisit
        else {
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
        
        // MARK: - Offline Plans
        if !offlinePlans.isEmpty {
            dispatchGroup.enter()
            viewModel.savePlans { done, message, idsMap  in
                if done {
                    var storedVisits = LocalStorageManager.shared.getNewPlanData() ?? []

                    for index in storedVisits.indices {
                        guard !storedVisits[index].isUploaded else { continue }
                        if let offlineID = storedVisits[index].offlineID,
                           let matched = idsMap.first(where: { $0.offlineID == offlineID }) {
                            storedVisits[index].isUploaded = true
                            storedVisits[index].onlineID = matched.onlineID
                        }
                    }
                    LocalStorageManager.shared.saveNewPlanData(storedVisits)
                    LocalStorageManager.shared.clearOfflinePlans()
                    requestStatuses.append("Planning Visits: Success ✅")
                } else {
                    requestStatuses.append("Planning Visits: Error - \(message) ❌")
                }
                dispatchGroup.leave()
            }
        }
        
        // MARK: - Offline UnPlanned Visit (SAFE)
        if shouldSendUnPlannedVisit {
            dispatchGroup.enter()
            viewModel.saveUnPlannedVisitAPI { done, message, idsMap in
                if done {
                    var storedVisits = LocalStorageManager.shared.getActualVisitData() ?? []

                    for index in storedVisits.indices {
                        guard !storedVisits[index].isUploaded else { continue }

                        
                        print("idsMap.first?.offlineID  >> \(idsMap.first?.offlineID ?? "")")
                        print("storedVisits[index].offlineID  >> \(storedVisits[index].offline_id ?? "")")
                        
                        
                        if let offlineID = storedVisits[index].offline_id,
                           let matched = idsMap.first(where: { $0.offlineID == offlineID }) {

                            storedVisits[index].isUploaded = true
                            storedVisits[index].online_id = "\(matched.onlineID)"
                        }
                    }
                   
                    LocalStorageManager.shared.saveActualVisitData(storedVisits)

                    LocalStorageManager.shared.clearVisitItemData()
                    LocalStorageManager.shared.clearManagerData()
                    LocalStorageManager.shared.clearGiftsData()
                    LocalStorageManager.shared.clearProductsData()
                    LocalStorageManager.shared.clearSelectedImageVisitData()
                    LocalStorageManager.shared.clearUnPlannedVisitOffline()
                    LocalStorageManager.shared.clearVisitStartLocation()

                    requestStatuses.append("UnPlanned Visit: Success ✅")
                } else {
                    requestStatuses.append("UnPlanned Visit: Error - \(message) ❌")
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
    
    //MARK: - open Link
    func openLink(Link: String) {
        guard let url = URL(string: Link) else { return }
        UIApplication.shared.open(url)
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
