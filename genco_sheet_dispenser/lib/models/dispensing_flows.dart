import 'dart:core';
import 'dart:math';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:genco_sheet_dispenser/models/convert_item.dart';
import 'package:genco_sheet_dispenser/models/dynamo_db_service.dart';
import 'package:genco_sheet_dispenser/models/institutions.dart';

class DispensingFlows {
  static var random = Random();

  DispensingFlows._();

  static Future<Map<String, dynamic>> get() async {
    Map<String, dynamic> institution = await Institutions.get();
    String dispensingFlowId = institution["dispensingFlowId"] as String;
    GetItemOutput dispensingFlow = await DynamoDbService.get().getItem(
        key: Map.from({"id": AttributeValue(s: dispensingFlowId)}),
        tableName: "dispensing_flows");
    return convertToDynamicMap(dispensingFlow.item!);
    // bool isAuthRequired = convertedDispensingFlow["isAuthRequired"] != null &&
    //     convertedDispensingFlow["isAuthRequired"] == true;

    // if (!isAuthRequired) {
    //   // Flatten the pageIdSequence based on a random selection of subsequences within a stage.
    //   // A stage in the flow is arbitrariy represented by a series of screens.
    //   // When auth is not required we simply choose the subsequences at random.
    //   List<dynamic> pageIdSequence =
    //       convertedDispensingFlow["pageIdSequence"] as List<dynamic>;
    //   convertedDispensingFlow["pageIdSequence"] =
    //       pageIdSequence.expand((possibleSubFlowsInStage) {
    //     int numOfSubFlowOptions =
    //         (possibleSubFlowsInStage as List<dynamic>).length;
    //     int randomlyChosenSubFlowIndex = random.nextInt(numOfSubFlowOptions);
    //     return possibleSubFlowsInStage[randomlyChosenSubFlowIndex];
    //   }).toList();
    // }
    // return convertedDispensingFlow;
  }
}
