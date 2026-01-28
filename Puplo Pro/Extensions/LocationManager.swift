//
//  LocationManager.swift
//  Puplo Pro
//
//  Created by Ahmed on 19/11/2025.
//

import Foundation
import CoreLocation

final class LocationManager: NSObject {

    static let shared = LocationManager()

    private let locationManager = CLLocationManager()
    private var completionHandler: ((Double, Double) -> Void)?

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    /// Request user location
    func getCurrentLocation(completion: @escaping (_ lat: Double, _ long: Double) -> Void) {
        self.completionHandler = completion
        
        let status = CLLocationManager.authorizationStatus()

        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .denied || status == .restricted {
            // Permission denied
            completion(0.0, 0.0)
        } else {
            locationManager.startUpdatingLocation()
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        let lat = location.coordinate.latitude
        let long = location.coordinate.longitude

        completionHandler?(lat, long)
        completionHandler = nil
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location:", error)
        completionHandler?(0.0, 0.0)
        completionHandler = nil
    }
}
