import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';

const String accessKey = String.fromEnvironment("AWSAccessKey");
const String secretKey = String.fromEnvironment("AWSSecretKey");
const String region = String.fromEnvironment("AWSRegion");

class DynamoDbService {
  static DynamoDbService? service;
  late DynamoDB db;

  DynamoDbService._() {
    db = DynamoDB(
        region: region,
        credentials: AwsClientCredentials(
          accessKey: accessKey,
          secretKey: secretKey));
  }

  static void initialize() {
    service ??= DynamoDbService._();
  }

  static DynamoDB get() {
    return service!.db;
  }
}
