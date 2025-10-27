import SwiftUI

struct ForecastCard: View {
    var forecast: ForecastEntry
    var isUsingMetric: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text(forecast.humanDate)
                .font(.headline)            
            AsyncImage(url: forecast.weather.first!.iconURL) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 40, height: 40)
            
            
                .foregroundStyle(Color.yellow)
            Text("\(isUsingMetric ? forecast.main.temp.formatted() : celsiusToFahrenheit(forecast.main.temp).formatted()) °\(isUsingMetric ? "C" : "F")")
                .font(.headline)
            
            
            Text(forecast.weather.first!.description)
                .font(.footnote)
        }
    }
}
