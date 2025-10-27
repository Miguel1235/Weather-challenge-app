import Testing
import Foundation
@testable import iWeather

func loadTestData<T: Decodable>(_ filename: String) throws -> T {
    let data: Data
    
    guard let file = Bundle(for: BundleFinder.self).url(forResource: filename, withExtension: nil) else {
        throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Couldn't find \(filename) in test bundle"])
    }
    
    data = try Data(contentsOf: file)
    
    let decoder = JSONDecoder()
    return try decoder.decode(T.self, from: data)
}

private class BundleFinder {}

struct iWeatherTests {

    // MARK: - Temperature Conversion Tests
    
    @Test("Celsius to Fahrenheit conversion")
    func celsiusToFahrenheitConversion() {
        let zeroCelsius = celsiusToFahrenheit(0)
        #expect(zeroCelsius == 32.0)
        
        let hundredCelsius = celsiusToFahrenheit(100)
        #expect(hundredCelsius == 212.0)
        
        let negativeCelsius = celsiusToFahrenheit(-40)
        #expect(negativeCelsius == -40.0)
        
        let decimalCelsius = celsiusToFahrenheit(25.5)
        #expect(abs(decimalCelsius - 77.9) < 0.1)
    }
    
    @Test("Fahrenheit to Celsius conversion")
    func fahrenheitToCelsiusConversion() {
        let zeroFahrenheit = fahrenheitToCelsius(32)
        #expect(zeroFahrenheit == 0.0)
        
        let hundredFahrenheit = fahrenheitToCelsius(212)
        #expect(abs(hundredFahrenheit - 100.0) < 0.1)
        
        let negativeFahrenheit = fahrenheitToCelsius(-40)
        #expect(negativeFahrenheit == -40.0)
        
        let decimalFahrenheit = fahrenheitToCelsius(77.9)
        #expect(abs(decimalFahrenheit - 25.5) < 0.1)
        
        let bigFahrenheit = fahrenheitToCelsius(899.0)
        #expect(abs(bigFahrenheit - 481.667) < 0.1)
    }
    
    // MARK: - City Validation Tests
    
    @Test("Valid city names")
    func validCityNames() {
        #expect(isvalidCity("New York"))
        #expect(isvalidCity("San Francisco"))
        #expect(isvalidCity("São Paulo"))
        #expect(isvalidCity("City's"))
        #expect(isvalidCity("New-York"))
        #expect(isvalidCity("Los Angeles"))
        #expect(isvalidCity("New York City"))
    }
    
    @Test("Invalid city names")
    func invalidCityNames() {
        #expect(!isvalidCity(""))
        #expect(!isvalidCity(" "))
        #expect(!isvalidCity("AB"))
        #expect(!isvalidCity("NY"))
        #expect(!isvalidCity("MD"))
        #expect(!isvalidCity("City123"))
        #expect(!isvalidCity("City@Name"))
        #expect(!isvalidCity("City#Name"))
    }
    
    @Test("Edge cases for city validation")
    func cityValidationEdgeCases() {
        // Minimum valid length (3 characters)
        #expect(isvalidCity("ABC"))
        #expect(!isvalidCity("AB"))
        
        // Whitespace trimming
        #expect(isvalidCity("  New York  "))
        #expect(!isvalidCity("   "))
        
        // Special characters allowed
        #expect(isvalidCity("O'Brien"))
        #expect(isvalidCity("Saint-Jean"))
        
        // Not allowed
        #expect(!isvalidCity("123456"))
        #expect(!isvalidCity("City@123"))
    }
    
    // MARK: - WeatherViewModel Tests
    
    @Test("WeatherViewModel initial state")
    func weatherViewModelInitialState() {
        let viewModel = WeatherViewModel()
        #expect(viewModel.weather == nil)
        #expect(viewModel.forecast == nil)
        #expect(viewModel.weatherState == .idle)
        #expect(viewModel.forecastState == .idle)
    }
    
    @Test("WeatherViewModel loadWeatherFromCache")
    func weatherViewModelLoadWeatherFromCache() throws {
        let viewModel = WeatherViewModel()
        let weather: CurrentWeatherResponse = try loadTestData("weather.json")
        
        viewModel.loadWeatherFromCache(weather: weather)
        
        #expect(viewModel.weather != nil)
        #expect(viewModel.weatherState == .success)
        #expect(viewModel.weather?.name == "Mendoza")
    }
    
