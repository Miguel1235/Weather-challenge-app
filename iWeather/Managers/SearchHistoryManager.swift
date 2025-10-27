import Foundation
import Observation

@Observable final class SearchHistoryManager {
    private let storageKey = "search_history"
    private let maxSearchHistory = 10
    
    var cities: [String] = []
    
    init() {
        load()
    }
    
    func addCity(_ city: String) {
        let trimmed = city.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        cities.removeAll { $0.caseInsensitiveCompare(trimmed) == .orderedSame }
        cities.insert(trimmed, at: 0)
        
        if cities.count > maxSearchHistory {
            cities.removeLast(cities.count - 10)
        }
        
        save()
    }
    
    func removeCity(_ city: String) {
        cities.removeAll { $0 == city }
        save()
    }
    
    func removeAll() {
        cities.removeAll(keepingCapacity: false)
        save()
    }
    
    private func load() {
        if let saved = UserDefaults.standard.array(forKey: storageKey) as? [String] {
            cities = saved
        }
    }
    
    private func save() {
        UserDefaults.standard.set(cities, forKey: storageKey)
    }
}
