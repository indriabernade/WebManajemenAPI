import 'dart:convert';
import 'package:intl/intl.dart';
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

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  UsersPageState createState() => UsersPageState();
}

class UsersPageState extends State<UsersPage> {
  bool isLoading = false;
  /*late List<User> _users;
  List<User> usersFiltered = [];
  String _searchResult = '';

  @override
  void initState() {
    super.initState();
    Servicesdb.getUsers().then((users) {
      setState(() {
        _users = users;
        usersFiltered = users;
      });
    });
  }*/

  final GlobalKey<FormState> _form3 = GlobalKey<FormState>();

  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _cpassword = TextEditingController();
  final bool _obscureText = true;

  //final List<String> _roles = ['NewUser', 'Guest', 'Employee'];

  String _selectedRole = 'Guest';

  /*saveUserRecord() async {
    final username = EncryptionUtils.encrypt(_username.text);
    final email = EncryptionUtils.encrypt(_email.text);
    final password = EncryptionUtils.encrypt(_password.text);

    var url1 = Connection.register;

    try {
      var response = await http.post(Uri.parse(url1), body: {
        "username": username,
        "email": email,
        "pass_word": password,
        "role": _selectedRole
      });
      if (response.statusCode == 200) {
        var resBodyRegister = jsonDecode(response.body);
        if (resBodyRegister['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add User Successful'),
              backgroundColor: Colors.purple, // Change to your desired color
              duration: Duration(seconds: 2),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add User Failed!'),
              backgroundColor: Colors.purple, // Change to your desired color
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }*/

