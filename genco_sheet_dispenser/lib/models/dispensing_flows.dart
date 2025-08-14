import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:genco_sheet_dispenser/models/cache_utils.dart';
import 'package:genco_sheet_dispenser/models/convert_item.dart';
import 'package:genco_sheet_dispenser/models/dynamo_db_service.dart';
import 'package:genco_sheet_dispenser/models/institutions.dart';

const String cacheFilePath = "/genco/cache/dispensing_flow";

class DispensingFlows {
  static var random = Random();

  DispensingFlows._();

  static Future<Map<String, dynamic>> get() async {
    // try {
    Map<String, dynamic> institution = await Institutions.get();
    String dispensingFlowId = institution["dispensingFlowId"] as String;
    GetItemOutput dispensingFlow = await DynamoDbService.get().getItem(
        key: Map.from({"id": AttributeValue(s: dispensingFlowId)}),
        tableName: "dispensing_flows");
    Map<String, dynamic> flow = convertToDynamicMap(dispensingFlow.item!);

    // await _saveMapToFile(flow);
    return flow;
    // } catch (error) {
    //   return await getFromCache();
    // }
  }

  static Future<Map<String, dynamic>> getFromCache() async {
    final file = File(cacheFilePath);
    if (!(await file.exists())) {
      throw Exception("Dispensing Flows cache fallback unsuccessful");
    }
    return _loadFileToMap();
  }

  static Future<void> _saveMapToFile(Map<String, dynamic> data) async {
    try {
      await saveMapToFile(data, cacheFilePath);
    } catch (error) {
      print("Dispensing flow failed to save to cache");
      print(error);
    }
  }

  static Future<Map<String, dynamic>> _loadFileToMap() async {
    try {
      return loadFileToMap(cacheFilePath);
    } catch (error) {
      print("Dispensing flow failed to read from cache");
      print(error);
      rethrow;
    }
  }
}
