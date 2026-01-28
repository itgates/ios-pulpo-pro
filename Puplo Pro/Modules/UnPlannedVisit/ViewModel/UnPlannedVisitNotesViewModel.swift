//
//  UnPlannedVisitNotesViewModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 18/12/2025.
//
import Foundation
import RxSwift
import RxCocoa
import UIKit
import Alamofire
import CoreLocation

final class UnPlannedVisitNotesViewModel {
        
    // MARK: - Properties
    let loadingBehavior = BehaviorRelay<Bool>(value: false)
    let imagesSubject = BehaviorRelay<[SelectedImage]>(value: [])
    let uploadProgress = BehaviorRelay<Double>(value: 0.0)
    
    var selectedImages: [SelectedImage] = []
    var sections: [NotesSection] = []
    
    var imagesObservable: Observable<[SelectedImage]> {
        imagesSubject.asObservable()
    }
    
    // MARK: - Init
    init() {
        if let savedImages = LocalStorageManager.shared.getSelectedImageVisitData() {
            imagesSubject.accept(savedImages)
        }
    }
    
    // MARK: - Build Visit Details Section
    func buildVisitDetailsSection() -> NotesSection {
        let visitItems = LocalStorageManager.shared.getVisitItemData() ?? []
        
        let rows: [NotesRow] = visitItems.isEmpty
        ? [NotesRow(title: "", value: "No Visit Item Selected")]
        : visitItems.enumerated().flatMap { index, item in
            var rows: [NotesRow] = []
            
            
            if let division = item.division?.name {
                rows.append(NotesRow(title: "Division", value: division))
            }
            
            if let brick = item.brick?.name {
                rows.append(NotesRow(title: "Brick", value: brick))
            }
            
            if let accountType = item.accountType?.name {
                rows.append(NotesRow(title: "Account Type", value: accountType))
            }
            
            if let account = item.account?.name {
                rows.append(NotesRow(title: "Account", value: account))
            }
            
            if let doctor = item.doctor?.name {
                rows.append(NotesRow(title: "Doctor", value: doctor))
            }
            
            if let shift = item.shiftType?.name {
                rows.append(NotesRow(title: "Shift Type", value: shift))
            }
            
            if let visitType = item.visitType?.name {
                rows.append(NotesRow(title: "Visit Type", value: visitType))
            }
            
            if let comment = item.comment, !comment.isEmpty {
                rows.append(NotesRow(title: "Comment", value: comment))
            }
            
            return rows
        }
        
        return NotesSection(header: "Visit Details", rows: rows)
    }
    
    
    // MARK: - Build Gifts Section
    func buildGiftsSection() -> NotesSection {
        let gifts = LocalStorageManager.shared.getGiftsData() ?? []
        
        let rows: [NotesRow] = gifts.isEmpty
        ? [NotesRow(title: "", value: "No Gifts Selected")]
        : gifts.enumerated().map {
            NotesRow(title: "Giveaway \($0.offset + 1)", value: $0.element.name ?? "")
        }
        
        return NotesSection(header: "Giveaways Details", rows: rows)
    }
    // MARK: - Build Products Section
    func buildProductsSection() -> NotesSection {
        let products = LocalStorageManager.shared.getProductsData() ?? []
        
        let rows: [NotesRow] = products.isEmpty
        ? [NotesRow(title: "", value: "No Products Selected")]
        : products.enumerated().map {
            NotesRow(title: "Product \($0.offset + 1)", value: $0.element.product?.name ?? "")
        }
        
        return NotesSection(header: "Products Details", rows: rows)
    }
    
    
    // MARK: - Public Save
    func saveUnPlannedVisit(completion: @escaping (Bool, String) -> Void) {
        
        if Reachability.isConnectedToNetwork() {
            saveUnPlannedVisitAPI { [weak self] success, message, onlineID in
                guard let self = self else { return }
                
                LocalStorageManager.shared.setUnPlannedVisitOffline(false)
                self.saveActualVisitData(
                    onlineID: onlineID,
                    isUploaded: success
                )
                
                if success {
                    self.clearCachedVisitData()
                }
                
                completion(success, message)
            }
        } else {
            saveActualVisitData(
                onlineID: nil,
                isUploaded: false
            )
            
            LocalStorageManager.shared.setUnPlannedVisitOffline(true)
            completion(true, "تم حفظ الزيارة محليًا وسيتم رفعها عند الاتصال بالإنترنت")
        }
    }
    
