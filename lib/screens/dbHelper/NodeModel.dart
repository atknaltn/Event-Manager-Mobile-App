// To parse this JSON data, do
//
//     final NodeModel = NodeModelFromJson(jsonString);

import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

NodeModel NodeModelFromJson(String str) => NodeModel.fromJson(json.decode(str));

String NodeModelToJson(NodeModel data) => json.encode(data.toJson());

class NodeModel {
  NodeModel({
    required this.id,
    required this.nodeId,
    required this.nodeName,
    required this.category,
    required this.subcategory,
    required this.ip,
    required this.dns,
    required this.macAddress,
  });

  ObjectId id;
  String nodeId;
  String nodeName;
  String category;
  String subcategory;
  String ip;
  String dns;
  String macAddress;

  factory NodeModel.fromJson(Map<String, dynamic> json) => NodeModel(
        id: json["_id"],
        nodeId: json["NodeID"],
        nodeName: json["NodeName"],
        category: json["Category"],
        subcategory: json["Subcategory"],
        ip: json["IP"],
        dns: json["DNS"],
        macAddress: json["MacAddress"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "NodeID": nodeId,
        "NodeName": nodeName,
        "Category": category,
        "Subcategory": subcategory,
        "IP": ip,
        "DNS": dns,
        "MacAddress": macAddress,
      };
}
