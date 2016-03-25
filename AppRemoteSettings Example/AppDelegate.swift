import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let settings = NSUserDefaults.standardUserDefaults()

    let appRemoteSettingsURL = "http://localhost:8000/api/v1/"
    let fallbacks = [
        "ENABLE_RETRO_ENCABULATOR": false,
        "ENCABULATOR_MODE": "conservative",
        "PANAMETRIC_FAN_RPM": 4200
    ]

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // 1. Launch your app
        //
        // The first time this app is launched, settings will all be unset. After fetchRemoteSettings fires, these
        // settings will always be set to the values from AppRemoteSettings.
        //
        print("App launched")
        printSettings()

        // 2. Register your offline defaults
        //
        // registerDefaults has to be called to set defaults on every program launch.
        // These values are not persisted. They are only used when NSUserDefaults doesn't have a value for a key.
        //
        settings.registerDefaults(fallbacks)
        print("Saved first launch fallbacks")
        printSettings()
        
        // 3. Update your local settings from AppRemoteSettings
        //
        // After defaults are set, fetch settings from AppRemoteSettings and apply them to the NSUserDefaults,
        // overwriting any keys that may already exist.
        //
        let endpoint = NSURL(string: appRemoteSettingsURL)!
        let start = NSDate()
        settings.updateWithAppRemoteSettings(endpoint) { (remoteSettings) in
            
            // At this point, your app's settings are now updated from the server. Values may or may not have changed.
            print("Fetched remote app settings in \(NSDate().timeIntervalSinceDate(start)) sec")
            self.printSettings()
        }
        
        return true
    }
    
    func printSettings() {
        print("")
        print("NSUserDefaults.standardUserDefaults():")
        for key in fallbacks.keys {
            guard let val = settings.valueForKey(key) else {
                print("    \(key): (unset)")
                continue
            }
            print("    \(key): \(val)")
        }
        print("")
    }

}
