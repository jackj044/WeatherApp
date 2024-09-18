//
//  SearchRequest.swift
//  WeatherPOC
//
//  Created by Jatin Patel on 8/21/24.
//

import Foundation

struct SearchRequest {
    
    let keyword: String
    
    var toJSON: [String: Any] {
        
        return ["q": keyword,
                "limit": "100",
                "appid": OpenWeatherApiKey]
    }
}
