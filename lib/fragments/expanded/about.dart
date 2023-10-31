import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../connection/connectHost.dart';
import '../../model/user.dart';
import '../../userPreferences/user_preference.dart';

class About extends StatefulWidget {
  const About({Key? key}) : super(key: key);

  @override
  AboutPage createState() => AboutPage();
}

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

class AboutPage extends State<About> {
  User? currentUser;
  List<User> usersFiltered = [];

  @override
  void initState() {
    super.initState();
    getUserInfo();
    Servicesdb.getUsers().then((users) {
      setState(() {
        usersFiltered = users;
      });
    });
  }

  Future<void> getUserInfo() async {
    User? userInfo = await Storage.readUserInfo();
    setState(() {
      currentUser = userInfo;
    });
  }

  final ScrollController _scrollController5 = ScrollController();
  @override
  void dispose() {
    _scrollController5.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          controller: _scrollController5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 100),
              Container(
                color: Color.fromARGB(255, 236, 194, 243),
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                child: Column(
                  children: [
                    SizedBox(
                      width: 800,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Selamat datang ke Web Manajemen API',
                            style: GoogleFonts.albertSans(fontSize: 15),
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Web Manajemen API adalah sebuah web yang digunakan untuk mengelola dan mengamankan API.',
                            style: GoogleFonts.albertSans(fontSize: 15),
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Web Manajemen API memberikan pelayanan untuk menyediakan atau menampilkan API yang dibutuhkan.',
                            style: GoogleFonts.albertSans(fontSize: 15),
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Untuk melakukan akses harap salin token yang telah disediakan pada menu Dashboard.',
                            style: GoogleFonts.albertSans(fontSize: 15),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromARGB(255, 201, 90, 218)),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                ),
                onPressed: () {
                  final noticeController =
                      TextEditingController(text: currentUser!.notice);
                  final userId = currentUser!.id;
                  Future<void> _updateUserRecord() async {
                    final notice = noticeController.text;
                    final updateId = userId;

                    var url = Connection.notice;

                    try {
                      var response = await http.post(Uri.parse(url), body: {
                        "id": updateId.toString(),
                        "notice": notice,
                      });
                      print(response);
                      if (response.statusCode == 200) {
                        var resBodyRegister = jsonDecode(response.body);
                        if (resBodyRegister['success'] == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pesan Terkirim'),
                              backgroundColor:
                                  Colors.purple, // Change to your desired color
                              duration: Duration(seconds: 2),
                            ),
                          );
                          Navigator.of(context).pop();
                          var headers = {
                            'Content-Type': 'application/json',
                            'api-key':
                                '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',
                            'Cookie':
                                '__cf_bm=00Y9jnh_Ee2xvvH_7UAuqnVsDqKiOyc6g.ThRD16HO8-1692549128-0-AUJKc9JBoSD6MjBbd7So9PNXI1JZrkMznXh1RygJ/5Vi7R+1rVusrx4ip+xJ0P7PN1LuzTKQH3ho5+MEPFnfBC4='
                          };
                          var request = http.Request(
                              'POST',
                              Uri.parse(
                                  'https://api.sendinblue.com/v3/smtp/email'));
                          request.body = json.encode({
                            "sender": {
                              "name": "Indria",
                              "email": "minicrabf@gmail.com"
                            },
                            "to": [
                              {"email": "indriasinuraya@gmail.com"}
                            ],
                            "subject": "Ada Pesan Masuk",
                            "htmlContent":
                                "<p>Harap melakukan Sign In pada Web Manajemen API!</p>"
                          });
                          request.headers.addAll(headers);

                          http.StreamedResponse response = await request.send();

                          if (response.statusCode == 200) {
                            print(await response.stream.bytesToString());
                          } else {
                            print(response.reasonPhrase);
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pesan Gagal Terkirim'),
                              backgroundColor:
                                  Colors.purple, // Change to your desired color
                              duration: Duration(seconds: 2),
                            ),
                          );
                          Navigator.of(context).pop();
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
                                        contentPadding: EdgeInsets.all(15.0),
                                        labelText: 'Text',
                                        border: OutlineInputBorder(),
                                      ),
                                      controller: noticeController,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      onPressed: _updateUserRecord,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple,
                                      ),
                                      child: const Text('Submit'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: const Text(
                  'Kirim pesan ke Admin',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 200),
              Center(
                child: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '© Copyright Web Manajemen API 2023. All Rights Reserved',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
