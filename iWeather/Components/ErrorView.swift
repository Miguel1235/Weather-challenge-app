import SwiftUI

struct ErrorView: View {
    let error: WeatherApiError
    var body: some View {
        VStack {
            switch error {
            case .cityNotFound:
                Label("City not found", systemImage: "mappin.slash")
            case .unableToComplete:
                Label("Network error. Please try again.", systemImage: "wifi.slash")
            case .invalidData, .invalidResponse:
                Label("Server error. Try later.", systemImage: "exclamationmark.triangle")
            case .invalidURL:
                Label("Url not valid.", systemImage: "exclamationmark.circle")
            case .tooManyResquests:
                Label("Too many requests. Try again later.", systemImage: "thermometer.high")
            case .unauthorized:
                Label("You dont have permission", systemImage: "shield.slash")
            }
        }
        .foregroundColor(.red)
        .multilineTextAlignment(.center)
        .padding()
    }
}
