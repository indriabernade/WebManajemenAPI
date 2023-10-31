import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manajemen_api/fragments/expanded/notification.dart';
import 'package:manajemen_api/fragments/expanded/guest.dart';
import 'package:manajemen_api/fragments/expanded/listAPIguest.dart';
import '../algorithm/aesBase64.dart';
import '../connection/connectHost.dart';
import '../model/user.dart';
import '../routes/routes.dart';
import '../userPreferences/user_preference.dart';
import 'expanded/about.dart';
import 'expanded/accessAPI.dart';
import 'expanded/account.dart';
import 'expanded/dashboard.dart';
import 'expanded/jagajaga.dart';
import 'expanded/listAPIuser.dart';
import 'expanded/listKeys.dart';
import 'expanded/listKeysGroup.dart';
import 'expanded/listUser.dart';
import 'package:http/http.dart' as http;

enum UserRole {
  NewUser,
  Guest,
  Employee,
  SuperUser,
}

class Servicesdb {
  static const String url = Connection.getData;

  static Future<void> showNoticeNotifications(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<User> users = userModelFromJson(response.body);

        for (User user in users) {
          if (user.notice != null && user.notice.isNotEmpty) {
            await _showFloatingPopup(context, user.username, user.notice);
          }
        }
      }
    } catch (e) {
      print('Error fetching notices: $e');
    }
  }

  static Future<void> _showFloatingPopup(
      BuildContext context, String username, String notice) async {
    final overlayState = Overlay.of(context);

    final overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: 16,
          right: 16,
          child: Material(
            elevation: 4,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning, color: Colors.yellow),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Pesan masuk dari ${EncryptionUtils.decrypt(username)}!'),
                      SizedBox(height: 4),
                      Text(notice),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    overlayState.insert(overlayEntry);

    // Tunggu sejenak (misalnya, 3 detik) sebelum menghapus overlayEntry
    await Future.delayed(Duration(seconds: 3));

    // Hapus overlayEntry
    overlayEntry.remove();
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomePage createState() => HomePage();
}

