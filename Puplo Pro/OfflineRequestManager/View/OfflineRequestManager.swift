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
    
    
    // MARK: - fetch Data Applay
    func fetchDataApplay(OWS: [OWSModel],completion: @escaping (Bool,String) -> Void) {
        
        let user = LocalStorageManager.shared.getLoggedUser()
        let baseURL = LocalStorageManager.shared.getAPIPath() ?? ""
        let url = baseURL + URLs.saveOwURL
        
        let visitArray: [[String: Any]] = OWS.map { model in
            return [
                "ampm": model.shift_id ?? "1",
                "comments": model.notes,
                "date_added": model.date,
                "appVersion": AppInfo.shared.appVersion,
                "osVersion": AppInfo.shared.osVersion,
                "deviceBrand": AppInfo.shared.deviceModel,
                "osType": "iOS",
                "div_id": -1,
                "giveaway_info": [],
                "id": 0,
                "insertion_date": "",
                "insertion_time": "",
                "is_fake_end_location": false,
                "is_fake_start_location": false,
                "is_sync": 0,
                "item_doc_id": 0,
                "item_id": 0,
                "member_info": [],
                "members": "0",
                "no_of_doctors": 0,
                "offline_id": "11",
                "product_info": [],
                "selected_shift": model.shift_id ?? "1",
                "sync_date": "",
                "sync_time": "",
                "team_id": 0,
                "type_id": model.ow_type_id,
                "user_id": user?.user_id ?? "",
                "vdate": model.date,
                "visit_address": "",
                "visit_deviation": 0,
                "visit_duration": "00:00:08",
                "vplanned_id": 0,
                "vtime": model.time,
            ]
        }
        print("visitArray >>>\(visitArray)")
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: visitArray, options: [])
            print("bodyData >>>\(bodyData)")
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
            ) { [weak self] (result: Result<OWActivitiesResponse>) in
                self?.loadingBehavior.accept(false)
                switch result {
                case .success(let model):
                    completion(true, model.Status_Message ?? "")
                    print("model >>>\(model)")
                case .failure(let error):
                    completion(false, error.localizedDescription)
                }
            }
        } catch {
            completion(false, "JSON Encoding Error")
        }
    }
    
    // MARK: - save Plans
    func savePlans(completion: @escaping (Bool, String,[(offlineID: Int, onlineID: Int)]) -> Void) {
        guard
            let user = LocalStorageManager.shared.getLoggedUser(),
            let baseURL = LocalStorageManager.shared.getAPIPath()
        else {
            completion(false, "Unauthorized", [])
            return
        }
        let plans = LocalStorageManager.shared.getNewPlanData() ?? []
        let url = baseURL + URLs.planURL
        let paramsArray = buildParams(from: plans, user_id: user.user_id ?? "")
        let headers = buildHeaders()
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: paramsArray, options: [])
            loadingBehavior.accept(true)
            NetworkLayer.shared.fetchData(
                method: .post,
                url: url,
                parameters: [:],
                body: jsonData,
                headers: headers
            ) { [weak self] (result: Result<SavePlanResponse>) in
                self?.loadingBehavior.accept(false)
                switch result {
                case .success(let model):
                    let idsMap: [(offlineID: Int, onlineID: Int)] =
                    model.Data?.compactMap {
                        guard
                            let offlineID = $0.offline_id,
                            let onlineID = $0.planned_id
                        else { return nil }
                        
                        return (offlineID, onlineID)
                    } ?? []
                    print("model >>\(model)")
                    completion(true, model.Status_Message ?? "", idsMap)
                case .failure:
                    completion(false, "Something went wrong", [])
                }
            }
        } catch {
            completion(false, "Invalid JSON body", [])
        }
    }
    // MARK: - Helpers
    private func buildParams(from plans: [SaveNewPlanModel],user_id: String) -> [[String: Any]] {
        
        return plans.map {
            [
                "div_id": $0.divID ?? 0,
                "id": 0,
                "insertion_date": $0.insertionDate ?? "",
                "item_doc_id": $0.accountDoctorID ?? 0,
                "item_id": $0.accountID ?? 0,
                "offline_id": $0.offlineID ?? 0,
                "team_id": 1,
                "type_id": $0.accountTypeID ?? 0,
                "user_id": user_id,
                "vdate": $0.visitDate ?? "",
                "vtime": $0.visitTime ?? ""
            ]
        }
    }
    private func buildHeaders() -> HTTPHeaders {
        [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "lang": "ar",
            "device-id": AppInfo.shared.deviceID,
            "timezone": "Africa/Cairo"
        ]
    }
    
    // MARK: - API Call: Save UnPlanned Visit (Multiple Visits)
    func saveUnPlannedVisitAPI(
        completion: @escaping (Bool, String, [(offlineID: String, onlineID: String)]) -> Void
        
    ) {
        guard let user = LocalStorageManager.shared.getLoggedUser() else {
            completion(false, "Unauthorized", [])
            return
        }

        let baseURL = LocalStorageManager.shared.getAPIPath() ?? ""
        let url = baseURL + URLs.saveOw

        // Fetch all stored visits that are not uploaded
        let storedVisits = (LocalStorageManager.shared.getActualVisitData() ?? [])
            .filter { !$0.isUploaded }

        guard !storedVisits.isEmpty else {
            completion(false, "No visits to upload", [])
            return
        }

        let startLocation = LocalStorageManager.shared.getVisitStartLocation()
        let now = Date()

        // Aggregation state
        var visitsArray: [[String: Any]] = []
        let total = storedVisits.count
        var completed = 0

        // Synchronization
        let syncQueue = DispatchQueue(label: "com.puplo.offline.aggregate", attributes: .concurrent)
        let appendQueue = DispatchQueue(label: "com.puplo.offline.append")

        func markCompletedAndMaybeSend() {
            var shouldSend = false
            var currentCount = 0
            syncQueue.async(flags: .barrier) {
                completed += 1
                currentCount = completed
                shouldSend = (completed >= total)
                if shouldSend {
                    print("All visits aggregated (\(currentCount)/\(total)). Proceed to send.")
                } else {
                    print("Aggregated visit (\(currentCount)/\(total)).")
                }
                if shouldSend {
                    DispatchQueue.main.async { [visitsArray] in
                        self.proceedToSendUnplanned(visitsArray: visitsArray, url: url, completion: completion)
                    }
                }
            }
        }

        // Overall timeout: send whatever aggregated by then
        let overallTimeoutSeconds: Double = 8
        DispatchQueue.main.asyncAfter(deadline: .now() + overallTimeoutSeconds) { [weak self] in
            guard let self else { return }
            var countSnapshot = 0
            syncQueue.sync {
                countSnapshot = completed
            }
            if countSnapshot < total {
                print("Overall timeout fired. Sending partial aggregated visits (\(countSnapshot)/\(total)).")
                self.proceedToSendUnplanned(visitsArray: visitsArray, url: url, completion: completion)
            }
        }

        // Per-visit processing with per-visit timeout fallback for location
        for visit in storedVisits {
            // Prepare payloads
            let products = buildProductsPayloadNEW(visit.productVisit ?? [])
            let giveaways = buildGiftsPayloadNEW(visit.giftVisit ?? [])
            let members = buildMembersPayloadNEW(visit.managerVisit ?? [])

            // A helper to build and append visit dict with given end coordinates
            func buildAndAppend(endLat: Double, endLng: Double) {
                let accountLat = Double(visit.llAcccount) ?? 0
                let accountLng = Double(visit.lgAcccount) ?? 0

                let resolvedStartLat = startLocation?.coordinate.latitude ?? endLat
                let resolvedStartLng = startLocation?.coordinate.longitude ?? endLng

                let visitDeviation = self.calculateDistance(
                    from: accountLat,
                    lng1: accountLng,
                    to: endLat,
                    lng2: endLng
                )

                // Normalize types
                let selectedShift: Int = Int(visit.shiftTypeId ?? "1") ?? 1
                let vPlannedID: Int = Int(visit.palnID ?? "0") ?? 0
                let teamID: Int = Int((user.lineIds ?? "").components(separatedBy: ",").first ?? "0") ?? 0
                let userIDString: String = (user.user_id ?? "")

                let visitDict: [String: Any] = [
                    "ampm": selectedShift,
                    "comments": visit.comment ?? "",
                    "date_added": now.formattedDate,
                    "appVersion": AppInfo.shared.appVersion,
                    "osVersion": UIDevice.current.systemVersion,
                    "deviceBrand": UIDevice.current.model,
                    "osType": "iOS",
                    "div_id": visit.divisionID ?? 0,
                    "giveaway_info": giveaways,
                    "id": 0,
                    "insertion_date": now.formattedDate,
                    "insertion_time": now.formattedTime.to24HourFormat,
                    "is_fake_end_location": false,
                    "is_fake_start_location": false,
                    "is_sync": 0,
                    "item_doc_id": visit.doctorID ?? 0,
                    "item_id": visit.accountID ?? 0,
                    "member_info": members,
                    "members": "\(members.count)",
                    "no_of_doctors": 1,
                    "offline_id": visit.offline_id ?? "",
                    "product_info": products,
                    "selected_shift": selectedShift,
                    "sync_date": now.formattedDate,
                    "sync_time": now.formattedTime.to24HourFormat,
                    "team_id": teamID,
                    "type_id": visit.visitTypeId ?? 0,
                    "user_id": userIDString,
                    "vdate": now.formattedDate,
                    "visit_address": "",
                    "visit_deviation": visitDeviation,
                    "visit_duration": "00:02:00",
                    "vplanned_id": vPlannedID,
                    "vtime": now.formattedTime.to24HourFormat,
                    "ll_start": resolvedStartLat,
                    "lg_start": resolvedStartLng,
                    "ll": endLat,
                    "lg": endLng
                ]

                print("visitDict >>> \(visitDict)")
                appendQueue.async {
                    visitsArray.append(visitDict)
                    markCompletedAndMaybeSend()
                }
            }

            // Start location fetch with per-visit timeout
            var didFinishThisVisit = false
            let perVisitTimeout: Double = 2.0
            let timeoutWorkItem = DispatchWorkItem { [weak self] in
                guard let self else { return }
                if !didFinishThisVisit {
                    print("Per-visit location timeout. Using fallback coordinates for offline_id: \(visit.offline_id ?? "")")
                    // Fallback to startLocation if available, else zeros
                    let fallbackLat = startLocation?.coordinate.latitude ?? 0
                    let fallbackLng = startLocation?.coordinate.longitude ?? 0
                    didFinishThisVisit = true
                    buildAndAppend(endLat: fallbackLat, endLng: fallbackLng)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + perVisitTimeout, execute: timeoutWorkItem)

            LocationManager.shared.getCurrentLocation { endLat, endLng in
                if !didFinishThisVisit {
                    didFinishThisVisit = true
                    timeoutWorkItem.cancel()
                    buildAndAppend(endLat: endLat, endLng: endLng)
                }
            }
        }
    }
   
    // MARK: - Build Products Payload
    private func buildProductsPayloadNEW(_ productsData: [ProductVisitModel]) -> [[String: Any]] {
        return productsData.map { item in
            var dict: [String: Any] = [:]
            
            // MARK: - Basic
            dict["product_id"] = item.productId
            dict["samples"] = item.count
            dict["notes"] = item.comment
            
            // MARK: - Order & Stock
            dict["current_stock"] = item.stock
            dict["current_order"] = item.order
            dict["quotation_payment_method"] = item.payment
            
            // MARK: - Feedback
            dict["followup"] = item.followup_id ?? ""
            dict["mfeedback"] = item.market_feedback_id ?? ""
            dict["feedback_id"] = item.vFeedback_id ?? ""
            
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

    // MARK: - Build Gifts Payload
    private func buildGiftsPayloadNEW(_ giftsData: [GiftVisitModel]) -> [[String: Any]] {
        return giftsData.map { gift in
            [
                "gift_id": gift.giftId ?? 0,
                "noofunits": Int(gift.count ?? 0)
            ]
        }
    }

    // MARK: - Build Members Payload
    private func buildMembersPayloadNEW(_ managerData: [ManagerVisitModel]) -> [[String: Any]] {
        return managerData.map { manager in
            [
                "emp_id": manager.empId
            ]
        }
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

    private func proceedToSendUnplanned(
        visitsArray: [[String: Any]],
        url: String,
        completion: @escaping (Bool, String, [(offlineID: String, onlineID: String)]) -> Void
    ) {
        guard !visitsArray.isEmpty else {
            print("proceedToSendUnplanned: No visits aggregated to send")
            completion(false, "No visits to upload", [])
            return
        }

        do {
            let bodyData = try JSONSerialization.data(withJSONObject: visitsArray, options: [])
            print("Will send \(visitsArray.count) visits to: \(url)")
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
            ) { [weak self] (result: Result<UnPlannedVisitAResponse>) in
                self?.loadingBehavior.accept(false)
                switch result {
                case .success(let model):
                    let idsMap: [(offlineID: String, onlineID: String)] =
                    model.Data?.compactMap {
                        guard let offlineID = $0.offline_id, let onlineID = $0.visit_id else { return nil }
                        return (offlineID, onlineID)
                    } ?? []
                    print("Unplanned upload success. Mapped ids: \(idsMap)")
                    completion(true, model.Status_Message ?? "", idsMap)
                case .failure(let error):
                    print("Unplanned upload failed: \(error.localizedDescription)")
                    completion(false, error.localizedDescription, [])
                }
            }
        } catch {
            print("Unplanned upload JSON Encoding Error: \(error.localizedDescription)")
            completion(false, "JSON Encoding Error", [])
        }
    }

}
