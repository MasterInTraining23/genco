import 'dart:convert';

import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';

Map<String, dynamic> convertToDynamicMap(Map<String, AttributeValue> item) {
  return item.map((key, value) {
    return MapEntry(key, unwrapAttributeValue(value));
  });
}

dynamic unwrapAttributeValue(AttributeValue value) {
  dynamic unwrappedValue;
  if (value.b != null) {
    unwrappedValue = base64Encode(value.b!.toList());
  } else if (value.boolValue != null) {
    unwrappedValue = value.boolValue;
  } else if (value.bs != null) {
    unwrappedValue = value.bs!.map(base64Encode).toList();
  } else if (value.l != null) {
    unwrappedValue = value.l!.map(unwrapAttributeValue).toList();
  } else if (value.m != null) {
    unwrappedValue =
        value.m!.map((k, v) => MapEntry(k, unwrapAttributeValue(v)));
  } else if (value.n != null) {
    unwrappedValue = int.parse(value.n!);
  } else if (value.ns != null) {
    unwrappedValue = value.ns!.map(int.parse);
  } else if (value.nullValue != null) {
    unwrappedValue = value.nullValue;
  } else if (value.s != null) {
    unwrappedValue = value.s;
  } else if (value.ss != null) {
    unwrappedValue = value.ss;
  }
  return unwrappedValue;
}

List<String> convertDynamicsToString(List<dynamic> l1) {
  return l1.map((element) => element as String).toList();
}

List<bool> convertDynamicsToBool(List<dynamic> l1) {
  return l1.map((element) => element as bool).toList();
}

AttributeValue convertToDynamoDBFormat(dynamic item) {
  if (item is String) {
    return AttributeValue(s: item);
  } else if (item is int || item is double) {
    return AttributeValue(n: item.toString());
  } else if (item is bool) {
    return AttributeValue(boolValue: item);
  } else if (item == null) {
    return AttributeValue(nullValue: true);
  } else if (item is Map) {
    return AttributeValue(
        m: item.map(
            (key, value) => MapEntry(key, convertToDynamoDBFormat(value))));
  } else if (item is List) {
    return AttributeValue(
        l: item.map((element) => convertToDynamoDBFormat(element)).toList());
  } else {
    return AttributeValue(s: "Unsupported object: $item");
  }
}
