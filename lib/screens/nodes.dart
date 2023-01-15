import 'package:event_manager/screens/dbHelper/NodeModel.dart';
import 'package:flutter/material.dart';
import 'dbHelper/mongodb.dart';
import 'package:mongo_dart/mongo_dart.dart' as MongoDB;

class NodesPage extends StatefulWidget {
  const NodesPage({super.key, required this.title});

  final String title;

  @override
  State<NodesPage> createState() => _NodesPageState();
}

class _NodesPageState extends State<NodesPage> {
  var nodeNameController = new TextEditingController();
  var nodeCategoryController = new TextEditingController();
  var nodeSubcategoryController = new TextEditingController();
  var nodeIPController = new TextEditingController();
  var nodeDNSController = new TextEditingController();
  var nodeMACController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    scrollable: true,
                    title: Text('Add a new Node'),
                    content: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Form(
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              controller: nodeNameController,
                              decoration: const InputDecoration(
                                labelText: 'Device Name',
                                icon: Icon(Icons.abc),
                              ),
                            ),
                            TextFormField(
                              controller: nodeCategoryController,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                icon: Icon(Icons.category),
                              ),
                            ),
                            TextFormField(
                              controller: nodeSubcategoryController,
                              decoration: const InputDecoration(
                                labelText: 'Subcategory',
                                icon: Icon(Icons.category_outlined),
                              ),
                            ),
                            TextFormField(
                              controller: nodeIPController,
                              decoration: const InputDecoration(
                                labelText: 'IP Address',
                                icon: Icon(Icons.numbers),
                              ),
                            ),
                            TextFormField(
                              controller: nodeDNSController,
                              decoration: const InputDecoration(
                                labelText: 'DNS',
                                icon: Icon(Icons.numbers_outlined),
                              ),
                            ),
                            TextFormField(
                              controller: nodeMACController,
                              decoration: const InputDecoration(
                                labelText: 'MAC Address',
                                icon: Icon(Icons.tablet_mac),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                              child: Text("CANCEL"),
                              onPressed: () {
                                setState(() {}); //refreshes the page
                                Navigator.of(context, rootNavigator: true)
                                    .pop('dialog');
                                _clearAll();
                              }),
                          ElevatedButton(
                              child: Text("SAVE"),
                              onPressed: () {
                                _insertNode(
                                    nodeNameController.text,
                                    nodeCategoryController.text,
                                    nodeSubcategoryController.text,
                                    nodeIPController.text,
                                    nodeDNSController.text,
                                    nodeMACController.text);
                                setState(() {}); //refreshes the page
                                Navigator.of(context, rootNavigator: true)
                                    .pop('dialog');
                                _clearAll();
                              })
                        ],
                      )
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: MongoDatabase.getNodeData(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return (const Center(
              child: CircularProgressIndicator(),
            ));
          } else {
            if (snapshot.hasData) {
              var totalData = snapshot.data.length;
              print("Total Data: " + totalData.toString());
              return ListView.builder(
                  itemCount: totalData,
                  itemBuilder: ((context, index) {
                    return displayCard(
                        NodeModel.fromJson(snapshot.data[index]));
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

  Future<void> _insertNode(String NodeName, String Category, String Subcategory,
      String IP, String DNS, String MAC) async {
    var _id = MongoDB.ObjectId();
    final data = NodeModel(
        id: _id,
        nodeId: "19626",
        nodeName: NodeName,
        category: Category,
        subcategory: Subcategory,
        ip: IP,
        dns: DNS,
        macAddress: MAC);
    var result = await MongoDatabase.insertNode(data);
    print(result);
  }

  void _clearAll() {
    nodeCategoryController.text = "";
    nodeDNSController.text = "";
    nodeIPController.text = "";
    nodeMACController.text = "";
    nodeNameController.text = "";
    nodeSubcategoryController.text = "";
  }

  Widget displayCard(NodeModel data) {
    return FutureBuilder(
      future: getDeviceHealth(data.ip),
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          final healthCondition = snapshot.data!;
          String imagePath;
          if (healthCondition == "Healthy") {
            imagePath = 'assets/shield_healthy.png';
          } else if (healthCondition == "Stable") {
            imagePath = 'assets/shield_stable.png';
          } else if (healthCondition == "Unknown") {
            imagePath = 'assets/shield_unknown.png';
          } else {
            imagePath = 'assets/shield_worsening.png';
          }
          return ExpansionTile(
              title: Text(data.nodeName),
              trailing: Image(image: AssetImage(imagePath)),
              //leading: const Icon(Icons.keyboard_arrow_right_outlined),
              controlAffinity: ListTileControlAffinity.leading,
              collapsedIconColor: Colors.red,
              children: [
                Card(
                    child: Row(
                  children: <Widget>[
                    IconButton(
                        onPressed: () {}, icon: Icon(Icons.delete_forever)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                      child: Column(
                        children: [
                          RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan>[
                                TextSpan(
                                    text: 'Device Name: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                  text: data.nodeName,
                                  //style: TextStyle(fontWeight: FontWeight.bold)
                                ),
                                TextSpan(
                                  text: '\n',
                                ),
                                TextSpan(
                                    text: 'Device Ip: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                  text: data.ip,
                                  //style: TextStyle(fontWeight: FontWeight.bold)
                                ),
                                TextSpan(
                                  text: '\n',
                                ),
                                TextSpan(
                                    text: 'DNS: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                  text: data.dns,
                                  //style: TextStyle(fontWeight: FontWeight.bold)
                                ),
                                TextSpan(
                                  text: '\n',
                                ),
                                TextSpan(
                                    text: 'MAC: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                  text: data.macAddress,
                                  //style: TextStyle(fontWeight: FontWeight.bold)
                                ),
                                TextSpan(
                                  text: '\n',
                                ),
                                TextSpan(
                                    text: 'Category: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                  text: data.category,
                                  //style: TextStyle(fontWeight: FontWeight.bold)
                                ),
                                TextSpan(
                                  text: '\n',
                                ),
                                TextSpan(
                                    text: 'Subcategory: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                  text: data.subcategory,
                                  //style: TextStyle(fontWeight: FontWeight.bold)
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
              ]);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
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
    print("SAAAAAAAAA" + totalLogs.toString());
    final num unhealthyThreshold = (totalLogs * 0.9);
    final num stableThreshold = (totalLogs * 0.005);
    num totalWeight = 0;
    for (final log in selectedDeviceLogs) {
      final severity = log["Severity"];
      final weight = weights[severity];
      totalWeight += weight!;
    }
    if (totalLogs == 0) {
      return 'Unknown';
    } else {
      if (totalWeight >= unhealthyThreshold) {
        return 'Unhealthy';
      } else if (totalWeight > stableThreshold) {
        return 'Stable';
      } else {
        return 'Healthy';
      }
    }
  }
}
