import 'package:flutter_test/flutter_test.dart';
import 'package:dholera_real_estate/main.dart';

void main() {
  testWidgets('App initializes successfully test', (WidgetTester tester) async {
    await tester.pumpWidget(const DholeraRealEstateApp());
    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(DholeraRealEstateApp), findsOneWidget);
  });
}
