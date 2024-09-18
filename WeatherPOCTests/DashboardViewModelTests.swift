//
//  DashboardViewModelTests.swift
//  WeatherPOCTests
//
//  Created by Jatin Patel on 8/21/24.
//

import XCTest
import Combine
@testable import WeatherPOC

final class DashboardViewModelTests: XCTestCase {
    private var viewModel: DashboardViewModel!
    private var mockNetworkManager: MockNetworkManager!
    private var mockUserDefaults: MockUserDefaults!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager.shared as? MockNetworkManager
        mockUserDefaults = MockUserDefaults(suiteName: "TestDefaults")
        viewModel = DashboardViewModel()
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockNetworkManager = nil
        mockUserDefaults = nil
        cancellables = nil
        super.tearDown()
    }

    func testGetWeatherSuccess() async {
        // Given
        let mockWeatherData = WeatherData(
            coord: Coord(lon: -0.1276, lat: 51.5074), // Example coordinates for London
            weather: [
                Weather(id: 800, main: "Clear", description: "clear sky", icon: "01d")
            ],
            base: "stations",
            main: Main(
                temp: 15.0,
                feelsLike: 14.0,
                tempMin: 13.0,
                tempMax: 17.0,
                pressure: 1013.0,
                humidity: 72
            ),
            visibility: 10000.0, // Visibility in meters
            wind: Wind(
                speed: 3.5,
                deg: 210,
                gust: 5.0
            ),
            snow: Snow(the1H: 0.0), // No snow
            clouds: Clouds(all: 5), // Few clouds
            dt: 1692578400, // Example timestamp
            sys: Sys(
                type: 1,
                id: 1414,
                country: "GB",
                sunrise: 1692562210,
                sunset: 1692618090
            ),
            timezone: 3600, // GMT+1
            id: 2643743, // London city ID
            name: "London",
            cod: 200 // HTTP status code for OK
        )
        mockNetworkManager.weatherData = mockWeatherData
        
        // When
        await viewModel.getWeather(lat: 44.34, long: 10.99)

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.weatherResponse, mockWeatherData)
        
    }

    func testGetWeatherFailure() async {
        // Given
        mockNetworkManager.shouldReturnError = true

        // When
        await viewModel.getWeather(lat: 44.34, long: 10.99)

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.weatherResponse)
    }
}
