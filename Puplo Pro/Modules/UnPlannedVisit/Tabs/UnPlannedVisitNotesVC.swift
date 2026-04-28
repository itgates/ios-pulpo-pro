//
//  UnPlannedVisitNotesVC.swift
//  Gemstone Pro
//
//  Created by Ahmed on 09/12/2025.

import UIKit
import PhotosUI
import RxCocoa
import RxSwift

final class UnPlannedVisitNotesVC: BaseView {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var viewBackgroundAttachments: UIView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var collectionViewImages: UICollectionView!
    @IBOutlet private weak var addImagesTapped: UIImageView!
    @IBOutlet weak var endVisitButton: UIButton!
    // MARK: - Properties
    private let viewModel = UnPlannedVisitNotesViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - Computed Data
    private var visitItems: [VisitItem] {
        RealmStorageManager.shared.getVisitItemData() ?? []
    }
    
    private var giftsData: [IdNameModel] {
        RealmStorageManager.shared.getGiftsData() ?? []
    }
    
    private var productsData: [ProductItem] {
        RealmStorageManager.shared.getProductsData() ?? []
    }
    let masterData = AppDataProvider.shared.masterData?.Data?.settings
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindButtons()
        setupBindings()
        loadData()
        updateEndVisitButtonState()
        setupUI()
        
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        endVisitButton.layer.cornerRadius = endVisitButton.frame.height / 2
        endVisitButton.layer.masksToBounds = true
    }
}

// MARK: - UI Setup
private extension UnPlannedVisitNotesVC {
    
    /// Initial UI configuration
    func setupUI() {
        setupTableView()
        setupCollectionView()
        setupAddImagesGesture()
        style(view: viewBackgroundAttachments,
              cornerRadius: viewBackgroundAttachments.frame.height / 2,
              borderWidth: 2,
              borderColor: baseColor
        )
        LocationManager.shared.getCurrentLocation { lat, lng in
            RealmStorageManager.shared.saveVisitEndLocation(lat: lat, lng: lng)
        }
    }
    
    /// Configure add-images tap gesture
    func setupAddImagesGesture() {
        addImagesTapped.isUserInteractionEnabled = true
        addImagesTapped.onTap { [weak self] in
            guard let self = self else { return }
            ImagePickerManager.shared.presentImagePicker(from: self) { images in
                guard !images.isEmpty else { return }
                
                // ===== أظهر اللودر أولًا =====
                self.startLoading(withText: "Loading 0%")
                
                self.viewModel.uploadImages(
                    images: images,
                    progressHandler: { [weak self] progress in
                        self?.updateLoadingText("Loading \(progress)%")
                    },
                    completion: { [weak self] result in
                        guard let self = self else { return }
                        DispatchQueue.main.async { self.endLoading() }
                        
                        switch result {
                        case .success(let response):
                            print("✅ Upload success:", response.message)
                            var updatedImages: [SelectedImage] = []
                            for (index, uploaded) in response.data.enumerated() {
                                guard index < images.count else { continue }
                                let originalImage = images[index]
                                let updated = SelectedImage(
                                    id: originalImage.id,
                                    imageData: originalImage.imageData,
                                    path: uploaded.path
                                )
                                updatedImages.append(updated)
                            }
                            self.viewModel.selectedImages.append(contentsOf: updatedImages)
                            self.viewModel.imagesSubject.accept(self.viewModel.selectedImages)
                            RealmStorageManager.shared.saveSelectedImageVisitData(self.viewModel.selectedImages)
                        case .failure(let error):
                            print("❌ Upload failed:", error)
                            self.showAlert(
                                alertTitle: "Upload Error",
                                alertMessage: error.localizedDescription
                            )
                        }
                    }
                )
            }
        }
        
    }
    
    /// Configure collection view layout & cell
    func setupCollectionView() {
        if let layout = collectionViewImages.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 90, height: 35)
            layout.minimumInteritemSpacing = 8
            layout.minimumLineSpacing = 8
        }
        collectionViewImages.registerCell(cellClass: CellImage.self)
    }
    /// Configure table view
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NotesCell.self, forCellReuseIdentifier: "NotesCell")
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()
    }
}
// MARK: - Bindings
private extension UnPlannedVisitNotesVC {
    
