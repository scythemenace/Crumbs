import 'package:firebase_core/firebase_core.dart';
import 'auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


const Color textFieldColor = Color(0xFFF0F5FA);
const Color backgroundColor = Color(0xFF121223);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(EntryPage());
  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true,
  );
}

class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hungry App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserPageS(),
    );
  }
}

class UserPageS extends StatefulWidget {
  @override
  _UserPage createState() => _UserPage();
}

class _UserPage extends State<UserPageS> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          'Hello, ${FirebaseAuth.instance.currentUser!.email}!',
          style: GoogleFonts.sen(
            textStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: backgroundColor,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('restaurant')
              .doc('post')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              DocumentSnapshot restaurantData = snapshot.data!;
              List<String> postNames =
                  List<String>.from(restaurantData['postName']);
              List<String> postDescriptions =
                  List<String>.from(restaurantData['postDescription']);

              return Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                      postNames.length,
                      (index) => CustomCard(
                        title: postNames[index],
                        description: postDescriptions[index],
                      ),
                    ),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              print(snapshot.error); // Print the error for debugging
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String title;
  final String description;

  CustomCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.0),
                    Text(
                      description,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 120.0,
              height: 120.0,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Image.network(
                    "https://firebasestorage.googleapis.com/v0/b/crumbs-4db5b.appspot.com/o/restaurant_images%2F$title.jpg?alt=media&token=a2c9b3cb-97a5-4948-8682-a4ed3645b52f",
                    fit: BoxFit.cover,
                    width: 120.0,
                    height: 120.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





class RestaurantPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyStatefulPage(),
    );
  }
}

class MyStatefulPage extends StatefulWidget {
  @override
  _MyStatefulPageState createState() => _MyStatefulPageState();
}

class _MyStatefulPageState extends State<MyStatefulPage> {
  TextEditingController foodItemController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  void _showPostDialog() {
    TextEditingController imageController = TextEditingController();
    User? user = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Post Details', style: TextStyle(color: Colors.black)),
          content: Container(
            width: 300, // Adjust the width as needed
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRoundedTextField('Food Item', foodItemController),
                SizedBox(height: 10),
                _buildRoundedScrollableTextField(
                    'Short Description', descriptionController),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    // Add functionality to handle the post data here
                    String foodItem = foodItemController.text;
                    String description = descriptionController.text;

                    // Upload image to Firebase Storage
                    String imageUrl = await _uploadImage(
                        foodItem, imageController.text);

                    // Store post data in Firestore
                    if (user != null && user.uid != Null){
                      // Store the post data in Firestore
                      await _storePostData(foodItem, description, imageUrl);
                    }

                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('POST'),
                ),
              ],
            ),
          ),
          actions: [
            // Empty for now, you can add actions if needed
          ],
        );
      },
    );
  }

  Future<String> _uploadImage(String foodItem, String imageUrl) async {
  if (imageUrl.isNotEmpty) {
    // If the user provided an image URL, use it directly
    return imageUrl;
  } else {
    // If the user selected an image from the device, upload it to Firebase Storage
    File imageFile = await _pickImageFromGallery(); // Ensure it's a File type

    String imageName = '$foodItem.jpg'; // Adjust the image name as needed

    Reference storageReference =
        FirebaseStorage.instance.ref().child('restaurant_images/$imageName');

    try {
      await storageReference.putFile(imageFile);
      return await storageReference.getDownloadURL();
    } catch (error) {
      // Handle any errors that occur during the upload process
      print('Error uploading image: $error');
      return Future.error('Failed to upload image');
    }
  }
}

Future<File> _pickImageFromGallery() async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    return File(pickedFile.path);
  } else {
    // Handle if the user canceled image picking
    return Future.error('No image selected');
  }
}

  Future<void> _storePostData(String foodItem, String description, String imageUrl) async {
  CollectionReference restaurantCollection =
      FirebaseFirestore.instance.collection('restaurant');

  // Check if the document for the user already exists
  var userDoc = await restaurantCollection.doc("post").get();

  if (userDoc.exists) {
    // If the document exists, update the existing fields and add new ones
    await restaurantCollection.doc("post").update({
      'postName': FieldValue.arrayUnion([foodItem]),
      'postDescription': FieldValue.arrayUnion([description]),
    });
  } else {
    // If the document doesn't exist, create a new one
    await restaurantCollection.doc("post").set({
      'postName': [foodItem],
      'postDescription': [description],
    });
  }
}




