//
//  MockURLProtocol.swift
//  WeatherPOCTests
//
//  Created by Jatin Patel on 8/21/24.
//

import Foundation

class MockURLProtocol: URLProtocol {
    static var responseData: Data?
    static var responseError: Error?
    static var statusCode: Int = 200

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let error = MockURLProtocol.responseError {
            self.client?.urlProtocol(self, didFailWithError: error)
        } else {
            let response = HTTPURLResponse(url: request.url!, statusCode: MockURLProtocol.statusCode, httpVersion: nil, headerFields: nil)!
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = MockURLProtocol.responseData {
                self.client?.urlProtocol(self, didLoad: data)
            }
        }
        self.client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
