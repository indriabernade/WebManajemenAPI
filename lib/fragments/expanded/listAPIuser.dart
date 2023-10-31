import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../algorithm/aesBase64.dart';
import '../../connection/connectHost.dart';
import '../../model/api.dart';
import '../../model/user.dart';
import '../../userPreferences/user_preference.dart';

class UserAPIs extends StatefulWidget {
  const UserAPIs({Key? key}) : super(key: key);

  @override
  UserAPIsPage createState() => UserAPIsPage();
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

class UserAPIsPage extends State<UserAPIs> {
  final GlobalKey<FormState> _formAPI = GlobalKey<FormState>();
  bool isLoading = false;
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

  final _nameController = TextEditingController();
  final _apiController = TextEditingController();
  final _orgController = TextEditingController();
  final _pathController = TextEditingController();
  final _urlController = TextEditingController();
  final _authController = TextEditingController();

  final GlobalKey<_DataTableState> _dataTableKey2 =
      GlobalKey<_DataTableState>();

  final ScrollController _scrollController6 = ScrollController();
  @override
  void dispose() {
    _scrollController6.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SingleChildScrollView(
      controller: _scrollController6,
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
                child: const Text('APIs/  edit APIs',
                    style: TextStyle(color: Color(0xFFB6B0B0))),
              ),
            ])),
        const SizedBox(
          height: 10,
        ),
        Container(
            width: 915,
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: RichText(
                          text: const TextSpan(
                            //style: Theme.of(context).textTheme.body1,
                            children: [
                              WidgetSpan(
                                child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 2.0),
                                    child: Icon(Icons.info_outline)),
                              ),
                              TextSpan(
                                  text: 'APIs details',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              //TextSpan(text: 'By Michael'),
                            ],
                          ),
                        ),
                        content: Container(
                            width: 700,
                            padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                            child: SingleChildScrollView(
                                child: Form(
                              key: _formAPI,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      const Text('Name'),
                                      const SizedBox(width: 50),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _nameController,
                                          decoration: const InputDecoration(
                                            hintText: 'ex. Hello-World',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Text('API ID'),
                                      const SizedBox(width: 50),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _apiController,
                                          decoration: const InputDecoration(
                                            hintText: 'ex. Hello-World',
                                          ),
                                          validator: (val) {
                                            if (val!.isEmpty) {
                                              return 'Isian API ID wajib diisi!';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Text('Target User'),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _orgController,
                                          decoration: const InputDecoration(
                                            hintText: 'ex. username',
                                            helperText:
                                                'tidak wajib diisi jika API tidak ditampilkan ke user siapapun',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Text('Listen Path'),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _pathController,
                                          decoration: const InputDecoration(
                                            hintText: 'ex. /hello-world/',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Text('Target Url'),
                                      const SizedBox(width: 25),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _urlController,
                                          decoration: const InputDecoration(
                                            hintText:
                                                'ex. http://echo.tyk-demo.com:8080/',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Text('Auth Type'),
                                      const SizedBox(width: 25),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _authController,
                                          decoration: const InputDecoration(
                                            hintText:
                                                'ex. Basic ... / Bearer ...',
                                            helperText:
                                                'tidak wajib diisi jika API tidak terkunci',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ))),
                        actions: [
                          TextButton(
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.purple),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.purple),
                            ),
                            onPressed: () {
                              if (_formAPI.currentState!.validate()) {
                                // Perform form submission logic here
                                _addDataAPI();
                                Navigator.of(context).pop();
                              }
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
                label: const Text('CREATE API FILES'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[300]),
              ),
              const SizedBox(
                width: 10,
              ),
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
            ])),
        const SizedBox(
          height: 10,
        ),
        if (isLoading) // Display loading indicator if isLoading is true
          const CircularProgressIndicator(),
        if (!isLoading) _DataTable(key: _dataTableKey2),
      ]),
    ));
  }

  Future<void> _addDataAPI() async {
    String name = _nameController.text;
    String apiId = _apiController.text;
    String orgId = _orgController.text;
    String listenPath = _pathController.text;
    String targetUrl = _urlController.text;
    String authorization = _authController.text;

    var headers = {
      'Content-Type': 'application/json',
      'x-tyk-authorization': 'foo'
    };
    var request = http.Request('POST', Uri.parse(Connection.myrepData));
    request.body = json.encode({
      "name": name,
      "slug": EncryptionUtils.decrypt(currentUser!.username),
      "api_id": apiId,
      "org_id": orgId,
      "use_keyless": false,
      "auth": {"auth_header_name": "Authorization"},
      "definition": {"location": "header", "key": "x-api-version"},
      "version_data": {
        "not_versioned": true,
        "versions": {
          "Default": {
            "name": "Default",
            "use_extended_paths": true,
            "global_headers": {"Authorization": authorization}
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
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      _toServer();
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> _toServer() async {
    final apiResult =
        await http.get(Uri.parse(Connection.myrepReload), headers: {
      'x-tyk-authorization': 'foo',
      'Access-Control-Allow-Origin': '*',
      'Content-Type': 'application/json',
    });

    if (apiResult.statusCode == 200) {
      final jsonObject = jsonDecode(apiResult.body);
      print(jsonObject);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Data has updating! Please click UPDATE DATA to see the latest data'),
        backgroundColor: Colors.purple,
      ));
    } else {
      print(apiResult.statusCode);
    }
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
              label: Text('API Name', style: GoogleFonts.albertSans()),
            ),
            DataColumn(
              label: Text('API ID', style: GoogleFonts.albertSans()),
            ),
            DataColumn(
              label: Text('Target User', style: GoogleFonts.albertSans()),
            ),
            DataColumn(
              label: Text('Delete', style: GoogleFonts.albertSans()),
            ),
            DataColumn(
              label: Text('Edit', style: GoogleFonts.albertSans()),
            )
          ],
          rows: List.generate(
            usersFiltered.length,
            (index) => DataRow(
              cells: <DataCell>[
                DataCell(Text(usersFiltered[index].name)),
                DataCell(Text(usersFiltered[index].api_id)),
                DataCell(Text(usersFiltered[index].org_id)),
                DataCell(Visibility(
                    visible: usersFiltered[index].slug ==
                        EncryptionUtils.decrypt(currentUser!.username),
                    child: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          showDeleteConfirmationDialog(context, () async {
                            var headers = {'x-tyk-authorization': 'foo'};
                            var request = http.Request(
                                'DELETE',
                                Uri.parse(
                                    'https://apicore.myrepublic.net.id/tyk/apis/${usersFiltered[index].api_id}/'));

                            request.headers.addAll(headers);

                            http.StreamedResponse response =
                                await request.send();

                            if (response.statusCode == 200) {
                              print(await response.stream.bytesToString());

                              var headers = {'x-tyk-authorization': 'foo'};
                              var request = http.Request(
                                  'GET', Uri.parse(Connection.myrepReload));

                              request.headers.addAll(headers);

                              http.StreamedResponse response1 =
                                  await request.send();

                              if (response1.statusCode == 200) {
                                print(await response1.stream.bytesToString());
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                      'Data is deleted! Please click UPDATE DATA to see the latest data'),
                                  backgroundColor: Colors.purple,
                                ));
                              } else {
                                print(response1.reasonPhrase);
                              }
                            } else {
                              print(response.reasonPhrase);
                            }
                          });
                        } //disini
                        ))),
                DataCell(Visibility(
                    visible: usersFiltered[index].slug ==
                        EncryptionUtils.decrypt(currentUser!.username),
                    child: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          if (usersFiltered[index].slug ==
                              EncryptionUtils.decrypt(currentUser!.username)) {
                            final nameController = TextEditingController(
                                text: usersFiltered[index].name);
                            final slugController = TextEditingController(
                                text: usersFiltered[index].slug);
                            final orgController = TextEditingController(
                                text: usersFiltered[index].org_id);
                            final pathController = TextEditingController(
                                text: usersFiltered[index].proxy.listen_path);
                            final urlController = TextEditingController(
                                text: usersFiltered[index].proxy.target_url);
                            final keyController = TextEditingController(
                                text: usersFiltered[index]
                                    .request_signing
                                    .key_id);
                            final authController = TextEditingController(
                                text: usersFiltered[index]
                                    .version_data
                                    .versions
                                    .default_
                                    .global_headers
                                    .authorization);

                            Future<void> _updateList() async {
                              String name = nameController.text;
                              //String slug = slugController.text;
                              String orgId = orgController.text;
                              String listenPath = pathController.text;
                              String targetUrl = urlController.text;
                              String keyId = keyController.text;
                              String auth = authController.text;

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
                                "slug": EncryptionUtils.decrypt(
                                    currentUser!.username),
                                "api_id": usersFiltered[index].api_id,
                                "org_id": orgId,
                                "use_keyless": false,
                                "auth": {"auth_header_name": "Authorization"},
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
                                      "global_headers": {"Authorization": auth}
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
                                "request_signing": {"key_id": keyId}
                              });
                              request.headers.addAll(headers);

                              http.StreamedResponse response =
                                  await request.send();

                              if (response.statusCode == 200) {
                                _saveList();
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                      'Data has updating! Please click UPDATE DATA to see the latest data'),
                                  backgroundColor: Colors.purple,
                                ));
                              } else {
                                print(response.reasonPhrase);
                              }
                            }

                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: Stack(
                                      children: <Widget>[
                                        Form(
                                          child: SingleChildScrollView(
                                              child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextFormField(
                                                  //initialValue: initialvalue1,
                                                  decoration:
                                                      const InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.all(15.0),
                                                    labelText: 'Name',
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  controller: nameController,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextFormField(
                                                  //initialValue: initialvalue2,
                                                  decoration:
                                                      const InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.all(15.0),
                                                    labelText: 'Slug',
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  controller: slugController,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextFormField(
                                                  //initialValue: initialvalue3,
                                                  decoration:
                                                      const InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.all(15.0),
                                                    labelText: 'Target User',
                                                    border:
                                                        OutlineInputBorder(),
                                                    helperText:
                                                        'tidak wajib diisi jika API tidak ditampilkan ke user siapapun',
                                                  ),
                                                  controller: orgController,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextFormField(
                                                  //initialValue: initialvalue4,
                                                  decoration:
                                                      const InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.all(15.0),
                                                    labelText: 'Listen Path',
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  controller: pathController,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextFormField(
                                                  //initialValue: initialvalue5,
                                                  decoration:
                                                      const InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.all(15.0),
                                                    labelText: 'Target URL',
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  controller: urlController,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextFormField(
                                                  decoration:
                                                      const InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.all(15.0),
                                                    labelText: 'Authorization',
                                                    border:
                                                        OutlineInputBorder(),
                                                    // Set helperText untuk menampilkan pesan bahwa TextFormField tidak wajib diisi
                                                    helperText:
                                                        'tidak wajib diisi jika API tidak terkunci',
                                                  ),
                                                  controller: authController,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextFormField(
                                                  //initialValue: initialvalue5,
                                                  decoration:
                                                      const InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.all(15.0),
                                                    labelText: 'API Key',
                                                    border:
                                                        OutlineInputBorder(),
                                                    helperText:
                                                        'tidak wajib diisi jika Key API files belum terbuat',
                                                  ),
                                                  controller: keyController,
                                                ),
                                              ),
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: ElevatedButton(
                                                      onPressed: _updateList,
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.purple,
                                                      ),
                                                      child: const Text(
                                                          'Submit'))),
                                            ],
                                          )),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          }
                        })))
              ],
            ),
          ),
        ));
  }

  void showDeleteConfirmationDialog(
      BuildContext context, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content:
              const Text('Are you sure you want to delete this API files?'),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.purple),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.purple),
              ),
              child: const Text('Delete'),
              onPressed: () {
                // Call the onDelete callback to perform the deletion
                onDelete();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
