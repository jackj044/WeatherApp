//
//  NetworkManager.swift
//  WeatherPOC
//
//  Created by Jatin Patel on 8/21/24.
//

import Foundation
import Combine


enum Endpoint: String {
    case getWeather = "data/2.5/weather"
    case place = "geo/1.0/direct"
}

enum HttpMethods: String {
    case GET
    case POST
}

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    private var cancellables = Set<AnyCancellable>()
    private let baseURL = "https://api.openweathermap.org/"
    
    // Injecting URLSession for testing
    private var session: URLSession = URLSession.shared
    
    func configureSession(_ session: URLSession) {
        self.session = session
    }
    
    func makeNetworkCall<T: Decodable>(endpoint: Endpoint, httpMethod: HttpMethods, parameters: [String: Any], type: T.Type) async -> Future<T, Error> {
        return Future<T, Error> { [weak self] promise in
            guard let self1 = self, let url = URL(string: self1.baseURL.appending(endpoint.rawValue)) else {
                return promise(.failure(NetworkError.invalidURL))
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = httpMethod.rawValue
            
            if httpMethod == .GET {
                let queryItems = parameters.map { key, value in
                    URLQueryItem(name: key, value: "\(value)")
                }
                if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                    urlComponents.queryItems = queryItems
                    request.url = urlComponents.url
                }
            }
            
            self1.session.dataTaskPublisher(for: request)
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                        throw NetworkError.responseError
                    }
                    return data
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        switch error {
                        case let decodingError as DecodingError:
                            promise(.failure(decodingError))
                        case let apiError as NetworkError:
                            promise(.failure(apiError))
                        default:
                            promise(.failure(NetworkError.unknown))
                        }
                    }
                }, receiveValue: { value in
                    promise(.success(value))
                })
                .store(in: &self1.cancellables)
        }
    }
}

enum NetworkError: Error {
    case invalidURL
    case responseError
    case unknown
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Invalid URL", comment: "Invalid URL")
        case .responseError:
            return NSLocalizedString("Unexpected status code", comment: "Invalid response")
        case .unknown:
            return NSLocalizedString("Unknown error", comment: "Unknown error")
        }
    }
}
