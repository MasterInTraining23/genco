import 'dart:core';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:genco_sheet_dispenser/models/dynamo_db_service.dart';
import 'package:genco_sheet_dispenser/models/institutions.dart';
import 'package:genco_sheet_dispenser/sheet_type.dart';

class UserDispenseActivity {
  UserDispenseActivity._();

  static Future<void> successfullyDispensed(
      {required Map<String, dynamic> user,
      required SheetType sheetType,
      required List<Map<String, dynamic>> surveyInfos}) async {
    await DynamoDbService.get().putItem(
      item: {
        "institutionId-userId":
            AttributeValue(s: "$denverUniversityId-${user['id']}"),
        "timestampInMs":
            AttributeValue(s: DateTime.now().millisecondsSinceEpoch.toString()),
        "userId": AttributeValue(s: user["id"]),
        "sheetType": AttributeValue(s: sheetType.name),
        "surveys": AttributeValue(
            l: surveyInfos
                .map((surveyInfo) => AttributeValue.fromJson(surveyInfo))
                .toList())
      },
      tableName: "user_dispense_activity",
    );
  }
}
