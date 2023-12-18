import 'dart:async';
import 'dart:convert';
import 'model/MapProject.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Map Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Map Project'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Instansiasi variabel awal
  LocationData? currentLocation;
  Location location = Location();
  List<Marker> allMarkers = [];
  late FollowOnLocationUpdate _followOnLocationUpdate;
  String selectedCategory = '';
  String selectedFilterCategory = 'All';
  bool isLoading = true;
  bool isManualMarkerAdditionMode = false;
  var logger = Logger();
  double currentZoom = 13.0;
  late MapController mapController;
  String? tappedLatitude;
  String? tappedLongitude;

  void _zoomIn() {
    currentZoom = currentZoom + 0.3;
    mapController.move(
        LatLng(currentLocation!.latitude ?? 0.0,
            currentLocation!.longitude ?? 0.0),
        currentZoom);
  }

  void _zoomOut() {
    currentZoom = currentZoom - 0.3;
    mapController.move(
        LatLng(currentLocation!.latitude ?? 0.0,
            currentLocation!.longitude ?? 0.0),
        currentZoom);
  }

  Future<void> _fetchMarkersFromApi() async {
    try {
      const apiUrl = 'http://10.0.2.2/API/public/mapproject/72210456/';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        logger.d('jsonData : $jsonData');

        // Check if 'data' key exists and its value is a list
        if (jsonData.containsKey('data') && jsonData['data'] is List) {
          final List<dynamic> data = jsonData['data'];
          logger.d('dataN : $data');

          setState(() {
            allMarkers.clear(); // Clear existing markers

            for (final markerData in data) {
              try {
                final String lat = markerData['lat'].toString();
                final String lng = markerData['lng'].toString();
                final String nama = markerData['nama'];
                final String kategori = markerData['kategori'];
                final String keterangan = markerData['keterangan'];
                final String jamBuka = markerData['jamBuka'];
                final String jamTutup = markerData['jamTutup'];

                allMarkers.add(_createMarker(
                    double.parse(lat),
                    double.parse(lng),
                    nama,
                    kategori,
                    keterangan,
                    jamBuka,
                    jamTutup));
              } catch (e) {
                logger.d('Error processing marker data: $e');
              }
            }
          });
        } else {
          logger.d('Error: Unexpected response structure');
        }
      } else {
        logger.d('Error fetching markers: ${response.statusCode}');
      }
    } catch (e) {
      logger.d('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Marker _createMarker(double latitude, double longitude, String nama,
      String kategori, String keterangan, String jamBuka, String jamTutup) {
    IconData iconData;
    Color iconColor;

    // Map category to icon and color
    switch (kategori) {
      case 'Rumah Makan':
        iconData = Icons.restaurant;
        iconColor = Colors.red;
        break;
      case 'Hotel':
        iconData = Icons.hotel;
        iconColor = Colors.blue;
        break;
      case 'Things To do':
        iconData = Icons.directions;
        iconColor = Colors.green;
        break;
      case 'Kesehatan':
        iconData = Icons.local_hospital;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.place;
        iconColor = Colors.black;
    }

    return Marker(
      width: 100.0,
      height: 100.0,
      point: LatLng(latitude, longitude),
      child: IconButton(
        onPressed: () {
          _showLocationInfoDialog(
              latitude, longitude, nama, kategori, keterangan, jamBuka, jamTutup);
        },
        icon: Icon(iconData, color: iconColor),
      ),
    );
  }

  // Get Location Dari API
  Future<void> _getLocation() async {
    try {
      currentLocation = await location.getLocation();
      setState(() {
        _fetchMarkersFromApi();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error getting location: $e');
      }
    }
  }

  // Menambah Data
  void _toggleManualMarkerAdditionMode() {
    setState(() {
      isManualMarkerAdditionMode = !isManualMarkerAdditionMode;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isManualMarkerAdditionMode
            ? "Tap on the map to add a marker."
            : "Manual marker addition mode disabled."),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addMarker(LatLng tappedPoint) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        PlaceData newPlace = PlaceData(
          nama: "",
          kategori: "Rumah Makan",
          keterangan: "",
          lat: tappedPoint.latitude,
          lng: tappedPoint.longitude,
          jamBuka: "",
          jamTutup: "",
        );

        return AlertDialog(
          title: Text("Tambah Data Lokasi"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: "Nama"),
                  onChanged: (value) {
                    newPlace.nama = value;
                  },
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 0, top: 30),
                  child: Text(
                    "Pilih Kategori Tempat:",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: newPlace.kategori,
                  items: <String>[
                    'Rumah Makan',
                    'Hotel',
                    'Things To do',
                    'Kesehatan',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      newPlace.kategori = value!;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Keterangan"),
                  onChanged: (value) {
                    newPlace.keterangan = value;
                  },
                ),
                InkWell(
                  onTap: () async {
                    TimeOfDay? selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (selectedTime != null) {
                      newPlace.jamBuka =
                          "${selectedTime.hour}:${selectedTime.minute}";
                      setState(() {});
                    }
                  },
                  child: IgnorePointer(
                    child: TextField(
                      controller: TextEditingController(text: newPlace.jamBuka),
                      decoration: InputDecoration(
                        labelText: "Jam Buka",
                      ),
                    ),
                  ),
                ),

                // Replace the TextField for "Jam Tutup" with a showTimePicker
                InkWell(
                  onTap: () async {
                    TimeOfDay? selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (selectedTime != null) {
                      newPlace.jamTutup =
                          "${selectedTime.hour}:${selectedTime.minute}";
                      setState(() {});
                    }
                  },
                  child: IgnorePointer(
                    child: TextField(
                      controller:
                          TextEditingController(text: newPlace.jamTutup),
                      decoration: InputDecoration(
                        labelText: "Jam Tutup",
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  setState(() {
                    allMarkers.add(_createMarker(
                      tappedPoint.latitude,
                      tappedPoint.longitude,
                      newPlace.nama,
                      newPlace.kategori,
                      newPlace.keterangan,
                      newPlace.jamBuka,
                      newPlace.jamTutup,
                    ));
                  });

                  await _sendDataToApi(newPlace);
                  await _fetchMarkersFromApi();

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Data Map Berhasil Ditambahkan"),
                      duration: Duration(seconds: 3),
                    ),
                  );
                } catch (e) {
                  print('Error adding marker: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error adding marker: $e"),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  // Menampilkan Informasi Lebih Lanjut
  void _showLocationInfoDialog(double latitude, double longitude, String nama,
      String kategori, String keterangan, String jamBuka, String jamTutup) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(nama),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Latitude'),
                        Text('Longitude'),
                        Text('Kategori'),
                        Text('Jam Buka'),
                        Text('Jam Tutup'),
                        Text('Keterangan'),
                      ],
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(': $latitude'),
                          Text(': $longitude'),
                          Text(': $kategori'),
                          Text(': $jamBuka'),
                          Text(': $jamTutup'),
                          Text(': $keterangan'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("OK"),
            ),
          ],
        );

      },
    );
  }

  void _moveToCurrentLocation() {}

  // Filter data berdasarkan kategori
  Future<void> _filterMarkers(String category) async {
    try {
      setState(() {
        isLoading = true; // Set loading state to true while fetching data
      });

      String apiUrl = '';

      if (category == 'All') {
        apiUrl = 'http://10.0.2.2/API/public/mapproject/72210456/';
      } else {
        apiUrl = 'http://10.0.2.2/API/public/mapproject/72210456/$category';
      }

      logger.d(apiUrl);
      // Fetch data from the API
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        logger.d('jsonData : $jsonData');

        // Declare data outside the if block
        dynamic data;

        // Check if 'data' key exists
        if (jsonData.containsKey('data')) {
          final dynamic responseData = jsonData['data'];

          if (responseData is List) {
            data = responseData;
          } else if (category != 'All' && responseData is Map) {
            data = [responseData];
          } else {
            logger.d('Error: Unexpected response structure - ${response.body}');
            allMarkers.clear();
            return; // Exit early if the response structure is unexpected
          }
        } else {
          logger.d('Error: No "data" key in the response - ${response.body}');
          allMarkers.clear();
          return; // Exit early if there is no "data" key in the response
        }

        setState(() {
          allMarkers.clear(); // Clear existing markers

          for (final markerData in data) {
            try {
              final String lat = markerData['lat'].toString();
              final String lng = markerData['lng'].toString();
              final String nama = markerData['nama'];
              final String kategori = markerData['kategori'];
              final String keterangan = markerData['keterangan'];
              final String jamBuka = markerData['jamBuka'];
              final String jamTutup = markerData['jamTutup'];

              allMarkers.add(_createMarker(double.parse(lat), double.parse(lng),
                  nama, kategori, keterangan, jamBuka, jamTutup));
            } catch (e) {
              logger.d('Error processing marker data: $e');
            }
          }
        });
      } else {
        print('Error fetching markers: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false; // Set loading state to false after processing
      });
    }
  }

  // Mengirimkan data ke API
  Future<void> _sendDataToApi(PlaceData placeData) async {
    const apiUrl =
        'http://10.0.2.2/API/public/mapproject/72210456/'; // Replace with your API endpoint
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'nama': placeData.nama,
        'kategori': placeData.kategori,
        'keterangan': placeData.keterangan,
        'lat': placeData.lat.toString(),
        'lng': placeData.lng.toString(),
        'jamBuka': placeData.jamBuka,
        'jamTutup': placeData.jamTutup,
      },
    );

    if (response.statusCode == 200) {
      // Successfully added to the API
      print('Data sent to API successfully');
    } else {
      // Handle error
      print('Error sending data to API: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _followOnLocationUpdate = FollowOnLocationUpdate.once;
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (currentLocation != null)
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                onTap: (tapPosition, tapLatlng) {
                  if (isManualMarkerAdditionMode) {
                    _addMarker(tapLatlng);
                  } else {
                    setState(() {
                      tappedLatitude = tapLatlng.latitude.toStringAsFixed(6);
                      tappedLongitude = tapLatlng.longitude.toStringAsFixed(6);
                    });
                  }
                },
                initialCenter: LatLng(
                  currentLocation!.latitude ?? 0.0,
                  currentLocation!.longitude ?? 0.0,
                ),
                initialZoom: currentZoom,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  tileSize: 256,
                ),
                CurrentLocationLayer(
                  followOnLocationUpdate: _followOnLocationUpdate,
                ),
                MarkerLayer(markers: allMarkers),
              ],
            ),
          Positioned(
            top: 30,
            left: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white, // Set your desired background color
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedFilterCategory,
                      items: <String>[
                        'All',
                        'Rumah Makan',
                        'Hotel',
                        'Things To do',
                        'Kesehatan'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        logger.d(
                            'Before _filterMarkers: $selectedFilterCategory');
                        setState(() {
                          selectedFilterCategory = value!;
                          // _filterMarkers(selectedFilterCategory);
                        });
                        logger
                            .d('After _filterMarkers: $selectedFilterCategory');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    onPressed: () {
                      // Implement filtering logic here based on selectedFilterCategory
                      _filterMarkers(selectedFilterCategory);
                    },
                    child: const Text('Filter'),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 18,
            left: 16,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Latitude'),
                          Text('Longitude'),
                        ],
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (tappedLatitude != null)
                            Text(': $tappedLatitude')
                          else
                            const Text(': - '),
                          if (tappedLongitude != null)
                            Text(': $tappedLongitude')
                          else
                            const Text(': - '),
                        ],
                      ),
                    ],
                  ),
                  // Add other widgets as needed
                ],
              ),
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _toggleManualMarkerAdditionMode,
            child: Icon(
              isManualMarkerAdditionMode
                  ? Icons.location_off_rounded
                  : Icons.add_location,
            ),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _zoomIn, // Panggil fungsi _zoomIn saat tombol ditekan
            child: Icon(Icons.zoom_in),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _zoomOut, // Panggil fungsi _zoomOut saat tombol ditekan
            child: Icon(Icons.zoom_out),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _followOnLocationUpdate = FollowOnLocationUpdate.always;
              });

              // Introducing a delay
              Future.delayed(Duration(seconds: 1), () {
                setState(() {
                  _followOnLocationUpdate = FollowOnLocationUpdate.never;
                });
              });
            },
            child: Icon(Icons.gps_fixed),
          ),
        ],
      ),
    );
  }
}
