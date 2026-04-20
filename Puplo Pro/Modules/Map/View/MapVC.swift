//
//  MapVC.swift
//  Puplo Pro
//
//  Created by Ahmed on 16/02/2026.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation
import MapKit

enum ViewType {
    case actual
    case plannedVisit
    case location
}

final class MapVC: BaseView {

    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet private weak var viewBackgroundHeader: UIView!
    @IBOutlet private weak var appVersionLabel: UILabel!
    @IBOutlet private weak var companyNameLabel: UILabel!
    @IBOutlet private weak var buttonBack: UIButton!

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let locationManager = CLLocationManager()
    private var didCenterOnce = false

    var itemModel: ActualVisitModel?
    var delegateType: ViewType = .location
}

// MARK: - Lifecycle
extension MapVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocation()
        bindUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupMarkers()
    }
}

// MARK: - UI Setup
private extension MapVC {

    func setupUI() {
        drawRoundedCorners(for: viewBackgroundHeader,
                           cornerRadius: 20,
                           direction: .bottom)
        shadowView(viewBackgroundHeader)

        appVersionLabel.text = displayAppVersion()
        appVersionLabel.textColor = .green
        companyNameLabel.text = "I. \(user?.company_name ?? "")"

        mapView.delegate = self
        mapView.showsUserLocation = delegateType == .location
        mapView.userTrackingMode = delegateType == .location ? .follow : .none
    }

    func bindUI() {
        buttonBack.rx.tap
            .throttle(.milliseconds(300),
                      scheduler: MainScheduler.instance)
            .bind(with: self) { vc, _ in
                vc.dismiss()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Location Handling
private extension MapVC {

    func setupLocation() {
        guard delegateType == .location else { return }

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            if let lastLocation =
                RealmStorageManager.shared.getUserLocation() {
                centerOnce(at: lastLocation)
            }
        }
    }

    func centerOnce(at location: CLLocation) {
        guard !didCenterOnce else { return }
        didCenterOnce = true

        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )

        mapView.setRegion(region, animated: true)
    }
}

// MARK: - CLLocationManagerDelegate
extension MapVC: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        default:
            if let lastLocation =
                RealmStorageManager.shared.getUserLocation() {
                centerOnce(at: lastLocation)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        centerOnce(at: location)
        RealmStorageManager.shared.saveUserLocation(location)
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - Markers
private extension MapVC {

    func setupMarkers() {
        mapView.removeAnnotations(mapView.annotations)

        switch delegateType {

        case .actual:
            guard let model = itemModel,
                  let startLat = Double(model.llAcccount),
                  let startLng = Double(model.lgAcccount),
                  let endLat = Double(model.endLat ?? ""),
                  let endLng = Double(model.endLong ?? "") else { return }

            let start = CLLocationCoordinate2D(latitude: startLat,
                                               longitude: startLng)
            let end = CLLocationCoordinate2D(latitude: endLat,
                                             longitude: endLng)

            addAnnotation(
                coordinate: start,
                title: model.account_name ?? "",
                subtitle: "Start Location"
            )

            addAnnotation(
                coordinate: end,
                title: "Visit Location",
                subtitle: "End Location"
            )

            zoomToFit(coordinates: [start, end])

        case .plannedVisit:
            guard let model = itemModel,
                  let lat = Double(model.llAcccount),
                  let lng = Double(model.lgAcccount) else { return }

            let location = CLLocationCoordinate2D(latitude: lat,
                                                  longitude: lng)

            addAnnotation(
                coordinate: location,
                title: model.account_name ?? "",
                subtitle: "Planned Visit"
            )

            centerOnce(at: CLLocation(latitude: lat,
                                      longitude: lng))

        case .location:
            break
        }
    }

    func addAnnotation(
        coordinate: CLLocationCoordinate2D,
        title: String,
        subtitle: String
    ) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        annotation.subtitle = subtitle
        mapView.addAnnotation(annotation)
    }

    func zoomToFit(coordinates: [CLLocationCoordinate2D]) {
        var rect = MKMapRect.null

        coordinates.forEach {
            let point = MKMapPoint($0)
            rect = rect.union(
                MKMapRect(x: point.x,
                          y: point.y,
                          width: 0.01,
                          height: 0.01)
            )
        }

        mapView.setVisibleMapRect(
            rect,
            edgePadding: UIEdgeInsets(top: 80,
                                      left: 40,
                                      bottom: 80,
                                      right: 40),
            animated: true
        )
    }
}

// MARK: - MKMapViewDelegate
extension MapVC: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation)
    -> MKAnnotationView? {

        if annotation is MKUserLocation { return nil }

        let identifier = "Pin"
        let view =
            mapView.dequeueReusableAnnotationView(
                withIdentifier: identifier)
            as? MKMarkerAnnotationView
            ?? MKMarkerAnnotationView(
                annotation: annotation,
                reuseIdentifier: identifier)

        view.annotation = annotation
        view.canShowCallout = true
        view.markerTintColor = .systemGreen

        return view
    }
}
