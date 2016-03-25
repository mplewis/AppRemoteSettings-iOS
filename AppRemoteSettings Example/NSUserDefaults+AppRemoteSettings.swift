import Foundation

extension NSUserDefaults {
    func registerDefaultsFromAppRemoteSettings(endpointAPIv1: NSURL, success: (remoteSettings: NSDictionary) -> Void) {
        
        var appId: String
        if let s = NSBundle.mainBundle().bundleIdentifier {
            appId = s
        } else {
            print("Couldn't fetch bundle identifier")
            return
        }

        let params = [
            "app_id": appId,
            "format": "plist"
        ]

        let request = NSMutableURLRequest(URL: endpointAPIv1)
        request.HTTPMethod = "POST"
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch _ {
            print("Couldn't serialize params as JSON")
            return
        }
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {rawData, rawResponse, error -> Void in
            if let e = error {
                print("Error fetching plist from AppRemoteSettings")
                print(e)
                return
            }
        
            guard let data = rawData else {
                print("Data was not present in response")
                return
            }

            guard let dataStr = String(data: data, encoding: NSUTF8StringEncoding) else {
                print("Couldn't parse data as UTF-8")
                return
            }
            
            print("Data received")
            print(dataStr)
            
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
                print("Plist was in a weird format")
                return
            }
            
            for key in remoteSettings.keys {
                self.setValue(remoteSettings[key], forKey: key)
            }
            self.synchronize()
            success(remoteSettings: remoteSettings)
        })
        
        task.resume()
    }
}