    @Test("LoadState equality")
    func loadStateEquality() {
        #expect(LoadState.idle == LoadState.idle)
        #expect(LoadState.loading == LoadState.loading)
        #expect(LoadState.success == LoadState.success)
        
        #expect(!(LoadState.idle == LoadState.loading))
        #expect(!(LoadState.loading == LoadState.success))
    }
    
    // MARK: - SearchHistoryManager Tests
    
    @Test("SearchHistoryManager add city")
    func searchHistoryManagerAddCity() {
        let manager = SearchHistoryManager()
        manager.removeAll() // Start clean
        
        manager.addCity("New York")
        #expect(manager.cities.count == 1)
        #expect(manager.cities.contains("New York"))
        
        manager.addCity("Los Angeles")
        #expect(manager.cities.count == 2, "Expected that the array has two cities")
        #expect(manager.cities.first == "Los Angeles") // Most recent first
    }
    
    @Test("SearchHistoryManager max history limit")
    func searchHistoryManagerMaxLimit() {
        let manager = SearchHistoryManager()
        manager.removeAll() // Start clean
        
        // Add more than 10 cities
        for i in 1...15 {
            manager.addCity("City \(i)")
        }
        
        #expect(manager.cities.count == 10, "Expected to only 10 cities in history") // Should be capped at 10
        #expect(manager.cities.first == "City 15") // Most recent
        #expect(!manager.cities.contains("City 1")) // Oldest removed
    }
    
    @Test("SearchHistoryManager duplicate handling")
    func searchHistoryManagerDuplicateHandling() {
        let manager = SearchHistoryManager()
        manager.removeAll()
        
        manager.addCity("New York")
        manager.addCity("Los Angeles")
        manager.addCity("Chicago")
        
        #expect(manager.cities.count == 3)
        
        manager.addCity("New York")
        #expect(manager.cities.count == 3)
        #expect(manager.cities.first == "New York")
        #expect(manager.cities.contains("New York"))
        #expect(!manager.cities.contains("New York") || manager.cities.filter { $0 == "New York" }.count == 1)
    }
    
    @Test("SearchHistoryManager remove city")
    func searchHistoryManagerRemoveCity() {
        let manager = SearchHistoryManager()
        manager.removeAll()
        
        manager.addCity("New York")
        manager.addCity("Los Angeles")
        manager.addCity("Chicago")
        
        #expect(manager.cities.count == 3)
        
        manager.removeCity("Los Angeles")
        #expect(manager.cities.count == 2)
        #expect(!manager.cities.contains("Los Angeles"))
        #expect(manager.cities.contains("Chicago"))
        #expect(manager.cities.contains("New York"))
    }
    
    @Test("SearchHistoryManager remove all")
    func searchHistoryManagerRemoveAll() {
        let manager = SearchHistoryManager()
        manager.removeAll()
        
        manager.addCity("New York")
        manager.addCity("Los Angeles")
        manager.addCity("Chicago")
        
        #expect(manager.cities.count == 3)
        
        manager.removeAll()
        #expect(manager.cities.isEmpty, "Expected an empty History, got \(manager.cities)")
    }
    
    @Test("SearchHistoryManager empty or whitespace city")
    func searchHistoryManagerEmptyCity() {
        let manager = SearchHistoryManager()
        manager.removeAll()
        
        manager.addCity("")
        #expect(manager.cities.isEmpty)
        
        manager.addCity("   ")
        #expect(manager.cities.isEmpty)
        
        manager.addCity("  \n\t  ")
        #expect(manager.cities.isEmpty)
    }
    
    // MARK: - Sys Date Formatting Tests
    
    @Test("Sys sunrise date formatting")
    func sysSunriseDateFormatting() {
        let sys = Sys(id: 1, country: "AR", sunrise: 1761385375, sunset: nil)
        let formatted = sys.sunriseDate
        
        #expect(formatted != nil)
        if let formatted = formatted {
            #expect(formatted.count == 5) // "HH:mm"
            #expect(formatted.contains(":"))
        }
    }
    
    @Test("Sys sunset date formatting")
    func sysSunsetDateFormatting() {
        let sys = Sys(id: 1, country: "AR", sunrise: nil, sunset: 1761432931)
        let formatted = sys.sunsetDate
        
        #expect(formatted != nil)
        if let formatted = formatted {
            #expect(formatted.count == 5) // "HH:mm"
            #expect(formatted.contains(":"))
        }
    }
    
    @Test("Sys nil sunrise/sunset")
    func sysNilDates() {
        let sys = Sys(id: 1, country: "AR", sunrise: nil, sunset: nil)
        
        #expect(sys.sunriseDate == nil)
        #expect(sys.sunsetDate == nil)
    }
    
