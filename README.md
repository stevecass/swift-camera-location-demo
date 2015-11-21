## A simple app to allow for uploading a picture to an http server, along with location data.
Uses LocationServices to get the device lat/lng and uploads this along with the picture, constructing an multipart/form-data along the way. Much fun and games.

## Gotchas

LocationServices allows for registering a CLLocationManagerDelegate, whose functions are optional. However in some cases it seems necessary to implement at least the following two functions:

```
func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]);
func locationManager(manager: CLLocationManager, didFailWithError error: NSError);
```

It appears that calling the single-use clLocationManager.requestLocation() will cause an error unless the delegate is set and implements at least the two methods above. You'll get `Assertion failure in -[CLLocationManager requestLocation]`

If you call clLocationManager.startUpdatingLocation() instead, it seems that the locationManager may get location updates even without a delegate - at least clLocationManager.location seems to show a reasonable value. This seems odd, so I'm probably misunderstanding something. Callling startUpdatingLocation without a delegate does not seem to cause a crash though.

Location Services won't work unless one, other or both of these keys is set in Info.plist.

```
<key>NSLocationWhenInUseUsageDescription</key>
<string>Your message goes here</string>
```
and/or
```
<key>NSLocationAlwaysUsageDescription</key>
<string>Your message goes here</string>
```

Whereas calling currentLocation without a delegate causes an assertion failure, failing to set the info.plist keys seems to result only in a silent failure - the location property on the manager stays nil.
