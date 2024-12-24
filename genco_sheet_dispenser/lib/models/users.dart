import 'dart:core';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:genco_sheet_dispenser/models/convert_item.dart';
import 'package:genco_sheet_dispenser/models/dynamo_db_service.dart';
import 'package:genco_sheet_dispenser/models/institutions.dart';

class Users {
  Users._();

  static Future<Map<String, dynamic>?> get(String userId) async {
    if (userId.isEmpty) {
      return null;
    }

    Map<String, dynamic> institution = await Institutions.get();
    String institutionId = institution["id"]?.s as String;
    QueryOutput users = await DynamoDbService.get().query(
        tableName: "users",
        keyConditionExpression:
            "institutionId = :institutionId AND id = :userId",
        expressionAttributeValues: {
          ":institutionId": AttributeValue(s: institutionId),
          ":userId": AttributeValue(s: userId)
        });

    if (users.items == null || users.items!.isEmpty) {
      return null;
    }

    if (users.items!.length > 1) {
      // Notify GL since because this user needs to be deduped.
    }

    return convertToDynamicMap(users.items![0]);
  }

  static Future<void> successfullyDispensed(Map<String, dynamic> user) async {
    await DynamoDbService.get().updateItem(
        key: {
          "institutionId": AttributeValue(s: denverUniversityId),
          "id": AttributeValue(s: user["id"])
        },
        tableName: "users",
        attributeUpdates: {
          "totalDispenses": AttributeValueUpdate(
              action: AttributeAction.put,
              value: AttributeValue(n: (user["totalDispenses"] + 1).toString()))
        });
  }
}
