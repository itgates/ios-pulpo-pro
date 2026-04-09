//
//  AppDelegate.swift
//  Puplo Pro
//
//  Created by Ahmed on 17/11/2025.
//

import UIKit
import IQKeyboardManagerSwift
import CoreData
import CoreLocation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var locationManager = CLLocationManager()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
//        GMSServices.provideAPIKey("AIzaSyCr-qeqsO7QlkOMXdIU8xiyooVP7EezO9Q")
//        GMSPlacesClient.provideAPIKey("AIzaSyCr-qeqsO7QlkOMXdIU8xiyooVP7EezO9Q")
        
        rootVC()
        // clear data 1783633
        LocalStorageManager.shared.setUnPlannedVisitOffline(false)
        LocalStorageManager.shared.clearVisitItemData()
        LocalStorageManager.shared.clearManagerData()
        LocalStorageManager.shared.clearGiftsData()
        LocalStorageManager.shared.clearProductsData()
        LocalStorageManager.shared.clearSelectedImageVisitData()
        LocalStorageManager.shared.clearVisitStartLocation()
        LocalStorageManager.shared.clearNewPlanData()
        LocalStorageManager.shared.clearActualVisitData()
        LocalStorageManager.shared.clearOfficeWorkModel()
        return true
    }
    
    //MARK: - check user logged
    func rootVC() {
        let rootVC: UIViewController = SplashVC()
        
        // Use your BaseNavigationController so childForStatusBarStyle is respected
        let navController = BaseNavigationController(rootViewController: rootVC)
        navController.navigationBar.isHidden = true
        
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        
        // Force the nav controller to refresh status bar appearance
        navController.setNeedsStatusBarAppearanceUpdate()
    }
    
    // MARK: - Core Data
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("❌ CoreData Error: \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("❌ CoreData Save Error: \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