    // MARK: - Save Actual Visit (LOCAL)
    private func saveActualVisitData(
        onlineID: Int?,
        isUploaded: Bool
    ) {
        
        guard let visit = LocalStorageManager.shared.getVisitItemData()?.first else {
            print("❌ No visit item found")
            return
        }
        
        let products = LocalStorageManager.shared.getProductsData() ?? []
        let gifts = LocalStorageManager.shared.getGiftsData() ?? []
        let images = LocalStorageManager.shared.getSelectedImageVisitData() ?? []
        let managers = LocalStorageManager.shared.getManagerData() ?? []
        
        let now = Date()
        let offlineId = Int(Date().timeIntervalSince1970)
        
        LocationManager.shared.getCurrentLocation { [weak self] endLat, endLng in
            guard let self = self else { return }
            
            let model = ActualVisitModel(
                id: UUID().uuidString,
                
                accountID: visit.account?.id ?? 0,
                palnID: visit.planID ?? 0,
                doctorID: visit.doctor?.id ?? 0,
                accountTypeID: visit.accountType?.id ?? 0,
                divisionID: visit.division?.id ?? 0,
                brickID: visit.brick?.id ?? 0,
                lineId: visit.account?.line_id ?? 0,
                comment: visit.comment ?? "",
                visitTypeId: visit.visitType?.id ?? 0,
                shiftTypeId: visit.shiftType?.id ?? 0,
                shiftId: visit.accountType?.shift_id ?? 0,
                
                offline_id: offlineId,
                online_id: onlineID.map(String.init) ?? "",
                
                division_name: visit.division?.name ?? "",
                account_type: visit.accountType?.name ?? "",
                account_name: visit.account?.name ?? "",
                brick_name: visit.brick?.name ?? "",
                doctor_name: visit.doctor?.name ?? "",
                shift_type: visit.shiftType?.name ?? "",
                visit_type: visit.visitType?.name ?? "",
                
                visit_date: now.formattedDate,
                llAcccount: visit.account?.ll ?? "",
                lgAcccount: visit.account?.lg ?? "",
                endLat: "\(endLat)",
                endLong: "\(endLng)",
                isUploaded: isUploaded,
                
                productVisit: self.mapProducts(products),
                giftVisit: self.mapGifts(gifts),
                managerVisit: self.mapManagers(managers),
                imageVisit: self.mapImages(images)
            )
            
            self.persistActualVisit(model)
        }
    }
    
    // MARK: - Mappers
    private func mapProducts(_ items: [ProductItem]) -> [ProductVisitModel] {
        items.map {
            ProductVisitModel(
                productId: $0.product?.id ?? 0,
                name: $0.product?.name ?? "",
                count: $0.count,
                comment: $0.comment ?? "",
                stock: $0.stock ?? "",
                payment: $0.payment ?? "",
                order: $0.order ?? "",
                followup_id: $0.followUp?.id ?? 0,
                market_feedback_id: $0.market?.id ?? 0,
                vFeedback_id: $0.feedback?.id,
                presentations: $0.presentations
            )
        }
    }
    
    private func mapGifts(_ items: [Lines]) -> [GiftVisitModel] {
        items.map {
            GiftVisitModel(
                giftId: $0.id ?? 0,
                name: $0.name ?? "",
                count: Int($0.count ?? "") ?? 0
            )
        }
    }
    
    private func mapManagers(_ items: [Lines]) -> [ManagerVisitModel] {
        items.map {
            ManagerVisitModel(
                empId: $0.id ?? 0,
                name: $0.name ?? ""
            )
        }
    }
    
    private func mapImages(_ items: [SelectedImage]) -> [ImageVisitModel] {
        items.map {
            ImageVisitModel(path: $0.path ?? "")
        }
    }
    
    // MARK: - Persist
    private func persistActualVisit(_ model: ActualVisitModel) {
        var visits = LocalStorageManager.shared.getActualVisitData() ?? []
        
        visits.removeAll { $0.offline_id == model.offline_id }
        visits.append(model)
        
        LocalStorageManager.shared.saveActualVisitData(model: visits)
        print("✅ Actual Visit saved locally")
    }
    
