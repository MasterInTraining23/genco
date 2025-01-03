import 'dart:core';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:genco_sheet_dispenser/models/convert_item.dart';
import 'package:genco_sheet_dispenser/models/dynamo_db_service.dart';

class KioskPageInfos {
  KioskPageInfos._();

  // static Future<List<Map<String, AttributeValue>>> get() async {
  //   Map<String, AttributeValue> kioskFlow = await KioskFlows.get();
  //   List<String> pageIdSequence =
  //       kioskFlow["pageIdSequence"]?.ss as List<String>;
  //   ScanOutput kioskPageInfos = await DynamoDbService.get()
  //       .scan(tableName: "kiosk_page_infos", scanFilter: {
  //     "id": Condition(
  //         comparisonOperator: ComparisonOperator.$in,
  //         attributeValueList:
  //             pageIdSequence.map((id) => AttributeValue(s: id)).toList())
  //   });
  //   return kioskPageInfos.items!;
  // }

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
