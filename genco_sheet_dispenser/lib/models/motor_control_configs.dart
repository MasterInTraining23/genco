import 'dart:core';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:genco_sheet_dispenser/models/convert_item.dart';
import 'package:genco_sheet_dispenser/models/dynamo_db_service.dart';
import 'package:genco_sheet_dispenser/models/kiosks.dart';

class MotorControlConfigs {
  MotorControlConfigs._();

  static Future<Map<String, dynamic>> get() async {
    Map<String, dynamic> kiosk = await Kiosks.get();
    String motorControlConfigId = kiosk["motorControlConfigId"] as String;
    GetItemOutput motorControlConfig = await DynamoDbService.get().getItem(
        key: Map.from({"id": AttributeValue(s: motorControlConfigId)}),
        tableName: "motor_control_configs");
    return convertToDynamicMap(motorControlConfig.item!);
  }
}
