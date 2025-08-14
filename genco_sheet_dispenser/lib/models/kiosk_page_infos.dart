import 'dart:core';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:genco_sheet_dispenser/models/convert_item.dart';
import 'package:genco_sheet_dispenser/models/dynamo_db_service.dart';

class KioskPageInfos {
  KioskPageInfos._();

  static Future<Map<String, Map<String, dynamic>>> get() async {
    ScanOutput kioskPageInfos =
        await DynamoDbService.get().scan(tableName: "kiosk_page_infos");

    Map<String, Map<String, dynamic>> convertedKioskPageInfos = {
      for (var item in kioskPageInfos.items!)
        item["id"]!.s!: convertToDynamicMap(item)
    };
    return convertedKioskPageInfos;
  }
}
