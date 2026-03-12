//
//  UnPlannedVisitNotesViewModel.swift
//  Gemstone Pro
//
//  Created by Ahmed on 18/12/2025.
//
import Foundation
import RxSwift
import RxCocoa
import UIKit
import Alamofire
import CoreLocation
enum LocationZone {
    case white
    case green
    case red
}
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
    
    func validateActualVisit() -> String? {
        
        guard let visit = LocalStorageManager.shared.getVisitItemData()?.first else {
            return nil
        }
        
        let today = Date().formattedDate
        
        let visits = LocalStorageManager.shared.getActualVisitData() ?? []
        
       // Same doctor + same day
        let isDuplicate = visits.contains {
            $0.doctorID == visit.doctor?.id &&
            $0.visit_date == today
        }
        
        if isDuplicate {
            return "You can't visit the same doctor more than once in the same day."
        }
        
        return nil
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
            completion(true, "The data has been saved locally. It will be uploaded once an internet connection is available.")
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
        
        let ampm = visit.accountType?.cat_id == "1" ? "1" :
                   visit.accountType?.cat_id == "2" ? "2" : "3"
        
        let now = Date()
        let offlineId = String(Date().timeIntervalSince1970)

        LocationManager.shared.getCurrentLocation { [weak self] endLat, endLng in
            guard let self = self else { return }

            let model = ActualVisitModel(
                id: UUID().uuidString,
                accountID: visit.account?.id ?? "",
                palnID: visit.planID ?? "",
                doctorID: visit.doctor?.id ?? "",
                accountTypeID: visit.accountType?.id ?? "",
                divisionID: visit.division?.id ?? "",
                brickID: visit.brick?.id ?? "",
                lineId: visit.account?.line_id ?? "",
                comment: visit.comment ?? "",
                visitTypeId: visit.visitType?.id ?? "",
                ampm: ampm,
                shiftTypeId: visit.shiftType?.id ?? "",
                shiftId: visit.accountType?.shift_id ?? "",
                
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
            print("offline_id >> \(model.offline_id ?? "")")
            print("model >> \(model)")
            self.persistActualVisit(model)
        }
    }
    // MARK: - Mappers
    private func mapProducts(_ items: [ProductItem]) -> [ProductVisitModel] {
        items.map {
            ProductVisitModel(
                productId: $0.product?.id ?? "",
                name: $0.product?.name ?? "",
                count: $0.count,
                comment: $0.comment ?? "",
                feedback_id: $0.feedback?.id ?? "",
                follow_ups: $0.followUp ?? "",
                market_feedback: $0.market,
                presentations: $0.presentations
            )
        }
    }
    
    private func mapGifts(_ items: [IdNameModel]) -> [GiftVisitModel] {
        items.map {
            GiftVisitModel(
                giftId: $0.id ?? "",
                name: $0.name ?? "",
                count: Int($0.count ?? "") ?? 0
            )
        }
    }
    
    private func mapManagers(_ items: [IdNameModel]) -> [ManagerVisitModel] {
        items.map {
            ManagerVisitModel(
                empId: $0.id ?? "",
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
        
        LocalStorageManager.shared.saveActualVisitData(visits)
        print("✅ Actual Visit saved locally")
    }
    
    // MARK: - API Save (REMOTE) - BODY DATA VERSION
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
        let url = baseURL + URLs.saveOw
        
        let productsData = LocalStorageManager.shared.getProductsData() ?? []
        let giftsData = LocalStorageManager.shared.getGiftsData() ?? []
        let managerData = LocalStorageManager.shared.getManagerData() ?? []
        let startLocation = LocalStorageManager.shared.getVisitStartLocation()
        
        let products = buildProductsPayloadNEW(productsData)
        let giveaways = buildGiftsPayloadNEW(giftsData)
        let members = buildMembersPayloadNEW(managerData)
        
        let now = Date()

        let ampm = visit.accountType?.cat_id == "1" ? "1" :
                   visit.accountType?.cat_id == "2" ? "2" : "3"
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
            
            let visitDict: [String: Any] = [
               
                "ampm": ampm,
                "comments": visit.comment ?? "",
                "date_added": now.formattedDate,
                "appVersion": AppInfo.shared.appVersion,
                "osVersion": UIDevice.current.systemVersion,
                "deviceBrand": UIDevice.current.model,
                "osType": "iOS",
                "div_id": visit.division?.id ?? 0,
                "giveaway_info": giveaways,
                "id": 0,
                "insertion_date": now.formattedDate,
                "insertion_time": now.formattedTime.to24HourFormat,
                "is_fake_end_location": false,
                "is_fake_start_location": false,
                "is_sync": 0,
                "item_doc_id": visit.doctor?.id ?? 0,
                "item_id": visit.account?.id ?? 0,
                "member_info": members,
                "members": visit.visitType?.id ?? 0,
                "no_of_doctors": 1,
                "offline_id": "11",
                "product_info": products,
                "selected_shift": visit.shiftType?.id ?? 0,
                "sync_date": now.formattedDate,
                "sync_time": now.formattedTime.to24HourFormat,
                "team_id": user.lineIds ?? "",
                
                // accountType
                "type_id": visit.accountType?.id ?? 0,
                
                "user_id": user.user_id ?? 0,
                "vdate": now.formattedDate,
                "visit_address": "",
                "visit_deviation": visitDeviation,
                "visit_duration": "00:02:00",
                "vplanned_id": visit.planID ?? "0",
                "vtime": now.formattedTime.to24HourFormat,
                "ll_start": startLocation?.coordinate.latitude ?? endLat,
                "lg_start": startLocation?.coordinate.longitude ?? endLng,
                "ll": endLat,
                "lg": endLng
            ]
            print("MEMBER INFO PAYLOAD >>>", members)
            let visitArray = [visitDict]
            
            print("NEW BODY >>> \(visitArray)")
            
            do {
                let bodyData = try JSONSerialization.data(withJSONObject: visitArray, options: [])
                
                self.loadingBehavior.accept(true)
                
                NetworkLayer.shared.fetchData(
                    method: .post,
                    url: url,
                    parameters: [:],
                    body: bodyData,
                    headers: [
                        "Content-Type": "application/json",
                        "Accept": "application/json",
                        "lang": "ar",
                        "device-id": AppInfo.shared.deviceID,
                        "timezone": "Africa/Cairo"
                    ]
                ) { (result: Result<UnPlannedVisitAResponse>) in
                    self.loadingBehavior.accept(false)
                    switch result {
                    case .success(let model):
                        completion(true, model.Status_Message ?? "",Int(model.Data?.first?.visit_id ?? "") ?? 0)
                        print("model >>> \(model)")
                    case .failure(let error):
                        completion(false, error.localizedDescription, 0)
                    }
                }
            } catch {
                completion(false, "JSON Encoding Error", 0)
            }
        }
    }
    private func buildProductsPayloadNEW(_ productsData: [ProductItem]) -> [[String: Any]] {
        
        return productsData.map { item in
            
            var dict: [String: Any] = [:]
            
            // MARK: - Basic
            dict["product_id"] = item.product?.id ?? 0
            dict["samples"] = Int(item.count) ?? 0
            dict["notes"] = item.comment ?? ""
            
            // MARK: - Order & Stock
            dict["current_stock"] =  0
            dict["current_order"] =  0
            dict["quotation_payment_method"] = 0
            
            // MARK: - Feedback
            dict["followup"] = item.followUp ?? ""
            dict["mfeedback"] = item.market ?? ""
            dict["feedback_id"] = Int(item.feedback?.id ?? "") ?? 0
            
            // MARK: - Demo
            dict["is_demo"] = 0
            dict["demo_date"] = Date().formattedDate
            
            // MARK: - Extra Fields (Required by Backend)
            dict["average"] = 0
            dict["last_order_quantity"] = 0
            dict["quotation"] = ""
            dict["followup_comments"] = ""
            dict["followup_date"] = ""
            dict["followup_result"] = ""
            
            // MARK: - Presentations
            if let presentations = item.presentations, !presentations.isEmpty {
                
                dict["presentations"] = presentations.map { presentation in
                    
                    var presentationDict: [String: Any] = [:]
                    
                    presentationDict["no_of_entry_times"] = Int(1)
                    presentationDict["presentation_id"] = Int(presentation.presentation_id ?? "") ?? 0
                    
                    // MARK: - Ratings
                    if let ratings = presentation.ratings, !ratings.isEmpty {
                        presentationDict["ratings"] = ratings.map { rating in
                            return [
                                "rating": Int(rating.rating ?? "") ?? 0,
                                "slide_id": Int(rating.slide_id ?? "") ?? 0
                            ]
                        }
                    } else {
                        presentationDict["ratings"] = []
                    }
                    
                    // MARK: - Slides
                    if let slides = presentation.slides, !slides.isEmpty {
                        presentationDict["slides"] = slides.map { slide in
                            return [
                                "slide_id": Int(slide.id ?? "") ?? 0,
                                "start_time": slide.start_time ?? "",
                                "end_time": slide.end_time ?? "",
                                "rating": slide.rating ?? 0
                            ]
                        }
                    } else {
                        presentationDict["slides"] = []
                    }
                    
                    return presentationDict
                }
                
            } else {
                dict["presentations"] = []
            }
            return dict
        }
    }
    private func buildGiftsPayloadNEW(_ giftsData: [IdNameModel]) -> [[String: Any]] {
        
        return giftsData.map { gift in
            [
                "gift_id": gift.id ?? 0,
                "noofunits": Int(gift.count ?? "") ?? 0
            ]
        }
    }
    private func buildMembersPayloadNEW(_ managerData: [IdNameModel]) -> [[String: Any]] {
        
        return managerData.map { manager in
            [
                "emp_id": manager.id ?? 0
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
    
     func calculateDistance(
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
    
    func getZone(distance: Int, acceptedDistance: Int) -> LocationZone {

        if distance <= 15 {
            return .white
        }

        if distance <= acceptedDistance {
            return .green
        }

        return .red
    }
    
}