  register() async {
    final email = EncryptionUtils.encrypt(_email.text);

    var url2 = Connection.validate;
    try {
      var response = await http.post(Uri.parse(url2), body: {
        "email": email,
      });
      if (response.statusCode == 200) {
        var resBodyEmail = jsonDecode(response.body);
        if (resBodyEmail['emailFound'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email is already exist. Try another email'),
              backgroundColor: Colors.purple, // Change to your desired color
              duration: Duration(seconds: 2),
            ),
          );
          setState(() {
            _username.clear();
            _email.clear();
            _password.clear();
            _cpassword.clear();
          });
        } else {
          final username = EncryptionUtils.encrypt(_username.text);
          final email = EncryptionUtils.encrypt(_email.text);
          final password = EncryptionUtils.encrypt(_password.text);

          var url1 = Connection.register;

          try {
            var response = await http.post(Uri.parse(url1), body: {
              "username": username,
              "email": email,
              "pass_word": password,
              "role": _selectedRole
            });
            if (response.statusCode == 200) {
              var resBodyRegister = jsonDecode(response.body);
              if (resBodyRegister['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Add User Successful! Please click UPDATE DATA to see the latest data'),
                    backgroundColor:
                        Colors.purple, // Change to your desired color
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add User Failed!'),
                    backgroundColor:
                        Colors.purple, // Change to your desired color
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
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  final GlobalKey<_DataTableState> _dataTableKey = GlobalKey<_DataTableState>();

  final ScrollController _scrollController2 = ScrollController();
  @override
  void dispose() {
    _scrollController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
          controller: _scrollController2,
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
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 20)),
                  ),
                  Container(
                    width: 800,
                    color: const Color(0xFFE7E7E7),
                    child: const Text('Display all users in the database',
                        style: TextStyle(color: Color(0xFFB6B0B0))),
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
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: RichText(
                              text: const TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 2.0),
                                        child: Icon(Icons.info_outline)),
                                  ),
                                  TextSpan(
                                      text: 'Users details',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            content: SingleChildScrollView(
                                child: Container(
                              width: 700,
                              padding:
                                  const EdgeInsets.fromLTRB(10, 15, 10, 15),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Form(
                                      key: _form3,
                                      child: Column(
                                        children: [
                                          TextFormField(
                                            controller: _username,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: 'Username',
                                            ),
                                            validator: (val) {
                                              if (val!.isEmpty) {
                                                return 'Please enter the username';
                                              }
                                              if (val.length < 6) {
                                                return 'Username too short.';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 10),
                                          TextFormField(
                                            controller: _email,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: 'Email',
                                            ),
                                            validator: (val) {
                                              if (val!.isEmpty) {
                                                return 'Please enter a valid email address';
                                              }
                                              if (!val.contains('@') ||
                                                  !val.contains('.')) {
                                                return 'Email is invalid';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 10),
                                          TextFormField(
                                            controller: _password,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: 'Password',
                                              prefixIcon: Icon(Icons.lock),
                                            ),
                                            validator: (val) {
                                              if (val!.isEmpty) {
                                                return 'Please enter the password';
                                              }
                                              if (val.length < 6) {
                                                return 'Password too short.';
                                              }
                                              return null;
                                            },
                                            obscureText: _obscureText,
                                          ),
                                          const SizedBox(height: 10),
                                          TextFormField(
                                            controller: _cpassword,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: 'Confirm Password',
                                              prefixIcon: Icon(Icons.lock),
                                            ),
                                            validator: (val) {
                                              if (val!.isEmpty) {
                                                return 'Please enter the password';
                                              }
                                              if (val.length < 6) {
                                                return 'Password too short.';
                                              }
                                              if (val != _password.text) {
                                                return 'Not match';
                                              }
                                              return null;
                                            },
                                            obscureText: _obscureText,
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            'Select the role',
                                            style: GoogleFonts.albertSans(
                                                fontSize: 15,
                                                color: Colors.grey[700]),
                                          ),
                                          const SizedBox(height: 10),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                                DropdownButtonFormField<String>(
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.all(15.0),
                                                labelText: 'Role',
                                                border: OutlineInputBorder(),
                                              ),
                                              value: _selectedRole,
                                              onChanged: (newValue) {
                                                setState(() {
                                                  _selectedRole = newValue!;
                                                });
                                              },
                                              items: <String>[
                                                'Guest',
                                                'Employee'
                                              ].map<DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                            )),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.purple),
                                ),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.purple),
                                ),
                                onPressed: () {
                                  if (_form3.currentState!.validate()) {
                                    register();
                                    Navigator.of(context).pop();
                                    //register();
                                  }
                                  // Perform form submission logic here
                                  //String name = _nameController.text;
                                  //String email = _emailController.text;
                                  //sprint('Name: $name, Email: $email');
                                },
                                child: const Text('Submit'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(
                      // <-- Icon
                      Icons.add,
                      size: 24.0,
                    ),
                    label: const Text('CREATE USER'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[300]),
                  ),
                  const SizedBox(width: 20),
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
                  )
                  /*const Spacer(),
                  Expanded(
                    child: TextField(
                        decoration: const InputDecoration(
                          labelText: "search..",
                          icon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchResult = value;
                            usersFiltered = _users
                                .where((user) =>
                                    user.role.contains(_searchResult) ||
                                    user.username.contains(_searchResult))
                                .toList();
                          });
                        }),
                  ),
                  */
                ])),
            if (isLoading) // Display loading indicator if isLoading is true
              const CircularProgressIndicator(),
            if (!isLoading) // Display the DataTable if isLoading is false
              _DataTable(key: _dataTableKey),
            const SizedBox(
              height: 10,
            ),
          ])),
    );
  }
}

class _DataTable extends StatefulWidget {
  const _DataTable({Key? key}) : super(key: key);

  @override
  _DataTableState createState() => _DataTableState();
}

