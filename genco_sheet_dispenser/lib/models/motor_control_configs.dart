import 'dart:core';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:genco_sheet_dispenser/models/dynamo_db_service.dart';
import 'package:genco_sheet_dispenser/models/institutions.dart';

class MotorControlConfigs {
  MotorControlConfigs._();

  static Future<Map<String, AttributeValue>> get() async {
    Map<String, dynamic> institution = await Institutions.get();
    String motorControlConfigId = institution["motorControlConfigId"] as String;
    GetItemOutput motorControlConfig = await DynamoDbService.get().getItem(
        key: Map.from({"id": AttributeValue(s: motorControlConfigId)}),
        tableName: "motor_control_configs");
    return motorControlConfig.item!;
  }
}
