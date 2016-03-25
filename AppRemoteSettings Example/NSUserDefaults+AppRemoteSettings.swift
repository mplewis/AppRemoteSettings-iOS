import Foundation

extension NSUserDefaults {

    /**
     Updates the values in this NSUserDefaults instance with the values from an AppRemoteSettings server. Any existing
     keys that collide with keys in the AppRemoteSettings data will be replaced with the values from AppRemoteSettings.
     
     - parameter endpointAPIv1: The NSURL to the AppRemoteSettings API v1 endpoint
     - parameter success:       Completion handler fired when remote settings are successfully retrieved. Called with
                                the settings values received from AppRemoteSettings.
     */
    func updateWithAppRemoteSettings(endpointAPIv1: NSURL, success: (remoteSettings: NSDictionary) -> ()) {

        // Contact AppRemoteSettings with the app bundle ID so it knows which app we're fetching keys for
        // We will be parsing a plist format response using NSPropertyListSerialization
        let params = [
            "app_id": NSBundle.mainBundle().bundleIdentifier!,
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
                print("Couldn't parse data as plist")
                return
            }
            
            guard let remoteSettings = plist as? [String : AnyObject] else {
                print("Plist was parsed into an unexpected format")
                return
            }
            
            // Set new values or update existing ones
            for key in remoteSettings.keys {
                self.setValue(remoteSettings[key], forKey: key)
            }
            self.synchronize()
            success(remoteSettings: remoteSettings)
        })
        
        task.resume()
    }

}
