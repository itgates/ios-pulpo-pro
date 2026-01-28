import Foundation
import Alamofire

// MARK: - Result Type
enum Result<T> {
    case success(T)
    case failure(Error)
}

// MARK: - Network Errors
enum NetworkError: Error {
    case noData
    case noConnection
    case serverError(String)
}

// MARK: - Retry Handler
class RetryHandler: RequestInterceptor, @unchecked Sendable {
    private let maxRetryCount = 3
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        if request.retryCount < maxRetryCount {
            completion(.retry)
        } else {
            completion(.doNotRetry)
        }
    }
}

// MARK: - Network Layer (Singleton)
class NetworkLayer {
    
    static let shared = NetworkLayer()
    private init() {}
    
    func fetchData<T: Codable>(
        method: HTTPMethod,
        url: String,
        parameters: Parameters = [:],
        body: Data? = nil,
        headers: HTTPHeaders? = nil,
        completion: @escaping (Result<T>) -> Void
    ) {
        print("Request URL: \(url)")
        
        var finalHeaders: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        if let headers = headers {
            for header in headers { finalHeaders.add(header) }
        }
        
        print("Headers: \(finalHeaders)")
        
        if let body = body {
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = method.rawValue
            request.allHTTPHeaderFields = finalHeaders.dictionary
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            AF.request(request, interceptor: RetryHandler())
                .validate() // نسمح بكل status code ونشوف الresponse
                .responseData { response in
                    self.handleResponse(response: response, completion: completion)
                }
            
        } else {
            let encoder: ParameterEncoding = (method == .get) ? URLEncoding.default : JSONEncoding.default
            
            AF.request(url, method: method, parameters: parameters, encoding: encoder, headers: finalHeaders, interceptor: RetryHandler())
                .validate() // نسمح بكل status code
                .responseData { response in
                    self.handleResponse(response: response, completion: completion)
                }
        }
    }
    
    // MARK: - Handle Response
    private func handleResponse<T: Codable>(response: AFDataResponse<Data>, completion: @escaping (Result<T>) -> Void) {
        if let data = response.data, !data.isEmpty {
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                // Print raw JSON for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response JSON: \(jsonString)")
                }
                completion(.failure(error))
            }
        } else {
            let message = "No data received from server"
            print(message)
            completion(.failure(NetworkError.noData))
        }
        
        if let error = response.error {
            print("Network Error: \(error.localizedDescription)")
            if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                print("Error Response JSON: \(jsonString)")
            }
        }
    }
}
