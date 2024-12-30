import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';

class DynamoDbService {
  static DynamoDbService? service;
  late DynamoDB db;

  static void initialize() {
    service ??= DynamoDbService._();
  }

  static DynamoDB get() {
    return service!.db;
  }
}
