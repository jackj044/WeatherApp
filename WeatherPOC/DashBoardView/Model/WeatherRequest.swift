//
//  WeatherRequest.swift
//  WeatherPOC
//
//  Created by Jatin Patel on 8/21/24.
//

struct WeatherRequest {
    
    let lat: Double
    let long: Double
    
    var toJSON: [String: Any] {
        
        return ["lat": lat,
                "lon": long,
                "limit": "100",
                "units": "imperial",
                "appid": OpenWeatherApiKey]
    }
}
