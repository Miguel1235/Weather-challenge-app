import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(\.modelContext) private var context
    @State private var manager: FavoritesManager?
    @Query(sort: \FavoriteCity.addedAt, order: .reverse) private var favorites: [FavoriteCity]
        
    var body: some View {
        NavigationStack {
            if(favorites.count == 0) {
                ContentUnavailableView {
                    Label("No Favs", systemImage: "star")
                        .symbolVariant(.slash)
                } description: {
                    Text("You dont have any Favorites, yet ;)")
                }
                .navigationTitle("No Favorites")
            } else {
                List {
                    ForEach(favorites) { city in
                        NavigationLink(destination: DashboardView(city: city.name)) {
                            SearchResultRow(name: city.name, icon: "star.fill")
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            manager?.removeCity(id: favorites[index].id)
                        }
                    }
                }
                .navigationTitle("Favorites")
            }
        }
        .onAppear {
            manager = FavoritesManager(context: context)
        }
    }
}

#Preview {
    FavoritesView()
}
