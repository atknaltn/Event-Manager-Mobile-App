// To parse this JSON data, do
//
//     final LogModel = LogModelFromJson(jsonString);

import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

LogModel LogModelFromJson(String str) => LogModel.fromJson(json.decode(str));

String LogModelToJson(LogModel data) => json.encode(data.toJson());

class LogModel {
  LogModel({
    required this.dns,
    required this.id,
    required this.macAddress,
    required this.ip,
    required this.etiValue,
    required this.etiType,
    required this.alertName,
    required this.creationDate,
    required this.monitorUuid,
    required this.subcategory,
    required this.category,
    required this.nodeId,
    required this.node,
    required this.source,
    required this.status,
    required this.severity,
    required this.eventId,
  });

  ObjectId id;
  String dns;
  String macAddress;
  String ip;
  String etiValue;
  String etiType;
  String alertName;
  String creationDate;
  String monitorUuid;
  String subcategory;
  String category;
  String nodeId;
  String node;
  String source;
  String status;
  String severity;
  String eventId;

  factory LogModel.fromJson(Map<String, dynamic> json) => LogModel(
        id: json["_id"],
        dns: json["DNS "],
        macAddress: json["MacAddress"],
        ip: json["Ip"],
        etiValue: json["EtiValue"],
        etiType: json["EtiType"],
        alertName: json["AlertName"],
        creationDate: json["CreationDate"],
        monitorUuid: json["MonitorUUID"],
        subcategory: json["Subcategory"],
        category: json["Category"],
        nodeId: json["NodeID"],
        node: json["Node"],
        source: json["Source"],
        status: json["Status"],
        severity: json["Severity"],
        eventId: json["EventID"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "DNS ": dns,
        "MacAddress": macAddress,
        "Ip": ip,
        "EtiValue": etiValue,
        "EtiType": etiType,
        "AlertName": alertName,
        "CreationDate": creationDate,
        "MonitorUUID": monitorUuid,
        "Subcategory": subcategory,
        "Category": category,
        "NodeID": nodeId,
        "Node": node,
        "Source": source,
        "Status": status,
        "Severity": severity,
        "EventID": eventId,
      };
}
