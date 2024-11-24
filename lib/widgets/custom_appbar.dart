import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webagro/chopper_api/api_client.dart';
import 'package:webagro/utils/responsiveLayout.dart';
import 'package:webagro/widgets/dashboard.dart';
import 'package:webagro/widgets/grafik.dart';
import 'package:webagro/widgets/greenhouse.dart';
import 'package:webagro/widgets/kontrol.dart';
import 'package:webagro/widgets/login.dart';
import 'package:webagro/widgets/monitoring.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final activityName;

  const CustomAppBar({super.key, required this.activityName});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(activityName),
          const Row(
            children: [
              // Image.asset(
              //   'logofix.png',
              //   height: 20,
              // ),
            ],
          ),
          Row(
            children: [
              if (ResponsiveLayout.isSmallScreen(context))
                PopupMenuButton<String>(
                  icon: const Icon(Icons.menu, color: Color(0xFF215064)),
                  onSelected: (value) {
                    _onMenuSelected(value, context);
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      _buildPopupMenuItem(
                        'Dashboard',
                      ),
                      _buildPopupMenuItem('Green House'),
                      _buildPopupMenuItem('Kontrol'),
                      _buildPopupMenuItem('Monitoring'),
                      _buildPopupMenuItem('Grafik'),
                    ];
                  },
                )
              else
                Row(
                  children: [
                    _buildMenuItem('Dashboard', context),
                    _buildMenuItem('Green House', context),
                    _buildMenuItem('Kontrol', context),
                    _buildMenuItem('Monitoring', context),
                    _buildMenuItem('Grafik', context),
                  ],
                ),
              PopupMenuButton<String>(
                icon:
                    const Icon(Icons.account_circle, color: Color(0xFF215064)),
                onSelected: (value) {
                  _onProfileMenuSelected(value, context);
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'Logout',
                      child: Text(
                        'Logout',
                        style: TextStyle(color: Color(0xFF215064)),
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextButton(
        onPressed: () {
          _onMenuSelected(title, context);
        },
        child: Text(
          title,
          style: const TextStyle(color: Color(0xFF215064)),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String title) {
    return PopupMenuItem<String>(
      value: title,
      child: Text(title,
          style: const TextStyle(
            color: Color(0xFF215064),
          )),
    );
  }

  void _onMenuSelected(String value, BuildContext context) {
    // Implement navigation based on the selected menu item
    switch (value) {
      case 'Dashboard':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
        break;
      case 'Green House':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Greenhouse()),
        );
        break;
      case 'Kontrol':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Kontrol()),
        );
        break;
      case 'Monitoring':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Monitoring()),
        );
        break;
      case 'Grafik':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Grafik()),
        );
        break;
      default:
        Navigator.pushNamed(context, '/$value');
    }
  }

  void _onProfileMenuSelected(String value, BuildContext context) {
    if (value == 'Logout') {
      // Implement logout functionality here
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF215064), Color(0xFFF6EBE2)],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Are you sure you want to logout?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextButton(
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xFF215064),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextButton(
                            child: const Text(
                              'Logout',
                              style: TextStyle(
                                color: Color(0xFF215064),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              // Call the logout endpoint
                              String? token = prefs.getString('bearer_token');

                              final response = await ApiClient()
                                  .apiService
                                  .logout('Bearer $token');

                              if (response.isSuccessful) {
                                // Perform logout action here

                                await prefs.remove(
                                    'bearer_token'); // Remove the token from SharedPreferences

                                // Navigate to the Login screen
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Login(
                                        apiService: ApiClient().apiService),
                                  ),
                                );
                              } else {
                                // Handle logout error (optional)
                                // You can show a snackbar or alert dialog here
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Logout failed')),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
