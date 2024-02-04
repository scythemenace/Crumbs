import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color textFieldColor = Color(0xFFF0F5FA);
const Color backgroundColor = Color(0xFF121223);

void main() {
  runApp(LocationPage());
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
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  "User",
                  style: TextStyle(
                    color: Colors.white,
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
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  "Restaurant",
                  style: GoogleFonts.sen( textStyle: TextStyle(
                    color: Colors.white,
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
                if (action == 'Sign up') _buildTextField('Name'),
                if (action == 'Sign up') SizedBox(height: 10),
                _buildTextField('Email'),
                SizedBox(height: 10),
                _buildTextField('Password'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Handle authentication logic
                    Navigator.pop(context); // Close the bottom sheet
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

  Widget _buildTextField(String labelText) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: textFieldColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
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
