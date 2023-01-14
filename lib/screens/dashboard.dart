import 'package:event_manager/screens/search.dart';
import 'package:flutter/material.dart';

import 'dbHelper/NodeModel.dart';
import 'dbHelper/mongodb.dart';

class Dashboard extends StatefulWidget {
  Dashboard({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  List<Map<String, dynamic>>? connectedDevicesList;
  List<Map<String, dynamic>>? logsList;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String dropdownValue = 'Zabbix server';
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Select Device: '),
                SizedBox(width: 8),
                FutureBuilder(
                  future: MongoDatabase.getNodeData(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                    if (snapshot.hasData) {
                      widget.connectedDevicesList = snapshot.data;
                      return DropdownButton<String>(
                        value: dropdownValue,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold),
                        underline: Container(
                          height: 2,
                          color: Colors.white70,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                          });
                        },
                        items: snapshot.data!.map((document) {
                          //print("sa : " + document['NodeName'].toString());
                          return DropdownMenuItem<String>(
                            value: document['NodeName'],
                            child: Text(document['NodeName']),
                          );
                        }).toList(),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: MongoDatabase.getLogData(),
          builder: (
            context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return (const Center(
                child: CircularProgressIndicator(),
              ));
            } else {
              if (snapshot.hasData) {
                widget.logsList = snapshot.data;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Image(
                      image: AssetImage('assets/healthy.png'),
                      height: 350,
                      width: 350,
                    ),
                    SizedBox(height: 10),
                    const Text(
                      'My Text',
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextBox('Connected Device',
                            widget.connectedDevicesList?.length.toString()),
                        SizedBox(width: 35),
                        TextBox('Logs Analyzed',
                            CalculateAnalyzedLogs().toString()),
                        SizedBox(width: 10),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FutureBuilder(
                          future: getMostCriticalDevice(),
                          builder: (context, AsyncSnapshot<String> snapshot) {
                            if (snapshot.hasData) {
                              final node = snapshot.data!;
                              return TextBox("Most critical device: ", node);
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          },
                        ),
                        SizedBox(width: 35),
                        FutureBuilder(
                          future: getMostCommonAlert(),
                          builder: (context, AsyncSnapshot<String> snapshot) {
                            if (snapshot.hasData) {
                              final alertName = snapshot.data!;
                              return TextBox('Most Critical Event', alertName);
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          },
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextBox('Most Critical Node', "box 4"),
                        SizedBox(width: 35),
                        FutureBuilder(
                          future: getMostCommonSourceForMostCommonAlert(),
                          builder: (context, AsyncSnapshot<String> snapshot) {
                            if (snapshot.hasData) {
                              final sourceName = snapshot.data!;
                              return TextBox(
                                  'Most Critical Event Source', sourceName);
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          },
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ],
                );
              } else {
                return const Center(
                  child: Text("No Data Avaliable"),
                );
              }
            }
          },
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  int CalculateAnalyzedLogs() {
    int count = 0;
    // print("Loglistt " + widget.logsList!.length.toString());
    for (var i = 0; i < widget.logsList!.length; i++) {
      for (var j = 0; j < widget.connectedDevicesList!.length; j++) {
        //print("saa: " + widget.logsList!.elementAt(i)['Node']);
        // print("ass: " + widget.connectedDevicesList!.elementAt(j)['NodeName']);
        if (widget.logsList!.elementAt(i)['Node'] ==
            widget.connectedDevicesList!.elementAt(j)['NodeName']) {
          count++;
        }
      }
    }
    print("count" + count.toString());
    return count;
  }

  Future<String> getMostCriticalDevice() async {
    final logs = await MongoDatabase.getLogData();
    final connectedDevices = await MongoDatabase.getNodeData();
    final connectedDevicesList =
        connectedDevices.map((d) => d['NodeName']).toList();
    final counts = Map<String, int>();
    final weights = {
      'Critical': 5,
      'Major': 4,
      'Warning': 3,
      'Minor': 2,
      'Normal': 1,
      'Unknown': 0
    };

    for (final log in logs) {
      if (connectedDevicesList.contains(log["Node"])) {
        final node = log["Node"];
        final severity = log["Severity"];
        final weight = weights[severity];
        counts[node] =
            (counts.containsKey(node) ? counts[node]! + weight! : weight)!;
      }
    }

    var mostCriticalDevice = "";
    var maxScore = 0;
    for (final node in counts.keys) {
      if (counts[node]! > maxScore) {
        maxScore = counts[node]!;
        mostCriticalDevice = node;
      }
    }

    return mostCriticalDevice;
  }

  Future<String> getMostCommonAlert() async {
    final logs = await MongoDatabase.getLogData();
    final connectedDevices = await MongoDatabase.getNodeData();
    final connectedDevicesList =
        connectedDevices.map((d) => d['NodeName']).toList();
    final counts = Map<String, int>();

    for (final log in logs) {
      if (connectedDevicesList.contains(log["Node"])) {
        final alertName = log["AlertName"];
        counts[alertName] =
            counts.containsKey(alertName) ? counts[alertName]! + 1 : 1;
      }
    }

    var mostCommonAlert = "";
    var maxCount = 0;
    for (final alertName in counts.keys) {
      if (counts[alertName]! > maxCount) {
        maxCount = counts[alertName]!;
        mostCommonAlert = alertName;
      }
    }

    return mostCommonAlert;
  }

  Future<String> getMostCommonSourceForMostCommonAlert() async {
    final logs = await MongoDatabase.getLogData();
    final connectedDevices = await MongoDatabase.getNodeData();
    final connectedDevicesList =
        connectedDevices.map((d) => d['NodeName']).toList();
    final counts = Map<String, Map<String, int>>();

    for (final log in logs) {
      if (connectedDevicesList.contains(log["Node"])) {
        final alertName = log["AlertName"];
        final source = log["Source"];

        if (!counts.containsKey(alertName)) {
          counts[alertName] = Map<String, int>();
        }

        counts[alertName]![source] = counts[alertName]!.containsKey(source)
            ? counts[alertName]![source]! + 1
            : 1;
      }
    }

    var mostCommonAlert = "";
    var maxCount = 0;
    for (final alertName in counts.keys) {
      if (counts[alertName]!.values.reduce((a, b) => a + b) > maxCount) {
        maxCount = counts[alertName]!.values.reduce((a, b) => a + b);
        mostCommonAlert = alertName;
      }
    }

    var mostCommonSource = "";
    maxCount = 0;
    for (final source in counts[mostCommonAlert]!.keys) {
      if (counts[mostCommonAlert]![source]! > maxCount) {
        maxCount = counts[mostCommonAlert]![source]!;
        mostCommonSource = source;
      }
    }
    return mostCommonSource;
  }
}

class TextBox extends StatelessWidget {
  final String? title;
  final String? value;

  const TextBox(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.blueGrey),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: Text(title!,
                      style: TextStyle(fontSize: 18, color: Colors.amberAccent),
                      softWrap: true),
                )
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              value!,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber),
              softWrap: true,
            ),
          ],
        ));
  }
}
