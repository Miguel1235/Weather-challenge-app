import SwiftUI

struct WeatherDetails: View {
    var weather : CurrentWeatherResponse
    
    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 16) {
            GridRow {
                Label("Humidity: \(weather.main.humidity)%", systemImage: "drop.fill")
                Label("Sunrise: \(weather.sys.sunriseDate!)", systemImage: "sunrise.fill")
                    .foregroundStyle(.orange)
            }
            GridRow {
                Label("Wind: \(weather.wind.speed.formatted()) m/s", systemImage: "wind")
                    .foregroundStyle(.gray)
                Label("Sunset: \(weather.sys.sunsetDate!)", systemImage: "sunset.fill")
                    .foregroundStyle(.red)
            }
        }
    }
}
