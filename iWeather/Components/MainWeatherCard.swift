import SwiftUI

struct MainWeatherCard: View {
    var weather: CurrentWeatherResponse
    var isUsingMetric: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            AsyncImage(url: weather.weather.first!.iconURL) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 128, height: 128)
            VStack(alignment:.leading) {
                Text("\(isUsingMetric ? weather.main.temp.formatted() : celsiusToFahrenheit(weather.main.temp).formatted()) °\(isUsingMetric ? "C" : "F")")
                    .font(.largeTitle)
                    .bold()
                Text(weather.weather.first!.description)
                Text("Feels like \(isUsingMetric ? weather.main.feelsLike.formatted() : celsiusToFahrenheit(weather.main.feelsLike).formatted()) °\(isUsingMetric ? "C" : "F")")
                    .font(.footnote)
            }
        }
    }
}
