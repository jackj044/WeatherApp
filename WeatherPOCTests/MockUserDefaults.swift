//
//  MockUserDefaults.swift
//  WeatherPOCTests
//
//  Created by Jatin Patel on 8/21/24.
//

import Foundation

class MockUserDefaults: UserDefaults {
    var storedData: Data?

    override func set(_ value: Any?, forKey defaultName: String) {
        storedData = value as? Data
    }

    override func object(forKey defaultName: String) -> Any? {
        return storedData
    }
}
