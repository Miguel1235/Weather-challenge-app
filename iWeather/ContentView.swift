import SwiftUI

struct ContentView: View {   
    var body: some View {
        TabView {
            Tab("Dashboard", systemImage: "tray.and.arrow.down.fill") {
                DashboardView()
            }
            Tab("Favorites", systemImage: "heart") {
                FavoritesView()
            }
            Tab("History", systemImage: "arrow.counterclockwise") {
                HistoryView()
            }
            Tab(role: .search) {
                SearchView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview {
    @Previewable @State var searchHistory = SearchHistoryManager()
    ContentView()
        .environment(searchHistory)
}
