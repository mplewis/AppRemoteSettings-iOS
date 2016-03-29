import Foundation

extension NSUserDefaults {

    /**
     Updates the values in this NSUserDefaults instance with the values from an AppRemoteSettings server. Any existing
     keys that collide with keys in the AppRemoteSettings data will be replaced with the values from AppRemoteSettings.
     
     This method should be called as soon as possible in app execution so your settings are up-to-date quickly.
     You should probably call it in application:didFinishLaunchingWithOptions:.
     
     This method will never block or throw an exception.
     
     - parameter endpointAPIv1: The NSURL to the AppRemoteSettings API v1 endpoint
     - parameter success:       Completion handler fired when remote settings are successfully retrieved. Called with
                                the settings values received from AppRemoteSettings.
     */
    func updateWithAppRemoteSettings(endpointAPIv1: NSURL, success: (remoteSettings: NSDictionary) -> ()) {

        // Contact AppRemoteSettings with the app bundle ID so it knows which app we're fetching keys for
        // We will be parsing a plist format response using NSPropertyListSerialization
        let bundle = NSBundle.mainBundle()
        let params = [
            "app_id": bundle.bundleIdentifier!,
            "build_number": bundle.objectForInfoDictionaryKey("CFBundleVersion") as! String,
            "app_version": bundle.objectForInfoDictionaryKey("CFBundleShortVersionString") as! String,
            "os_version": NSProcessInfo.processInfo().operatingSystemVersionString,
            "hardware": systemInfoMachine(),
            "format": "plist"
        ]

        // AppRemoteSettings v1 API supports POST requests only
        let request = NSMutableURLRequest(URL: endpointAPIv1)
        request.HTTPMethod = "POST"
        
        // AppRemoteSettings v1 API takes POST data as JSON
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch _ {
            print("Couldn't serialize params as JSON")
            return
        }
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {rawData, rawResponse, error -> Void in
            if let e = error {
                print("Error during NSURLSessionDataTask")
                print(e)
                return
            }
        
            guard let data = rawData else {
                print("Data was not present in response")
                return
            }
            
            guard let response = rawResponse as? NSHTTPURLResponse else {
                print("Response was not HTTP")
                return
            }

            if response.statusCode != 200 {
                print("Non-200 status code returned: \(response.statusCode)")
                return
            }
            
            var plist: NSDictionary?
            do {
                plist = try NSPropertyListSerialization.propertyListWithData(data, options: [], format: nil) as? NSDictionary
            } catch _ {
                print("Couldn't parse plist data into dictionary")
                return
            }
            
            guard let remoteSettings = plist as? [String : AnyObject] else {
                print("Plist was parsed into an unexpected dictionary format")
                return
            }
            
            // Set new values or update existing ones
            for key in remoteSettings.keys {
                self.setValue(remoteSettings[key], forKey: key)
            }
            // Save values to disk
            self.synchronize()

            // We're done! Call the completion handler.
            success(remoteSettings: remoteSettings)
        })
        
        // Start the HTTP POST request
        task.resume()
    }

}

/**
 Read the iOS systeminfo.machine variable. <a href="http://stackoverflow.com/a/26962452/254187">Source</a>
 - returns: the value of systemInfo.machine as a String, e.g. "iPhone8,2"
 */
private func systemInfoMachine() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8 where value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
    return identifier
}
