import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../algorithm/aesBase64.dart';
import '../../connection/connectHost.dart';
import '../../model/user.dart';

class Servicesdb {
  static const String url = Connection.getData;
  static Future<List<User>> getUsers() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (200 == response.statusCode) {
        final List<User> users = userModelFromJson(response.body);
        return users;
      } else {
        return <User>[];
      }
    } catch (e) {
      return <User>[];
    }
  }
}

class Notify extends StatefulWidget {
  const Notify({Key? key}) : super(key: key);

  @override
  NotificationPage createState() => NotificationPage();
}

class NotificationPage extends State<Notify> {
  late List<User> _users;
  bool isLoading = false;
  List<User> usersFiltered = [];

  @override
  void initState() {
    super.initState();
    Servicesdb.getUsers().then((users) {
      setState(() {
        _users = users;
        usersFiltered = users;
      });
    });
  }

  final ScrollController _scrollController4 = ScrollController();
  @override
  void dispose() {
    _scrollController4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
          controller: _scrollController4,
          child: Column(children: [
            const SizedBox(
              height: 10,
            ),
            Container(
                color: const Color(0xFFE7E7E7),
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.fromLTRB(20, 15, 100, 15),
                child: Column(children: [
                  Container(
                    width: 800,
                    height: 60,
                    color: const Color(0xFFE7E7E7),
                    child: const Text('Check Notification',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 20)),
                  ),
                ])),
            const SizedBox(
              height: 10,
            ),
            Container(
                width: 915,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.fromLTRB(20, 0, 40, 0),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        isLoading = true; // Show the loading indicator
                      });
                      // Simulate an asynchronous operation
                      Future.delayed(const Duration(seconds: 2), () {
                        setState(() {
                          isLoading = false; // Hide the loading indicator
                        });
                      });
                    },
                    icon: const Icon(
                      // <-- Icon
                      Icons.refresh,
                      size: 24.0,
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[300]),
                    label: const Text('UPDATE DATA'),
                  ),
                  const Spacer(),
                ])),
            const SizedBox(
              height: 10,
            ),
            if (isLoading) // Display loading indicator if isLoading is true
              const CircularProgressIndicator(),
            if (!isLoading)
              DataTable(
                columns: [
                  DataColumn(
                      label: Text('Username', style: GoogleFonts.albertSans())),
                  DataColumn(
                      label: Text('Notice', style: GoogleFonts.albertSans())),
                  DataColumn(
                      label: Text('Confirm', style: GoogleFonts.albertSans()))
                ],
                rows: List.generate(usersFiltered.length, (index) {
                  final user = usersFiltered[index];
                  final decryptedUsername =
                      EncryptionUtils.decrypt(user.username);
                  return DataRow(cells: [
                    DataCell(Text(decryptedUsername)),
                    DataCell(Text(user.notice)),
                    DataCell(IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () async {
                        final updateId = user.id;
                        for (int i = 0; i < _users.length; i++) {
                          if (_users.elementAt(i).username ==
                              usersFiltered[index].username) {
                            _users.removeAt(i);
                          }
                        }
                        try {
                          var response = await http
                              .post(Uri.parse(Connection.deletenotice), body: {
                            "id": updateId.toString(),
                          });
                          if (response.statusCode == 200) {
                            var resBodyRegister = jsonDecode(response.body);
                            if (resBodyRegister['success'] == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Message Confirmed! Please click UPDATE DATA to see the latest data'),
                                  backgroundColor: Colors
                                      .purple, // Change to your desired color
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Confirm Failed'),
                                  backgroundColor: Colors
                                      .purple, // Change to your desired color
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          print(e.toString());
                          Fluttertoast.showToast(msg: e.toString());
                        }
                      },
                    )),
                  ]);
                }),
              ),
          ])),
    );
  }
}
