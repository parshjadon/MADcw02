import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final spark = Platform.environment['QUEST_SPARK_EVIDENCE'] == 'true';
  final directory = Directory(
    spark ? 'evidence/spark-screenshots' : 'evidence/screenshots',
  );
  await directory.create(recursive: true);
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      await File('${directory.path}/$name.png').writeAsBytes(bytes);
      return bytes.isNotEmpty;
    },
    responseDataCallback: (data) async {
      await File(
        spark
            ? 'evidence/spark-mobile-observations.json'
            : 'evidence/mobile-observations.json',
      ).writeAsString(
        const JsonEncoder.withIndent('  ').convert(data?['mobile']),
      );
    },
  );
}
