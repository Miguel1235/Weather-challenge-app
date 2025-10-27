import Foundation

struct ForecastResponse: Codable {
    let list: [ForecastEntry]
    var listPerDay: [ForecastEntry] {
        return list.filter { entry in
            entry.dtTxt.hasSuffix("12:00:00")
        }
    }
    let city: ForecastCity
}

struct ForecastEntry: Codable, Identifiable {
    var id: Double { dt }
    let dt: Double
    let main: MainWeatherData
    let weather: [WeatherCondition]
    let wind: Wind
    let visibility: Int
    let rain: Rain?
    let sys: Sys
    let dtTxt: String
    
    
    var humanDate: String {        
        let date = Date(timeIntervalSince1970: dt)

        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d" // "Sun, May 24"
        formatter.locale = Locale(identifier: "en_US_POSIX") // ensures consistent format

        return formatter.string(from: date)
    }

    enum CodingKeys: String, CodingKey {
        case dt, main, weather, wind, visibility, rain, sys
        case dtTxt = "dt_txt"
    }
}

struct Rain: Codable {
    let threeH: Double?

    enum CodingKeys: String, CodingKey {
        case threeH = "3h"
    }
}

struct ForecastCity: Codable {
    let id: Int
    let name: String
    let coord: Coordinate
    let country: String
    let population: Int
    let timezone: Int
    let sunrise: Int
    let sunset: Int
}

