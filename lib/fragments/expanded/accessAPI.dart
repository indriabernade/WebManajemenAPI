import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

class AccessAPI extends StatefulWidget {
  const AccessAPI({super.key});

  @override
  AccessAPIPage createState() => AccessAPIPage();
}

class AccessAPIPage extends State<AccessAPI> {
  String responseText = '';
  bool isLoading = false;
  final listen_path = TextEditingController();
  final key_id = TextEditingController();

  Future<void> fetchData() async {
    String listenPath = listen_path.text;
    String keyId = key_id.text;

    setState(() {
      isLoading = true; // Set loading state to true
    });

    var headers = {'Authorization': keyId};
    var request = http.Request(
        'GET', Uri.parse('https://apicore.myrepublic.net.id/tyk2$listenPath'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      setState(() {
        responseText = responseBody;
      });
    } else {
      setState(() {
        responseText = response.reasonPhrase!;
      });
    }

    setState(() {
      isLoading = false; // Set loading state to false
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SizedBox(width: 16),
          isLoading
              ? const Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : const SizedBox(width: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Html(data: responseText),
            ),
          ),
          Container(
            width: 250,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(15.0),
                    hintText: 'ex. /hello-world/',
                    labelText: 'Listen Path',
                    border: OutlineInputBorder(),
                  ),
                  controller: listen_path,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(15.0),
                    labelText: 'Key ID',
                    border: OutlineInputBorder(),
                  ),
                  controller: key_id,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isLoading ? null : () => fetchData(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[300],
                  ),
                  child: Text(isLoading ? 'Loading...' : 'ACCESS API'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