    // MARK: - ForecastResponse Tests
    
    @Test("ForecastEntry listPerDay filter")
    func forecastResponseListPerDay() throws {
        let forecast: ForecastResponse = try loadTestData("forecast.json")
        
        // Should only include entries with "12:00:00" suffix
        for entry in forecast.listPerDay {
            #expect(entry.dtTxt.hasSuffix("12:00:00"))
        }
        
        #expect(forecast.listPerDay.count < forecast.list.count)
        #expect(forecast.listPerDay.count == 5, "Expeted only 5 days in the forecast, got \(forecast.listPerDay.count)")
    }
    
    @Test("ForecastEntry human date formatting")
    func forecastEntryHumanDate() throws {
        let forecast: ForecastResponse = try loadTestData("forecast.json")
        
        if let entry = forecast.list.first {
            let formatted = entry.humanDate
            #expect(!formatted.isEmpty)
            // Should be in "E, MMM d" format like "Sun, May 24"
            let components = formatted.components(separatedBy: ", ")
            #expect(components.count == 2)
        }
    }
    
    @Test("WeatherCondition icon URL")
    func weatherConditionIconURL() {
        let condition = WeatherCondition(description: "clear sky", icon: "01d")
        let url = condition.iconURL
        
        #expect(url.absoluteString == "https://openweathermap.org/img/wn/01d@2x.png")
        
        let nightCondition = WeatherCondition(description: "clear sky", icon: "01n")
        let nightURL = nightCondition.iconURL
        #expect(nightURL.absoluteString == "https://openweathermap.org/img/wn/01n@2x.png")
    }
    
    @Test("ForecastEntry ID")
    func forecastEntryID() throws {
        let forecast: ForecastResponse = try loadTestData("forecast.json")
        
        if let entry = forecast.list.first {
            #expect(entry.id == entry.dt)
        }
    }
    
    // MARK: - Integration Tests
    
    @Test("Complete weather data parsing")
    func completeWeatherDataParsing() throws {
        let weather: CurrentWeatherResponse = try loadTestData("weather.json")
        
        #expect(weather.name == "Mendoza")
        #expect(weather.id == 3844421)
        #expect(weather.cod == 200)
        #expect(weather.coord.lat == -32.8908)
        #expect(weather.coord.lon == -68.8272)
        #expect(weather.main.temp == 19.74)
        #expect(weather.main.humidity == 22)
        #expect(weather.weather.count == 1)
        #expect(weather.wind.speed == 3.6)
    }
    
    @Test("Complete forecast data parsing")
    func completeForecastDataParsing() throws {
        let forecast: ForecastResponse = try loadTestData("forecast.json")
        
        #expect(!forecast.list.isEmpty)
        #expect(forecast.city.name == "Mendoza")
        #expect(forecast.city.id == 3844421)
        #expect(forecast.city.country == "AR")
        #expect(forecast.listPerDay.count > 0)
        
        // Verify first entry structure
        if let firstEntry = forecast.list.first {
            #expect(firstEntry.main.temp > 0)
            #expect(firstEntry.weather.count > 0)
            #expect(!firstEntry.dtTxt.isEmpty)
        }
    }
    
    // MARK: - API Tests
    
    @Test("NetworkManager get current weather for valid city", .timeLimit(.minutes(1)))
    func networkManagerGetCurrentWeather() async throws {
        let result = await NetworkManager.shared.getCurrentWeather(of: "London")
        
        switch result {
        case .success(let weather):
            #expect(weather.name == "London")
            #expect(weather.cod == 200)
            await #expect(weather.coord.lat != 0)
            await #expect(weather.coord.lon != 0)
            await #expect(weather.main.temp != 0)
            #expect(!weather.weather.isEmpty)
            await #expect(weather.wind.speed >= 0)
        case .failure(let error):
            Issue.record("Unexpected API error: \(error)")
        }
    }
    
    @Test("NetworkManager get current weather for invalid city", .timeLimit(.minutes(1)))
    func networkManagerGetCurrentWeatherInvalidCity() async {
        let result = await NetworkManager.shared.getCurrentWeather(of: "InvalidCityThatDoesNotExist12345")
        
        switch result {
        case .success:
            Issue.record("Expected failure for invalid city")
        case .failure(let error):
            #expect(error == .cityNotFound)
        }
    }
    
