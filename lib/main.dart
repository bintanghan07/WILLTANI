import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webagro/chopper_api/api_client.dart';
import 'package:webagro/widgets/dashboard.dart';
import 'package:webagro/widgets/login.dart';
import 'package:webagro/widgets/register.dart';
import 'widgets/navbar.dart';
import 'utils/responsiveLayout.dart';

Future<void> main() async {
  final apiClient = ApiClient();
  apiClient.initialize();

  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('bearer_token');

  runApp(MaterialApp(
    title: 'Flutter Landing Page',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: HomePage(
      bearerToken: token,
    ),
  ));
}

class HomePage extends StatelessWidget {
  final String? bearerToken;

  const HomePage({super.key, required this.bearerToken});

  @override
  Widget build(BuildContext context) {
    if (bearerToken != null) {
      // If token exists, navigate to the Dashboard
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
      });
    } else {
      return Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color(0xFFF8FBFF),
          Color(0xFFFCFDFD),
        ])),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const NavBar(),
                Body(apiClient: ApiClient(), bearerToken: bearerToken)
              ],
            ),
          ),
        ),
      );
    }
    return Container();
  }
}

class Body extends StatelessWidget {
  final ApiClient apiClient;
  final String? bearerToken;

  const Body({super.key, required this.apiClient, this.bearerToken});
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      largeScreen: LargeChild(
        apiClient: apiClient,
      ),
      smallScreen: SmallChild(
        apiClient: apiClient,
      ),
    );
  }
}

class LargeChild extends StatelessWidget {
  final ApiClient apiClient;

  const LargeChild({super.key, required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Gambar navbar.png ditampilkan di sini
          FractionallySizedBox(
            alignment: Alignment.centerRight,
            widthFactor: .6,
            child: Image.asset(
                "lib/assets/navbar.png", scale: .85),
          ),
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: .6,
            child: Padding(
              padding: const EdgeInsets.only(left: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Hello!",
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Montserrat-Regular",
                      color: Color(0xFF8591B0),
                    ),
                  ),
                  RichText(
                    text: const TextSpan(
                      text: "WellCome To ",
                      style: TextStyle(fontSize: 60, color: Color(0xFF8591B0)),
                      children: [
                        TextSpan(
                          text: "webagro.willtani",
                          style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 12.0, top: 20),
                    child: Text("We're glad you do cultivation management"),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      // Tombol Register
                      InkWell(
                        child: Container(
                          margin: const EdgeInsets.only(left: 20),
                          width: 120,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF215064), Color(0xFFF6EBE2)],
                              begin: Alignment.bottomRight,
                              end: Alignment.topLeft,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6078ea).withOpacity(.3),
                                offset: const Offset(0, 8),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Register(
                                    apiService: apiClient.apiService,
                                  ),
                                ),
                              );
                            },
                            child: const Material(
                              color: Colors.transparent,
                              child: Center(
                                child: Text(
                                  "Register",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    letterSpacing: 1,
                                    fontFamily: "Montserrat-Bold",
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Tombol Login
                      InkWell(
                        child: Container(
                          margin: const EdgeInsets.only(left: 20),
                          width: 120,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF215064), Color(0xFFF6EBE2)],
                              begin: Alignment.bottomRight,
                              end: Alignment.topLeft,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6078ea).withOpacity(.3),
                                offset: const Offset(0, 8),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Login(
                                    apiService: apiClient.apiService,
                                  ),
                                ),
                              );
                            },
                            child: const Material(
                              color: Colors.transparent,
                              child: Center(
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    letterSpacing: 1,
                                    fontFamily: "Montserrat-Bold",
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class SmallChild extends StatelessWidget {
  final ApiClient apiClient;

  const SmallChild({super.key, required this.apiClient});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              "Hello!",
              style: TextStyle(
                  fontSize: 40,
                  color: Color(0xFF8591B0),
                  fontWeight: FontWeight.bold,
                  fontFamily: "Montserrat-Regular"),
            ),
            RichText(
              text: const TextSpan(
                text: 'WellCome To ',
                style: TextStyle(fontSize: 40, color: Color(0xFF8591B0)),
                children: <TextSpan>[
                  TextSpan(
                      text: 'webagro.willtani',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                          color: Colors.black87)),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 0, top: 20),
              child: Text("We're glad you do cultivation management"),
            ),
            const SizedBox(
              height: 30,
            ),
            Center(
              child: Image.asset(
                "lib/assets/navbar.png",
                scale: 1,
              ),
            ),
            const SizedBox(
              height: 32,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  child: Container(
                    margin: const EdgeInsets.only(left: 20),
                    width: 120,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF215064), Color(0xFFF6EBE2)],
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6078ea).withOpacity(.3),
                          offset: const Offset(0, 8),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Register(apiService: apiClient.apiService),
                          ),
                        );
                      },
                      child: const Material(
                        color: Colors.transparent,
                        child: Center(
                          child: Text(
                            "Register",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              letterSpacing: 1,
                              fontFamily: "Montserrat-Bold",
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  child: Container(
                    margin: const EdgeInsets.only(left: 20),
                    width: 120,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF215064), Color(0xFFF6EBE2)],
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6078ea).withOpacity(.3),
                          offset: const Offset(0, 8),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Login(apiService: apiClient.apiService),
                          ),
                        );
                      },
                      child: const Material(
                        color: Colors.transparent,
                        child: Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              letterSpacing: 1,
                              fontFamily: "Montserrat-Bold",
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}