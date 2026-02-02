////
////  MyLocationVC.swift
////  Puplo Pro
////
//
//import UIKit
//import RxCocoa
//import RxSwift
//import CoreLocation
//import GoogleMaps
//
//enum ViewType {
//    case actual
//    case plannedVisit
//    case location
//}
//
//final class MyLocationVC: BaseView {
//
//    // MARK: - Outlets
//    @IBOutlet weak var mapView: GMSMapView!
//    @IBOutlet private weak var viewBackgroundHeader: UIView!
//    @IBOutlet private weak var appVersionLabel: UILabel!
//    @IBOutlet private weak var companyNameLabel: UILabel!
//    @IBOutlet private weak var buttonBack: UIButton!
//
//    // MARK: - Properties
//    private let disposeBag = DisposeBag()
//    private let locationManager = CLLocationManager()
//    private var didCenterOnce = false
//    private let zoomLevel: Float = 18
//
//    var itemModel: ActualVisitModel?
//    var delegateType: ViewType = .location
//}
//
//// MARK: - Lifecycle
//extension MyLocationVC {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupLocation()
//        bindUI()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        setupMarkers()
//    }
//}
//
//// MARK: - UI Setup
//private extension MyLocationVC {
//
//    func setupUI() {
//        drawRoundedCorners(for: viewBackgroundHeader, cornerRadius: 20, direction: .bottom)
//        shadowView(viewBackgroundHeader)
//
//        appVersionLabel.text = displayAppVersion()
//        appVersionLabel.textColor = .green
//        companyNameLabel.text = "I. \(user?.company_name ?? "")"
//
//        mapView.delegate = self
//
//        switch delegateType {
//        case .actual, .plannedVisit:
//            mapView.isMyLocationEnabled = false
//            mapView.settings.myLocationButton = false
//        case .location:
//            mapView.isMyLocationEnabled = true
//            mapView.settings.myLocationButton = true
//        }
//    }
//
//    func bindUI() {
//        buttonBack.rx.tap
//            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
//            .bind(with: self) { vc, _ in vc.dismiss() }
//            .disposed(by: disposeBag)
//    }
//}
//
//// MARK: - Location Handling
//private extension MyLocationVC {
//
//    func setupLocation() {
//        guard delegateType == .location else { return }
//
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//
//        switch locationManager.authorizationStatus {
//        case .notDetermined:
//            locationManager.requestWhenInUseAuthorization()
//        case .authorizedAlways, .authorizedWhenInUse:
//            locationManager.startUpdatingLocation()
//        default:
//            if let lastLocation = LocalStorageManager.shared.getUserLocation() {
//                centerOnce(at: lastLocation)
//            }
//        }
//    }
//
//    func centerOnce(at location: CLLocation) {
//        guard !didCenterOnce else { return }
//        didCenterOnce = true
//
//        let camera = GMSCameraPosition(target: location.coordinate, zoom: zoomLevel)
//        mapView.animate(to: camera)
//    }
//}
//
//// MARK: - CLLocationManagerDelegate
//extension MyLocationVC: CLLocationManagerDelegate {
//
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        switch manager.authorizationStatus {
//        case .authorizedAlways, .authorizedWhenInUse:
//            locationManager.startUpdatingLocation()
//            mapView.isMyLocationEnabled = true
//            mapView.settings.myLocationButton = true
//        default:
//            if let lastLocation = LocalStorageManager.shared.getUserLocation() {
//                centerOnce(at: lastLocation)
//            }
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager,
//                         didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.first else { return }
//
//        centerOnce(at: location)
//        LocalStorageManager.shared.saveUserLocation(location)
//        locationManager.stopUpdatingLocation()
//    }
//}
//
//// MARK: - Marker Types
//private enum LocationPinType {
//    case start
//    case end
//}
//
//// MARK: - Marker Data
//private struct MarkerData {
//    let type: LocationPinType
//    let accountName: String
//    let startLat: String
//    let startLng: String
//    let endLat: String
//    let endLng: String
//}
//
//// MARK: - Markers
//private extension MyLocationVC {
//
//    func setupMarkers() {
//        mapView.clear()
//
//        switch delegateType {
//
//        case .actual:
//            guard let model = itemModel,
//                  let startLat = Double(model.llAcccount),
//                  let startLng = Double(model.lgAcccount),
//                  let endLat = Double(model.endLat ?? ""),
//                  let endLng = Double(model.endLong ?? "") else { return }
//
//            print("📍 Start:", startLat, startLng)
//            print("📍 End:", endLat, endLng)
//
//            let start = CLLocationCoordinate2D(latitude: startLat, longitude: startLng)
//            let end = CLLocationCoordinate2D(latitude: endLat, longitude: endLng)
//
//            addMarker(at: start, type: .start, model: model)
//            addMarker(at: end, type: .end, model: model)
//
//            var bounds = GMSCoordinateBounds()
//            bounds = bounds.includingCoordinate(start)
//            bounds = bounds.includingCoordinate(end)
//
//            mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 80))
//
//        case .plannedVisit:
//            guard let model = itemModel,
//                  let lat = Double(model.llAcccount),
//                  let lng = Double(model.lgAcccount) else { return }
//
//            print("📍 Planned:", lat, lng)
//
//            let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
//            addMarker(at: location, type: .start, model: model)
//
//            mapView.animate(to: GMSCameraPosition(target: location, zoom: zoomLevel))
//
//        case .location:
//            break
//        }
//    }
//
//    func addMarker(
//        at coordinate: CLLocationCoordinate2D,
//        type: LocationPinType,
//        model: ActualVisitModel
//    ) {
//        let marker = GMSMarker(position: coordinate)
//
//        // ✅ مهم جدًا – يخلي الـ marker clickable
//        marker.icon = UIImage(named: "PinMap")
//        marker.isTappable = true
//
//        marker.userData = MarkerData(
//            type: type,
//            accountName: model.account_name ?? "",
//            startLat: model.llAcccount,
//            startLng: model.lgAcccount,
//            endLat: model.endLat ?? "",
//            endLng: model.endLong ?? ""
//        )
//
//        marker.map = mapView
//    }
//}
//
//// MARK: - GMSMapViewDelegate
//extension MyLocationVC: GMSMapViewDelegate {
//
//    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
//        print("✅ Marker tapped:",
//              marker.position.latitude,
//              marker.position.longitude)
//        return false // لازم false عشان infoWindow يظهر
//    }
//
//    func mapView(_ mapView: GMSMapView,
//                 markerInfoWindow marker: GMSMarker) -> UIView? {
//
//        guard let data = marker.userData as? MarkerData else { return nil }
//
//        let label = UILabel()
//        label.numberOfLines = 0
//        label.font = .systemFont(ofSize: 12)
//        label.textAlignment = .center
//
//        switch data.type {
//        case .start:
//            label.text = """
//            \(data.accountName)
//            \(data.startLat), \(data.startLng)
//            """
//        case .end:
//            label.text = """
//            Visit Location
//            \(data.endLat), \(data.endLng)
//            """
//        }
//
//        let padding: CGFloat = 10
//        let maxWidth: CGFloat = 180
//        let size = label.sizeThatFits(CGSize(width: maxWidth - padding * 2,
//                                             height: .greatestFiniteMagnitude))
//
//        let container = UIView(frame: CGRect(x: 0, y: 0,
//                                             width: maxWidth,
//                                             height: size.height + padding * 2))
//        container.backgroundColor = .white
//        container.layer.cornerRadius = 8
//        container.layer.borderWidth = 0.5
//        container.layer.borderColor = UIColor.lightGray.cgColor
//
//        label.frame = CGRect(x: padding, y: padding,
//                             width: maxWidth - padding * 2,
//                             height: size.height)
//        container.addSubview(label)
//
//        return container
//    }
//}


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

final class MyLocationVC: BaseView {

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
extension MyLocationVC {

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
private extension MyLocationVC {

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
private extension MyLocationVC {

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
                LocalStorageManager.shared.getUserLocation() {
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
extension MyLocationVC: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        default:
            if let lastLocation =
                LocalStorageManager.shared.getUserLocation() {
                centerOnce(at: lastLocation)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        centerOnce(at: location)
        LocalStorageManager.shared.saveUserLocation(location)
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - Markers
private extension MyLocationVC {

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
extension MyLocationVC: MKMapViewDelegate {

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
