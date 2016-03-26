# AppRemoteSettings: iOS + Swift Client

Update variables in your production iOS apps, live. Skip the lengthy App Store review process.

For use with the [AppRemoteSettings server](https://github.com/mplewis/AppRemoteSettings).

# Installation

Add [NSUserDefaults+AppRemoteSettings.swift](AppRemoteSettings%20Example/NSUserDefaults%2BAppRemoteSettings.swift) to your project.

I'm not interested in maintaining a CocoaPods project at this time.

# Usage

1. [Register your default settings](AppRemoteSettings%20Example/AppDelegate.swift#L27-L35) in your AppDelegate
2. [Call `NSUserDefaults.standardUserDefaults().updateWithAppRemoteSettings(...)`](AppRemoteSettings%20Example/AppDelegate.swift#L40-L44) in your AppDelegate
3. Replace your hardcoded variables with values from `NSUserDefaults.standardUserDefaults()`
4. Change values in the AppRemoteSettings Dashboard to update them in your production apps.

# Contributions

Bug reports, fixes, or features? Feel free to open an issue or pull request any time. You can also email me at [matt@mplewis.com](mailto:matt@mplewis.com).

# License

MIT
