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
  TextEditingController _searchController = TextEditingController();
  String searchString = "";
  bool isSearching = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !isSearching
            ? Text(widget.title)
            : TextField(
                style: TextStyle(color: Colors.white),
                controller: _searchController,
                decoration: const InputDecoration(
                    icon: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    hintText: " Search Logs Here...",
                    border: OutlineInputBorder(),
                    //prefixIcon: Icon(Icons.search),
                    hintStyle: TextStyle(color: Colors.white)),
                onChanged: (value) {
                  setState(() {
                    searchString = value.toLowerCase();
                  });
                },
              ),
        actions: <Widget>[
          isSearching
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      this.isSearching = false;
                    });
                  },
                  icon: Icon(Icons.cancel))
              : IconButton(
                  onPressed: () {
                    setState(() {
                      this.isSearching = true;
                    });
                  },
                  icon: Icon(Icons.search))
        ],
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
              var filteredData = snapshot.data.where((data) {
                for (var key in data.keys) {
                  var value = data[key].toString().toLowerCase();
                  if (value.contains(searchString)) {
                    return true;
                  }
                }
                return false;
              }).toList();
              var totalData = filteredData.length;
              return ListView.builder(
                  itemCount: totalData,
                  itemBuilder: ((context, index) {
                    return displayCard(LogModel.fromJson(filteredData[index]));
                  }));
            } else {
              return const Center(
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
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Alert Name: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: data.alertName,
                      //style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    TextSpan(
                        text: ' Category: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: data.category,
                      //style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    TextSpan(
                        text: ' Creation Date: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: data.creationDate,
                      //style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    TextSpan(
                        text: ' DNS',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: data.dns,
                      //style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    TextSpan(
                        text: ' eti Type: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: data.etiType,
                      //style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    TextSpan(
                        text: ' eti Value: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: data.etiValue,
                      //style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    TextSpan(
                        text: ' Event ID: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: data.eventId,
                      //style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    TextSpan(
                        text: ' IP: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: data.ip,
                      //style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    TextSpan(
                        text: ' MAC: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: data.macAddress,
                      //style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    TextSpan(
                        text: ' Monitor Uuid: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: data.monitorUuid,
                      //style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    TextSpan(
                        text: ' Node: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: data.node,
                      //style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    TextSpan(
                        text: ' Node ID: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: data.nodeId,
                      //style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    TextSpan(
                        text: ' Severity: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: data.severity,
                      //style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    TextSpan(
                        text: ' Source: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: data.source,
                      //style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    TextSpan(
                        text: ' Status: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: data.status,
                      //style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    TextSpan(
                        text: ' Sub Category: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: data.subcategory,
                      //style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
