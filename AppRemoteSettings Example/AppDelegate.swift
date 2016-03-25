import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var settings: NSUserDefaults?
    var fallbacks = [
        "ENABLE_RETRO_ENCABULATOR": false,
        "ENCABULATOR_MODE": "conservative",
        "DEFAULT_FELINE_LIVES": 7
    ]

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        settings = NSUserDefaults.standardUserDefaults()
        clearSettings()
        setOfflineFallbacks()
        fetchRemoteSettings()
        return true
    }

    func clearSettings() {
        guard let keys = settings?.dictionaryRepresentation().keys else {
            print("Settings isn't ready")
            return
        }
        
        for key in keys {
            settings?.removeObjectForKey(key)
        }
        settings?.synchronize()
        
        print("Cleared settings")
        printSettings()
    }
    
    func setOfflineFallbacks() {
        settings?.registerDefaults(fallbacks)
        settings?.synchronize()
        print("Saved offline fallbacks")
        printSettings()
    }
    
    func fetchRemoteSettings() {
        guard let endpoint = NSURL(string: "http://localhost:8000/api/v1/") else {
            print("Couldn't construct NSURL")
            return
        }
        
        let start = NSDate()
        settings?.registerDefaultsFromAppRemoteSettings(endpoint) { (remoteSettings) -> Void in
            print("Saved remote app settings in \(NSDate().timeIntervalSinceDate(start)) sec")
            self.printSettings()
        }
    }
    
    func printSettings() {
        guard let s = settings else {
            print("Couldn't print settings")
            return
        }
        
        print("")
        print("Settings:")
        for key in fallbacks.keys {
            guard let val = s.valueForKey(key) else {
                print("    \(key): (unset)")
                continue
            }
            print("    \(key): \(val)")
        }
        print("")
    }

}
