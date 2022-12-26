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
                              decoration: InputDecoration(
                                labelText: 'Node Name',
                                icon: Icon(Icons.abc),
                              ),
                            ),
                            TextFormField(
                              controller: nodeCategoryController,
                              decoration: InputDecoration(
                                labelText: 'Category',
                                icon: Icon(Icons.category),
                              ),
                            ),
                            TextFormField(
                              controller: nodeSubcategoryController,
                              decoration: InputDecoration(
                                labelText: 'Subcategory',
                                icon: Icon(Icons.category_outlined),
                              ),
                            ),
                            TextFormField(
                              controller: nodeIPController,
                              decoration: InputDecoration(
                                labelText: 'IP Address',
                                icon: Icon(Icons.numbers),
                              ),
                            ),
                            TextFormField(
                              controller: nodeDNSController,
                              decoration: InputDecoration(
                                labelText: 'DNS',
                                icon: Icon(Icons.numbers_outlined),
                              ),
                            ),
                            TextFormField(
                              controller: nodeMACController,
                              decoration: InputDecoration(
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
          )
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
    return ExpansionTile(
        title: Text(data.nodeName),
        trailing: const Image(image: AssetImage('assets/shield_worsening.png')),
        //leading: const Icon(Icons.keyboard_arrow_right_outlined),
        controlAffinity: ListTileControlAffinity.leading,
        collapsedIconColor: Colors.red,
        children: [
          Card(
              child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Text("${data.nodeId}"),
                SizedBox(
                  height: 5,
                ),
                Text("${data.nodeName}"),
                SizedBox(
                  height: 5,
                ),
                Text("${data.ip}"),
                SizedBox(
                  height: 5,
                ),
                Text("${data.dns}"),
                SizedBox(
                  height: 5,
                ),
                Text("${data.macAddress}"),
                SizedBox(
                  height: 5,
                ),
                Text("${data.category}"),
                SizedBox(
                  height: 5,
                ),
                Text("${data.subcategory}"),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          )),
        ]);
  }
}