    // MARK: - Binding Buttons
    private func bindButtons() {
        endVisitButton.rx.tap
            .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
            .bind(with: self) { vc, _ in
                vc.handleEndVisitTap()
            }
            .disposed(by: disposeBag)
    }
    // MARK: - Loading Indicator
    private func subscribeToLoading() {
        viewModel.loadingBehavior
            .subscribe(onNext: { [weak self] isLoading in
                isLoading ? self?.startLoading() : self?.endLoading()
            })
            .disposed(by: disposeBag)
    }
    private func handleEndVisitTap() {

        subscribeToLoading()

        guard validateEndVisitData() else {
            updateEndVisitButtonState()
            return
        }

        if let errorMessage = viewModel.validateActualVisit() {
            showAlert(alertTitle: "Error", alertMessage: errorMessage)
            updateEndVisitButtonState()
            return
        }
        guard let acceptedDistance = getAcceptedDistance() else {
            saveVisit()
            return
        }
        LocationManager.shared.getCurrentLocation { [weak self] lat, lng in
            guard let self = self else { return }
            RealmStorageManager.shared.saveVisitEndLocation(lat: lat, lng: lng) // ✅ هنا
            self.validateLocationAndSave(
                endLat: lat,
                endLng: lng,
                acceptedDistance: acceptedDistance
            )
        }
    }
    func saveVisit() {

        subscribeToLoading()
//        setApplyButton(button: endVisitButton, enabled: false)
        viewModel.saveUnPlannedVisit { [weak self] done, message in
            guard let self else { return }
            if done {
                self.showTopAlert(message: "The visit was successfully completed") {
                    self.navigationHomeVC()
                }
            } else {
                self.showAlert(alertTitle: "Error", alertMessage: message)
                self.updateEndVisitButtonState()
            }
        }
    }
    private func updateEndVisitButtonState() {
        let isValid =
        !visitItems.isEmpty
//        !giftsData.isEmpty &&
//        !productsData.isEmpty
        
        setApplyButton(button: endVisitButton, enabled: isValid)
    }
    
    func validateEndVisitData() -> Bool {
        
        if visitItems.isEmpty {
            showAlert(alertTitle: "Error", alertMessage: "Please add details of the visit.")
            return false
        }
        
//        if giftsData.isEmpty {
//            showAlert(alertTitle: "Error", alertMessage: "Please add a gift.")
//            return false
//        }
//
//        if productsData.isEmpty {
//            showAlert(alertTitle: "Error", alertMessage: "Please add a product.")
//            return false
//        }
        return true
    }
    
    /// Rx bindings for collection view
    func setupBindings() {
        collectionViewImages.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.imagesObservable
            .bind(to: collectionViewImages.rx.items(
                cellIdentifier: String(describing: CellImage.self),
                cellType: CellImage.self
            )) { [weak self] _, model, cell in
                guard let self = self else { return }
                
                // Styling
                self.style(view: cell.imageView, cornerRadius: 17.5)
                self.style(view: cell.deleteButton,
                           cornerRadius: cell.deleteButton.frame.height / 2)
                
                // Configure cell
                cell.configure(image: model)
                
                // Fast delete using UUID
                cell.deleteImage = { [weak self] in
                    guard let self = self else { return }
                    
                    var currentImages = self.viewModel.imagesSubject.value
                    
                    if let index = currentImages.firstIndex(where: { $0.id == model.id }) {
                        currentImages.remove(at: index)
                        
                        self.viewModel.imagesSubject.accept(currentImages)
                        RealmStorageManager.shared.saveSelectedImageVisitData(currentImages)
                        self.viewModel.selectedImages = currentImages
                    }
                }
                
            }
            .disposed(by: disposeBag)
    }
}
// MARK: - Data Builders
private extension UnPlannedVisitNotesVC {
    
    /// Load all table sections
    func loadData() {
        viewModel.sections = [
            viewModel.buildVisitDetailsSection(),
            viewModel.buildGiftsSection(),
            viewModel.buildProductsSection()
        ]
        tableView.reloadData()
    }
    
 
}
// MARK: - UITableView Delegate & DataSource
extension UnPlannedVisitNotesVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.sections[section].header
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplayHeaderView view: UIView,
                   forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = baseColor
        header.textLabel?.font = .boldSystemFont(ofSize: 17)
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesCell",
                                                 for: indexPath) as! NotesCell
        let row = viewModel.sections[indexPath.section].rows[indexPath.row]
        cell.configure(title: row.title, value: row.value)
        return cell
    }
}

// MARK: - Validate End Location
extension UnPlannedVisitNotesVC {

