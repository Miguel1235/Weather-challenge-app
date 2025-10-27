enum WeatherApiError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case invalidData
    case unableToComplete
    case cityNotFound
    case tooManyResquests
    case unauthorized
}