class _DataTableState extends State<_DataTable> {
  late List<User> _users;
  List<User> usersFiltered = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Servicesdb.getUsers().then((users) {
      setState(() {
        _users = users;
        usersFiltered = _users;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return generateDataTable();
  }

  Widget generateDataTable() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(
                label: Text('Username', style: GoogleFonts.albertSans())),
            DataColumn(label: Text('Email', style: GoogleFonts.albertSans())),
            DataColumn(label: Text('Role', style: GoogleFonts.albertSans())),
            DataColumn(
                label: Text('Tanggal Dibuat', style: GoogleFonts.albertSans())),
            DataColumn(
                label: Text('Hapus Akun', style: GoogleFonts.albertSans())),
            DataColumn(
                label: Text('Edit Akun', style: GoogleFonts.albertSans()))
          ],
          rows: List.generate(usersFiltered.length, (index) {
            final user = usersFiltered[index];
            final decryptedUsername = EncryptionUtils.decrypt(user.username);
            final decryptedEmail = EncryptionUtils.decrypt(user.email);
            final decryptedPassword = EncryptionUtils.decrypt(user.pass_word);
            final formattedDate = DateFormat.yMMMMd().format(user.created_at);
            String selectedRole = user.role;

            return DataRow(cells: [
              DataCell(Text(decryptedUsername)),
              DataCell(Text(decryptedEmail)),
              DataCell(Text(user.role)),
              DataCell(Text(formattedDate)),
              DataCell(IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            content: const Text(
                                'Are you sure want to delete this API data?'),
                            actions: [
                              TextButton(
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.purple),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.purple),
                                ),
                                onPressed: () async {
                                  final updateId = user.id;

                                  try {
                                    var response = await http.post(
                                        Uri.parse(Connection.deleteData),
                                        body: {
                                          "id": updateId.toString(),
                                        });
                                    if (response.statusCode == 200) {
                                      var resBodyRegister =
                                          jsonDecode(response.body);
                                      if (resBodyRegister['success'] == true) {
                                        for (int i = 0;
                                            i < _users.length;
                                            i++) {
                                          if (_users.elementAt(i).username ==
                                              usersFiltered[index].username) {
                                            _users.removeAt(i);
                                          }
                                        }
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'User Deleted! Please click UPDATE DATA to see the latest data'),
                                            backgroundColor: Colors
                                                .purple, // Change to your desired color
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('Delete User Failed'),
                                            backgroundColor: Colors
                                                .purple, // Change to your desired color
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                      Navigator.of(context).pop();
                                    }
                                  } catch (e) {
                                    print(e.toString());
                                    Fluttertoast.showToast(msg: e.toString());
                                  }
                                },
                                child: const Text('Delete'),
                              ),
                            ]);
                      });
                },
              )),
              DataCell(IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final usernameController =
                        TextEditingController(text: decryptedUsername);
                    final emailController =
                        TextEditingController(text: decryptedEmail);
                    final passwordController =
                        TextEditingController(text: decryptedPassword);
                    //final roleController = TextEditingController(text: _selectedRole);
                    final userId = user.id;

                    Future<void> _updateUserRecord() async {
                      final username =
                          EncryptionUtils.encrypt(usernameController.text);
                      final email =
                          EncryptionUtils.encrypt(emailController.text);
                      final password =
                          EncryptionUtils.encrypt(passwordController.text);
                      //final role = roleController.text;
                      final updateId = userId;

                      var url1 = Connection.updateData;

                      try {
                        var response = await http.post(Uri.parse(url1), body: {
                          "id": updateId.toString(),
                          "username": username,
                          "email": email,
                          "pass_word": password,
                          "role": selectedRole
                        });
                        if (response.statusCode == 200) {
                          var resBodyRegister = jsonDecode(response.body);
                          if (resBodyRegister['success'] == true) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Update User Successful! Please click UPDATE DATA to see the latest data'),
                                backgroundColor: Colors
                                    .purple, // Change to your desired color
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Update User Failed'),
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
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          //initialValue: initialvalue1,
                                          decoration: const InputDecoration(
                                            contentPadding:
                                                EdgeInsets.all(15.0),
                                            labelText: 'Username',
                                            border: OutlineInputBorder(),
                                          ),
                                          controller: usernameController,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          //initialValue: initialvalue2,
                                          decoration: const InputDecoration(
                                            contentPadding:
                                                EdgeInsets.all(15.0),
                                            labelText: 'Email',
                                            border: OutlineInputBorder(),
                                          ),
                                          controller: emailController,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          //initialValue: initialvalue3,
                                          decoration: const InputDecoration(
                                            contentPadding:
                                                EdgeInsets.all(15.0),
                                            labelText: 'Password',
                                            border: OutlineInputBorder(),
                                          ),
                                          controller: passwordController,
                                        ),
                                      ),
                                      /*Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      //initialValue: initialvalue3,
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.all(15.0),
                                        labelText: 'Role',
                                        border: OutlineInputBorder(),
                                      ),
                                      controller: roleController,
                                    ),
                                  ),*/
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: DropdownButtonFormField<String>(
                                          decoration: const InputDecoration(
                                            contentPadding:
                                                EdgeInsets.all(15.0),
                                            labelText: 'Role',
                                            border: OutlineInputBorder(),
                                          ),
                                          value: selectedRole,
                                          onChanged: (newValue) {
                                            setState(() {
                                              selectedRole = newValue!;
                                            });
                                          },
                                          items: <String>['Guest', 'Employee']
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton(
                                              onPressed: _updateUserRecord,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.purple,
                                              ),
                                              child: const Text('Submit'))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                  })),
            ]);
          }),
        ));
  }
}
