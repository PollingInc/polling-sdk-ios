/*
 *  ContentView.swift
 *  SwiftUIApp
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

import SwiftUI
import Polling

struct ContentView: View {
	@State private var UUID: String = ""
	@State private var eventName: String = ""
	@State private var eventValue: String = ""

	private var polling: Polling = Polling()

	class Listener: NSObject, PollingDelegate {
		var view: any View
		init(view: any View) {
			self.view = view
		}
		func polling(onSuccess response: String) {
			NSLog("SUCCESS (SwiftUIApp): response=\(response)")
		}
		func polling(onFailure error: String) {
			NSLog("ERROR (SwiftUIApp): error=\(error)")
		}
		func polling(on reward: Polling.Reward) {
			NSLog("REWARD (SwiftUIApp): reward=\(reward)")
		}
		func pollingOnSurveyAvailable() {
			NSLog("(SwiftUIApp) There is a survey available.")
		}
	}
	var listener: Listener?

	init() {
		listener = Listener(view: self)
		polling.customerID = "swiftui-customer_\(Date().timeIntervalSinceReferenceDate)"
		polling.apiKey = "H3uZsrv6B2qyRXGePLxQ9U8g7vilWFTjIhZO"
		polling.delegate = listener
	}

	func showDialog() {
		NSLog("(SwiftUIApp) \(#function) UUID=\($UUID.wrappedValue)")
		polling.viewType = .dialog
		polling.showSurvey($UUID.wrappedValue)
	}

	func showBottom() {
		NSLog("(SwiftUIApp) \(#function) UUID=\($UUID.wrappedValue)")
		polling.viewType = .bottom
		polling.showSurvey($UUID.wrappedValue)
	}

	func embedDialog() {
		NSLog("(SwiftUIApp) \(#function)")
		polling.viewType = .dialog
		polling.showEmbedView()
	}

	func embedBottom() {
		NSLog("(SwiftUIApp) \(#function)")
		polling.viewType = .bottom
		polling.showEmbedView()
	}

	func logEvent() {
		NSLog("(SwiftUIApp) \(#function) eventName=\($eventName.wrappedValue), eventValue=\($eventValue.wrappedValue)")
		polling.logEvent($eventName.wrappedValue, value: $eventValue.wrappedValue)
	}

	var body: some View {
		VStack() {
			GroupBox(label: Label("Survey", systemImage: "checklist")) {
				VStack {
					Form {
						TextField("UUID", text: $UUID)
							.autocorrectionDisabled(true)
							.keyboardType(.asciiCapable)
							.textInputAutocapitalization(.none)
					}
					HStack {
						Button("Show Dialog") {
							showDialog()
						}.padding(.leading)

						Spacer()

						Button("Show Bottom") {
							showBottom()
						}.padding(.trailing)
					}.buttonStyle(.bordered)
				}
			}

			GroupBox(label: Label("Embed", systemImage: "rectangle.on.rectangle.square")) {
				HStack {
					Button("Embed Dialog") {
						embedDialog()
					}.padding(.leading)

					Spacer()

					Button("Embed Bottom") {
						embedBottom()
					}.padding(.trailing)
				}.buttonStyle(.bordered)
			}

			GroupBox(label: Label("Event", systemImage: "calendar")) {
				VStack {
					Form {
						TextField("Name", text: $eventName)
							.autocorrectionDisabled(true)
							.keyboardType(.asciiCapable)
							.textInputAutocapitalization(.none)
						TextField("Value", text: $eventValue)
							.autocorrectionDisabled(true)
							.keyboardType(.asciiCapable)
							.textInputAutocapitalization(.none)
					}
					Button("Log Event") {
						logEvent()
					}
				}.buttonStyle(.bordered)
			}
		}
		.padding()
	}
}

#Preview {
    ContentView()
}
