import Foundation
import RxSwift
import RxCocoa
import Alamofire
import CoreData

class PinViewModel {
    
    let loadingBehavior = BehaviorRelay<Bool>(value: false)
    let alertBehavior = PublishSubject<String>()
    
    func loginUser(pin: String, completion: @escaping (Bool,String,String) -> Void) {
        
        let body = "?FN=master&pin=\(pin)"
        loadingBehavior.accept(true)
        
        NetworkLayer.shared.fetchData(
            method: .post,
            url: URLs.pinURL + body,
            parameters: [:],
            headers: [:]
        ) { [weak self] (result: Result<PinModel>) in
            guard let self = self else { return }
            self.loadingBehavior.accept(false)
            switch result {
            case .success(let model):
                let data = model.data ?? []
                if data.isEmpty {
                    completion(false,"", "Invalid PIN. No account found.")
                } else {
                    if let apiPath = model.data?.first?.apiPath {
                        LocalStorageManager.shared.saveAPIPath(apiPath)
                        print("🔥 Saved API Path = \(apiPath)")
                    }
                    
                    if model.data?.first?.system == "P" {
                        completion(true,model.data?.first?.name ?? "", "Done")
                    } else {
                        completion(false,"", "The system is unavailable.")
                    }
                }
                print("model: \(model)")
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion(false,"", "")
            }
        }
    }
}
