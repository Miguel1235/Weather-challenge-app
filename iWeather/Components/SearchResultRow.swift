import SwiftUI

struct SearchResultRow: View {
    let name: String
    var icon: String
    
    var body: some View {
        HStack {
            Label(name, systemImage: icon)
        }
    }
}
