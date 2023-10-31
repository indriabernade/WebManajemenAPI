import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import '../../connection/connectHost.dart';
import '../../model/api.dart';
import '../../model/user.dart';
import '../../userPreferences/user_preference.dart';

class ChartData {
  final String date;
  final int count;

  ChartData(this.date, this.count);
}

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  DashboardPage createState() => DashboardPage();
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

class DashboardPage extends State<Dashboard> {
  String? receivedToken;
  int? allUsers;
  int? allAPIs;
  User? currentUser;
  List<User> usersFiltered = [];

  String selectedMonth = "August"; // Default selected month

  final List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

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

  List<charts.Series<ChartData, String>> _createSeriesData(
      String desiredMonth) {
    final Map<String, int> countMap = {};

    // Count the occurrences of each date
    for (final user in usersFiltered) {
      final formattedDate = DateFormat.yMMMMd().format(user.created_at);
      final month = DateFormat.MMMM().format(user.created_at);

      // Check if the current date's month matches the desired month
      if (month == desiredMonth) {
        if (countMap.containsKey(formattedDate)) {
          countMap[formattedDate] = countMap[formattedDate]! + 1;
        } else {
          countMap[formattedDate] = 1;
        }
      }
    }

    final List<ChartData> data = countMap.entries
        .map((entry) => ChartData(entry.key, entry.value))
        .toList();

    return [
      charts.Series<ChartData, String>(
        id: 'UserCount',
        domainFn: (ChartData userCount, _) => userCount.date,
        measureFn: (ChartData userCount, _) => userCount.count,
        data: data,
        labelAccessorFn: (ChartData userCount, _) =>
            '${userCount.date}: ${userCount.count}',
        colorFn: (ChartData userCount, _) =>
            charts.ColorUtil.fromDartColor(Colors.purple[200]!),
      ),
    ];
  }

