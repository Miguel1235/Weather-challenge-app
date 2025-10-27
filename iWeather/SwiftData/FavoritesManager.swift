import Foundation
import SwiftData

@MainActor
final class FavoritesManager {
    private var context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func getAllFavorites() -> [FavoriteCity] {
        let descriptor = FetchDescriptor<FavoriteCity>(sortBy: [SortDescriptor(\.addedAt, order: .reverse)])
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func isFavorite(cityID: Int) -> Bool {
        let predicate = #Predicate<FavoriteCity> { $0.id == cityID }
        let descriptor = FetchDescriptor<FavoriteCity>(predicate: predicate)
        return (try? context.fetch(descriptor))?.isEmpty == false
    }
    
    func addCity(from current: CurrentWeatherResponse) {
        guard !isFavorite(cityID: current.id) else { return }
        
        let encodedCurrent = try? JSONEncoder().encode(current)
        
        let favorite = FavoriteCity(
            id: current.id,
            name: current.name,
            country: current.sys.country,
            latitude: current.coord.lat,
            longitude: current.coord.lon,
            currentWeather: encodedCurrent,
        )
        context.insert(favorite)
        try? context.save()
    }
    
    func removeCity(id: Int) {
        let predicate = #Predicate<FavoriteCity> { $0.id == id }
        let descriptor = FetchDescriptor<FavoriteCity>(predicate: predicate)
        if let city = try? context.fetch(descriptor).first {
            context.delete(city)
            try? context.save()
        }
    }
}
