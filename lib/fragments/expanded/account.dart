import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../algorithm/aesBase64.dart';
import '../../connection/connectHost.dart';
import '../../model/user.dart';
import '../../routes/routes.dart';
import '../../userPreferences/user_preference.dart';

class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);

  @override
  AccountPage createState() => AccountPage();
}

class AccountPage extends State<Account> {
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
    });
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
                child: const Text('Account',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
              ),
              Container(
                width: 800,
                color: const Color(0xFFE7E7E7),
                child: const Text('Manage account and account datas',
                    style: TextStyle(color: Color(0xFFB6B0B0))),
              ),
            ])),
        const SizedBox(
          height: 10,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            child: currentUser != null
                ? DataTable(
                    columns: [
                      DataColumn(
                          label: Text('Name', style: GoogleFonts.albertSans())),
                      DataColumn(
                          label: Text('Password',
                              style: GoogleFonts.albertSans())),
                      DataColumn(
                          label:
                              Text('Email', style: GoogleFonts.albertSans())),
                      DataColumn(
                          label: Text('Position',
                              style: GoogleFonts.albertSans())),
                      DataColumn(
                        label: Text(
                          'Edit',
                          style: GoogleFonts.albertSans(),
                        ),
                      )
                    ],
                    rows: [
                      DataRow(cells: [
                        DataCell(Text(
                            EncryptionUtils.decrypt(currentUser!.username))),
                        DataCell(Text(
                            EncryptionUtils.decrypt(currentUser!.pass_word))),
                        DataCell(
                            Text(EncryptionUtils.decrypt(currentUser!.email))),
                        DataCell(Text(currentUser!.role)),
                        DataCell(IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              final usernameController = TextEditingController(
                                  text: EncryptionUtils.decrypt(
                                      currentUser!.username));
                              final emailController = TextEditingController(
                                  text: EncryptionUtils.decrypt(
                                      currentUser!.email));
                              final passwordController = TextEditingController(
                                  text: EncryptionUtils.decrypt(
                                      currentUser!.pass_word));
                              final userId = currentUser!.id;

                              Future<void> _updateUserRecord() async {
                                final username = EncryptionUtils.encrypt(
                                    usernameController.text);
                                final email = EncryptionUtils.encrypt(
                                    emailController.text);
                                final password = EncryptionUtils.encrypt(
                                    passwordController.text);
                                final updateId = userId;

                                var url1 = Connection.updateData;

                                try {
                                  var response =
                                      await http.post(Uri.parse(url1), body: {
                                    "id": updateId.toString(),
                                    "username": username,
                                    "email": email,
                                    "pass_word": password,
                                    "role": currentUser!.role
                                  });
                                  print(response);
                                  if (response.statusCode == 200) {
                                    var resBodyRegister =
                                        jsonDecode(response.body);
                                    if (resBodyRegister['success'] == true) {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Update User Succesful!'),
                                          backgroundColor: Colors
                                              .purple, // Change to your desired color
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                      Navigator.pushNamed(
                                          context, RoutesName.LOGIN_PAGE);
                                    } else {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Update User Failed!'),
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
                              }

                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Stack(
                                        children: <Widget>[
                                          Form(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                /*Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                    //initialValue: initialvalue1,
                                                    decoration:
                                                        const InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.all(15.0),
                                                      labelText: 'Username',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                    controller:
                                                        usernameController,
                                                  ),
                                                ),*/
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                    //initialValue: initialvalue2,
                                                    decoration:
                                                        const InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.all(15.0),
                                                      labelText: 'Email',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                    controller: emailController,
                                                  ),
                                                ),
                                                /*Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                    //initialValue: initialvalue3,
                                                    decoration:
                                                        const InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.all(15.0),
                                                      labelText: 'Password',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                    controller:
                                                        passwordController,
                                                  ),
                                                ),*/
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: ElevatedButton(
                                                        onPressed:
                                                            _updateUserRecord,
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.purple,
                                                        ),
                                                        child: const Text(
                                                            'Submit'))),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                            }))
                      ]),
                    ],
                  )
                : const Text('No user information found.'),
          ),
        ),
      ]),
    );
  }
}
