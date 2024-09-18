//
//  NetworkManagerTests.swift
//  WeatherPOCTests
//
//  Created by Jatin Patel on 8/21/24.
//

import XCTest
import Combine
@testable import WeatherPOC

class NetworkManagerTests: XCTestCase {
    var networkManager: NetworkManager!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        networkManager = NetworkManager.shared
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        networkManager.configureSession(session)
    }
    
    override func tearDown() {
        networkManager = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    func testSuccessfulResponse() async {
        // Given
        let expectedData = """
        {
            "name": "Test City",
            "sys": { "country": "TC" }
        }
        """.data(using: .utf8)
        MockURLProtocol.responseData = expectedData
        MockURLProtocol.responseError = nil
        MockURLProtocol.statusCode = 200
        
        // When
        let expectation = self.expectation(description: "Success response received")
        await networkManager.makeNetworkCall(endpoint: .getWeather, httpMethod: .GET, parameters: [:], type: WeatherResponse.self)
            .sink(receiveCompletion: { _ in }, receiveValue: { response in
                XCTAssertEqual(response.name, "Test City")
                XCTAssertEqual(response.sys?.country, "TC")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        // Then
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    func testDecodingErrorResponse() async {
        // Given
        let invalidData = "invalid data".data(using: .utf8)
        MockURLProtocol.responseData = invalidData
        MockURLProtocol.responseError = nil
        MockURLProtocol.statusCode = 200
        
        // When
        let expectation = self.expectation(description: "Decoding error received")
        await networkManager.makeNetworkCall(endpoint: .getWeather, httpMethod: .GET, parameters: [:], type: WeatherResponse.self)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertTrue(error is DecodingError)
                    expectation.fulfill()
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        // Then
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    func testResponseError() async {
        // Given
        MockURLProtocol.responseData = nil
        MockURLProtocol.responseError = nil
        MockURLProtocol.statusCode = 404
        
        // When
        let expectation = self.expectation(description: "Response error received")
        await networkManager.makeNetworkCall(endpoint: .getWeather, httpMethod: .GET, parameters: [:], type: WeatherResponse.self)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertTrue(error is NetworkError)
                    if let networkError = error as? NetworkError, networkError == .responseError {
                        expectation.fulfill()
                    }
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        // Then
        await fulfillment(of: [expectation], timeout: 10.0)
    }
}

// Dummy response model for testing
struct WeatherResponse: Decodable {
    let name: String
    let sys: Sys?
    
    struct Sys: Decodable {
        let country: String
    }
}
