import 'dart:core';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:genco_sheet_dispenser/models/convert_item.dart';
import 'package:genco_sheet_dispenser/models/dynamo_db_service.dart';
import 'package:genco_sheet_dispenser/models/institutions.dart';

const String denverUniversityKioskId = "1";

class Kiosks {
  Kiosks._();

  static Future<Map<String, dynamic>> get() async {
    GetItemOutput kiosk = await DynamoDbService.get().getItem(
        key: Map.from({
          "institutionId": AttributeValue(s: denverUniversityId),
          "kioskId": AttributeValue(s: denverUniversityKioskId)
        }),
        tableName: "kiosks");
    return convertToDynamicMap(kiosk.item!);
  }

  static Future<void> successfullyDispensed(
      {required Map<String, dynamic> user}) async {
    await DynamoDbService.get().updateItem(
      key: {
        "institutionId": AttributeValue(s: denverUniversityId),
        "kioskId": AttributeValue(s: denverUniversityKioskId)
      },
      tableName: "kiosks",
      attributeUpdates: {
        "remainingUnscentedSheets": AttributeValueUpdate(
          action: AttributeAction.put,
          value: AttributeValue(
              n: ((user["remainingUnscentedSheets"] ?? 0) + 1).toString()),
        ),
        "remainingScentedSheets": AttributeValueUpdate(
          action: AttributeAction.put,
          value: AttributeValue(
              n: ((user["remainingScentedSheets"] ?? 0) - 1).toString()),
        )
      },
    );
  }
}
