import SwiftUI
import SwiftData

struct CurrentWeatherCard: View {
    var current: CurrentWeatherResponse
    var isUsingMetric: Bool
    
    @Environment(\.modelContext) private var context
    @State private var manager: FavoritesManager?
    @Query(sort: \FavoriteCity.addedAt, order: .reverse) private var favorites: [FavoriteCity]

    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            HStack(alignment:.firstTextBaseline) {
                Text(current.name)
                    .font(.title)
                Spacer()
                Button {
                    if(manager?.isFavorite(cityID: current.id) ?? false) {
                        manager?.removeCity(id: current.id)
                    } else {
                        manager?.addCity(from: current)
                    }
                } label: {
                    Image(systemName: favorites.contains(where: { $0.id == current.id }) ? "star.fill" : "star")
                        .glassEffect(.regular.interactive())
                        .foregroundStyle(.yellow)
                }
            }
            .onAppear {
                manager = FavoritesManager(context: context)
            }
            MainWeatherCard(weather: current, isUsingMetric: isUsingMetric)
            WeatherDetails(weather: current)
        }
    }
}

#Preview {
    CurrentWeatherCard(current: load("weather.json"), isUsingMetric: true)
}
