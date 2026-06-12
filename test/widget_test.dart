import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle/main.dart';

void main() {
  testWidgets('App can be instantiated', (WidgetTester tester) async {
    await tester.pumpWidget(const Cyber1TMSApp());
  });
}
