import SwiftUI
import Polling

struct ContentView: View {
    private var polling: Polling = Polling()

    class Listener: NSObject, PollingDelegate {
        var view: any View
        init(view: any View) {
            self.view = view
        }
        func polling(onSuccess response: String) {
            NSLog("SUCCESS: response=\(response)")
        }
        func polling(onFailure error: String) {
            NSLog("ERROR: error=\(error)")
        }
        func polling(on reward: Polling.Reward) {
            NSLog("REWARD: reward=\(reward)")
        }
        func pollingOnSurveyAvailable() {
            NSLog("AVAILABLE: Survey available")
        }
    }
    var listener: Listener?

    init() {
        listener = Listener(view: self)
        polling.customerID = "id_\(Date().timeIntervalSinceReferenceDate)"
        polling.apiKey = "l4chQVGY1rYlFS7WPmbl5vIqCsZunsuDXUOx"
        polling.delegate = listener
    }

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Button("Show Survey") {
                polling.showSurvey("caa4fc7a-a7b9-489c-a7c8-e5e7f8aeeefa")
            }.padding(.top)
        }.buttonStyle(.bordered)
        .padding()
    }
}
