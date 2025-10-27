import SwiftUI

struct HistoryView: View {
    @Environment(SearchHistoryManager.self) private var searchHistory
    @State private var isPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            if searchHistory.cities.isEmpty {
                ContentUnavailableView {
                    Label("No History", systemImage: "arrow.counterclockwise")
                } description: {
                    Text("You search history will appear here")
                }
                .navigationTitle("No history")
            } else {
                List {
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
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button(role: .destructive) {
                            isPresented = true
                        } label: {
                            Label("Delete all", systemImage: "trash")
                        }
                    }
                }
                .alert("Delete all history?", isPresented: $isPresented) {
                    Button("Delete All", role: .destructive) {
                        searchHistory.removeAll()
                    }
                    Button("Cancel", role: .cancel) {}
                }
                .navigationTitle("History")
            }
        }
    }
}
