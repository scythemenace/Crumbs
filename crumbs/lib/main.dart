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
                      (index) => Padding(
                        padding: const EdgeInsets.all(24.0), // Adjust padding as needed
                        child: CustomCard(
                          title: postNames[index],
                          description: postDescriptions[index],
                        ),
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

  const CustomCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Container(
        width: 150, // Adjust as needed
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: Image.network(
                "https://firebasestorage.googleapis.com/v0/b/crumbs-4db5b.appspot.com/o/restaurant_images%2F$title.jpg?alt=media&token=a2c9b3cb-97a5-4948-8682-a4ed3645b52f",
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            // Add spacing between image and title
            SizedBox(height: 12.0), // Adjust as needed
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
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
  // ignore: library_private_types_in_public_api
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
            width: 300,
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
                    String foodItem = foodItemController.text;
                    String description = descriptionController.text;

                    String imageUrl = await _uploadImage(
                        foodItem, imageController.text);

                    if (user != null && user.uid != Null){
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
            // Empty -- for now, maybe we add something later.
          ],
        );
      },
    );
  }

  Future<String> _uploadImage(String foodItem, String imageUrl) async {
  if (imageUrl.isNotEmpty) {
    return imageUrl;
  } else {
    File imageFile = await _pickImageFromGallery(); 

    String imageName = '$foodItem.jpg';

    Reference storageReference =
        FirebaseStorage.instance.ref().child('restaurant_images/$imageName');

    try {
      await storageReference.putFile(imageFile);
      return await storageReference.getDownloadURL();
    } catch (error) {
      
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

    return Future.error('No image selected');
  }
}

  Future<void> _storePostData(String foodItem, String description, String imageUrl) async {
  CollectionReference restaurantCollection =
      FirebaseFirestore.instance.collection('restaurant');

  var userDoc = await restaurantCollection.doc("post").get();

  if (userDoc.exists) {

    await restaurantCollection.doc("post").update({
      'postName': FieldValue.arrayUnion([foodItem]),
      'postDescription': FieldValue.arrayUnion([description]),
    });
  } else {

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
      color: textFieldColor,
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
      color: textFieldColor,
      borderRadius: BorderRadius.circular(10),
    ),
    child: SingleChildScrollView(
      child: TextField(
        controller: controller,
        maxLines: null,
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
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && user.uid != Null) {

      CollectionReference locationsRef = FirebaseFirestore.instance.collection('locations');
      DocumentSnapshot locationsSnapshot = await locationsRef.doc(user.uid).get();

      if (locationsSnapshot.exists) {
        
        locationsRef.doc(user.uid).set({
          'latitude': latitude,
          'longitude': longitude,
        }, SetOptions(merge: true));
      } else {
        
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

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

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
              locationMessage,
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
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, 
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

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid != Null) {

        CollectionReference typeRef = FirebaseFirestore.instance.collection('type');


        DocumentSnapshot typeSnapshot = await typeRef.doc(user.uid).get();

        if (typeSnapshot.exists) {

          typeRef.doc(user.uid).set({
            'who': who,
          }, SetOptions(merge: true));
        } else {

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
            Navigator.pop(context);
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
                    
                      String email = emailController.text;
                      String password = passwordController.text;

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
                    Navigator.pop(context); 
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
