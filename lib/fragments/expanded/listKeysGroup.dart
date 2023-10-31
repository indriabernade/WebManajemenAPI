import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../../algorithm/aesBase64.dart';
import '../../connection/connectHost.dart';
import '../../model/api.dart';
import '../../model/user.dart';
import '../../userPreferences/user_preference.dart';

class ListKeysUser extends StatefulWidget {
  const ListKeysUser({Key? key}) : super(key: key);

  @override
  ListKeysUserPage createState() => ListKeysUserPage();
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

class ListKeysUserPage extends State<ListKeysUser> {
  List<UserModel> usersFiltered = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    setState(() {
      ServicesApi.getUsers().then((users) {
        setState(() {
          usersFiltered = users;
        });
      });
    });
  }

  final ScrollController _scrollController7 = ScrollController();
  @override
  void dispose() {
    _scrollController7.dispose();
    super.dispose();
  }

  final GlobalKey<_DataTableState> _dataTableKey2 =
      GlobalKey<_DataTableState>();

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SingleChildScrollView(
            controller: _scrollController7,
            child: Column(
              children: [
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
                        child: const Text('Create API Keys',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 20)),
                      ),
                      Container(
                        width: 800,
                        color: const Color(0xFFE7E7E7),
                        child: const Text('Keys/  add or edit Keys',
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
                if (!isLoading) _DataTable(key: _dataTableKey2),
              ],
            )));
  }
}

Future<void> _saveList() async {
  var headers = {'x-tyk-authorization': 'foo'};
  var request = http.Request('GET', Uri.parse(Connection.myrepReload));

  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    print(await response.stream.bytesToString());
    // refreshList();
  } else {
    print(response.reasonPhrase);
  }
}

Future<void> _toServer() async {
  final apiResult = await http.get(Uri.parse(Connection.myrepReload), headers: {
    'x-tyk-authorization': 'foo',
    'Access-Control-Allow-Origin': '*',
    'Content-Type': 'application/json',
  });

  if (apiResult.statusCode == 200) {
    final jsonObject = jsonDecode(apiResult.body);
    print(jsonObject);
  } else {
    print(apiResult.statusCode);
  }
}

class _DataTable extends StatefulWidget {
  const _DataTable({Key? key}) : super(key: key);

  @override
  _DataTableState createState() => _DataTableState();
}