    func validateLocationAndSave(
        endLat: Double,
        endLng: Double,
        acceptedDistance: Int
    ) {

        guard let visit = RealmStorageManager.shared.getVisitItemData()?.first else { return }

        let accountLat = Double(visit.account?.ll ?? "") ?? 0
        let accountLng = Double(visit.account?.lg ?? "") ?? 0

        let distance = viewModel.calculateDistance(
            from: accountLat,
            lng1: accountLng,
            to: endLat,
            lng2: endLng
        )

        let zone = viewModel.getZone(
            distance: distance,
            acceptedDistance: acceptedDistance
        )

        let trackingSettingIsOn = getSettingValue("allow_actual_with_deviation")
        let greenZoneSettingIsOn = getSettingValue("green_zone_with_deviation")
        let checkStartSettingIsOn = getSettingValue("check_on_start_location")
        
        switch zone {

        case .white:

            if checkStartSettingIsOn {
                validateStartLocation(acceptedDistance: acceptedDistance)
            } else {
                saveVisit()
            }

        case .green:

            if greenZoneSettingIsOn {

                if checkStartSettingIsOn {
                    validateStartLocation(acceptedDistance: acceptedDistance)
                } else {
                    saveVisit()
                }

            } else {

                if getSettingValue("hide_dialog_on_deviation") {
                    saveVisit()
                } else {
                    showLocationDeviationDialog(distance, acceptedDistance, true)
                }
            }
      
        case .red:

            if trackingSettingIsOn {

                if getSettingValue("hide_dialog_on_deviation") {
                    saveVisit()
                } else {
                    showLocationDeviationDialog(distance, acceptedDistance, true)
                }

            } else {

                if getSettingValue("hide_dialog_on_deviation") {
                    return
                } else {
                    showLocationDeviationDialogWithoutSave(distance, acceptedDistance)
                }
            }
        }
    }

    func validateStartLocation(acceptedDistance: Int) {

        guard let visit = RealmStorageManager.shared.getVisitItemData()?.first else { return }

        guard let startLocation = RealmStorageManager.shared.getVisitStartLocation() else {
            saveVisit()
            return
        }

        let accountLat = Double(visit.account?.ll ?? "") ?? 0
        let accountLng = Double(visit.account?.lg ?? "") ?? 0

        let distance = viewModel.calculateDistance(
            from: accountLat,
            lng1: accountLng,
            to: startLocation.coordinate.latitude,
            lng2: startLocation.coordinate.longitude
        )

        let zone = viewModel.getZone(
            distance: distance,
            acceptedDistance: acceptedDistance
        )

        switch zone {

        case .white:
            saveVisit()

        case .green:
            saveVisit()

        case .red:
            showLocationDeviationDialogWithTryAgain(distance, acceptedDistance)
        }
    }

    private func getAcceptedDistance() -> Int? {

        let value = RealmStorageManager.shared
            .getMasterData()?
            .Data?
            .account_types?
            .first?
            .accepted_distance

        print("value >>> \(value ?? "")")

        return Int(value ?? "250")
    }

    private func getSettingValue(_ key: String) -> Bool {

        return RealmStorageManager.shared
            .getMasterData()?
            .Data?
            .settings?
            .first(where: { $0.attribute_name == key })?
            .attribute_value == "1"
    }

    func showLocationDeviationDialog(
        _ deviation: Int,
        _ acceptedDistance: Int,
        _ allowSave: Bool
    ) {

        let message = "You are \(deviation)m away from the location"

        let alert = UIAlertController(
            title: "Location Deviation",
            message: message,
            preferredStyle: .alert
        )

        if allowSave {
            alert.addAction(UIAlertAction(title: "Save Anyway", style: .default) { _ in
                self.saveVisit()
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    func showLocationDeviationDialogWithTryAgain(
        _ deviation: Int,
        _ acceptedDistance: Int
    ) {

        let message = "You are \(deviation)m away from the location. Please try again."

        let alert = UIAlertController(
            title: "Location Error",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Try Again", style: .default))

        present(alert, animated: true)
    }

    func showLocationDeviationDialogWithoutSave(
        _ deviation: Int,
        _ acceptedDistance: Int
    ) {

        let message = "You are outside the allowed distance (\(acceptedDistance)m)."

        let alert = UIAlertController(
            title: "Location Error",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))

        present(alert, animated: true)
    }
}
