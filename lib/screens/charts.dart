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
  String dropdownValue = '101.169.213';
  Map<String, double> dataMap = {
    'Unknown': 0,
    'Normal': 0,
    'Warning': 0,
    'Minor': 0,
    'Major': 0,
    'Critical': 0,
  };
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
                Container(
                  height: 300,
                  child: FutureBuilder(
                    future: MongoDatabase.getLogData(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                              print("dropdown: " +
                                  dropdownValue +
                                  "logmodel: " +
                                  LogModel.fromJson(snapshot.data[i]).ip);
                              dataMap.update(
                                  temp, (value) => dataMap[temp]! + 1);
                            }
                          }
                          return PieChart(
                            dataMap: dataMap,
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
                              primaryMeasureAxis: charts.NumericAxisSpec(
                                  renderSpec: charts.SmallTickRendererSpec(
                                      labelStyle: charts.TextStyleSpec(),
                                      lineStyle: charts.LineStyleSpec()),
                                  showAxisLine: true),
                              domainAxis: charts.OrdinalAxisSpec(
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
        )));
  }
}

class ChartData {
  final num value;
  final String severity;

  ChartData({required this.value, required this.severity});
}