class _DataTableState extends State<_DataTable> {
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
      ServicesApi.getUsers().then((users) {
        setState(() {
          usersFiltered = users;
        });
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
          columns: <DataColumn>[
            DataColumn(
              label: Text('Listen Path', style: GoogleFonts.albertSans()),
            ),
            DataColumn(
              label: Text('Key', style: GoogleFonts.albertSans()),
            ),
            /*DataColumn(
                        label:
                            Text('Created by', style: GoogleFonts.albertSans()),
                      ),*/
            DataColumn(
              label: Text('Copy Key', style: GoogleFonts.albertSans()),
            ),
            DataColumn(
              label: Text('Delete', style: GoogleFonts.albertSans()),
            ),
            DataColumn(
              label: Text('Add Key', style: GoogleFonts.albertSans()),
            ),
          ],
          rows: List.generate(
              usersFiltered.length,
              (index) => DataRow(cells: <DataCell>[
                    DataCell(SelectableText(
                        (usersFiltered[index].proxy.listen_path))),
                    DataCell(SelectableText(
                        usersFiltered[index].request_signing.key_id)),

                    //DataCell(Text(usersFiltered[index].slug)),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                              text:
                                  usersFiltered[index].request_signing.key_id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Key copied to clipboard'),
                              backgroundColor: Colors.purple,
                            ),
                          );
                        },
                      ),
                    ),
                    DataCell(Visibility(
                        visible: usersFiltered[index].slug ==
                            EncryptionUtils.decrypt(currentUser!.username),
                        child: IconButton(
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
                                                MaterialStateProperty.all<
                                                    Color>(Colors.purple),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          style: ButtonStyle(
                                            foregroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.purple),
                                          ),
                                          onPressed: () async {
                                            if (usersFiltered[index].slug ==
                                                EncryptionUtils.decrypt(
                                                    currentUser!.username)) {
                                              var headers = {
                                                'x-tyk-authorization': 'foo'
                                              };
                                              var request = http.Request(
                                                  'DELETE',
                                                  Uri.parse(
                                                      'https://apicore.myrepublic.net.id/tyk/keys/${usersFiltered[index].request_signing.key_id}'));

                                              request.headers.addAll(headers);

                                              http.StreamedResponse response =
                                                  await request.send();
                                              if (response.statusCode == 200) {
                                                _saveList();
                                                String name =
                                                    usersFiltered[index].name;
                                                String slug =
                                                    usersFiltered[index].slug;
                                                String orgId =
                                                    usersFiltered[index].org_id;
                                                String apiId =
                                                    usersFiltered[index].api_id;
                                                String listenPath =
                                                    usersFiltered[index]
                                                        .proxy
                                                        .listen_path;
                                                String targetUrl =
                                                    usersFiltered[index]
                                                        .proxy
                                                        .target_url;
                                                String auth =
                                                    usersFiltered[index]
                                                        .version_data
                                                        .versions
                                                        .default_
                                                        .global_headers
                                                        .authorization;

                                                var headers = {
                                                  'Content-Type':
                                                      'application/json',
                                                  'x-tyk-authorization': 'foo'
                                                };
                                                var request = http.Request(
                                                    'PUT',
                                                    Uri.parse(
                                                        'https://apicore.myrepublic.net.id/tyk/apis/${usersFiltered[index].api_id}/'));
                                                request.body = json.encode({
                                                  "name": name,
                                                  "slug": slug,
                                                  "api_id": apiId,
                                                  "org_id": orgId,
                                                  "use_keyless": false,
                                                  "auth": {
                                                    "auth_header_name":
                                                        "Authorization"
                                                  },
                                                  "definition": {
                                                    "location": "header",
                                                    "key": "x-api-version"
                                                  },
                                                  "version_data": {
                                                    "not_versioned": true,
                                                    "versions": {
                                                      "Default": {
                                                        "name": "Default",
                                                        "use_extended_paths":
                                                            true,
                                                        "global_headers": {
                                                          "Authorization": auth
                                                        }
                                                      }
                                                    }
                                                  },
                                                  "proxy": {
                                                    "listen_path": listenPath,
                                                    "target_url": targetUrl,
                                                    "strip_listen_path": true,
                                                    "target_rewrite": {
                                                      "strip_path": true
                                                    }
                                                  },
                                                  "active": true,
                                                  "request_signing": {
                                                    "key_id": ""
                                                  }
                                                });
                                                request.headers.addAll(headers);

                                                http.StreamedResponse response =
                                                    await request.send();

                                                if (response.statusCode ==
                                                    200) {
                                                  Navigator.of(context).pop();
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                          const SnackBar(
                                                    content: Text(
                                                        'Key has deleted!'),
                                                    backgroundColor:
                                                        Colors.purple,
                                                  ));
                                                } else {
                                                  print(response.reasonPhrase);
                                                }
                                              } else {
                                                print(response.reasonPhrase);
                                              }
                                            }
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ]);
                                });
                          },
                        ))),
                    DataCell(Visibility(
                        visible: usersFiltered[index].slug ==
                            EncryptionUtils.decrypt(currentUser!.username),
                        child: IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () async {
                              if (usersFiltered[index].slug ==
                                  EncryptionUtils.decrypt(
                                      currentUser!.username)) {
                                String name = usersFiltered[index].name;
                                String slug = usersFiltered[index].slug;
                                String orgId = usersFiltered[index].org_id;
                                String apiId = usersFiltered[index].api_id;
                                String listenPath =
                                    usersFiltered[index].proxy.listen_path;
                                String targetUrl =
                                    usersFiltered[index].proxy.target_url;
                                String auth = usersFiltered[index]
                                    .version_data
                                    .versions
                                    .default_
                                    .global_headers
                                    .authorization;

                                var jsonshow = {
                                  "allowance": 1000,
                                  "rate": 1000,
                                  "per": 1,
                                  "expires": -1,
                                  "quota_max": -1,
                                  "org_id": "1",
                                  "quota_renews": 1449051461,
                                  "quota_remaining": -1,
                                  "quota_renewal_rate": 60,
                                  "access_rights": {
                                    apiId: {
                                      "api_id": apiId,
                                      "api_name": name,
                                      "versions": ["Default"]
                                    }
                                  },
                                  "meta_data": {}
                                };
                                final String jsonString = jsonEncode(jsonshow);

                                final apiResult = await http.post(
                                    Uri.parse(Connection.myrepKeys),
                                    headers: {
                                      'x-tyk-authorization': 'foo',
                                      'Content-Type': 'application/json',
                                    },
                                    body: jsonString);

                                if (apiResult.statusCode == 200) {
                                  /*final jsonObject =
                                    jsonDecode(apiResult.body);*/
                                  final Map<String, dynamic> jsonObject =
                                      jsonDecode(apiResult.body);
                                  print(jsonObject);

                                  var headers = {
                                    'Content-Type': 'application/json',
                                    'x-tyk-authorization': 'foo'
                                  };
                                  var request = http.Request(
                                      'PUT',
                                      Uri.parse(
                                          'https://apicore.myrepublic.net.id/tyk/apis/${usersFiltered[index].api_id}/'));
                                  request.body = json.encode({
                                    "name": name,
                                    "slug": slug,
                                    "api_id": apiId,
                                    "org_id": orgId,
                                    "use_keyless": false,
                                    "auth": {
                                      "auth_header_name": "Authorization"
                                    },
                                    "definition": {
                                      "location": "header",
                                      "key": "x-api-version"
                                    },
                                    "version_data": {
                                      "not_versioned": true,
                                      "versions": {
                                        "Default": {
                                          "name": "Default",
                                          "use_extended_paths": true,
                                          "global_headers": {
                                            "Authorization": auth
                                          }
                                        }
                                      }
                                    },
                                    "proxy": {
                                      "listen_path": listenPath,
                                      "target_url": targetUrl,
                                      "strip_listen_path": true,
                                      "target_rewrite": {"strip_path": true}
                                    },
                                    "active": true,
                                    "request_signing": {
                                      "key_id": "${jsonObject['key']}"
                                    }
                                  });
                                  request.headers.addAll(headers);

                                  http.StreamedResponse response =
                                      await request.send();

                                  if (response.statusCode == 200) {
                                    //Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text(
                                          'Key has added! Please click UPDATE DATA to see the latest data'),
                                      backgroundColor: Colors.purple,
                                    ));
                                  } else {
                                    print(response.reasonPhrase);
                                  }
                                  _toServer();
                                } else {
                                  print(apiResult.statusCode);
                                  print(jsonshow);
                                  print(jsonString);
                                }
                              }
                            })))
                  ])),
        ));
  }
}
