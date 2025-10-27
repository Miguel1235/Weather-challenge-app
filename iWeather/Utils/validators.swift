import Foundation

func isvalidCity(_ city: String) -> Bool {
    let trimmed = city.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return false }

    guard trimmed.count >= 3 else { return false }

    let pattern = "^[A-Za-zÀ-ÿ'\\-\\s]+$"
    let isValid = trimmed.range(of: pattern, options: .regularExpression) != nil
    guard isValid else { return false }
    
    return true
}
