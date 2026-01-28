//
//  OfflineRequestManagerVC.swift
//  Puplo Pro
//
//  Created by Ahmed on 27/11/2025.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import CoreLocation

class OfflineRequestManager {
    
    // MARK: - Properties
    let loadingBehavior = BehaviorRelay<Bool>(value: false)
    let alertBehavior = PublishSubject<String>()
    
    // MARK: - API Call: SavePlans
    func savePlans(completion: @escaping (Bool, String,[(offlineID: Int, onlineID: Int)]) -> Void) {
        guard let user = LocalStorageManager.shared.getLoggedUser() else {
            completion(false, "Unauthorized", [])
            return
        }
        
        let baseURL = LocalStorageManager.shared.getAPIPath() ?? ""
        let url = baseURL + URLs.planURL
        
        let plans = LocalStorageManager.shared.getNewPlanData() ?? []
        var plansArray: [[String: Any]] = []
        
        for planModel in plans {
            let planDict: [String: Any] = [
                "account_dr_id": planModel.accountDoctorID ?? 0,
                "account_id": planModel.accountID ?? 0,
                "account_type_id": planModel.accountTypeID ?? 0,
                "div_id": planModel.divID ?? 0,
                "insertion_date":  planModel.insertionDate ?? "",
                "line_id": planModel.lineID ?? 0,
                "offline_id": planModel.offlineID ?? 0,
                "visit_date": planModel.visitDate ?? "",
                "visit_time": planModel.visitTime ?? ""
            ]
            plansArray.append(planDict)
        }
        
        let params: [String: Any] = ["plans": plansArray]
        print("params >> \(params)")
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(user.access_token ?? "")",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "lang": "ar",
            "device-id": AppInfo.shared.deviceID,
            "timezone": "Africa/Cairo"
        ]
        
