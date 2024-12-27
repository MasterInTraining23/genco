import 'dart:core';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:genco_sheet_dispenser/models/dynamo_db_service.dart';
import 'package:genco_sheet_dispenser/models/institutions.dart';
import 'package:genco_sheet_dispenser/models/kiosks.dart';
import 'package:genco_sheet_dispenser/sheet_type.dart';

class KioskDispenseActivity {
  KioskDispenseActivity._();

  static Future<void> successfullyDispensed(
      {required Map<String, dynamic> user,
      required SheetType sheetType}) async {
    await DynamoDbService.get().putItem(
      item: {
        "institutionId-kioskId":
            AttributeValue(s: "$denverUniversityId-$denverUniversityKioskId"),
        "timestampInMs":
            AttributeValue(s: DateTime.now().millisecondsSinceEpoch.toString()),
        "userId": AttributeValue(s: user["id"]),
        "sheetType": AttributeValue(s: sheetType.name),
      },
      tableName: "kiosk_dispense_activity",
    );
  }
}
