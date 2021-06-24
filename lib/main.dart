import 'dart:io';
import 'package:activity_recognition_flutter/activity_recognition_flutter.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as locatie;
import 'package:latlong/latlong.dart';

double pastLatitude = 0;
double pastLongitude = 0;
DateTime pastTime = new DateTime(1989, DateTime.november, 9);
String pastAction = '';

double distanceON_FOOT = 0.0;
double distanceON_BICYCLE = 0.0;
double distanceON_TRAIN = 0.0;
double distanceON_BUS = 0.0;
bool ON_TRAIN = false;
bool ON_BUS = false;



void getLocation(action, time) async {

  print('locatia trecuta: ' + pastLongitude.toString() + " " + pastLatitude.toString());
  print('momentul de timp trecut: ' + pastTime.toString());
  print('tipul de actiune trecut: ' + action);

  locatie.LocationData _locationData;
  locatie.Location location = new locatie.Location();
  _locationData = await location.getLocation();

  print('locatia curenta: ' + _locationData.toString());

  final Distance distance = new Distance();

  final double meter = distance(
      new LatLng(_locationData.latitude,_locationData.longitude),
      new LatLng(pastLatitude,pastLongitude)
  );


  print("Distanta: " + meter.toString());
  if(pastLongitude == 0.0 && pastLatitude == 0.0)
  {

  }
  else
  {
    if (action == "ON_FOOT" || action == "RUNNING" || action == "WALKING")
      {
        distanceON_FOOT += meter;

        if(meter/time.difference(pastTime).inSeconds > 5.5) // 5.5 m/s == 20 km/h
          {
            bool ON_TRAIN = false;
            bool ON_BUS = false;
          }
      }

    if (action == "ON_BICYCLE")
        distanceON_BICYCLE += meter;

    if (action == "IN_VEHICLE")
    {
      if(ON_TRAIN == true)
        distanceON_TRAIN += meter;
      if(ON_BUS == true)
        distanceON_BUS += meter;
    }
  }


  pastLongitude = _locationData.longitude;
  pastLatitude = _locationData.latitude;
  pastTime = time;
  pastAction = action;

}

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Stream<ActivityEvent> activityStream;
  ActivityEvent latestActivity = ActivityEvent.empty();
  ActivityEvent secondToLastActivity = ActivityEvent.empty();
  List<ActivityEvent> _events = [];
  ActivityRecognition activityRecognition = ActivityRecognition.instance;

  locatie.Location location = new locatie.Location();

  bool _serviceEnabled;
  locatie.PermissionStatus _permissionGranted;
  locatie.LocationData _locationData;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {


    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == locatie.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != locatie.PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();


    /// Android requires explicitly asking permission
    if (Platform.isAndroid) {
      if (await Permission.activityRecognition.request().isGranted) {
        _startTracking();
      }
    }

    /// iOS does not
    else {
      _startTracking();
    }
  }

  void _startTracking() {
    activityStream =
        activityRecognition.startStream(runForegroundService: true);
    activityStream.listen(onData);
  }

  void onData(ActivityEvent activityEvent) {
    print(activityEvent.toString());
    setState(() {
      _events.add(activityEvent);
      if(_events.length > 2)
        {
          secondToLastActivity = latestActivity;
        }
      else
        {
          secondToLastActivity = activityEvent;
        }
      latestActivity = activityEvent;

      if(secondToLastActivity.type.toString().split('.').last == 'ON_BICYCLE')
        {
          getLocation('ON_BICYCLE', latestActivity.timeStamp.toString().substring(0, 19));
        }

      if(secondToLastActivity.type.toString().split('.').last == 'ON_FOOT')
        {
          getLocation('ON_FOOT', latestActivity.timeStamp.toString().substring(0, 19));
        }
      if(secondToLastActivity.type.toString().split('.').last == 'RUNNING')
        {
          getLocation('RUNNING', latestActivity.timeStamp.toString().substring(0, 19));
        }
      if(secondToLastActivity.type.toString().split('.').last == 'WALKING')
        {
          getLocation('WALKING', latestActivity.timeStamp.toString().substring(0, 19));
        }

      if(secondToLastActivity.type.toString().split('.').last == 'IN_VEHICLE')
      {
        getLocation('IN_VEHICLE', latestActivity.timeStamp.toString().substring(0, 19));
      }


    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Activity Recognition Demo'),
        ),
        body: Column(
          children: [
            Text(
              'Distanta mers pe jos sau fugit: ' + distanceON_FOOT.toString(),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
                'Distanta pe bicicleta: ' + distanceON_BICYCLE.toString(),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Distanta pe autobuz: ' + distanceON_BUS.toString(),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Distanta pe tren: ' + distanceON_TRAIN.toString(),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Center(
              child: Row(
                children: [
                  Text(
                    'Autobuz: ' + ON_BUS.toString(),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    onPressed: () {setState(() => ON_BUS = !ON_BUS);},
                    child: Text('Activare/dezactivare tren'),
                  )
                ],
              ),
            ),
            Center(
              child: Row(
                children: [
                  Text(
                    'Tren: ' + ON_TRAIN.toString(),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    onPressed: () {setState(() => ON_TRAIN = !ON_TRAIN);},
                    child: Text('Activare/dezactivare tren'),
                  )
                ],
              ),
            ),
            Center(
              child: Container(
                child: new Center(
                    child: new ListView.builder(
                        itemCount: _events.length,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        reverse: false,
                        itemBuilder: (BuildContext context, int idx) {
                          final entry = _events[idx];
                          return ListTile(
                              leading:
                              Text(entry.timeStamp.toString().substring(0, 19)),
                              trailing: Text(entry.type.toString().split('.').last));
                        })),
              ),
            ),
          ],
        )
      ),
    );
  }
}
