//
//  MockNetworkManager.swift
//  WeatherPOCTests
//
//  Created by Jatin Patel on 8/21/24.
//

import Foundation
import Combine
@testable import WeatherPOC

class MockNetworkManager: NetworkManager {
    var shouldReturnError = false
    var weatherData: WeatherData?

    override func makeNetworkCall<T>(endpoint: Endpoint, httpMethod: HttpMethods, parameters: [String: Any], type: T.Type) async -> Future<T, Error> where T : Decodable {
        return Future<T, Error> { promise in
            if self.shouldReturnError {
                promise(.failure(NetworkError.responseError))
            } else if let weatherData = self.weatherData as? T {
                promise(.success(weatherData))
            }
        }
    }
}
