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
  String dropdownValue = '101.169.213';
  @override
  Widget build(BuildContext context) {
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
                          return DropdownMenuItem<String>(
                            value: document['IP'],
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
                    FutureBuilder(
                      future: getDeviceHealth(dropdownValue),
                      builder: (context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasData) {
                          final healthCondition = snapshot.data!;
                          String imagePath;
                          if (healthCondition == "Healthy") {
                            imagePath = 'assets/healthy.png';
                          } else if (healthCondition == "Stable") {
                            imagePath = 'assets/stable.png';
                          } else {
                            imagePath = 'assets/worsening.png';
                          }
                          return Image(
                            image: AssetImage(imagePath),
                            height: 350,
                            width: 350,
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    FutureBuilder(
                      future: getDeviceHealth(dropdownValue),
                      builder: (context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasData) {
                          final healthCondition = snapshot.data!;
                          return Text(healthCondition,
                              style: TextStyle(fontSize: 24));
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FutureBuilder(
                          future: getConnectedDeviceCount(),
                          builder: (context, AsyncSnapshot<String> snapshot) {
                            if (snapshot.hasData) {
                              final connectedDeviceCount = snapshot.data!;
                              return TextBox(
                                  "Connected Device: ", connectedDeviceCount);
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          },
                        ),
                        SizedBox(width: 35),
                        FutureBuilder(
                          future: calculateAnalyzedLogs(),
                          builder: (context, AsyncSnapshot<String> snapshot) {
                            if (snapshot.hasData) {
                              final analyzedLogs = snapshot.data!;
                              return TextBox("Logs Analyzed: ", analyzedLogs);
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
                        FutureBuilder(
                          future: getMostCriticalNodeForMostCriticalDevice(),
                          builder: (context, AsyncSnapshot<String> snapshot) {
                            if (snapshot.hasData) {
                              final criticalNode = snapshot.data!;
                              return TextBox(
                                  'Most Critical Node', criticalNode);
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          },
                        ),
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

  Future<String> getConnectedDeviceCount() async {
    final connectedDevices = await MongoDatabase.getNodeData();
    final connectedDevicesList = connectedDevices.map((d) => d['IP']).toList();
    var count = connectedDevicesList.length.toString();
    return count;
  }

  Future<String> calculateAnalyzedLogs() async {
    int count = 0;
    final logs = await MongoDatabase.getLogData();
    final connectedDevices = await MongoDatabase.getNodeData();
    final connectedDevicesList = connectedDevices.map((d) => d['IP']).toList();

    for (final log in logs) {
      if (connectedDevicesList.contains(log["Ip"])) {
        count = count + 1;
      }
    }
    var analyzedLogs = count.toString();
    return analyzedLogs;
  }

  Future<String> getMostCriticalDevice() async {
    final logs = await MongoDatabase.getLogData();
    final connectedDevices = await MongoDatabase.getNodeData();
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
      final ip = log["Ip"];
      final severity = log["Severity"];
      final weight = weights[severity];
      final connectedDevice =
          connectedDevices.firstWhere((d) => d["IP"] == ip, orElse: () => {});
      if (connectedDevice.isNotEmpty) {
        final deviceName = connectedDevice["NodeName"];
        counts[deviceName] = (counts.containsKey(deviceName)
            ? counts[deviceName]! + weight!
            : weight)!;
      }
    }

    var mostCriticalDevice = "";
    var maxScore = 0;
    for (final deviceName in counts.keys) {
      if (counts[deviceName]! > maxScore) {
        maxScore = counts[deviceName]!;
        mostCriticalDevice = deviceName;
      }
    }

    return mostCriticalDevice;
  }

  Future<String> getMostCommonAlert() async {
    final logs = await MongoDatabase.getLogData();
    final connectedDevices = await MongoDatabase.getNodeData();
    final connectedDevicesList = connectedDevices.map((d) => d['IP']).toList();
    final counts = Map<String, int>();

    for (final log in logs) {
      if (connectedDevicesList.contains(log["Ip"])) {
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
    final connectedDevicesList = connectedDevices.map((d) => d['IP']).toList();
    final counts = Map<String, Map<String, int>>();

    for (final log in logs) {
      if (connectedDevicesList.contains(log["Ip"])) {
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

  Future<String> getMostCriticalNodeForMostCriticalDevice() async {
    final logs = await MongoDatabase.getLogData();
    final connectedDevices = await MongoDatabase.getNodeData();
    final connectedDevicesIp = connectedDevices.map((d) => d['IP']).toList();
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
      final severity = log["Severity"];
      final weight = weights[severity];
      final node = log["Node"];
      final ip = log["Ip"];
      counts[ip] = (counts.containsKey(ip) ? counts[ip]! + weight! : weight)!;
    }

    var mostCriticalDeviceIp = "";
    var maxScore = 0;
    for (final ip in counts.keys) {
      if (counts[ip]! > maxScore && connectedDevicesIp.contains(ip)) {
        maxScore = counts[ip]!;
        mostCriticalDeviceIp = ip;
      }
    }
    final filteredLogs = logs.where((log) => log["Ip"] == mostCriticalDeviceIp);
    final nodeCounts = Map<String, int>();
    for (final log in filteredLogs) {
      final node = log["Node"];
      nodeCounts[node] =
          nodeCounts.containsKey(node) ? nodeCounts[node]! + 1 : 1;
    }

    var mostCriticalNode = "";
    var maxCount = 0;
    for (final node in nodeCounts.keys) {
      if (nodeCounts[node]! > maxCount) {
        maxCount = nodeCounts[node]!;
        mostCriticalNode = node;
      }
    }
    return mostCriticalNode;
  }

  Future<String> getDeviceHealth(String selectedDeviceIp) async {
    final weights = {
      'Critical': 5,
      'Major': 4,
      'Warning': 3,
      'Minor': 2,
      'Normal': 0,
      'Unknown': 0
    };
    final logs = await MongoDatabase.getLogData();
    List<Map<String, dynamic>> selectedDeviceLogs =
        logs.where((log) => log['Ip'] == selectedDeviceIp).toList();
    num totalLogs = selectedDeviceLogs.length;
    final num unhealthyThreshold = (totalLogs * 0.1);
    final num stableThreshold = (totalLogs * 0.05);

    num totalWeight = 0;
    for (final log in selectedDeviceLogs) {
      final severity = log["Severity"];
      final weight = weights[severity];
      totalWeight += weight!;
    }

    if (totalWeight >= unhealthyThreshold) {
      return 'Unhealthy';
    } else if (totalWeight > stableThreshold) {
      return 'Stable';
    } else {
      return 'Healthy';
    }
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