Widget _buildRoundedTextField(String labelText, TextEditingController controller) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 20),
    margin: EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: textFieldColor, // Change color according to your design
      borderRadius: BorderRadius.circular(10),
    ),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: InputBorder.none,
        labelStyle: TextStyle(color: Colors.black),
      ),
      style: TextStyle(fontSize: 18, color: Colors.black),
    ),
  );
}


Widget _buildRoundedScrollableTextField(String labelText, TextEditingController controller) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 20),
    margin: EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: textFieldColor, // Change color according to your design
      borderRadius: BorderRadius.circular(10),
    ),
    child: SingleChildScrollView(
      child: TextField(
        controller: controller,
        maxLines: null, // Set maxLines to null for multiline input
        decoration: InputDecoration(
          labelText: labelText,
          border: InputBorder.none,
          labelStyle: TextStyle(color: Colors.black),
        ),
        style: TextStyle(fontSize: 18, color: Colors.black),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          'Hello, ${FirebaseAuth.instance.currentUser!.email}!',
          style: GoogleFonts.sen(
            textStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Go ahead post about the leftovers',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showPostDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                fixedSize: Size(320, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                'POST',
                style: GoogleFonts.sen(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Location extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {

  late String lat;
  late String long;
  late String locationMessage = "Current Location";
  bool locationAccessed = false;

  Future<void> _storeLocationInFirestore(double latitude, double longitude) async {
  try {
    // Get the current user from Firebase authentication
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && user.uid != Null) {
      // Use the user's UID to create a reference to the 'locations' collection in Firestore
      CollectionReference locationsRef = FirebaseFirestore.instance.collection('locations');

      // Check if the 'locations' collection already exists
      DocumentSnapshot locationsSnapshot = await locationsRef.doc(user.uid).get();

      if (locationsSnapshot.exists) {
        // 'locations' collection exists, check if user UID exists and update or create new data
        locationsRef.doc(user.uid).set({
          'latitude': latitude,
          'longitude': longitude,
        }, SetOptions(merge: true));
      } else {
        // 'locations' collection doesn't exist, create it and add data
        locationsRef.doc(user.uid).set({
          'latitude': latitude,
          'longitude': longitude,
        });
      }

      print('Location stored successfully for user with ID: ${user.uid}');
    } else {
      print('No user or UID is null.');
    }
  } catch (e) {
    print('Error storing location: $e');
  }
}

  Future<Position> _getCurrentLocation() async {
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
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
}

  StreamSubscription<Position>? _locationSubscription;

  void _livelocation() {

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    // Start a new stream
    _locationSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      lat = position.latitude.toString();
      long = position.longitude.toString();

      setState(() {
        locationMessage = "Latitude: $lat, Longitude: $long";
      });

    });
  }
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(
                Icons.location_on,
                size: 80,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 90),
            ElevatedButton(
              onPressed: () async {
                try {
                  Position position = await _getCurrentLocation();
                  setState(() {
                    lat = '${position.latitude}';
                    long = '${position.longitude}';
                    locationMessage = "Latitude: $lat, Longitude: $long";
                    locationAccessed = true;
                  });

                  await _storeLocationInFirestore(position.latitude, position.longitude);
                  _livelocation();
                  _locationSubscription?.cancel();
                } catch (e) {
                  print(e.toString());
                  // Handle errors if needed
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                fixedSize: Size(320, 60),
              ),
              child: Text(
                "ACCESS LOCATION",
                style: GoogleFonts.sen(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 50.0),
              child: Text(
                "Please hold steady, this will only take a while",
                style: GoogleFonts.sen(
                  textStyle: TextStyle(
                    color: Color(0xFFFBF6F6),
                    fontSize: 19.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            Text(
              locationMessage, // Added null check
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 30),
            Visibility(
              visible: locationAccessed,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    // ignore: unrelated_type_equality_checks
                    if (user != null && user.uid != Null) {
                      CollectionReference typeRef = FirebaseFirestore.instance.collection('type');
                      DocumentSnapshot typeSnapshot = await typeRef.doc(user.uid).get();
                      if (typeSnapshot.exists) {
                        String who = typeSnapshot['who'];
                        if (who == 'user') {
                          // ignore: use_build_context_synchronously
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UserPage()),
                          );
                        } else if (who == 'restaurant') {
                          // ignore: use_build_context_synchronously
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RestaurantPage()),
                          );
                        }
                      }
                    }

                  } catch (e) {
                    print(e.toString());
                    // Handle errors if needed
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Change the color as needed
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  fixedSize: Size(320, 60),
                ),
                child: Text(
                  "NEXT",
                  style: GoogleFonts.sen(
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





class MyApp extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyApp> {
  
  late String who;

  Future<void> _storeTypeInFirestore(String who) async {
    try {
      // Get the current user from Firebase authentication
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid != Null) {
        // Use the user's UID to create a reference to the 'locations' collection in Firestore
        CollectionReference typeRef = FirebaseFirestore.instance.collection('type');

        // Check if the 'locations' collection already exists
        DocumentSnapshot typeSnapshot = await typeRef.doc(user.uid).get();

        if (typeSnapshot.exists) {
          // 'locations' collection exists, check if user UID exists and update or create new data
          typeRef.doc(user.uid).set({
            'who': who,
          }, SetOptions(merge: true));
        } else {
          // 'locations' collection doesn't exist, create it and add data
          typeRef.doc(user.uid).set({
            'who': who,
          });
        }

        print('Type stored successfully for user with ID: ${user.uid}');
      } else {
        print('No user or UID is null.');
      }
    } catch (e) {
      print('Error storing Type: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context); // Navigate back to the EntryPage
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              Icon(
                Icons.arrow_back,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Are you a user or a restaurant?",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "No matter who you are, we would love to be of service to you",
                style: GoogleFonts.sen(textStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16.0,
                )),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 40.0),
            SizedBox(
              width: 300.0,
              height: 50.0,
              child: ElevatedButton(
                onPressed: () async {
                  who = "user";
                  try {
                    await _storeTypeInFirestore(who);
                    // ignore: use_build_context_synchronously
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Location()),
                    );
                  } catch (e) {
                    print('Error handling user button press: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  "USER",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            SizedBox(
              width: 300.0,
              height: 50.0,
              child: ElevatedButton(
                onPressed: () async {
                  who = "restaurant";
                  try {
                    await _storeTypeInFirestore(who);
                    // ignore: use_build_context_synchronously
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Location()),
                    );
                  } catch (e) {
                    print('Error handling restaurant button press: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  "RESTAURANT",
                  style: GoogleFonts.sen( textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class EntryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: EntryPageContent(),
        ),
      ),
    );
  }
}

class EntryPageContent extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _EntryPageContentState createState() => _EntryPageContentState();
}

class _EntryPageContentState extends State<EntryPageContent> {
  final Auth _auth = Auth();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _showBottomSheet(String action) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (action == 'Sign up') _buildTextField('Name', nameController),
                if (action == 'Sign up') SizedBox(height: 10),
                _buildTextField('Email', emailController),
                SizedBox(height: 10),
                _buildTextField('Password', passwordController, isPassword: true),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (action == 'Log in') {
                      // Get email and password from controllers
                      String email = emailController.text;
                      String password = passwordController.text;
                      // Handle login logic
                      await _auth.signInWithEmailAndPassword(email: email, password: password);
                    } else if (action == 'Sign up') {
                      // Get name, email, and password from controllers
                      String name = nameController.text;
                      String email = emailController.text;
                      String password = passwordController.text;
                      // Handle signup logic
                      await _auth.createUserWithEmailAndPassword(name: name, email: email, password: password);
                    }

                    // ignore: use_build_context_synchronously
                    Navigator.pop(context); // Close the bottom sheet
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyApp()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text(
                    action,
                    style: GoogleFonts.sen(
                      textStyle: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller, {bool isPassword = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: textFieldColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: labelText,
          border: InputBorder.none,
        ),
        style: TextStyle(fontSize: 18, color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/crumbs_logo.png', height: 170, width: 170),
        Image.asset('assets/Crumbs-logos_transparent.png', height: 140, width: 140),
        SizedBox(height: 20),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                _showBottomSheet('Log in');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: SizedBox(
                width: 200,
                child: Center(
                  child: Text(
                    'Log in',
                    style: GoogleFonts.sen(
                      textStyle: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _showBottomSheet('Sign up');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: SizedBox(
                width: 200,
                child: Center(
                  child: Text(
                    'Sign up',
                    style: GoogleFonts.sen(
                      textStyle: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
