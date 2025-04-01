# Getting Started

Read this first.

## Overview

Before you begin you should sign up on [](Polling.com). Once you have
an account you can create and embed and obtain an API key. You then
add the SDK to a project and finaly use the SDK's API to load and
display surveys.

### API Key and Customer ID

You may obtain an API key from Polling.com dashboard (you will need an
account). An API key links your integration to an embed.

You can sign up for free on our website. No credit card is required to
get started. Our free plan includes unlimited surveys and responses!

You will also need to provide a Customer ID (your customer), which is
your unique identifier for the user on your application, we'll use
this to link your customers to surveys and events within the
[](Polling.com) ecosystem.

### Add the SDK to a Project

We support the Swift Package Manager, CocoaPods, and manual SDK
integration. If your existing projects is using the Swift Package
Manger or CocoaPods we recommend using that package manager for adding
the Polling SDK to your project. If you just want to try the SDK in a
throw away project manual integration is a great option. Refer to one
of the following articles for detailed instructions

- <doc:UsingSwiftPM>
- <doc:UsingCocoaPods>
- <doc:ManuallyAddSDK>

### Use the SDK's API in a Project

Using the SDK's API is simple and requires adding just a few lines of
code to a project.

You must import the Polling SDK before using the API, then you
configure the SDK singleton, followed by logging events or using a
method to show a survey or an embed. That's it in a nutshell.

See the Swift UI or UIKit tutorials for detailed step-by-step
instructions

- <doc:tutorials/SwiftUIToC>
- <doc:tutorials/UIKitToC>
