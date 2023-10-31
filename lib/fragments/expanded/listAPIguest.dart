import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../algorithm/aesBase64.dart';
import '../../connection/connectHost.dart';
import '../../model/api.dart';
import '../../model/user.dart';
import '../../userPreferences/user_preference.dart';

class ListAPIguest extends StatefulWidget {
  const ListAPIguest({Key? key}) : super(key: key);

  @override
  DashboardPage createState() => DashboardPage();
}

class ServicesApi {
  static const String url = Connection.myrepData;
  static Future<List<UserModel>> getUsers() async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: {'x-tyk-authorization': 'foo'});
      if (200 == response.statusCode) {
        final List<UserModel> users = userAPIModelFromJson(response.body);
        return users;
      } else {
        return <UserModel>[];
      }
    } catch (e) {
      return <UserModel>[];
    }
  }
}

class DashboardPage extends State<ListAPIguest> {
  List<UserModel> usersFiltered = [];
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
      filterUsersByUser();
    });
  }

  void filterUsersByUser() {
    if (currentUser != null) {
      String userName = EncryptionUtils.decrypt(currentUser!.username);
      ServicesApi.getUsers().then((users) {
        setState(() {
          usersFiltered =
              users.where((user) => user.org_id == userName).toList();
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
                child: const Text('API Files',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
              ),
              Container(
                width: 800,
                color: const Color(0xFFE7E7E7),
                child: const Text('APIs',
                    style: TextStyle(color: Color(0xFFB6B0B0))),
              ),
            ])),
        const SizedBox(
          height: 10,
        ),
        DataTable(
          columns: <DataColumn>[
            DataColumn(
              label: Text('Listen Path', style: GoogleFonts.albertSans()),
            ),
            DataColumn(
              label: Text('Keys', style: GoogleFonts.albertSans()),
            ),
            const DataColumn(
              label: Text(''),
            )
          ],
          rows: List.generate(
            usersFiltered.length,
            (index) => DataRow(
              cells: <DataCell>[
                DataCell(Text(usersFiltered[index].proxy.listen_path)),
                DataCell(Text(usersFiltered[index].request_signing.key_id)),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                          text: usersFiltered[index].request_signing.key_id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Key copied to clipboard'),
                          backgroundColor: Colors.purple,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