    // MARK: - API Save (REMOTE)
    private func saveUnPlannedVisitAPI(
        completion: @escaping (Bool, String, Int) -> Void
    ) {
        
        guard let user = LocalStorageManager.shared.getLoggedUser(),
              let visit = LocalStorageManager.shared.getVisitItemData()?.first
        else {
            completion(false, "Unauthorized", 0)
            return
        }
        
        let baseURL = LocalStorageManager.shared.getAPIPath() ?? ""
        let url = baseURL + URLs.saveActualsURL
        
        let productsData = LocalStorageManager.shared.getProductsData() ?? []
        let giftsData = LocalStorageManager.shared.getGiftsData() ?? []
        let managerData = LocalStorageManager.shared.getManagerData() ?? []
        let imagesData = LocalStorageManager.shared.getSelectedImageVisitData() ?? []
        let startLocation = LocalStorageManager.shared.getVisitStartLocation()
        
        let products = buildProductsPayload(productsData)
        let giveaways = buildGiftsPayload(giftsData)
        let members = buildMembersPayload(managerData)
        let attachments = buildAttachments(imagesData)
        
        let attachReferenceId = UUID().uuidString
        let now = Date()
        let offlineId = Int(Date().timeIntervalSince1970)
        
        LocationManager.shared.getCurrentLocation { [weak self] endLat, endLng in
            guard let self = self else { return }
            
            let accountLat = Double(visit.account?.ll ?? "") ?? 0
            let accountLng = Double(visit.account?.lg ?? "") ?? 0
            
            let visitDeviation = self.calculateDistance(
                from: accountLat,
                lng1: accountLng,
                to: endLat,
                lng2: endLng
            )
            
            var visitDict: [String: Any] = [:]
            
            // MARK: - IDs
            visitDict["id"] = 0
            visitDict["offline_id"] = offlineId
            visitDict["plan_id"] = visit.planID ?? 0
            visitDict["account_id"] = visit.account?.id ?? 0
            visitDict["account_dr_id"] = visit.doctor?.id ?? 0
            visitDict["account_type_id"] = visit.accountType?.id ?? 0
            visitDict["div_id"] = visit.division?.id ?? 0
            visitDict["brick_id"] = visit.brick?.id ?? 0
            visitDict["line_id"] = visit.account?.line_id ?? 0
            
            // MARK: - Date & Time
            visitDict["visit_date"] = now.formattedDate
            visitDict["visit_time"] = now.formattedTime.to24HourFormat
            visitDict["insertion_date"] = now.formattedDate
            visitDict["insertion_time"] = now.formattedTime.to24HourFormat
            visitDict["visit_duration"] = "00:02:18"
            visitDict["visit_deviation"] = visitDeviation
            
            // MARK: - Notes & Relations
            visitDict["notes_aw_comment"] = visit.comment ?? ""
            visitDict["giveaways"] = giveaways
            visitDict["products"] = products
            visitDict["members"] = members
            visitDict["attachments"] = attachments
            visitDict["attach_reference_id"] = attachReferenceId
            
            // MARK: - Visit Info
            visitDict["no_of_doctors"] = 1
            visitDict["visit_type_id"] = visit.visitType?.id ?? 0
            visitDict["selected_shift"] = visit.shiftType?.id ?? 0
            visitDict["shift"] = visit.accountType?.shift_id ?? 0
            
            // MARK: - Location
            visitDict["ll_start"] = startLocation?.coordinate.latitude ?? endLat
            visitDict["lg_start"] = startLocation?.coordinate.longitude ?? endLng
            visitDict["ll"] = endLat
            visitDict["lg"] = endLng
            visitDict["is_fake_start_location"] = false
            visitDict["is_fake_end_location"] = false
            
            // MARK: - Device
            visitDict["os_type"] = "IOS"
            visitDict["os_version"] = UIDevice.current.systemVersion
            visitDict["device_brand"] = UIDevice.current.model
            visitDict["appVersion"] = AppInfo.shared.appVersion
            visitDict["visited_doctors"] = [""]
            
            let params: [String: Any] = [
                "visits": [visitDict]
            ]
            print("params >>\(params)")
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(user.access_token ?? "")",
                "Content-Type": "application/json",
                "Accept": "application/json",
                "lang": "ar",
                "device-id": AppInfo.shared.deviceID,
                "timezone": "Africa/Cairo"
            ]
            
            self.loadingBehavior.accept(true)
            
            NetworkLayer.shared.fetchData(
                method: .post,
                url: url,
                parameters: params,
                headers: headers
            ) { (result: Result<SavePlanResponse>) in
                self.loadingBehavior.accept(false)
                
                switch result {
                case .success(let model):
                    completion(true, model.message, model.data?.first?.visitID ?? 0)
                    print("model >>\(model)")
                case .failure:
                    completion(false, "Network Error", 0)
                }
            }
        }
    }
    
    private func buildProductsPayload(_ productsData: [ProductItem]) -> [[String: Any]] {
        return productsData.map { item in
            var dict: [String: Any] = [:]
            dict["product_id"] = item.product?.id ?? 0
            dict["samples"] = item.count
            dict["notes"] = item.comment ?? ""
            dict["stock"] = item.stock ?? ""
            dict["payment"] = item.payment ?? ""
            dict["order"] = item.order ?? ""
            dict["followup_id"] = item.followUp?.id ?? 0
            dict["market_feedback_id"] = item.market?.id ?? 0
            dict["vFeedback_id"] = item.feedback?.id ?? 0
            
            if let presentations = item.presentations {
                dict["presentations"] = presentations.map { presentation in
                    return [
                        "no_of_entry_times": "1",//presentation.no_of_entry_times,
                        "presentation_id": presentation.presentation_id ?? 0,
                        "ratings": presentation.ratings?.map { [
                            "rating": $0.rating ?? 0,
                            "slide_id": $0.slide_id ?? 0
                        ]} ?? [],
                        "slides": presentation.slides?.map { [
                            "end_time": $0.end_time ?? "",
                            "rating": $0.rating ?? "",
                            "slide_id": $0.slide_id ?? "",
                            "start_time": $0.start_time ?? ""
                        ]} ?? []
                    ]
                }
            }
            return dict
        }
    }

    private func buildGiftsPayload(_ giftsData: [Lines]) -> [[String: Any]] {
        return giftsData.map {
            [
                "giveaway_id": $0.id ?? 0,
                "units": Int($0.count ?? "") ?? 0
            ]
        }
    }
    private func buildMembersPayload(_ managerData: [Lines]) -> [[String: Any]] {
        return managerData.map {
            [
                "emp_id": $0.id ?? 0
            ]
        }
    }
    private func buildAttachments(_ imagesData: [SelectedImage]) -> [String] {
        let paths = imagesData.compactMap { $0.path }
        return paths.isEmpty ? ["NO_IMAGES_TO_REFERENCE"] : paths
    }
    
    
    // MARK: - Helpers
    private func clearCachedVisitData() {
        LocalStorageManager.shared.clearVisitItemData()
        LocalStorageManager.shared.clearManagerData()
        LocalStorageManager.shared.clearGiftsData()
        LocalStorageManager.shared.clearProductsData()
        LocalStorageManager.shared.clearSelectedImageVisitData()
        LocalStorageManager.shared.clearVisitStartLocation()
    }
    
    private func calculateDistance(
        from lat1: Double,
        lng1: Double,
        to lat2: Double,
        lng2: Double
    ) -> Int {
        let start = CLLocation(latitude: lat1, longitude: lng1)
        let end = CLLocation(latitude: lat2, longitude: lng2)
        return Int(start.distance(from: end))
    }
    
    
    // uploadImages
    func uploadImages(
        images: [SelectedImage],
        progressHandler: ((Int) -> Void)? = nil,
        completion: @escaping (Swift.Result<UploadResponse, Error>) -> Void
    ){
        guard
            let user = LocalStorageManager.shared.getLoggedUser(),
            !images.isEmpty
        else { return }
        
        let baseURL = LocalStorageManager.shared.getAPIPath() ?? ""
        let url = baseURL + URLs.attachmentsURL
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(user.access_token ?? "")",
            "Accept": "application/json"
        ]
        
        AF.upload(
            multipartFormData: { multipart in
                for (index, item) in images.enumerated() {
                    guard let imageData = item.image.jpegData(compressionQuality: 0.8) else { continue }
                    multipart.append(
                        imageData,
                        withName: "attachments[\(index)]",
                        fileName: "image_\(index).jpg",
                        mimeType: "image/jpeg"
                    )
                }
                
                for index in images.indices {
                    multipart.append(
                        Data("\(index + 1)".utf8),
                        withName: "ids[\(index)]"
                    )
                }
                
                multipart.append(
                    Data("GemstoneMobileApplication".utf8),
                    withName: "folder"
                )
                
                multipart.append(
                    Data("\(images.count)".utf8),
                    withName: "count_files"
                )
            },
            to: url,
            headers: headers
        )
        .uploadProgress { progress in
            let valueInt = Int(progress.fractionCompleted * 100)
            print("📤 Upload Progress:", valueInt, "%")
            progressHandler?(valueInt)
        }
        .responseData { response in
            if let error = response.error {
                completion(.failure(error))
                return
            }
            guard let data = response.data else {
                completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                return
            }
            do {
                let decoded = try JSONDecoder().decode(UploadResponse.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