  Future<void> getUserInfo() async {
    String? storedToken = await Storage.getToken();
    List<User> users = await Servicesdb.getUsers();
    List<UserModel> apis = await ServicesApi.getUsers();
    User? userInfo = await Storage.readUserInfo();
    int jumlahUser = users.length;
    int jumlahAPI = apis.length;
    setState(() {
      currentUser = userInfo;
      receivedToken = storedToken;
      allUsers = jumlahUser;
      allAPIs = jumlahAPI;
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
    return Center(
        child: SingleChildScrollView(
      controller: _scrollController5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),
          DropdownButton<String>(
            value: selectedMonth,
            onChanged: (String? newValue) {
              setState(() {
                selectedMonth = newValue!;
              });
            },
            items: months.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SizedBox(height: 5),
          Container(
            width: 400,
            height: 300,
            child: SizedBox(
              height: 300,
              child: Column(
                children: [
                  Expanded(
                    child: charts.BarChart(
                      _createSeriesData(selectedMonth),
                      animate: true,
                      domainAxis: const charts.OrdinalAxisSpec(
                        renderSpec: charts.SmallTickRendererSpec(
                          labelStyle: charts.TextStyleSpec(
                            color: charts.MaterialPalette.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  const Text('User Terdaftar per Tanggal'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth <= 600) {
                // Page is minimized, display as a column
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 400,
                      color: const Color(0xFFE7E7E7),
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.fromLTRB(20, 15, 100, 15),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Container(
                            width: 400,
                            color: const Color(0xFFE7E7E7),
                            child: Column(
                              children: [
                                Container(
                                  width: 400,
                                  height: 30,
                                  color: const Color(0xFFE7E7E7),
                                  child: const Text(
                                    'Jumlah Pengguna Terdaftar',
                                    style: TextStyle(color: Color(0xFFB6B0B0)),
                                  ),
                                ),
                                Container(
                                  width: 400,
                                  color: const Color(0xFFE7E7E7),
                                  child: allUsers != null
                                      ? SelectableText(
                                          allUsers.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 50,
                                          ),
                                        )
                                      : const Text('No user found.'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 400,
                      color: const Color(0xFFE7E7E7),
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.fromLTRB(20, 15, 100, 15),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Container(
                            width: 400,
                            color: const Color(0xFFE7E7E7),
                            child: Column(
                              children: [
                                Container(
                                  width: 400,
                                  height: 30,
                                  color: const Color(0xFFE7E7E7),
                                  child: const Text(
                                    'Jumlah API files Terdaftar',
                                    style: TextStyle(color: Color(0xFFB6B0B0)),
                                  ),
                                ),
                                Container(
                                  width: 400,
                                  color: const Color(0xFFE7E7E7),
                                  child: allAPIs != null
                                      ? SelectableText(
                                          allAPIs.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 50,
                                          ),
                                        )
                                      : const Text('No user found.'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                // Page is not minimized, display as a row
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 400,
                      color: const Color(0xFFE7E7E7),
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.fromLTRB(20, 15, 100, 15),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Container(
                            width: 400,
                            color: const Color(0xFFE7E7E7),
                            child: Column(
                              children: [
                                Container(
                                  width: 400,
                                  height: 30,
                                  color: const Color(0xFFE7E7E7),
                                  child: const Text(
                                    'Jumlah Pengguna Terdaftar',
                                    style: TextStyle(color: Color(0xFFB6B0B0)),
                                  ),
                                ),
                                Container(
                                  width: 400,
                                  color: const Color(0xFFE7E7E7),
                                  child: allUsers != null
                                      ? SelectableText(
                                          allUsers.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 50,
                                          ),
                                        )
                                      : const Text('No user found.'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 400,
                      color: const Color(0xFFE7E7E7),
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.fromLTRB(20, 15, 100, 15),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Container(
                            width: 400,
                            color: const Color(0xFFE7E7E7),
                            child: Column(
                              children: [
                                Container(
                                  width: 400,
                                  height: 30,
                                  color: const Color(0xFFE7E7E7),
                                  child: const Text(
                                    'Jumlah API files Terdaftar',
                                    style: TextStyle(color: Color(0xFFB6B0B0)),
                                  ),
                                ),
                                Container(
                                  width: 400,
                                  color: const Color(0xFFE7E7E7),
                                  child: allAPIs != null
                                      ? SelectableText(
                                          allAPIs.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 50,
                                          ),
                                        )
                                      : const Text('No user found.'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 10),
          Container(
            color: const Color(0xFFE7E7E7),
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 800,
                  height: 30,
                  color: const Color(0xFFE7E7E7),
                  child: Row(
                    children: [
                      RichText(
                        text: const TextSpan(
                          //style: Theme.of(context).textTheme.body1,
                          children: [
                            WidgetSpan(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2.0),
                                child: Icon(Icons.info_outline),
                              ),
                            ),
                            TextSpan(
                              text: 'JWT Token',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      /*const Text(
                        '   (Silahkan salin token dibawah untuk validasi user)',
                        style: TextStyle(
                            color: Color.fromARGB(255, 141, 135, 135)),
                      ),*/
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          if (receivedToken != null) {
                            Clipboard.setData(
                                ClipboardData(text: receivedToken!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Token copied to clipboard'),
                                backgroundColor: Colors.purple,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 800,
                  color: const Color(0xFFE7E7E7),
                  child: receivedToken != null
                      ? SelectableText(
                          receivedToken!,
                          style: const TextStyle(color: Color(0xFFB6B0B0)),
                        )
                      : const Text('No token found.'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          /*Container(
            color: const Color(0xFFE7E7E7),
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            child: Column(
              children: [
                Container(
                  width: 800,
                  height: 80,
                  color: const Color(0xFFE7E7E7),
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      if (constraints.maxWidth < 600) {
                        // Modify the width value as per your requirement
                        return Column(
                          children: [
                            Column(
                              children: [
                                RichText(
                                  text: const TextSpan(
                                    //style: Theme.of(context).textTheme.body1,
                                    children: [
                                      WidgetSpan(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 2.0),
                                          child: Icon(Icons.info_outline),
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'About',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            /*ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.purple[500]!),
                              ),
                              onPressed: () {
                                final noticeController = TextEditingController(
                                    text: currentUser!.notice);
                                final userId = currentUser!.id;
                                Future<void> _updateUserRecord() async {
                                  final notice = noticeController.text;
                                  final updateId = userId;

                                  var url = Connection.notice;

                                  try {
                                    var response =
                                        await http.post(Uri.parse(url), body: {
                                      "id": updateId.toString(),
                                      "notice": notice,
                                    });
                                    print(response);
                                    if (response.statusCode == 200) {
                                      var resBodyRegister =
                                          jsonDecode(response.body);
                                      if (resBodyRegister['success'] == true) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('Pesan Terkirim'),
                                            backgroundColor: Colors
                                                .purple, // Change to your desired color
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                        Navigator.of(context).pop();
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Pesan Gagal Terkirim'),
                                            backgroundColor: Colors
                                                .purple, // Change to your desired color
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
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: TextFormField(
                                                      //initialValue: initialvalue1,
                                                      decoration:
                                                          const InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets.all(
                                                                15.0),
                                                        labelText: 'Text',
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                      controller:
                                                          noticeController,
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: ElevatedButton(
                                                          onPressed:
                                                              _updateUserRecord,
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            primary:
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
                              },
                              child: const Text('Kirim pesan ke Admin'),
                            ),*/
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            RichText(
                              text: const TextSpan(
                                //style: Theme.of(context).textTheme.body1,
                                children: [
                                  WidgetSpan(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 2.0),
                                      child: Icon(Icons.info_outline),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'About',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.purple[500]!),
                              ),
                              onPressed: () {
                                final noticeController = TextEditingController(
                                    text: currentUser!.notice);
                                final userId = currentUser!.id;
                                Future<void> _updateUserRecord() async {
                                  final notice = noticeController.text;
                                  final updateId = userId;

                                  var url = Connection.notice;

                                  try {
                                    var response =
                                        await http.post(Uri.parse(url), body: {
                                      "id": updateId.toString(),
                                      "notice": notice,
                                    });
                                    print(response);
                                    if (response.statusCode == 200) {
                                      var resBodyRegister =
                                          jsonDecode(response.body);
                                      if (resBodyRegister['success'] == true) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('Pesan Terkirim'),
                                            backgroundColor: Colors
                                                .purple, // Change to your desired color
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                        Navigator.of(context).pop();
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Pesan Gagal Terkirim'),
                                            backgroundColor: Colors
                                                .purple, // Change to your desired color
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
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: TextFormField(
                                                      //initialValue: initialvalue1,
                                                      decoration:
                                                          const InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets.all(
                                                                15.0),
                                                        labelText: 'Text',
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                      controller:
                                                          noticeController,
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: ElevatedButton(
                                                          onPressed:
                                                              _updateUserRecord,
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            primary: Colors
                                                                .purple[300],
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
                              },
                              child: const Text('Kirim pesan ke Admin'),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 800,
                  height: 30,
                  color: const Color(0xFFE7E7E7),
                  child: const Text('Selamat datang ke web manajemen API ...'),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),*/
        ],
      ),
    ));
  }
}