        loadingBehavior.accept(true)
        NetworkLayer.shared.fetchData(
            method: .post,
            url: url,
            parameters: params,
            headers: headers
        ) { [weak self] (result: Result<SavePlanResponse>) in
            guard let self = self else { return }
            self.loadingBehavior.accept(false)
            switch result {
            case .success(let model):
                let idsMap: [(offlineID: Int, onlineID: Int)] =
                    model.data?.compactMap {
                        guard
                            let offlineID = $0.offlineID,
                            let onlineID = $0.visitID
                        else { return nil }
                        return (offlineID, onlineID)
                    } ?? []
                print("model >>\(model)")
                completion(true, model.message, idsMap)
            case .failure:
                completion(false, "Network Error",[])
            }
        }
    }
    
    // MARK: - fetch Data Applay
    func fetchDataApplay(OWS: [OWSModel], completion: @escaping (Bool, String) -> Void) {
        guard let user = LocalStorageManager.shared.getLoggedUser() else {
            completion(false, "Unauthorized")
            return
        }
        
        let baseURL = LocalStorageManager.shared.getAPIPath() ?? ""
        let url = baseURL + URLs.saveOwURL
        
        let owsArray: [[String: Any]] = OWS.map { ows in
            return [
                "id": ows.id,
                "offline_id": ows.offline_id,
                "ow_plan_id": ows.ow_plan_id,
                "ow_type_id": ows.ow_type_id,
                "shift_id": ows.shift_id,
                "date": ows.date,
                "time": ows.time,
                "notes": ows.notes
            ]
        }
        
        let params: [String: Any] = [
            "os_type": "IOS",
            "ows": owsArray
        ]
        
        print("params >> \(params)")
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(user.access_token ?? "")",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "lang": "ar",
            "device-id": AppInfo.shared.deviceID,
            "timezone": "Africa/Cairo"
        ]
        
        loadingBehavior.accept(true)
        
        NetworkLayer.shared.fetchData(
            method: .post,
            url: url,
            parameters: params,
            headers: headers
        ) { [weak self] (result: Result<OWActivitiesResponse>) in
            guard let self = self else { return }
            self.loadingBehavior.accept(false)
            switch result {
            case .success(let model):
                let hasData = (model.Data?.isEmpty == false)
                completion(hasData, model.message ?? "")
            case .failure:
                completion(false, "Network Error")
            }
        }
    }
    
    // MARK: - API Call: Save UnPlanned Visit (Multiple Visits + visitItems)
    func saveUnPlannedVisitAPI(
        completion: @escaping (Bool, String, [(offlineID: Int, onlineID: Int)]) -> Void
        
    ) {
        guard let user = LocalStorageManager.shared.getLoggedUser() else {
                    completion(false, "Unauthorized", [])
                    return
            }
        let baseURL = LocalStorageManager.shared.getAPIPath() ?? ""
        let url = baseURL + URLs.saveActualsURL
        
        let storedVisits = (LocalStorageManager.shared.getActualVisitData() ?? [])
            .filter { !$0.isUploaded }

        guard storedVisits.isEmpty == false else {
            print("🚫 No visits with isUploaded == false, request will not be sent")
            completion(false, "No visits to upload", [])
            return
        }

        let startLocation = LocalStorageManager.shared.getVisitStartLocation()
        var visitsArray: [[String: Any]] = []
        
        for visitModel in storedVisits {
            
            // MARK: - Products
            let products: [[String: Any]] = visitModel.productVisit?.map { product in
                // Build presentations array if available
                let presentationsArray: [[String: Any]] = (product.presentations ?? []).map { presentation in
                    let ratingsArray: [[String: Any]] = (presentation.ratings ?? []).map { rating in
                        return [
                            "rating": rating.rating ?? 0,
                            "slide_id": rating.slide_id ?? 0
                        ]
                    }
                    let slidesArray: [[String: Any]] = (presentation.slides ?? []).map { slide in
                        return [
                            "end_time": slide.end_time ?? "",
                            "rating": slide.rating ?? "",
                            "slide_id": slide.slide_id ?? "",
                            "start_time": slide.start_time ?? ""
                        ]
                    }
                    return [
                        "no_of_entry_times": "1", // presentation.no_of_entry_times (hardcoded as per original)
                        "presentation_id": presentation.presentation_id ?? 0,
                        "ratings": ratingsArray,
                        "slides": slidesArray
                    ]
                }
                var dict: [String: Any] = [
                    "product_id": product.productId,
                    "samples": product.count,
                    "notes": product.comment,
                    "stock": product.stock,
                    "payment": product.payment,
                    "order": product.order,
                    "followup_id": product.followup_id ?? 0,
                    "market_feedback_id": product.market_feedback_id ?? 0,
                    "vFeedback_id": product.vFeedback_id ?? 0
                ]
                // Always include presentations key with an array (empty if none)
                dict["presentations"] = presentationsArray
                return dict
            } ?? []
            
            
            // MARK: - Giveaways
            let giveaways: [[String: Any]] = visitModel.giftVisit?.map {
                [
                    "giveaway_id": $0.giftId ?? 0,
                    "units": $0.count ?? 1
                ]
            } ?? []
            
            // MARK: - members
            let members: [[String: Any]] = visitModel.managerVisit?.map {
                [
                    "emp_id": $0.empId,
                ]
            } ?? []
            
            
            // MARK: - Attachments
            var attachments = visitModel.imageVisit?.map { $0.path } ?? []
            if visitModel.imageVisit?.count ?? 0 < 1 {
                attachments = ["NO_IMAGES_TO_REFERENCE"]
            }
            let attachReferenceId = attachments.isEmpty ? "NO_IMAGES_TO_REFERENCE" : ""
            
            // MARK: - Distance
            let visitDeviation = calculateDistance(
                from: Double(visitModel.llAcccount) ?? 0,
                lng1: Double(visitModel.lgAcccount) ?? 0,
                to: Double(visitModel.endLat ?? "") ?? 0,
                lng2: Double(visitModel.endLong ?? "") ?? 0
            )
            
            let now = Date()
            
            // MARK: - Visit Object
            let visit: [String: Any] = [
                "id": 0,
                "offline_id": visitModel.offline_id ?? 0, // ✅ مهم
                "plan_id": visitModel.palnID ?? 0,
                "account_id": visitModel.accountID ?? 0,
                "account_dr_id": visitModel.doctorID ?? 0,
                "account_type_id": visitModel.accountTypeID ?? 0,
                "div_id": visitModel.divisionID ?? 0,
                "brick_id": visitModel.brickID ?? 0,
                "line_id": visitModel.lineId ?? 0,
                "visit_date": visitModel.visit_date ?? "",
                "visit_time": now.formattedTime.to24HourFormat,
                "insertion_date": visitModel.visit_date ?? "",
                "insertion_time": now.formattedTime.to24HourFormat,
                "visit_duration":"00:02:18",
                "visit_deviation": visitDeviation,
                "notes_aw_comment": visitModel.comment ?? "",
                "giveaways": giveaways,
                "products": products,
                "attachments": attachments,
                "attach_reference_id": attachReferenceId,
                "no_of_doctors": 1,
                "visit_type_id": visitModel.visitTypeId ?? 1,
                "selected_shift": visitModel.shiftTypeId ?? 1,
                "shift": visitModel.shiftId ?? 0,
                "ll_start": startLocation?.coordinate.latitude ?? 0,
                "lg_start": startLocation?.coordinate.longitude ?? 0,
                "ll": Double(visitModel.endLat ?? "") ?? 0,
                "lg": Double(visitModel.endLong ?? "") ?? 0,
                "is_fake_start_location": false,
                "is_fake_end_location": false,
                "os_type": "IOS",
                "os_version": UIDevice.current.systemVersion,
                "device_brand": UIDevice.current.model,
                "appVersion": AppInfo.shared.appVersion,
                "members": members,
                "visited_doctors": [""]
            ]
            
            visitsArray.append(visit)
        }
        
        let params: [String: Any] = ["visits": visitsArray]
        print("📦 Upload Visits Params:", params)
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(user.access_token ?? "")",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "lang": "ar",
            "device-id": AppInfo.shared.deviceID,
            "timezone": "Africa/Cairo"
        ]
        
        loadingBehavior.accept(true)
        
        NetworkLayer.shared.fetchData(
            method: .post,
            url: url,
            parameters: params,
            headers: headers
        ) { [weak self] (result: Result<SavePlanResponse>) in
            self?.loadingBehavior.accept(false)
            switch result {
            case .success(let model):
                let idsMap: [(offlineID: Int, onlineID: Int)] =
                    model.data?.compactMap {
                        guard
                            let offlineID = $0.offlineID,
                            let onlineID = $0.visitID
                        else { return nil }
                        return (offlineID, onlineID)
                    } ?? []

                completion(true, model.message, idsMap)
                print("model >\(model)")
                
            case .failure:
                completion(false, "Network Error", [])
            }
        }
    }
    
