import SwiftUI
import Polling

struct ContentView: View {
    private var polling: Polling = Polling()

    init() {
        polling.customerID = "UniqueCustomerIDProvidedByYou"
        polling.apiKey = "EmbedAPIKeyFromPolling.com"
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
