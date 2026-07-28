import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class PhotoForm extends StatefulWidget {
  const PhotoForm({super.key});

  @override
  State<PhotoForm> createState() => _PhotoFormState();
}

class _PhotoFormState extends State<PhotoForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _image;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late Future<Position> _futurePosition;
  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _futurePosition = _determinePosition();
  }

  void _getImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
      );

      if (pickedFile == null) {
        debugPrint('Camera returned no image.');
        return;
      }

      debugPrint('Selected image: ${pickedFile.path}');

      if (!mounted) return;

      setState(() {
        _image = File(pickedFile.path);
      });
    } on PlatformException catch (error, stackTrace) {
      debugPrint('Image picker platform error: $error');
      debugPrintStack(stackTrace: stackTrace);
    } catch (error, stackTrace) {
      debugPrint('Image picker error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo Form')),
      body: Center(
        child: Form(key: _formKey, child: _buildForm()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImage,
        tooltip: "Pick Image",
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Processing Data')));
      if (_image != null) {
        try {
          Position position = await _futurePosition;
          Uuid uuid = Uuid();
          String uuidString = uuid.v4();
          if (kDebugMode) {
            print(uuidString);
          }
          String downloadUrl = await uploadFile(uuidString);
          await addItem(downloadUrl, position);
          //navigate back
          Navigator.pop(context);
        } catch (e) {
          if (kDebugMode) {
            print('Error: $e');
          }
        }
      } else {
        if (kDebugMode) {
          print("No Image Selected.");
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please take a photo first')),
        );
      }
    }
  }

  Future<String> uploadFile(String uuidString) async {
    Reference ref = FirebaseStorage.instance.ref().child(
      'photos/$uuidString.jpg',
    );
    final SettableMetadata metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: <String, String>{'file': "image"},
      contentLanguage: "en",
    );
    UploadTask uploadTask = ref.putFile(_image!, metadata);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadURL = await taskSnapshot.ref.getDownloadURL();
    if (kDebugMode) {
      print('File uploaded to $downloadURL');
    }
    return downloadURL;
  }

  Future<void> addItem(String downloadURL, Position position) async {
    CollectionReference photos = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'summer26',
    ).collection("photos");
    Map<String, dynamic> document = {
      "title": _titleController.text,
      "description": _descriptionController.text,
      "imageURL": downloadURL,
      "location": GeoPoint(position.latitude, position.longitude),
      "user": FirebaseAuth.instance.currentUser!.uid,
      "timestamp": FieldValue.serverTimestamp(),
    };
    await photos.add(document);
  }

  Widget _buildForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: "Title"),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(labelText: "Description"),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
        SizedBox(
          height: 200,
          width: 200,
          child: _image != null
              ? Image.file(_image!)
              : Image.network(
                  "https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png",
                ),
        ),
        FutureBuilder(
          future: _futurePosition,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
                'Latitude: ${snapshot.data!.latitude}, Longitude: ${snapshot.data!.longitude}',
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return const CircularProgressIndicator();
          },
        ),
        Text(FirebaseAuth.instance.currentUser!.uid),
        ElevatedButton(onPressed: _submitForm, child: const Text("Submit")),
      ],
    );
  }
}