//    func saveUnPlannedVisitAPI(
//        completion: @escaping (Bool, String, [(offlineID: Int, onlineID: Int)]) -> Void
//    ) {
//        guard let user = LocalStorageManager.shared.getLoggedUser() else {
//            completion(false, "Unauthorized", [])
//            return
//        }
//
//        let baseURL = LocalStorageManager.shared.getAPIPath() ?? ""
//        let url = baseURL + URLs.saveActualsURL
//
//        let storedVisits = (LocalStorageManager.shared.getActualVisitData() ?? [])
//            .filter { !$0.isUploaded }
//
//        guard !storedVisits.isEmpty else {
//            print("🚫 No visits with isUploaded == false")
//            completion(false, "No visits to upload", [])
//            return
//        }
//
//        let startLocation = LocalStorageManager.shared.getVisitStartLocation()
//        var visitsArray: [[String: Any]] = []
//
//        for visitModel in storedVisits {
//
//            // MARK: - Products
//            let products: [[String: Any]] = visitModel.productVisit?.map {
//                [
//                    "product_id": $0.productId,
//                    "samples": $0.count,
//                    "notes": $0.comment,
//                    "stock": $0.stock,
//                    "payment": $0.payment,
//                    "order": $0.order,
//                    "followup_id": $0.followup_id ?? 0,
//                    "market_feedback_id": $0.market_feedback_id ?? 0,
//                    "vFeedback_id": $0.vFeedback_id ?? 0,
//                    "presentations": []
//                ]
//            } ?? []
//
//            // MARK: - Giveaways
//            let giveaways: [[String: Any]] = visitModel.giftVisit?.map {
//                [
//                    "giveaway_id": $0.giftId ?? 0,
//                    "units": $0.count ?? 1
//                ]
//            } ?? []
//
//            // MARK: - Members
//            let members: [[String: Any]] = visitModel.managerVisit?.map {
//                [
//                    "emp_id": $0.empId
//                ]
//            } ?? []
//
//            // MARK: - Attachments
//            let attachments = visitModel.imageVisit?.map { $0.path } ?? []
//            let attachReferenceId = attachments.isEmpty ? "NO_IMAGES_TO_REFERENCE" : ""
//
//            // MARK: - Distance
//            let visitDeviation = calculateDistance(
//                from: Double(visitModel.llAcccount) ?? 0,
//                lng1: Double(visitModel.lgAcccount) ?? 0,
//                to: Double(visitModel.endLat) ?? 0,
//                lng2: Double(visitModel.endLong) ?? 0
//            )
//
//            let now = Date()
//
//            let visit: [String: Any] = [
//                "id": 0,
//                "offline_id": visitModel.offline_id ?? 0,
//                "plan_id": 0,
//                "account_id": visitModel.accountID ?? 0,
//                "account_dr_id": visitModel.doctorID ?? 0,
//                "account_type_id": visitModel.accountTypeID ?? 0,
//                "div_id": visitModel.divisionID ?? 0,
//                "brick_id": visitModel.brickID ?? 0,
//                "line_id": visitModel.lineId ?? 0,
//                "visit_date": visitModel.visit_date,
//                "visit_time": now.formattedTime.to24HourFormat,
//                "insertion_date": visitModel.visit_date,
//                "insertion_time": now.formattedTime.to24HourFormat,
//                "visit_duration": "00:02:18",
//                "visit_deviation": visitDeviation,
//                "notes_aw_comment": visitModel.comment ?? "",
//                "giveaways": giveaways,
//                "products": products,
//                "attachments": attachments,
//                "attach_reference_id": attachReferenceId,
//                "no_of_doctors": 1,
//                "visit_type_id": visitModel.visitTypeId ?? 1,
//                "selected_shift": visitModel.shiftTypeId ?? 1,
//                "shift": visitModel.shiftId ?? 0,
//                "ll_start": startLocation?.coordinate.latitude ?? 0,
//                "lg_start": startLocation?.coordinate.longitude ?? 0,
//                "ll": Double(visitModel.endLat) ?? 0,
//                "lg": Double(visitModel.endLong) ?? 0,
//                "is_fake_start_location": false,
//                "is_fake_end_location": false,
//                "os_type": "IOS",
//                "os_version": UIDevice.current.systemVersion,
//                "device_brand": UIDevice.current.model,
//                "appVersion": AppInfo.shared.appVersion,
//                "members": members,
//                "visited_doctors": [""]
//            ]
//
//            visitsArray.append(visit)
//        }
//
//        let params: [String: Any] = ["visits": visitsArray]
//
//        let headers: HTTPHeaders = [
//            "Authorization": "Bearer \(user.access_token ?? "")",
//            "Content-Type": "application/json",
//            "Accept": "application/json",
//            "lang": "ar",
//            "device-id": AppInfo.shared.deviceID,
//            "timezone": "Africa/Cairo"
//        ]
//
//        loadingBehavior.accept(true)
//
//        NetworkLayer.shared.fetchData(
//            method: .post,
//            url: url,
//            parameters: params,
//            headers: headers
//        ) { [weak self] (result: Result<SavePlanResponse>) in
//
//            self?.loadingBehavior.accept(false)
//
//            switch result {
//            case .success(let model):
//
//                let idsMap: [(offlineID: Int, onlineID: Int)] =
//                    model.data?.compactMap {
//                        guard
//                            let offlineID = $0.offlineID,
//                            let onlineID = $0.visitID
//                        else { return nil }
//                        return (offlineID, onlineID)
//                    } ?? []
//
//                completion(true, model.message, idsMap)
//
//            case .failure:
//                completion(false, "Network Error", [])
//            }
//        }
//    }

    
    private func calculateDistance(
        from lat1: Double,
        lng1: Double,
        to lat2: Double,
        lng2: Double
    ) -> Int {
        let startLocation = CLLocation(latitude: lat1, longitude: lng1)
        let endLocation = CLLocation(latitude: lat2, longitude: lng2)
        let distanceInMeters = startLocation.distance(from: endLocation)
        return Int(distanceInMeters)
    }
}
