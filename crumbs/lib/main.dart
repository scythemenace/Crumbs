import 'package:firebase_core/firebase_core.dart';
import 'auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color textFieldColor = Color(0xFFF0F5FA);
const Color backgroundColor = Color(0xFF121223);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(EntryPage());
}


class LocationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Location(),
    );
  }
}

class Location extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              onPressed: () {
                // Add your location access logic here
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
              margin: EdgeInsets.symmetric(horizontal: 50.0), // Adjusted margin to occupy the width
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
          ],
        ),
      ),
    );
  }
}





class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: EntryPage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
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
                onPressed: () {
                  // Handle user button press
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LocationPage()),
                  );
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
                onPressed: () {
                  // Handle restaurant button press
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LocationPage()),
                  );
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
                      MaterialPageRoute(builder: (context) => MyHomePage()),
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
