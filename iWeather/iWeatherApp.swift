import SwiftUI
import SwiftData

@main
struct iWeatherApp: App {
    @State var searchHistory = SearchHistoryManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(searchHistory)
                .modelContainer(for: FavoriteCity.self)
        }
        .modelContainer(for: FavoriteCity.self) { result in
            // this is used on the test to clear the favs and hist
            if ProcessInfo.processInfo.environment["RESET_DATA"] == "1" {
                if let bundleID = Bundle.main.bundleIdentifier {
                    UserDefaults.standard.removePersistentDomain(forName: bundleID)
                    UserDefaults.standard.synchronize()
                }
                
                if let container = try? result.get() {
                    do {
                        try container.mainContext.delete(model: FavoriteCity.self)
                    } catch {
                        print("Failed to delete all objects for UI tests: \(error)")
                    }
                }
            }
        }
    }
}
