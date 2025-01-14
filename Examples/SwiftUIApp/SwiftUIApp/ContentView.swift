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

	private var polling: Polling = Polling();

	class Listener: NSObject, PollingDelegate {
		var view: any View
		init(view: any View) {
			self.view = view
		}
		func polling(onSuccess response: String) {
			print("onSuccess")
		}
		func polling(onFailure error: String) {
			print("onFailure")
		}
		func polling(on reward: Polling.Reward) {
			print("onReward")
		}
		func pollingOnSurveyAvailable() {
			print("onSurveyAvailable")
		}
	}
	var listener: Listener?

	init() {
		listener = Listener(view: self)
		polling.delegate = listener
	}

    var body: some View {
		VStack {
			GroupBox(label: Label("Survey", systemImage: "checklist")) {
				VStack {
					Form {
						TextField("UUID", text: $UUID)
					}
					HStack {
						Button("Show Dialog") {

						}.padding(.leading)

						Spacer()

						Button("Show Bottom") {

						}.padding(.trailing)
					}.buttonStyle(.bordered)
				}
			}

			GroupBox(label: Label("Event", systemImage: "calendar")) {
				VStack {
					Form {
							TextField("Name", text: $eventName)
							TextField("Value", text: $eventValue)
					}
					Button("Log Event") {

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
