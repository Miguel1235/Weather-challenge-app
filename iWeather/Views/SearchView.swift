import SwiftUI

struct SearchView: View {
    @Environment(SearchHistoryManager.self) private var searchHistory
    @State var searchText: String = ""
    @State private var readyToNavigate = false

    var body: some View {
        NavigationStack {
            List {
                if(!searchText.isEmpty) {
                    NavigationLink(destination: DashboardView(city: searchText)) {
                        SearchResultRow(name: searchText, icon: "magnifyingglass")
                    }
                    .disabled(!isvalidCity(searchText))
                    .simultaneousGesture(TapGesture().onEnded {
                        let city = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                        if isvalidCity(city) {
                            searchHistory.addCity(city)
                        }
                        readyToNavigate = true
                    })


                }
                if !searchHistory.cities.isEmpty {
                    ForEach(searchHistory.cities, id: \.self) { city in
                        NavigationLink(destination: DashboardView(city: city)) {
                            SearchResultRow(name: city, icon: "arrow.clockwise")
                        }
                    }
                    .onDelete { indexSet in
                          for index in indexSet {
                              searchHistory.removeCity(searchHistory.cities[index])
                          }
                      }
                }
            }
            .navigationDestination(isPresented: $readyToNavigate) {
                let city = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                DashboardView(city: city)
            }
            .navigationTitle("Search")
        }
        .searchable(
            text: $searchText,
            placement: .automatic,
            prompt: "Type here to search a city"
        )
        .onSubmit(of: .search) {
            let city = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            if(isvalidCity(city)) {
                searchHistory.addCity(city)
                readyToNavigate = true
            }
        }
    }
}

#Preview {
    @Previewable @State var searchHistory = SearchHistoryManager()

    SearchView()
        .environment(searchHistory)
}
