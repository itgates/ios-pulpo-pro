//
//  LocationPermissionManager.swift
//  Puplo Pro
//
//  Created by Ahmed on 28/12/2025.
//

import CoreLocation
import UIKit

class LocationPermissionManager: NSObject, CLLocationManagerDelegate {

    static let shared = LocationPermissionManager()
    private let locationManager = CLLocationManager()

    private override init() {
        super.init()
        locationManager.delegate = self
    }

    func checkLocationPermission(from vc: UIViewController) {
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        case .denied, .restricted:
            showLocationAlert(from: vc)

        case .authorizedWhenInUse, .authorizedAlways:
            break
        @unknown default:
            break
        }
    }

    private func showLocationAlert(from vc: UIViewController) {
        let alert = UIAlertController(
            title: "Location Required",
            message: "Enable location to improve visit accuracy. You can continue using the app without it.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })

        vc.present(alert, animated: true)
    }
}
