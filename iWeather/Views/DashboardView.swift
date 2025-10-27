import SwiftUI
import SwiftData

struct DashboardView: View {
    @State var city: String = ""
    @State private var isUsingMetric = true
    @State private var manager: FavoritesManager?
    
    var viewModel = WeatherViewModel()
    
    @Environment(\.modelContext) private var context
    @Query(sort: \FavoriteCity.addedAt, order: .reverse) private var favorites: [FavoriteCity]
    
    
    @Environment(SearchHistoryManager.self) private var searchHistory
    
    var body: some View {
        NavigationStack {
            Form() {
                Section("Current") {
                    if viewModel.weatherState == .loading {
                        ProgressView("Loading current weather...")
                    }
                    
                    if viewModel.weatherState == .success {
                        CurrentWeatherCard(current: viewModel.weather!, isUsingMetric: isUsingMetric)
                    }
                    
                    if case .failure(let error) = viewModel.forecastState {
                        ErrorView(error: error)
                    }
                }
                Section("5-Day Forecast") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        if viewModel.forecastState == .loading {
                            ProgressView("Loading forecast...")
                        }
                        
                        if case .failure(let error) = viewModel.forecastState {
                            ErrorView(error: error)
                        }
                        
                        if viewModel.forecastState == .success {
                            HStack {
                                ForEach(viewModel.forecast!.listPerDay) {
                                    ForecastCard(forecast: $0, isUsingMetric: isUsingMetric)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Menu {
                        Button {
                            isUsingMetric = true
                        } label: {
                            Label("Celsius", systemImage: isUsingMetric ? "checkmark" : "degreesign.celsius")
                        }
                        
                        Button {
                            isUsingMetric = false
                        } label: {
                            Label("Fahrenheit", systemImage: isUsingMetric ? "degreesign.fahrenheit" : "checkmark")
                        }
                    } label: {
                        Label("Units", systemImage: "thermometer")
                    }
                }
            }
            .onDisappear {
                city = ""
            }
            .onAppear {
                if city.isEmpty {
                    city = favorites.first?.name ?? "Mendoza"
                }
                
                manager = FavoritesManager(context: context)
                let fav = favorites.first(where: { $0.name == city })
                let date = fav?.addedAt ?? Date()
                let now = Date()
                let oneHourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: now)!
                
                // The cache is only valid for one hour
                if(fav != nil && date >= oneHourAgo && date <= now) {
                    print("Going to use the cache of the favorites...")
                    let weather = fav!.decodedCurrentWeather!
                    viewModel.loadWeatherFromCache(weather: weather)
                    Task {
                        // the forecast is never cached as it can change
                        await viewModel.getForecast(for: city)
                    }
                } else {
                    Task {
                        await viewModel.getCurrentWeather(for: city)
                        await viewModel.getForecast(for: city)
                    }
                }
                
                
            }
            .refreshable {
                await viewModel.getCurrentWeather(for: city)
                await viewModel.getForecast(for: city)
            }
        }
    }
}
