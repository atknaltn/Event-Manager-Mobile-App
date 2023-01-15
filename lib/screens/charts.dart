import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dbHelper/LogModel.dart';
import 'dbHelper/mongodb.dart';

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key, required this.title});

  final String title;

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  String selectedNodePie = "";
  String dropdownValue = '101.169.213';
  bool isDeviceChanged = false;
  Map<String, double> dataMap = {
    'Unknown': 0,
    'Normal': 0,
    'Warning': 0,
    'Minor': 0,
    'Major': 0,
    'Critical': 0,
  };
  List<String> list = <String>[
    'Select a Source',
    'Severity',
    'Status',
    'Category',
    'Subcategory'
  ];
  String selectedSourcePie = 'Select a Source';
  List<ChartData> chartData = [];

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
                      return DropdownButton<String>(
                        value: dropdownValue,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                            isDeviceChanged = true;
                            selectedNodePie = "Select a Node";
                            selectedSourcePie = 'Select a Source';
                          });
                        },
                        items: snapshot.data!.map((document) {
                          //print("sa : " + document['NodeName'].toString());
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
        child: Column(
          children: <Widget>[
            Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text(
                          "Node: ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        FutureBuilder(
                          future: getNodesForSelectedIp(dropdownValue),
                          builder:
                              (context, AsyncSnapshot<List<String>> snapshot) {
                            if (snapshot.hasData) {
                              if (isDeviceChanged &&
                                  snapshot.data!.isNotEmpty) {
                                selectedNodePie = snapshot.data!.first;
                              }

                              return DropdownButton<String>(
                                value: selectedNodePie,
                                hint: Text("Select a node"),
                                items: snapshot.data!
                                    .map((node) => DropdownMenuItem<String>(
                                          value: node,
                                          child: Text(node),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedNodePie = value!;
                                    isDeviceChanged = false;
                                  });
                                },
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        ),
                        const Text(
                          "Source: ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        DropdownButton<String>(
                          value: selectedSourcePie,
                          hint: Text("Select a Source"),
                          items: list
                              .map((node) => DropdownMenuItem<String>(
                                    value: node,
                                    child: Text(node),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedSourcePie = value!;
                              isDeviceChanged = false;
                            });
                          },
                        ),
                      ],
                    ),
                    Container(
                      height: 300,
                      child: FutureBuilder(
                        future: getCountsForSelectedIpAndNode(
                            dropdownValue, selectedNodePie, selectedSourcePie),
                        builder: (context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return (const Center(
                              child: CircularProgressIndicator(),
                            ));
                          } else {
                            log("Dropdown: " +
                                dropdownValue +
                                " selectedNodePie: " +
                                selectedNodePie);
                            if (snapshot.hasData) {
                              return PieChart(
                                dataMap: snapshot.data,
                                chartRadius:
                                    MediaQuery.of(context).size.width / 1.7,
                                legendOptions: const LegendOptions(
                                    legendPosition: LegendPosition.bottom,
                                    showLegendsInRow: true),
                                chartValuesOptions: const ChartValuesOptions(
                                    showChartValuesInPercentage: true),
                              );
                            } else {
                              return const Center(
                                child: Text("No Data Avaliable"),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                    height: 300,
                    child: FutureBuilder(
                      future: MongoDatabase.getLogData(),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return (const Center(
                            child: CircularProgressIndicator(),
                          ));
                        } else {
                          if (snapshot.hasData) {
                            var totalData = snapshot.data.length;
                            print("Total Data: " + totalData.toString());
                            dataMap.forEach((key, value) => dataMap[key] = 0);
                            for (var i = 0; i < totalData; i++) {
                              var temp = LogModel.fromJson(snapshot.data[i])
                                  .severity
                                  .toString();
                              if (dropdownValue ==
                                  LogModel.fromJson(snapshot.data[i]).ip) {
                                dataMap.update(
                                    temp, (value) => dataMap[temp]! + 1);
                              }
                            }
                            dataMap.forEach((key, value) => chartData
                                .add(ChartData(value: value, severity: key)));
                            return charts.BarChart(
                              [
                                charts.Series<ChartData, String>(
                                  id: 'severity',
                                  colorFn: (ChartData data, _) {
                                    if (data.severity == "Normal") {
                                      return charts
                                          .MaterialPalette.green.shadeDefault;
                                    } else if (data.severity == "Minor") {
                                      return charts
                                          .MaterialPalette.yellow.shadeDefault;
                                    } else if (data.severity == "Major") {
                                      return charts.MaterialPalette.deepOrange
                                          .shadeDefault;
                                    } else if (data.severity == 'Critical') {
                                      return charts
                                          .MaterialPalette.red.shadeDefault;
                                    } else if (data.severity == 'Waring') {
                                      return charts
                                          .MaterialPalette.teal.shadeDefault;
                                    } else {
                                      return charts
                                          .MaterialPalette.purple.shadeDefault;
                                    }
                                  },
                                  domainFn: (ChartData data, _) =>
                                      data.severity,
                                  measureFn: (ChartData data, _) => data.value,
                                  data: chartData,
                                ),
                              ],
                              animate: true,
                              barGroupingType: charts.BarGroupingType.grouped,
                              behaviors: [],
                              primaryMeasureAxis: const charts.NumericAxisSpec(
                                  renderSpec: charts.SmallTickRendererSpec(
                                      labelStyle: charts.TextStyleSpec(),
                                      lineStyle: charts.LineStyleSpec()),
                                  showAxisLine: true),
                              domainAxis: const charts.OrdinalAxisSpec(
                                renderSpec: charts.SmallTickRendererSpec(
                                    labelRotation: 45,
                                    labelStyle: charts.TextStyleSpec(),
                                    lineStyle: charts.LineStyleSpec()),
                                showAxisLine: true,
                              ),
                            );
                          } else {
                            return const Center(
                              child: Text("No Data Avaliable"),
                            );
                          }
                        }
                      },
                    )),
                Container(
                  height: 200,
                  child: Text("Vay aq"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<Map<String, double>?> getCountsForSelectedIpAndNode(
      String selectedIp, String selectedNodePie, String selectedSource) async {
    final logs = await MongoDatabase.getLogData();
    if (selectedSource == 'Severity' && selectedNodePie != 'Select a Node') {
      final Map<String, double> counts = {
        'Critical': 0,
        'Major': 0,
        'Warning': 0,
        'Minor': 0,
        'Normal': 0,
        'Unknown': 0
      };

      for (final log in logs) {
        final severity = log["Severity"];
        final ip = log["Ip"];
        final node = log["Node"];
        if (ip == selectedIp && node == selectedNodePie) {
          counts[severity] = (counts[severity]! + 1);
        }
      }

      return counts;
    } else if (selectedSource == 'Status' &&
        selectedNodePie != 'Select a Node') {
      final Map<String, double> counts = {
        'Open': 0,
        'Close': 0,
        'PROBLEM': 0,
        'OK': 0
      };

      for (final log in logs) {
        final status = log["Status"];
        final ip = log["Ip"];
        final node = log["Node"];
        if (ip == selectedIp && node == selectedNodePie) {
          counts[status] = (counts[status]! + 1);
        }
      }

      return counts;
    } else if (selectedSource == 'Category' &&
        selectedNodePie != 'Select a Node') {
      var counts = new Map<String, double>();
      counts = {};
      for (final log in logs) {
        final category = log["Category"];
        final ip = log["Ip"];
        final node = log["Node"];
        if (ip == selectedIp && node == selectedNodePie) {
          counts[category] = (counts[category] ?? 0) + 1;
        }
      }
      return counts;
    } else if (selectedSource == 'Subcategory' &&
        selectedNodePie != 'Select a Node') {
      var counts = new Map<String, double>();
      counts = {};
      for (final log in logs) {
        final Subcategory = log["Subcategory"];
        final ip = log["Ip"];
        final node = log["Node"];
        if (ip == selectedIp && node == selectedNodePie) {
          counts[Subcategory] = (counts[Subcategory] ?? 0) + 1;
        }
      }
      return counts;
    } else {
      return null;
    }
  }

  Future<List<String>> getNodesForSelectedIp(String selectedIp) async {
    final logs = await MongoDatabase.getLogData();
    final connectedDevices = await MongoDatabase.getNodeData();
    final connectedDevicesIp = connectedDevices.map((d) => d['IP']).toList();
    final nodes = Set<String>();

    nodes.add("Select a Node");

    for (final log in logs) {
      final node = log["Node"];
      final ip = log["Ip"];
      if (ip == selectedIp && connectedDevicesIp.contains(ip)) {
        nodes.add(node);
      }
    }

    if (nodes.isNotEmpty && selectedNodePie == "") {
      selectedNodePie = nodes.first;
      print(nodes.first);
    }

    return nodes.toList();
  }

  Future<Map<String, double>> getSeverityCountsForSelectedIpAndNode(
      String selectedIp, String selectedNodePie) async {
    final logs = await MongoDatabase.getLogData();
    final Map<String, double> counts = {
      'Critical': 0,
      'Major': 0,
      'Warning': 0,
      'Minor': 0,
      'Normal': 0,
      'Unknown': 0
    };

    for (final log in logs) {
      final severity = log["Severity"];
      final ip = log["Ip"];
      final node = log["Node"];
      if (ip == selectedIp && node == selectedNodePie) {
        counts[severity] = (counts[severity]! + 1);
      }
    }

    return counts;
  }

  Future<Map<String, double>> getStatusCountsForSelectedIpAndNode(
      String selectedIp, String selectedNodePie) async {
    final logs = await MongoDatabase.getLogData();
    final Map<String, double> counts = {
      'Open': 0,
      'Close': 0,
      'PROBLEM': 0,
      'OK': 0
    };

    for (final log in logs) {
      final status = log["Status"];
      final ip = log["Ip"];
      final node = log["Node"];
      if (ip == selectedIp && node == selectedNodePie) {
        counts[status] = (counts[status]! + 1);
      }
    }

    return counts;
  }
}

class ChartData {
  final num value;
  final String severity;

  ChartData({required this.value, required this.severity});
}