class HomePage extends State<Home> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPageIndex = 0;
  User? currentUser;
  String? receivedToken;
  late bool _isMenuExpanded;
  DateTime? _firstAccessTime;

  @override
  void initState() {
    super.initState();
    getUserInfo();
    _isMenuExpanded = true;
  }

  // Metode untuk menampilkan showDialog kedua
  Future<bool?> showSecondDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Token Expired"),
          content: const Text("Harap melakukan Sign In ulang"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<bool> showFormDialog(BuildContext context) async {
    final TextEditingController tokenController = TextEditingController();
    bool isValid = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Validasi User'),
          content: TextField(
              controller: tokenController,
              decoration: const InputDecoration(
                labelText: 'Masukkan token disini',
              ),
              textInputAction:
                  TextInputAction.done, // Set the keyboard action to "Done"
              onEditingComplete: () {}),
          actions: [
            ElevatedButton(
                onPressed: () {
                  String enteredToken = tokenController.text.trim();
                  if (enteredToken == receivedToken) {
                    isValid = true;
                    Navigator.of(context).pop(); // Close the dialog
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Invalid Token'),
                          content:
                              const Text('Token is invalid. Please try again.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.purple[500]!), // Set the background color
                ),
                child: const Text('Submit')),
          ],
        );
      },
    );

    return isValid;
  }

  Future<void> getUserInfo() async {
    User? userInfo = await Storage.readUserInfo();
    String? storedToken = await Storage.getToken();
    setState(() {
      currentUser = userInfo;
      receivedToken = storedToken;
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  void _toggleMenuExpansion() {
    setState(() {
      _isMenuExpanded = !_isMenuExpanded;
    });
  }

  UserRole getUserRole() {
    if (currentUser == null) {
      return UserRole.NewUser;
    } else {
      String role = currentUser!.role;

      if (role == 'Guest') {
        return UserRole.Guest;
      } else if (role == 'Employee') {
        return UserRole.Employee;
      } else if (role == 'SuperUser') {
        return UserRole.SuperUser;
      } else {
        return UserRole.NewUser;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserRole userRole = getUserRole();
    if (currentUser?.role == 'SuperUser') {
      Servicesdb.showNoticeNotifications(context);
    }

    return Scaffold(
      body: Row(
        children: [
          AnimatedContainer(
            color: const Color.fromARGB(129, 247, 225, 225),
            duration: const Duration(milliseconds: 300),
            width: _isMenuExpanded ? 200.0 : 80.0,
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(8),
                  color: Colors.purple[200],
                  child: Image.network(
                    'https://3.bp.blogspot.com/-vWjOy9zkFw4/Ws8tWhxY7SI/AAAAAAAAACw/CpURM2VgC0cnyuJRTE7u-Gh1TOWn063qQCLcBGAs/s1600/rocket-logo.png',
                    height: 40,
                  ),
                ),
                ListTileTheme(
                  selectedColor: Colors.purple[
                      700], // Set the selected color for the text and icon
                  child: ListTile(
                    leading: const Icon(Icons.dashboard),
                    title: _isMenuExpanded
                        ? const Text('Dashboard')
                        : const SizedBox.shrink(),
                    selected: _currentPageIndex == 0,
                    onTap: () {
                      if (userRole == UserRole.Guest ||
                          userRole == UserRole.NewUser) {
                        _pageController.jumpToPage(0);
                      } else if (userRole == UserRole.SuperUser ||
                          userRole == UserRole.Employee) {
                        _pageController.jumpToPage(1);
                      }
                      setState(() {
                        _currentPageIndex = _pageController.page!.toInt();
                      });
                    },
                  ),
                ),
                ListTileTheme(
                  selectedColor: Colors.purple[
                      700], // Set the selected color for the text and icon
                  child: userRole == UserRole.SuperUser ||
                          userRole == UserRole.Employee
                      ? ListTile(
                          leading: const Icon(Icons.account_box),
                          title: _isMenuExpanded
                              ? const Text('Account')
                              : const SizedBox.shrink(),
                          selected: _currentPageIndex == 2,
                          onTap: () {
                            if (userRole == UserRole.SuperUser) {
                              _pageController.jumpToPage(2);
                            } else if (userRole == UserRole.Employee) {
                              _firstAccessTime ??= DateTime.now();
                              Duration timeDifference =
                                  DateTime.now().difference(_firstAccessTime!);

                              if (timeDifference.inMinutes < 5) {
                                showFormDialog(context).then((isValid) {
                                  if (isValid) {
                                    _pageController.jumpToPage(2);
                                  }
                                });
                              } else {
                                showSecondDialog(context).then((isValid) {});
                              }
                            }
                          },
                        )
                      : const SizedBox.shrink(),
                ),
                ListTileTheme(
                  selectedColor: Colors.purple[
                      700], // Set the selected color for the text and icon
                  child: userRole == UserRole.SuperUser
                      ? ListTile(
                          leading: const Icon(Icons.group),
                          title: _isMenuExpanded
                              ? const Text('User groups')
                              : const SizedBox.shrink(),
                          selected: _currentPageIndex == 3,
                          onTap: () {
                            _pageController.jumpToPage(3);
                          },
                        )
                      : const SizedBox.shrink(),
                ),
                ListTileTheme(
                  selectedColor: Colors.purple[
                      700], // Set the selected color for the text and icon
                  child: userRole == UserRole.SuperUser
                      ? ListTile(
                          leading: const Icon(Icons.group),
                          title: _isMenuExpanded
                              ? const Text('Notification')
                              : const SizedBox.shrink(),
                          selected: _currentPageIndex == 4,
                          onTap: () {
                            _pageController.jumpToPage(4);
                          },
                        )
                      : const SizedBox.shrink(),
                ),
                ListTileTheme(
                  selectedColor: Colors.purple[
                      700], // Set the selected color for the text and icon
                  child: userRole == UserRole.SuperUser ||
                          userRole == UserRole.Employee ||
                          userRole == UserRole.Guest
                      ? ListTile(
                          leading: const Icon(Icons.api),
                          title: _isMenuExpanded
                              ? const Text('APIs')
                              : const SizedBox.shrink(),
                          selected: _currentPageIndex == 5,
                          onTap: () {
                            if (userRole == UserRole.SuperUser) {
                              _pageController.jumpToPage(5);
                            } else if (userRole == UserRole.Employee) {
                              _firstAccessTime ??= DateTime.now();
                              Duration timeDifference =
                                  DateTime.now().difference(_firstAccessTime!);

                              if (timeDifference.inMinutes < 5) {
                                showFormDialog(context).then((isValid) {
                                  if (isValid) {
                                    _pageController.jumpToPage(6);
                                  }
                                });
                              } else {
                                showSecondDialog(context).then((isValid) {});
                              }
                            } else if (userRole == UserRole.Guest) {
                              _firstAccessTime ??= DateTime.now();
                              Duration timeDifference =
                                  DateTime.now().difference(_firstAccessTime!);

                              if (timeDifference.inMinutes < 5) {
                                showFormDialog(context).then((isValid) {
                                  if (isValid) {
                                    _pageController.jumpToPage(7);
                                  }
                                });
                              } else {
                                showSecondDialog(context).then((isValid) {});
                              }
                            }
                          },
                        )
                      : const SizedBox.shrink(),
                ),
                ListTileTheme(
                  selectedColor: Colors.purple[
                      700], // Set the selected color for the text and icon
                  child: userRole == UserRole.SuperUser ||
                          userRole == UserRole.Employee
                      ? ListTile(
                          leading: const Icon(Icons.vpn_key),
                          title: _isMenuExpanded
                              ? const Text('Keys')
                              : const SizedBox.shrink(),
                          selected: _currentPageIndex == 8,
                          onTap: () {
                            if (userRole == UserRole.SuperUser) {
                              _pageController.jumpToPage(8);
                            } else if (userRole == UserRole.Employee) {
                              _firstAccessTime ??= DateTime.now();
                              Duration timeDifference =
                                  DateTime.now().difference(_firstAccessTime!);

                              if (timeDifference.inMinutes < 5) {
                                showFormDialog(context).then((isValid) {
                                  if (isValid) {
                                    _pageController.jumpToPage(9);
                                  }
                                });
                              } else {
                                showSecondDialog(context).then((isValid) {});
                              }
                            }
                          },
                        )
                      : const SizedBox.shrink(),
                ),
                ListTileTheme(
                    selectedColor: Colors.purple[
                        700], // Set the selected color for the text and icon
                    child: userRole == UserRole.SuperUser ||
                            userRole == UserRole.Employee ||
                            userRole == UserRole.Guest
                        ? ListTile(
                            leading: const Icon(Icons.api),
                            title: _isMenuExpanded
                                ? const Text('Access API')
                                : const SizedBox.shrink(),
                            selected: _currentPageIndex == 10,
                            onTap: () {
                              if (userRole == UserRole.SuperUser ||
                                  userRole == UserRole.Employee ||
                                  userRole == UserRole.Guest) {
                                _pageController.jumpToPage(10);
                              }
                            },
                          )
                        : const SizedBox.shrink()),
                ListTileTheme(
                    selectedColor: Colors.purple[
                        700], // Set the selected color for the text and icon
                    child: userRole == UserRole.SuperUser ||
                            userRole == UserRole.Employee ||
                            userRole == UserRole.Guest
                        ? ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: _isMenuExpanded
                                ? const Text('About')
                                : const SizedBox.shrink(),
                            selected: _currentPageIndex == 11,
                            onTap: () {
                              if (userRole == UserRole.SuperUser ||
                                  userRole == UserRole.Employee ||
                                  userRole == UserRole.Guest) {
                                _pageController.jumpToPage(11);
                              }
                            },
                          )
                        : const SizedBox.shrink()),
                ListTileTheme(
                    selectedColor: Colors.purple[
                        700], // Set the selected color for the text and icon
                    child: ListTile(
                      leading: const Icon(Icons.logout),
                      title: _isMenuExpanded
                          ? const Text('Log Out')
                          : const SizedBox.shrink(),
                      //selected: _currentPageIndex == 8,
                      onTap: () {
                        //Navigator.pushNamed(context, RoutesName.LOGOUT_PAGE);
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          RoutesName.LOGIN_PAGE,
                          (route) => false, // Remove all pages from the history
                        );
                        RouteGenerator.isLoggedIn = false;
                      },
                    )),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(8),
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      if (constraints.maxWidth < 600) {
                        // Modify the width value as per your requirement
                        return Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.menu),
                                  onPressed: _toggleMenuExpansion,
                                ),
                                const Spacer(),
                                Center(
                                  child: Text(
                                    "API Files Management",
                                    style: GoogleFonts.albertSans(fontSize: 20),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.center,
                              child: currentUser != null
                                  ? Text(
                                      'Welcome, user ${EncryptionUtils.decrypt(currentUser!.username)}!',
                                      textAlign: TextAlign.center,
                                    )
                                  : const Text('No user information found.',
                                      textAlign: TextAlign.center),
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.menu),
                              onPressed: _toggleMenuExpansion,
                            ),
                            const Spacer(),
                            const Spacer(),
                            Text(
                              "API Files Management",
                              style: GoogleFonts.albertSans(fontSize: 20),
                            ),
                            const Spacer(),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: currentUser != null
                                    ? Text(
                                        'Welcome, ${EncryptionUtils.decrypt(currentUser!.username)}!',
                                        style: GoogleFonts.albertSans(
                                            fontSize: 15),
                                      )
                                    : const Text('No user information found.'),
                              ),
                            ),
                            const SizedBox(width: 8)
                          ],
                        );
                      }
                    },
                  ),
                ),
                Expanded(
                  child: PageView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    children: const [
                      DashboardGuest(),
                      Dashboard(),
                      Account(),
                      UsersPage(),
                      Notify(),
                      APIs(),
                      UserAPIs(),
                      ListAPIguest(),
                      ListKeys(),
                      ListKeysUser(),
                      AccessAPI(),
                      About()
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
