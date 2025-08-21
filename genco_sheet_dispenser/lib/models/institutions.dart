import 'dart:core';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:genco_sheet_dispenser/models/convert_item.dart';
import 'package:genco_sheet_dispenser/models/dynamo_db_service.dart';

const String denverUniversityId = String.fromEnvironment("institutionId");

class Institutions {
  Institutions._();

  static Future<Map<String, dynamic>> get() async {
    GetItemOutput institution = await DynamoDbService.get().getItem(
        key: Map.from({"id": AttributeValue(s: denverUniversityId)}),
        tableName: "institutions");
    return convertToDynamicMap(institution.item!);
  }
}
