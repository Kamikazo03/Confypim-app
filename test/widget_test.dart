import 'package:flutter_test/flutter_test.dart';

import 'package:confypim_mobile/main.dart';

void main() {
  testWidgets('Confypim construye correctamente su interfaz',
          (WidgetTester tester) async {
        await tester.pumpWidget(const ConfypimApp());

        expect(find.byType(ConfypimApp), findsOneWidget);
      });
}