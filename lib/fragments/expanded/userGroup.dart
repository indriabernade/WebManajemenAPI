import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../algorithm/aesBase64.dart';
import '../../connection/connectHost.dart';
import '../../model/user.dart';
import '../../userPreferences/user_preference.dart';

class Servicesdb {
  static const String url = Connection.getData;
  static Future<List<User>> getUsers() async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: {'x-tyk-authorization': 'foo'});
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

class UserGroups extends StatefulWidget {
  const UserGroups({Key? key}) : super(key: key);

  @override
  UsersPageState createState() => UsersPageState();
}

class UsersPageState extends State<UserGroups> {
  List<User> usersFiltered = [];
  User? currentUser;

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    User? userInfo = await Storage.readUserInfo();
    setState(() {
      currentUser = userInfo;
      filterUsersByRole();
    });
  }

  void filterUsersByRole() {
    if (currentUser != null) {
      String userRole = currentUser!.role;
      //usersFiltered = _users.where((user) => user.role == userRole).toList();
      //setState(() {});
      Servicesdb.getUsers().then((users) {
        setState(() {
          usersFiltered = users.where((user) => user.role == userRole).toList();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
                height: 30,
                color: const Color(0xFFE7E7E7),
                child: const Text('User Groups',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
              ),
              Container(
                width: 800,
                color: const Color(0xFFE7E7E7),
                child: currentUser != null
                    ? Text('Display users in the ${currentUser!.role}',
                        style: const TextStyle(color: Color(0xFFB6B0B0)))
                    : const Text('No user information foud'),
              ),
            ])),
        const SizedBox(
          height: 10,
        ),
        DataTable(
          columns: [
            DataColumn(
                label: Text('Username', style: GoogleFonts.albertSans())),
            DataColumn(label: Text('Email', style: GoogleFonts.albertSans()))
          ],
          rows: List.generate(
            usersFiltered.length,
            (index) {
              final user = usersFiltered[index];
              final decryptedUsername = EncryptionUtils.decrypt(user.username);
              final decryptedEmail = EncryptionUtils.decrypt(user.email);

              return DataRow(
                cells: [
                  DataCell(Text(decryptedUsername)),
                  DataCell(Text(decryptedEmail))
                ],
              );
            },
          ),
        )
      ]),
    );
  }
}
