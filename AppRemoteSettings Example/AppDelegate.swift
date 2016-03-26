import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // This is the demo instance of AppRemoteSettings. Point this URL to your own server.
    let appRemoteSettingsURL = "https://appremotesettings.herokuapp.com/api/v1/"

    // Set your variables here during offline development
    let fallbacks = [
        "ENABLE_RETRO_ENCABULATOR": false,
        "ENCABULATOR_MODE": "conservative",
        "PANAMETRIC_FAN_RPM": 4200
    ]

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // 1. Launch your app
        //
        // The first time this app is launched, settings will all be unset.
        //
        print("App launched")
        printSettings()

        // 2. Register your default settings
        //
        // This is where you should put your variables during offline development. Later, when your app is published in
        // the App Store, you can update these variables on your users' devices by changing their values in
        // AppRemoteSettings.
        //
        // registerDefaults MUST be called to set defaults on every program launch. These values are not persisted.
        // NSUserDefaults only falls back to these when no value exists for a given key.
        //
        NSUserDefaults.standardUserDefaults().registerDefaults(fallbacks)
        print("Saved offline defaults")
        printSettings()
        
        // 3. Update your local settings from AppRemoteSettings
        //
        // After defaults are set, fetch settings from AppRemoteSettings and apply them to the NSUserDefaults,
        // overwriting any keys that may already exist.
        //
        let endpoint = NSURL(string: appRemoteSettingsURL)!
        let start = NSDate()
        NSUserDefaults.standardUserDefaults().updateWithAppRemoteSettings(endpoint) { (remoteSettings) in
            
            // At this point, your app's settings are now updated from the server. Values may or may not have changed.
            print("Fetched remote app settings in \(NSDate().timeIntervalSinceDate(start)) sec")
            self.printSettings()
        }
        
        // 4. You're done!
        //
        // When you develop your app, use the values from NSUserDefaults.standardUserDefaults() instead of hardcoding
        // your variables. Any values you read from there can be changed in the field using AppRemoteSettings.
        
        return true
    }
    
    /**
     Helper method to print a representation of local settings. This helps us see what is happening in
     NSUserDefaults.standardUserDefaults().
     */
    func printSettings() {
        print("")
        print("NSUserDefaults.standardUserDefaults():")
        let settings = NSUserDefaults.standardUserDefaults()
        for key in fallbacks.keys {
            if let val = settings.valueForKey(key) {
                print("    \(key): \(val)")
            } else {
                print("    \(key): (unset)")
            }
        }
        print("")
    }

}
