import 'dart:developer';

import 'package:event_manager/screens/dbHelper/NodeModel.dart';
import 'package:event_manager/screens/dbHelper/constants.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase {
  static var db, logsCollection, nodesCollection;
  static connect() async {
    db = await Db.create(MONGO_CONN_URL);
    await db.open();
    inspect(db);
    logsCollection = db.collection(LOGS_COLLECTION);
    nodesCollection = db.collection(NODES_COLLECTION);
  }

  static Future<List<Map<String, dynamic>>> getLogData() async {
    final logData = await logsCollection.find().toList();
    return logData;
  }

  static Future<List<Map<String, dynamic>>> getNodeData() async {
    final nodeData = await nodesCollection.find().toList();
    return nodeData;
  }

  static delete(NodeModel data) async {
    await nodesCollection.remove(where.id(data.id));
  }

  static Future<String> insertNode(NodeModel data) async {
    try {
      var result = await nodesCollection.insertOne(data.toJson());
      if (result.isSuccess) {
        return "Data Inserted";
      } else {
        return "Something went wrong while inserting data !";
      }
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }
}
