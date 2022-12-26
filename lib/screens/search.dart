import 'package:flutter/material.dart';

import 'dbHelper/LogModel.dart';
import 'dbHelper/mongodb.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.title});

  final String title;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
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
            return (Center(
              child: CircularProgressIndicator(),
            ));
          } else {
            if (snapshot.hasData) {
              var totalData = snapshot.data.length;
              print("Total Data: " + totalData.toString());
              return ListView.builder(
                  itemCount: totalData,
                  itemBuilder: ((context, index) {
                    return displayCard(LogModel.fromJson(snapshot.data[index]));
                  }));
            } else {
              return Center(
                child: Text("No Data Avaliable"),
              );
            }
          }
        },
      ),
    );
  }

  Widget displayCard(LogModel data) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          Text("${data.alertName}"),
          SizedBox(
            height: 5,
          ),
          Text("${data.category}"),
          SizedBox(
            height: 5,
          ),
          Text("${data.creationDate}"),
          SizedBox(
            height: 5,
          ),
          Text("${data.dns}"),
          SizedBox(
            height: 5,
          ),
          Text("${data.etiType}"),
          SizedBox(
            height: 5,
          ),
          Text("${data.etiValue}"),
          SizedBox(
            height: 5,
          ),
          Text("${data.eventId}"),
          SizedBox(
            height: 5,
          ),
          Text("${data.ip}"),
          SizedBox(
            height: 5,
          ),
          Text("${data.macAddress}"),
          SizedBox(
            height: 5,
          ),
          Text("${data.monitorUuid}"),
          SizedBox(
            height: 5,
          ),
          Text("${data.node}"),
          SizedBox(
            height: 5,
          ),
          Text("${data.nodeId}"),
          SizedBox(
            height: 5,
          ),
          Text("${data.severity}"),
          SizedBox(
            height: 5,
          ),
          Text("${data.source}"),
          SizedBox(
            height: 5,
          ),
          Text("${data.status}"),
          SizedBox(
            height: 5,
          ),
          Text("${data.subcategory}"),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    ));
  }
}
