//
//  Network.swift
//  Classified
//
//  Created by Burhanuddin Sunelwala on 25/12/20.
//

import Foundation
import Alamofire

enum NetworkError: Error {

    case invalidURL
    case serverDown
    case invalidResponse
    case invalidParameters
}

extension NetworkError: LocalizedError {

    public var errorDescription: String? {
        switch self {

        case .invalidURL:
            return NSLocalizedString("Bad Error", comment: "My error")

        case .serverDown:
            return NSLocalizedString("Server is down. Please try again.", comment: "My error")

        case .invalidResponse:
            return NSLocalizedString("Server is down. Please try again.", comment: "My error")

        case .invalidParameters:
            return NSLocalizedString("BadError", comment: "My error")
        }
    }
}

class Network {

    static let shared = Network()

    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        return dateFormatter
    }()

    private var decoder = JSONDecoder()

    private init() {
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func getProducts(completionHandler: @escaping (Result<[Product]>) -> ()) {

        request(URL.sampleClassified).responseJSON { (response) in

            response.result.ifSuccess {

                guard let value = response.value as? [String: Any] else {
                    completionHandler(.failure(NetworkError.invalidResponse))
                    return
                }
                if let results = value["results"] as? [[String: Any]],
                   let data = try? JSONSerialization.data(withJSONObject: results, options: []) {

                    if let articles = try? self.decoder.decode([Product].self, from: data) {
                        completionHandler(.success(articles))
                    } else {
                        completionHandler(.failure(NetworkError.invalidResponse))
                    }

                } else if let _ = value["message"] as? String {
                    completionHandler(.failure(NetworkError.invalidURL))
                } else {
                    completionHandler(.failure(NetworkError.invalidResponse))
                }
            }

            response.result.ifFailure {
                completionHandler(.failure(response.result.error!))
            }
        }
    }

}

