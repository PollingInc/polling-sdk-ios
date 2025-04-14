import SwiftUI
import Polling

struct ContentView: View {
    private var polling: Polling = Polling()

    init() {
        polling.customerID = "id_\(Date().timeIntervalSinceReferenceDate)"
        polling.apiKey = "l4chQVGY1rYlFS7WPmbl5vIqCsZunsuDXUOx"
    }

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}
