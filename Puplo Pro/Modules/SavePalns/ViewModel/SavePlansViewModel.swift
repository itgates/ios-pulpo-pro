//
//  SavePlansViewModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 27/11/2025.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
final class SavePlansViewModel {

    // MARK: - Observables
    let loadingBehavior = BehaviorRelay<Bool>(value: false)
    let alertBehavior = PublishSubject<String>()

    // MARK: - Public Methods
    func savePlansWithNetworkCheck(
        plans: [SavePlanData],
        completion: @escaping (Bool, String) -> Void
    ) {
        Reachability.isConnectedToNetwork()
        ? saveOnline(plans: plans, completion: completion)
        : saveOffline(plans: plans, completion: completion)
    }

    // MARK: - Online Flow
    private func saveOnline(
        plans: [SavePlanData],
        completion: @escaping (Bool, String) -> Void
    ) {
        savePlans(plans: plans) { [weak self] success, message, responseData in
            guard let self = self else { return }
            print("plans >>\(plans)")
            self.storePlans(
                plans: plans,
                responseData: responseData,
                isUploaded: success
            )

            if success {
                LocalStorageManager.shared.clearOfflinePlans()
            }

            completion(success, message)
        }
    }

    // MARK: - Offline Flow
    private func saveOffline(
        plans: [SavePlanData],
        completion: @escaping (Bool, String) -> Void
    ) {
        LocalStorageManager.shared.saveOfflinePlans(model: plans)

        self.storePlans(
            plans: plans,
            responseData: [],
            isUploaded: false
        )

        completion(true, "تم حفظ البيانات محليًا. سيتم رفعها عند الاتصال بالإنترنت.")
    }

    // MARK: - Local Storage
    private func storePlans(
        plans: [SavePlanData],
        responseData: [ResponseData],
        isUploaded: Bool
    ) {
        let storedPlans = plans.map { plan -> SaveNewPlanModel in

            let matchedResponse = responseData.first {
                $0.offlineID == plan.offline_id
            }

            return SaveNewPlanModel(
                id: UUID().uuidString,
                onlineID: matchedResponse?.visitID.map(String.init) ?? "",
                offlineID: plan.offline_id,

                accountID: plan.account_id,
                accountDoctorID: plan.account_dr_id,
                accountTypeID: plan.account_type_id,
                divID: plan.div_id,
                lineID: plan.line_id,

                insertionDate: plan.insertion_date,
                visitDate: plan.visit_date,
                visitTime: plan.visit_time,

                accountName: plan.acccount,
                doctorName: plan.doctor,
                shift: plan.shift,

                latitude: plan.llAcccount,
                longitude: plan.lgAcccount,

                isUploaded: isUploaded
            )
        }

        var existingPlans = LocalStorageManager.shared.getNewPlanData() ?? []
        existingPlans.append(contentsOf: storedPlans)
        LocalStorageManager.shared.saveNewPlanData(model: existingPlans)
    }

    // MARK: - API Call
    private func savePlans(
        plans: [SavePlanData],
        completion: @escaping (Bool, String, [ResponseData]) -> Void
    ) {
        guard
            let user = LocalStorageManager.shared.getLoggedUser(),
            let baseURL = LocalStorageManager.shared.getAPIPath()
        else {
            completion(false, "Unauthorized", [])
            return
        }

        let url = baseURL + URLs.planURL
        let parameters = buildParams(from: plans)
        let headers = buildHeaders()
        print("parameters >>\(parameters)")
        print("baseURL >>\(baseURL)")
        loadingBehavior.accept(true)

        NetworkLayer.shared.fetchData(
            method: .post,
            url: url,
            parameters: parameters,
            headers: headers
        ) { [weak self] (result: Result<SavePlanResponse>) in
            self?.loadingBehavior.accept(false)

            switch result {
            case .success(let model):
                completion(true, model.message, model.data ?? [])
            case .failure:
                completion(false, "Something went wrong", [])
            }
        }
    }

    // MARK: - Helpers
    private func buildParams(from plans: [SavePlanData]) -> [String: Any] {
        let plansArray = plans.map {
            [
                "account_dr_id": $0.account_dr_id ?? 0,
                "account_id": $0.account_id ?? 0,
                "account_type_id": $0.account_type_id ?? 0,
                "div_id": $0.div_id ?? 0,
                "insertion_date": $0.insertion_date ?? "",
                "line_id": $0.line_id ?? 0,
                "offline_id": $0.offline_id ?? 0,
                "visit_date": $0.visit_date ?? "",
                "visit_time": $0.visit_time ?? ""
            ]
        }

        return ["plans": plansArray]
    }

    private func buildHeaders() -> HTTPHeaders {
        [
//            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "lang": "ar",
            "device-id": AppInfo.shared.deviceID,
            "timezone": "Africa/Cairo"
        ]
    }
}
