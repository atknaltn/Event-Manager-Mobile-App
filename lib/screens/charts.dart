import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

import 'dbHelper/LogModel.dart';
import 'dbHelper/mongodb.dart';

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key, required this.title});

  final String title;

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  Map<String, double> dataMap = {
    'Unknown': 0,
    'Normal': 0,
    'Warning': 0,
    'Minor': 0,
    'Major': 0,
    'Critical': 0,
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
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
              for (var i = 0; i < totalData; i++) {
                var temp =
                    LogModel.fromJson(snapshot.data[i]).severity.toString();
                //if (LogModel.fromJson(snapshot.data[i]).severity == "Unknown") {
                dataMap.update(temp, (value) => dataMap[temp]! + 1);
                //}
              }
              return PieChart(
                dataMap: dataMap,
                chartRadius: MediaQuery.of(context).size.width / 1.7,
                legendOptions: LegendOptions(
                    legendPosition: LegendPosition.bottom,
                    showLegendsInRow: true),
                chartValuesOptions:
                    ChartValuesOptions(showChartValuesInPercentage: true),
              );
            } else {
              return const Center(
                child: Text("No Data Avaliable"),
              );
            }
          }
        },
        /*child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              PieChart(
                dataMap: dataMap,
                chartRadius: MediaQuery.of(context).size.width / 1.7,
                legendOptions: LegendOptions(
                    legendPosition: LegendPosition.bottom,
                    showLegendsInRow: true),
                chartValuesOptions:
                    ChartValuesOptions(showChartValuesInPercentage: true),
              ),
            ],*/
      ),
    );
  }

  //Map<String, double> getSeverityStatistics() {}
}
