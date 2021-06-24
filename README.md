# Flutter app for Android and iOS for activity recognition, transition, location, distance calculation with bus and train support(beta).

`activity_recognition_flutter 4.0.3`

Each detected activity will have an activity type, which is one of the following:

- IN_VEHICLE
- ON_BICYCLE
- ON_FOOT
- RUNNING
- STILL
- TILTING
- UNKNOWN
- WALKING
- INVALID (used for parsing errors)

As well as a confidence expressed in percentages (i.e. a value from 0-100).

`location 4.3.0`

**getLocation()**
Allow to get a one time position of the user. It will try to request permission if not granted yet and will throw a PERMISSION_DENIED error code if permission still not granted.

`latlong 0.6.1`

LatLong provides a lightweight library for common latitude and longitude calculation. 
This library supports both, the "Haversine" and the "Vincenty" algorithm.
"Haversine" is a bit faster but "Vincenty" is far more accurate!