    @Test("NetworkManager get forecast for valid city", .timeLimit(.minutes(1)))
    func networkManagerGetForecast() async throws {
        let result = await NetworkManager.shared.getForecast(of: "Paris")
        
        switch result {
        case .success(let forecast):
            await #expect(forecast.city.name == "Paris")
            #expect(forecast.list.count > 0)
            #expect(!forecast.listPerDay.isEmpty)
            
            // Verify forecast entries have valid data
            if let firstEntry = await forecast.list.first {
                await #expect(firstEntry.main.temp != 0)
                #expect(!firstEntry.weather.isEmpty)
                #expect(!firstEntry.dtTxt.isEmpty)
            }
            
            // Verify city data
            await #expect(forecast.city.population > 0)
            await #expect(!forecast.city.country.isEmpty)
            await #expect(forecast.city.coord.lat != 0)
            await #expect(forecast.city.coord.lon != 0)
        case .failure(let error):
            Issue.record("Unexpected API error: \(error)")
        }
    }
    
    @Test("NetworkManager get forecast for invalid city", .timeLimit(.minutes(1)))
    func networkManagerGetForecastInvalidCity() async {
        let result = await NetworkManager.shared.getForecast(of: "FakeCity999999")
        
        switch result {
        case .success:
            Issue.record("Expected failure for invalid city")
        case .failure(let error):
            #expect(error == .cityNotFound)
        }
    }
    
    @Test("NetworkManager test multiple cities", .timeLimit(.minutes(1)))
    func networkManagerMultipleCities() async {
        let cities = ["Tokyo", "New York", "Berlin"]
        var successCount = 0
        
        for city in cities {
            let result = await NetworkManager.shared.getCurrentWeather(of: city)
            if case .success = result {
                successCount += 1
            }
        }
        
        #expect(successCount >= 2, "Expected at least 2 cities to succeed")
    }
    
    @Test("NetworkManager singleton instance")
    func networkManagerSingleton() {
        let manager = NetworkManager.shared
        let manager2 = NetworkManager.shared
        
        #expect(manager === manager2, "NetworkManager should be a singleton")
    }
    
    @Test("NetworkManager URL construction")
    func networkManagerURLConstruction() {
        // Test that URLs can be constructed correctly
        let baseURL = "https://api.openweathermap.org/data/2.5"
        let city = "London"
        
        // Test weather URL construction
        let weatherURL = URL(string: "\(baseURL)/weather/?q=\(city)&appid=testKey&units=metric")
        #expect(weatherURL != nil)
        #expect(weatherURL?.absoluteString.contains(city) == true)
        
        // Test forecast URL construction
        let forecastURL = URL(string: "\(baseURL)/forecast/?q=\(city)&appid=testKey&units=metric")
        #expect(forecastURL != nil)
        #expect(forecastURL?.absoluteString.contains(city) == true)
        #expect(forecastURL?.absoluteString.contains("forecast") == true)
    }
    
    @Test("API response data structure validation", .timeLimit(.minutes(1)))
    func apiResponseDataStructureValidation() async {
        let result = await NetworkManager.shared.getCurrentWeather(of: "Rome")
        
        switch result {
        case .success(let weather):
            await #expect(weather.coord.lat >= -90 && weather.coord.lat <= 90)
            await #expect(weather.coord.lon >= -180 && weather.coord.lon <= 180)
            
            await #expect(weather.main.temp > -100 && weather.main.temp < 100)
            await #expect(weather.main.humidity >= 0 && weather.main.humidity <= 100)
            await #expect(weather.main.pressure > 0)
            
            await #expect(weather.wind.speed >= 0)
            
            #expect(!weather.weather.isEmpty)
            if let firstCondition = await weather.weather.first {
                #expect(!firstCondition.description.isEmpty)
                #expect(!firstCondition.icon.isEmpty)
                #expect(firstCondition.iconURL.absoluteString.contains("openweathermap.org"))
            }
            
            if let sunrise = await weather.sys.sunrise {
                #expect(sunrise > 0)
            }
            if let sunset = await weather.sys.sunset {
                #expect(sunset > 0)
            }
            
        case .failure(let error):
            Issue.record("Unexpected API error: \(error)")
        }
    }
    
    @Test("NetworkManager error handling with special characters")
    func networkManagerSpecialCharacters() async {
        let cities = ["São Paulo", "New York", "Los Angeles"]
        
        for city in cities {
            let result = await NetworkManager.shared.getCurrentWeather(of: city)
            if case .success(let weather) = result {
                #expect(!weather.name.isEmpty)
                #expect(weather.cod == 200)
            }
        }
    }
}
