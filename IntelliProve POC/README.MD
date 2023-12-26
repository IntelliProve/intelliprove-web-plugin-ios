# IntelliProve POC

## Compilation and Deployment

To build and deply this application: 

* Open the project in Xcode.
* In the Project Settings, go to "Signing & Capabilities" tab, and select an appropriate iOS Development Team.
* Attach a physical iOS Device associated with this Development Team and select it in the top bar.
* Build the "IntelliProve POC" Scheme to this device.

## POC premise and main takeaways

This POC serves as a preview application for correctly integrating a Web Application that needs to use the camera inline in a Native iOS Application.
For this POC, SwiftUI was chosen as the UI library. A `WKWebView` was wrapped in a SwiftUI `UIViewRepresentable`.
When using UIKit instead of SwiftUI, simply don't wrap the `WKWebView` and use it directly instead.
In this POC, a static URL to the Web Application was used, which includes an authentication token.
Sharing session from the native application with the WebView is possible in several different ways, but that is not part of this POC. 

When using the WKWebView directly, without adjusting any settings, the Camera integration in the Web Application will not work.


### Camera permissions

The first step that needs to be taken, is to add some keys to the Info.plist. Otherwise the iOS application will not ask for Camera permissions, *and* will not pass the AppStore certification process:

* `Privacy - Camera Usage Description` (NSCameraUsageDescription) - Provide a description here why the application needs to use the camera (will be shown to the user).
* `Privacy - Privacy - Microphone Usage Description` (NSMicrophoneUsageDescription) - Provide a description here why the application needs to use the microphone (will be shown to the user).

When this step is taken, the Camera permissions will be asked to the user as soon as the Web Application needs them.
Depending on the desired UX, these permissions could be asked before starting the Web Application by using the appropriate native API's.

At this point, the camera access will be granted, but it will be shown fullscreen instead of inline, breaking the desired usage of the Web App.


### Inline Camera Video

To get the camera feed to be displayed inline in the Web App, configuration must be set on the WKWebView:

```
let configuration = WKWebViewConfiguration()
configuration.mediaTypesRequiringUserActionForPlayback = []
configuration.allowsInlineMediaPlayback = true
```

* Setting `mediaTypesRequiringUserActionForPlayback` to an empty array ensures that the user does not have to press any button before the video is displayed.
* Setting `allowsInlineMediaPlayback` to `true` allows for inline media playback.

Make sure to create this `WKWebViewConfiguration` object *before* initializing the `WKWebView`, and then pass it to its initializer.
Otherwise an obscure WebKit bug will be triggered, and the `allowsInlineMediaPlayback` is ignored.


### Easy Debugging

To allow for easy debugging of the Web Application from a MacBook device, set the following on the `WKWebView`:

```
webView.isInspectable = true
```

* Then build the application to a device from within Xcode.
* Launch Safari on the MacBook.
* From the Safari Application Bar, there should be a `Develop` menu.
* This menu should display the list of attached devices, and then for those devices the debuggable Web Sessions.

This way it could be verified that other things (the attributes on the video tag, calling `getMediaTypes()` from JavaScript, ...) happened correctly.
